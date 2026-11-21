import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'ios_storage.dart';

QueryExecutor? openCacheExecutor() => driftDatabase(
  name: 'balnana_cache',
  native: Platform.isIOS ? const DriftNativeOptions(databasePath: iosOfflineDatabasePath) : null,
);
