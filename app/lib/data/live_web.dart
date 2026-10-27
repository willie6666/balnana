import 'dart:async';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;

import 'live.dart';

/// Reads the stream in the browser. The web app on its own server signs in
/// with a cookie, which the browser's EventSource sends. A web app on
/// another origin signs in with a bearer token instead, which EventSource
/// cannot send, so it reads the stream with fetch.
Stream<LiveEvent> groupEvents(Dio dio, String token, Duration retryAfter) {
  final url = '${dio.options.baseUrl}/g/$token/events';
  if (dio.options.headers['Authorization'] case final String authorization) {
    return _fetchEvents(url, authorization, retryAfter);
  }
  return _eventSource(url, retryAfter);
}

/// EventSource sends the session cookie and reconnects by itself after a
/// dropped connection.
Stream<LiveEvent> _eventSource(String url, Duration retryAfter) {
  late final StreamController<LiveEvent> out;
  web.EventSource? source;
  Timer? retry;
  var delay = retryAfter;

  void connect() {
    final s = source = web.EventSource(url);
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

/// fetch with the bearer token, reconnecting like the Android app does. The
/// server pings every 25 seconds, so a minute without data means the
/// connection is dead.
Stream<LiveEvent> _fetchEvents(String url, String authorization, Duration retryAfter) {
  late final StreamController<LiveEvent> out;
  web.AbortController? abort;
  Timer? retry;
  var delay = retryAfter;
  var stopped = false;

  Future<void> connect() async {
    final thisAbort = abort = web.AbortController();
    Timer? idle;
    void stillAlive() {
      idle?.cancel();
      idle = Timer(const Duration(minutes: 1), () => thisAbort.abort());
    }

    try {
      stillAlive();
      final headers = web.Headers()
        ..append('Authorization', authorization)
        ..append('Accept', 'text/event-stream');
      final res = await web.window
          .fetch(url.toJS, web.RequestInit(headers: headers, signal: thisAbort.signal, cache: 'no-store'))
          .toDart;
      final body = res.body;
      if (!res.ok || body == null) {
        // The server refused the stream: retrying will not help.
        if (res.status >= 400 && res.status < 500 && res.status != 429) stopped = true;
      } else {
        out.add(LiveEvent.connected);
        delay = retryAfter;
        final reader = body.getReader() as web.ReadableStreamDefaultReader;
        await for (final event in eventNames(_chunks(reader, stillAlive))) {
          if (event == 'change') out.add(LiveEvent.change);
          if (event == 'gone') {
            stopped = true;
            out.add(LiveEvent.gone);
            break;
          }
        }
        thisAbort.abort();
      }
    } on Object {
      // A dropped connection, or one aborted: try again unless stopped.
    } finally {
      idle?.cancel();
    }
    if (stopped) {
      if (!out.isClosed) await out.close();
      return;
    }
    retry = Timer(delay, connect);
    delay = nextRetry(delay);
  }

  out = StreamController(
    onListen: connect,
    onCancel: () {
      stopped = true;
      retry?.cancel();
      abort?.abort();
    },
  );
  return out.stream;
}

/// The bytes [reader] reads, telling [received] of each chunk.
Stream<List<int>> _chunks(web.ReadableStreamDefaultReader reader, void Function() received) async* {
  while (true) {
    final chunk = await reader.read().toDart;
    if (chunk.done) return;
    received();
    yield (chunk.value! as JSUint8Array).toDart;
  }
}
