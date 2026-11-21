import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _storage = MethodChannel('balnana/storage');

/// Only iOS overrides this. Session readers keep their synchronous view of
/// the tokens loaded at startup while Keychain operations run off the UI thread.
final iosSessionTokensProvider = Provider<IosSessionTokens?>((ref) => null);

class IosSessionTokens {
  IosSessionTokens._(this._tokens);

  final Map<String, String> _tokens;

  static Future<IosSessionTokens> load() async {
    try {
      return IosSessionTokens._(await _storage.invokeMapMethod<String, String>('sessionTokens') ?? {});
    } on PlatformException catch (error, stack) {
      _reportStorageError(error, stack, 'loading iOS session tokens');
      return IosSessionTokens._({});
    }
  }

  String? operator [](String? server) => _tokens[server];

  Future<void> set(String server, String? token) async {
    if (token == null) {
      _tokens.remove(server);
    } else {
      _tokens[server] = token;
    }
    try {
      await _storage.invokeMethod<void>('setSessionToken', {'server': server, 'token': token});
    } on PlatformException catch (error, stack) {
      _reportStorageError(error, stack, 'saving an iOS session token');
    }
  }
}

/// Upgrade the database even if the user no longer has a server selected.
Future<void> prepareIosOfflineDatabase() async {
  try {
    await iosOfflineDatabasePath();
  } on PlatformException catch (error, stack) {
    // Opening the database will retry the migration.
    _reportStorageError(error, stack, 'moving the iOS offline database');
  }
}

Future<String> iosOfflineDatabasePath() async =>
    (await _storage.invokeMethod<String>('offlineDatabasePath'))!;

void _reportStorageError(PlatformException error, StackTrace stack, String context) =>
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'Balnana',
        context: ErrorDescription(context),
      ),
    );
