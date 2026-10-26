import 'dart:async';
import 'dart:io';

import 'package:balnana/data/live.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Dio dio;
  // What each request to the stream gets, in turn.
  late List<Future<void> Function(HttpResponse)> replies;
  var requests = 0;

  setUp(() async {
    requests = 0;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      expect(req.uri.path, '/api/v1/g/tok/events');
      expect(req.headers.value('authorization'), 'Bearer s');
      final reply = replies[requests++];
      await reply(req.response);
    });
    dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:${server.port}/api/v1', headers: {'Authorization': 'Bearer s'}));
  });

  tearDown(() async {
    dio.close(force: true);
    await server.close(force: true);
  });

  Future<void> Function(HttpResponse) stream(String body) => (res) async {
    res.headers.contentType = ContentType('text', 'event-stream');
    res.write('retry: 3000\n\n$body');
    await res.close();
  };

  Future<void> Function(HttpResponse) status(int code) => (res) async {
    res.statusCode = code;
    await res.close();
  };

  test('reads changes, reconnects after a drop and stops when gone', () async {
    replies = [
      stream(': ping\n\nevent: change\ndata: {}\n\n'),
      stream('event: change\ndata: {}\n\nevent: gone\ndata: {}\n\nevent: change\ndata: {}\n\n'),
    ];
    final events = await groupEvents(dio, 'tok', retry: Duration.zero).toList();
    expect(events, [
      LiveEvent.connected,
      LiveEvent.change,
      LiveEvent.connected,
      LiveEvent.change,
      LiveEvent.gone,
    ]);
    expect(requests, 2);
  });

  test('retries a server that is away, not one that refuses', () async {
    replies = [status(502), status(503), stream(''), status(404)];
    final events = await groupEvents(dio, 'tok', retry: Duration.zero).toList();
    expect(events, [LiveEvent.connected]);
    expect(requests, 4);
  });

  test('cancelling stops reconnecting', () async {
    replies = [stream('event: change\ndata: {}\n\n'), stream('')];
    final got = <LiveEvent>[];
    final changed = Completer<void>();
    final sub = groupEvents(dio, 'tok', retry: const Duration(milliseconds: 200)).listen((e) {
      got.add(e);
      if (e == LiveEvent.change) changed.complete();
    });
    await changed.future;
    await sub.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(got, [LiveEvent.connected, LiveEvent.change]);
    expect(requests, 1);
  });
}
