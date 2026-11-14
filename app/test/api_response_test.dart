import 'package:balnana/data/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('malformed response fields consistently report bad_response', () async {
    final badResponse = throwsA(isA<ApiException>().having((e) => e.code, 'code', 'bad_response'));
    final dio = Dio(BaseOptions(baseUrl: 'https://split.example.com/api/v1'));
    addTearDown(dio.close);
    final api = BalnanaApi(dio).group('tok');
    final responses = <String, Object?>{
      '/g/tok': {
        'token': 'tok',
        'name': 'Trip',
        'currency': 'USD',
        'minorDigits': -1,
        'createdAt': '2026-01-01T00:00:00Z',
        'members': [],
      },
      '/g/tok/balances': {
        'balances': [
          {'memberId': 'ana', 'amount': 'oops'},
        ],
        'transfers': [],
      },
      '/g/tok/activity': {'items': [], 'nextCursor': 42},
      '/g/tok/expenses': {'items': [], 'nextCursor': false},
      '/g/tok/stats': {
        'total': '1',
        'count': 1,
        'categories': [],
        'members': [],
        'months': [
          {'month': '2026-13', 'amount': '1'},
        ],
      },
    };
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, handler) {
          handler.resolve(Response(requestOptions: o, data: responses[o.path]));
        },
      ),
    );

    await expectLater(api.get(), badResponse);
    await expectLater(api.balances(2), badResponse);
    await expectLater(api.activity(), badResponse);
    await expectLater(api.expenses(2), badResponse);
    await expectLater(api.stats(2), badResponse);
  });
}
