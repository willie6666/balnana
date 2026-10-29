import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import 'location_io.dart' if (dart.library.js_interop) 'location_web.dart' as impl;

/// Why the device's position could not be read.
enum LocationProblem {
  /// The person said no, now or before.
  denied,

  /// Location is turned off on the device.
  off,

  /// The device did not find where it is in time, or cannot tell.
  unavailable,
}

class LocationException implements Exception {
  const LocationException(this.problem);

  final LocationProblem problem;

  @override
  String toString() => 'LocationException(${problem.name})';
}

/// Asks the device where it is, once. The app calls it only when the person
/// taps "Use current location", never on its own: that tap is also when the
/// system asks for permission. Throws [LocationException].
///
/// Android gives up 15 seconds after the person answers the permission
/// question, however long that took, so this only guards against no answer
/// at all.
Future<GeoPoint> currentLocation() => impl
    .currentLocation()
    .timeout(const Duration(minutes: 2), onTimeout: () => throw const LocationException(LocationProblem.unavailable));

/// Reads the device's position; tests replace it.
final currentLocationProvider = Provider<Future<GeoPoint> Function()>((ref) => currentLocation);
