import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../data/models.dart';
import 'location.dart';

/// Asks the browser, which asks the person first.
Future<GeoPoint> currentLocation() {
  final done = Completer<GeoPoint>();
  web.window.navigator.geolocation.getCurrentPosition(
    ((web.GeolocationPosition p) => done.complete(GeoPoint(p.coords.latitude, p.coords.longitude))).toJS,
    ((web.GeolocationPositionError e) => done.completeError(
      LocationException(e.code == web.GeolocationPositionError.PERMISSION_DENIED
          ? LocationProblem.denied
          : LocationProblem.unavailable),
    )).toJS,
    web.PositionOptions(timeout: 15000, maximumAge: 60000),
  );
  return done.future;
}
