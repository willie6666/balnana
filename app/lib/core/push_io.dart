import 'package:shared_preferences/shared_preferences.dart';

import 'push.dart';

/// Only browsers have this push service.
PushService? webPushService(SharedPreferences prefs) => null;
