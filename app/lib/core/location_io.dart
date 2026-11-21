import 'package:flutter/services.dart';

import '../data/models.dart';
import 'location.dart';

const _channel = MethodChannel('balnana/location');

/// Asks the mobile platform for a foreground location fix.
Future<GeoPoint> currentLocation() async {
  try {
    final point = await _channel.invokeMapMethod<String, double>('current');
    if (point case {'latitude': final lat, 'longitude': final lng}) return GeoPoint(lat, lng);
  } on PlatformException catch (e) {
    throw LocationException(LocationProblem.values.asNameMap()[e.code] ?? LocationProblem.unavailable);
  } on MissingPluginException {
    // This platform has no native location handler.
  }
  throw const LocationException(LocationProblem.unavailable);
}
