import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_cache.dart';
import 'session.dart';
import 'settings.dart';

const apiBasePath = '/api/v1';

/// The server used when the user has not chosen one.
///
/// A build can bake one in with `--dart-define=BALNANA_SERVER_URL=https://...`.
/// The web app otherwise talks to the server that served it. An Android build
/// without one asks on first launch.
String? get defaultServerUrl {
  const fromBuild = String.fromEnvironment('BALNANA_SERVER_URL');
  if (fromBuild.isNotEmpty) return normalizeServerUrl(fromBuild);
  if (kIsWeb) return normalizeServerUrl(Uri.base.origin);
  return null;
}

/// Whether people pick the server in Settings. The web app always talks to
/// the server it came from, so it has nothing to choose.
const canChooseServer = !kIsWeb;

/// The server this app talks to, or null when none is set.
final serverUrlProvider = Provider<String?>((ref) {
  if (!canChooseServer) return defaultServerUrl;
  return ref.watch(settingsProvider.select((s) => s.serverUrl)) ?? defaultServerUrl;
});

/// Turns what a person typed into `scheme://host[:port][/path]`, or null.
///
/// A missing scheme means https. Query, fragment and trailing slashes are dropped;
/// a path is kept for servers behind a reverse proxy sub-path.
String? normalizeServerUrl(String input) {
  var text = input.trim();
  if (text.isEmpty || text.contains(RegExp(r'\s'))) return null;
  if (!text.contains('://')) text = 'https://$text';
  final uri = Uri.tryParse(text);
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https') || uri.host.isEmpty) {
    return null;
  }
  if (uri.userInfo.isNotEmpty) return null;
  var path = uri.path;
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return Uri(scheme: uri.scheme, host: uri.host, port: uri.hasPort ? uri.port : null, path: path).toString();
}

/// True for plain http to anything but this machine or a private network.
bool isInsecureServerUrl(String url) {
  final uri = Uri.parse(url);
  if (uri.scheme != 'http') return false;
  final host = uri.host.toLowerCase();
  if (host == 'localhost' || host.endsWith('.localhost') || host.endsWith('.local')) return false;
  if (host.contains(':')) {
    // IPv6: loopback, link-local, unique local.
    return !(host == '::1' || host.startsWith('fe80:') || host.startsWith('fc') || host.startsWith('fd'));
  }
  return !_isPrivateIPv4(host);
}

bool _isPrivateIPv4(String host) {
  final octets = host.split('.').map(int.tryParse).toList();
  if (octets.length != 4 || octets.any((o) => o == null || o < 0 || o > 255)) return false;
  final a = octets[0]!, b = octets[1]!;
  // 10.0.2.2, the Android emulator's address for the host machine, is in 10/8.
  return a == 10 ||
      a == 127 ||
      (a == 169 && b == 254) ||
      (a == 172 && b >= 16 && b <= 31) ||
      (a == 192 && b == 168);
}

enum AuthMode { link, accounts }

enum SignupPolicy { open, inviteOnly, closed }

/// GET /server-info, see api/openapi.yaml.
@immutable
class ServerInfo {
  const ServerInfo({
    required this.version,
    required this.authMode,
    this.password = false,
    this.signup = SignupPolicy.open,
    this.firstAccount = false,
    this.linkGroups = true,
    this.email = false,
    this.oauthProviders = const [],
    this.push = false,
    required this.publicUrl,
    this.sourceUrl,
    this.setupRequired = false,
    this.setupCode = false,
  });

  factory ServerInfo.fromJson(Object? json) {
    if (json is! Map<String, Object?>) throw const FormatException('server-info is not an object');
    final name = json['name'], version = json['version'], mode = json['authMode'];
    final publicUrl = json['publicUrl'];
    if (name is! String || version is! String || mode is! String || publicUrl is! String) {
      throw const FormatException('server-info is missing fields');
    }
    if (name != 'balnana') throw const FormatException('not a Balnana server');
    final authMode = AuthMode.values.asNameMap()[mode];
    if (authMode == null) throw FormatException('unknown authMode $mode');
    return ServerInfo(
      version: version,
      authMode: authMode,
      password: json['password'] == true,
      signup: switch (json['signup']) {
        'invite_only' => SignupPolicy.inviteOnly,
        'closed' => SignupPolicy.closed,
        _ => SignupPolicy.open,
      },
      firstAccount: json['firstAccount'] == true,
      linkGroups: json['linkGroups'] != false,
      email: json['email'] == true,
      oauthProviders: [
        if (json['oauthProviders'] case final List<Object?> list)
          for (final p in list)
            if (p case {'id': final String id, 'name': final String name}) OAuthProvider(id: id, name: name),
      ],
      push: json['push'] == true,
      publicUrl: publicUrl,
      sourceUrl: _webUrl(json['sourceUrl']),
      setupRequired: json['setupRequired'] == true,
      setupCode: json['setupCode'] == true,
    );
  }

