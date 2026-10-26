import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import 'open_link.dart';

/// The app pages a web link may open, after the server's address.
final _appPaths = RegExp(r'^/(g/[A-Za-z0-9_-]{22}|invite/[A-Za-z0-9_-]+|verify-email|reset-password)/?$');

/// The page of this app that [link] opens, for a link to the current server
/// ([serverUrl], or the [publicUrl] it advertises). Throws
/// [ForeignGroupLink] for a Balnana link to another server: its secret must
/// not be sent here. Returns null for anything else.
String? appRouteFromLink(String link, {required String? serverUrl, String? publicUrl}) {
  final uri = Uri.tryParse(link.trim());
  if (uri == null ||
      !(uri.isScheme('http') || uri.isScheme('https')) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  final aliases = {
    for (final url in [serverUrl, publicUrl])
      if (url != null) ?normalizeServerUrl(url),
  };
  for (final alias in aliases) {
    final base = Uri.parse(alias);
    if (uri.scheme != base.scheme ||
        uri.host.toLowerCase() != base.host.toLowerCase() ||
        uri.port != base.port) {
      continue;
    }
    if (uri.path != base.path && !uri.path.startsWith('${base.path}/')) continue;
    final rest = uri.path.substring(base.path.length);
    final match = _appPaths.firstMatch(rest);
    if (match == null) return null;
    return Uri(path: '/${match.group(1)}', query: uri.query.isEmpty ? null : uri.query).toString();
  }
  // Balnana's pages on some other server, or not Balnana at all.
  if (_appPaths.hasMatch(uri.path) || RegExp(r'/(g|invite)/').hasMatch(uri.path)) {
    throw const ForeignGroupLink();
  }
  return null;
}

/// /link?url=...: a web link Android opened in the app (see MainActivity).
/// It opens the page the link is for, if the link is for this app's server.
class LinkPage extends ConsumerWidget {
  const LinkPage({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final server = ref.watch(serverUrlProvider);
    final info = ref.watch(serverInfoProvider);
    // The advertised address may be the one the link uses; wait for it.
    if (server != null && info.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String? route;
    var foreign = false;
    try {
      route = url == null
          ? null
          : appRouteFromLink(url!, serverUrl: server, publicUrl: ref.watch(serverPublicUrlProvider));
    } on ForeignGroupLink {
      foreign = true;
    }
    if (route case final route?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(route);
      });
      return Scaffold(body: Center(child: Text(l10n.linkOpening)));
    }
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(BSpace.s16),
          child: EmptyState(
            icon: Icons.link_off,
            title: foreign ? l10n.linkForeignTitle : l10n.linkInvalidTitle,
            body: foreign && server != null ? l10n.linkForeignBody(server) : l10n.linkInvalidBody,
            action: FilledButton(onPressed: () => context.go('/groups'), child: Text(l10n.linkGoHome)),
          ),
        ),
      ),
    );
  }
}
