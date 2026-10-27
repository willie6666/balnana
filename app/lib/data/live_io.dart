import 'dart:async';

import 'package:dio/dio.dart';

import 'live.dart';

/// Reads the stream through Dio. The server pings every 25 seconds, so a
/// minute without data means the connection is dead.
Stream<LiveEvent> groupEvents(Dio dio, String token, Duration retryAfter) {
  late final StreamController<LiveEvent> out;
  CancelToken? cancel;
  Timer? retry;
  var delay = retryAfter;
  var stopped = false;

  Future<void> connect() async {
    final thisCancel = cancel = CancelToken();
    try {
      final res = await dio.get<ResponseBody>(
        '/g/$token/events',
        cancelToken: thisCancel,
        options: Options(responseType: ResponseType.stream, receiveTimeout: const Duration(minutes: 1)),
      );
      out.add(LiveEvent.connected);
      delay = retryAfter;
      await for (final event in eventNames(res.data!.stream)) {
        if (event == 'change') out.add(LiveEvent.change);
        if (event == 'gone') {
          stopped = true;
          out.add(LiveEvent.gone);
          break;
        }
      }
    } on DioException catch (e) {
      // The server refused the stream: retrying will not help.
      final status = e.response?.statusCode ?? 0;
      if (status >= 400 && status < 500 && status != 429) stopped = true;
    } on Exception {
      // A dropped connection: try again.
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
      cancel?.cancel();
    },
  );
  return out.stream;
}
