import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'live_io.dart' if (dart.library.js_interop) 'live_web.dart' as impl;

/// What a group's event stream says, see `GET /g/{token}/events`.
enum LiveEvent {
  /// The stream is open. After a reconnect, changes may have been missed.
  connected,

  /// The group changed: reload what is shown.
  change,

  /// This app may no longer see the group. The stream ends.
  gone,
}

/// How long to wait before connecting again after losing the stream; it
/// doubles up to [liveRetryMax] while the server stays away.
const liveRetry = Duration(seconds: 3);
const liveRetryMax = Duration(minutes: 1);

/// Opens [token]'s event stream on the server behind [dio], reconnecting
/// until it says [LiveEvent.gone] or the subscription is cancelled.
Stream<LiveEvent> groupEvents(Dio dio, String token, {Duration retry = liveRetry}) =>
    impl.groupEvents(dio, token, retry);

/// Opens group event streams; tests replace it.
final groupEventsProvider = Provider<Stream<LiveEvent> Function(Dio dio, String token)>((ref) => groupEvents);

Duration nextRetry(Duration retry) => retry * 2 > liveRetryMax ? liveRetryMax : retry * 2;

/// The names of the events in a text/event-stream, as they arrive. Comments
/// (the server's pings) and data lines carry nothing the app needs.
Stream<String> eventNames(Stream<List<int>> bytes) async* {
  String? event;
  await for (final line in const LineSplitter().bind(utf8.decoder.bind(bytes))) {
    if (line.startsWith('event:')) {
      event = line.substring(6).trim();
    } else if (line.isEmpty) {
      if (event != null) yield event;
      event = null;
    }
  }
}
