import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/expense.dart';
import '../models/page.dart';
import '../models/view_link.dart';
import 'time_zone.dart';
import 'transport.dart';

/// A group seen through its view-only link: no session, member or key.
class ViewApi {
  ViewApi(this._transport, this.token);

  final ApiTransport _transport;
  final String token;

  Dio get _dio => _transport.dio;
  String get _base => '/v/${Uri.encodeComponent(token)}';

  /// 404 `not_found` when revoked, 410 `view_link_expired`, 403
  /// `view_link_paused` while the group's plan lacks it.
  Future<ViewGroup> get() => _transport.send(() => _dio.get<Object?>(_base), ViewGroup.fromJson);

  Future<Page<Expense>> expenses(
    int digits, {
    String? cursor,
    int limit = 50,
    ExpenseFilter filter = const ExpenseFilter(),
  }) => _transport.send(
    () => _dio.get<Object?>(
      '$_base/expenses',
      queryParameters: {'cursor': ?cursor, 'limit': limit, ...filter.query},
    ),
    (data) => Page.fromJson(data, (item) => viewExpenseFromJson(item, digits)),
  );

  /// What the group spent in [period], with months starting in this device's time zone.
  Future<GroupStats> stats(int digits, {Period? period}) => withLocalTimeZone(
    (zone) => _transport.send(
      () => _dio.get<Object?>(
        '$_base/stats',
        queryParameters: {
          if (period != null) ...{
            'from': period.from.toUtc().toIso8601String(),
            'to': period.to.toUtc().toIso8601String(),
          },
          ...zone,
        },
      ),
      (data) => GroupStats.fromJson(data, digits),
    ),
  );

  /// The photo of the expense's receipt, as JPEG bytes.
  Future<Uint8List> receipt(String id) => _transport.send(
    () =>
        _dio.get<Object?>('$_base/expenses/$id/receipt', options: Options(responseType: ResponseType.bytes)),
    (data) => data is List<int> ? Uint8List.fromList(data) : throw const FormatException('bad receipt'),
  );
}
