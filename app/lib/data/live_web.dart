import 'dart:async';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;

import 'live.dart';

/// Reads the stream with the browser's EventSource, which sends the session
/// cookie and reconnects by itself after a dropped connection.
Stream<LiveEvent> groupEvents(Dio dio, String token, Duration retryAfter) {
  late final StreamController<LiveEvent> out;
  web.EventSource? source;
  Timer? retry;
  var delay = retryAfter;

  void connect() {
    final s = source = web.EventSource('${dio.options.baseUrl}/g/$token/events');
    s.onopen = ((web.Event _) {
      delay = retryAfter;
      out.add(LiveEvent.connected);
    }).toJS;
    s.addEventListener('change', ((web.Event _) => out.add(LiveEvent.change)).toJS);
    s.addEventListener(
      'gone',
      ((web.Event _) {
        s.close();
        out
          ..add(LiveEvent.gone)
          ..close();
      }).toJS,
    );
    s.onerror = ((web.Event _) {
      // The browser gives up only when the server refused the stream, which
      // it cannot tell apart from the server being away: try again later.
      if (s.readyState != web.EventSource.CLOSED) return;
      retry = Timer(delay, connect);
      delay = nextRetry(delay);
    }).toJS;
  }

  out = StreamController(
    onListen: connect,
    onCancel: () {
      retry?.cancel();
      source?.close();
    },
  );
  return out.stream;
}