  final String version;
  final AuthMode authMode;

  /// Email and password sign-in is available.
  final bool password;
  final SignupPolicy signup;

  /// No account exists yet, so the first one may sign up even when [signup]
  /// is closed.
  final bool firstAccount;

  /// Group owners may open a group to anyone with its link.
  final bool linkGroups;

  /// The server sends email: verification, password reset and invitations.
  final bool email;

  /// Google or OpenID Connect sign-in, as buttons on the sign-in page.
  final List<OAuthProvider> oauthProviders;

  /// The server sends push notifications, to builds of the app made for its
  /// Firebase project.
  final bool push;
  final String publicUrl;

  /// Where to get the server's source code, if the operator set it. Only
  /// http(s) links are kept, since the app opens it in a browser.
  final Uri? sourceUrl;

  /// No administrator password is set yet: the server is new, and the app
  /// sends people to /admin to set one.
  final bool setupRequired;

  /// Setting it up also needs the code the server printed in its log.
  final bool setupCode;
}

@immutable
class OAuthProvider {
  const OAuthProvider({required this.id, required this.name});

  final String id;

  /// What the button says: "Google", or the operator's name for their provider.
  final String name;
}

Uri? _webUrl(Object? value) {
  if (value is! String) return null;
  final uri = Uri.tryParse(value);
  if (uri == null || !(uri.isScheme('https') || uri.isScheme('http')) || uri.host.isEmpty) return null;
  return uri;
}

Dio _newDio(String serverUrl) => Dio(
  BaseOptions(
    baseUrl: '$serverUrl$apiBasePath',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    responseType: ResponseType.json,
  ),
);

/// The HTTP client for the chosen server, or null when no server is set.
///
/// It is made anew when the session changes, so everything loaded through it
/// reloads as the new account.
final apiProvider = Provider<Dio?>((ref) {
  final url = ref.watch(serverUrlProvider);
  if (url == null) return null;
  final session = ref.watch(sessionProvider);
  final dio = _cachedDio(ref, url, cacheAccount(session.token));
  if (session.token case final token?) dio.options.headers['Authorization'] = 'Bearer $token';
  ref.onDispose(dio.close);
  return dio;
});

/// A client for [url] that falls back on what this device saved for
/// [account] when the server cannot be reached.
Dio _cachedDio(Ref ref, String url, String account) {
  final dio = _newDio(url);
  if (ref.watch(cacheDbProvider) case final db?) {
    dio.interceptors.add(
      OfflineCache(db, url, account, (offline) {
        if (ref.mounted) ref.read(offlineProvider.notifier).set(offline);
      }),
    );
  }
  return dio;
}

/// A client for [serverUrl] that sends no session and keeps no offline
/// copies, for the administrator's pages.
Dio plainDio(String serverUrl) => _newDio(serverUrl);

class NoServerException implements Exception {
  const NoServerException();
}

final serverInfoProvider = FutureProvider<ServerInfo>((ref) async {
  final url = ref.watch(serverUrlProvider);
  if (url == null) throw const NoServerException();
  final dio = _cachedDio(ref, url, CacheDb.public);
  try {
    final res = await dio.get<Object?>('/server-info');
    return ServerInfo.fromJson(res.data);
  } finally {
    dio.close();
  }
});

/// Only settled metadata can advertise an alias: a dependency reload can keep
/// the previous server's value while the newly selected server is loading.
final serverPublicUrlProvider = Provider<String?>((ref) {
  final info = ref.watch(serverInfoProvider);
  return info.isLoading || info.hasError ? null : info.value?.publicUrl;
});

/// Whether the chosen server still needs its administrator password set;
/// false until its info has loaded.
final setupRequiredProvider = Provider<bool>(
  (ref) => ref.watch(serverInfoProvider.select((info) => info.value?.setupRequired ?? false)),
);

/// Whether the chosen server has accounts; false until its info has loaded.
final accountsModeProvider = Provider<bool>(
  (ref) => ref.watch(serverInfoProvider.select((info) => info.value?.authMode == AuthMode.accounts)),
);

enum ProbeError { unreachable, notBalnana }

class ProbeException implements Exception {
  const ProbeException(this.error);
  final ProbeError error;
}

/// Checks that [serverUrl] (already normalized) is a Balnana server.
Future<ServerInfo> probeServer(String serverUrl) async {
  final dio = _newDio(serverUrl)
    ..options.connectTimeout = const Duration(seconds: 6)
    ..options.receiveTimeout = const Duration(seconds: 6);
  try {
    final res = await dio.get<Object?>('/server-info');
    return ServerInfo.fromJson(res.data);
  } on DioException catch (e) {
    // A response of any kind means something is there, just not Balnana.
    throw ProbeException(e.response == null ? ProbeError.unreachable : ProbeError.notBalnana);
  } on FormatException {
    throw const ProbeException(ProbeError.notBalnana);
  } finally {
    dio.close();
  }
}
