import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../core/settings.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/page.dart';

/// Choose which Balnana server this app talks to.
class ServerPage extends ConsumerStatefulWidget {
  const ServerPage({super.key});

  @override
  ConsumerState<ServerPage> createState() => _ServerPageState();
}

enum _Problem { invalid, unreachable, notBalnana }

class _ServerPageState extends ConsumerState<ServerPage> {
  late final _controller = TextEditingController(text: ref.read(serverUrlProvider) ?? '');
  bool _busy = false;
  ServerInfo? _info;
  _Problem? _problem;

  /// Set when a save failed the connection test, so the user may keep the
  /// address anyway (for a server that is down right now).
  String? _unverified;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _show({ServerInfo? info, _Problem? problem, String? unverified}) {
    _info = info;
    _problem = problem;
    _unverified = unverified;
  }

  String? get _normalized => normalizeServerUrl(_controller.text);

  /// Returns the normalized address if it answers as a Balnana server.
  Future<String?> _test() async {
    final url = _normalized;
    if (url == null) {
      setState(() => _show(problem: _Problem.invalid));
      return null;
    }
    setState(() {
      _busy = true;
      _show();
    });
    try {
      final info = await probeServer(url);
      if (!mounted) return null;
      setState(() => _info = info);
      return url;
    } on ProbeException catch (e) {
      if (!mounted) return null;
      setState(() {
        _problem = switch (e.error) {
          ProbeError.unreachable => _Problem.unreachable,
          ProbeError.notBalnana => _Problem.notBalnana,
        };
        _unverified = url;
      });
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final url = await _test();
    if (url != null) _commit(url);
  }

  void _commit(String? url) {
    // Keep the stored value null while it equals the default, so a future
    // default change still applies.
    ref.read(settingsProvider.notifier).setServerUrl(url == defaultServerUrl ? null : url);
    ref.invalidate(serverInfoProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(context.l10n.serverSaved)));
    context.canPop() ? context.pop() : context.go('/groups');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fallback = defaultServerUrl;
    final normalized = _normalized;
    final insecure = normalized != null && isInsecureServerUrl(normalized);

    final problem = switch (_problem) {
      null => null,
      _Problem.invalid => l10n.serverErrorInvalid,
      _Problem.unreachable => l10n.serverErrorUnreachable,
      _Problem.notBalnana => l10n.serverErrorNotBalnana,
    };

    return BPage(
      title: l10n.serverTitle,
      children: [
        Text(l10n.serverIntro, style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: BSpace.s24),
        TextField(
          controller: _controller,
          enabled: !_busy,
          keyboardType: TextInputType.url,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(_show),
          onSubmitted: (_) => _save(),
          decoration: InputDecoration(
            labelText: l10n.serverUrlLabel,
            hintText: l10n.serverUrlHint,
            prefixIcon: const Icon(Icons.dns_outlined),
            errorText: problem,
            errorMaxLines: 3,
            helperText: fallback == null ? null : l10n.serverDefault(fallback),
          ),
        ),
        if (insecure) ...[
          const SizedBox(height: BSpace.s16),
          _Notice(
            icon: Icons.lock_open,
            text: l10n.serverInsecure,
            background: scheme.errorContainer,
            foreground: scheme.onErrorContainer,
          ),
        ],
        if (_info case final info?) ...[
          const SizedBox(height: BSpace.s16),
          _Notice(
            icon: Icons.check_circle_outline,
            text: [
              l10n.serverConnected(info.version),
              switch (info.authMode) {
                AuthMode.link => l10n.serverModeLink,
                AuthMode.accounts => l10n.serverModeAccounts,
              },
            ].join('\n'),
            background: scheme.secondaryContainer,
            foreground: scheme.onSecondaryContainer,
          ),
        ],
        const SizedBox(height: BSpace.s24),
        Wrap(
          spacing: BSpace.s8,
          runSpacing: BSpace.s8,
          alignment: WrapAlignment.end,
          children: [
            if (fallback != null && ref.watch(settingsProvider).serverUrl != null)
              TextButton(onPressed: _busy ? null : () => _commit(fallback), child: Text(l10n.serverReset)),
            if (_unverified case final url? when _problem == _Problem.unreachable)
              TextButton(onPressed: _busy ? null : () => _commit(url), child: Text(l10n.serverSaveAnyway)),
            OutlinedButton(onPressed: _busy ? null : _test, child: Text(l10n.serverTest)),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onSurface),
                    )
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, required this.background, required this.foreground});

  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(BShape.md)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(BSpace.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: BSpace.s12),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }
}
