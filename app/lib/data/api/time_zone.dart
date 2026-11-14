import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'expense_draft.dart';
import 'transport.dart';

/// A fixed time zone the server knows by its offset, such as "UTC+05:30".
@visibleForTesting
String fixedZone(Duration offset) {
  if (offset == Duration.zero) return 'UTC';
  final minutes = offset.inMinutes.abs();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'UTC${offset.isNegative ? '-' : '+'}${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// This device's IANA time zone, such as "Europe/Berlin", or null when the
/// platform does not say. Tests replace it.
@visibleForTesting
Future<String?> Function() deviceTimeZone = () async {
  try {
    final zone = (await FlutterTimezone.getLocalTimezone()).identifier;
    return zone.isEmpty ? null : zone;
  } on Object {
    return null;
  }
};

/// Sends [draft] in this device's time zone when it names none: by its
/// IANA name, or as the fixed offset at the start when the device does not
/// say or the server does not know the name, so the schedule keeps its
/// local day and time.
Future<T> withRecurringTimeZone<T>(
  RecurringDraft draft,
  Future<T> Function(Map<String, Object?> Function(int digits, {int? version}) json) send,
) async {
  if (draft.timeZone != null) return send(draft.toJson);
  Map<String, Object?> Function(int, {int? version}) inZone(String zone) =>
      (digits, {version}) => {...draft.toJson(digits, version: version), 'timeZone': zone};
  final offset = fixedZone(draft.expense.occurredAt.toLocal().timeZoneOffset);
  final name = await deviceTimeZone();
  if (name == null) return send(inZone(offset));
  try {
    return await send(inZone(name));
  } on ApiException catch (e) {
    if (e.code != 'invalid_time_zone') rethrow;
    return send(inZone(offset));
  }
}

/// Asks with this device's time zone. Its name lets the server date each
/// expense by the offset in force then, across daylight saving time; the
/// current offset is for a server that does not know the name.
Future<T> withLocalTimeZone<T>(Future<T> Function(Map<String, Object> zone) ask) async {
  final offset = {'utcOffset': DateTime.now().timeZoneOffset.inMinutes};
  final name = await deviceTimeZone();
  if (name == null) return ask(offset);
  try {
    return await ask({...offset, 'timeZone': name});
  } on ApiException catch (e) {
    if (e.code != 'invalid_time_zone') rethrow;
    return ask(offset);
  }
}
