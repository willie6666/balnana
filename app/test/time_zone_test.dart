import 'package:balnana/data/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // One offset cannot date a whole year across daylight saving time, so the
  // server is told the zone's name, and the offset only for servers that do
  // not know it.
  test('stats and exports name the time zone, and fall back to the offset', () async {
    final asked = <Map<String, Object?>>[];
    var known = true;
    final dio = Dio(BaseOptions(baseUrl: 'https://a.example/api/v1'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, handler) {
          asked.add(o.queryParameters);
          if (!known && o.queryParameters.containsKey('timeZone')) {
            handler.reject(
              DioException.badResponse(
                statusCode: 400,
                requestOptions: o,
                response: Response(requestOptions: o, statusCode: 400, data: {'code': 'invalid_time_zone'}),
              ),
            );
          } else {
            handler.resolve(Response(requestOptions: o, data: <int>[]));
          }
        },
      ),
    );
    final saved = deviceTimeZone;
    addTearDown(() => deviceTimeZone = saved);
    deviceTimeZone = () async => 'America/New_York';
    final api = BalnanaApi(dio).group('AAAAAAAAAAAAAAAAAAAAAA');
    final offset = DateTime.now().timeZoneOffset.inMinutes;

    await api.exportCsv();
    expect(asked, [
      {'utcOffset': offset, 'timeZone': 'America/New_York'},
    ]);

    asked.clear();
    known = false;
    await api.exportCsv();
    expect(asked, [
      {'utcOffset': offset, 'timeZone': 'America/New_York'},
      {'utcOffset': offset},
    ]);

    asked.clear();
    deviceTimeZone = () async => null;
    await api.exportCsv();
    expect(asked, [
      {'utcOffset': offset},
    ]);
  });
}
