import 'dart:convert';

import 'package:dio/dio.dart';

/// A failed request. [code] is the server's error code (see api/openapi.yaml),
/// or [network] when no answer came back.
class ApiException implements Exception {
  const ApiException(this.code, {this.status, this.params = const {}});

  static const network = 'network';

  final String code;
  final int? status;
  final Map<String, Object?> params;

  bool get isNotFound => status == 404;

  /// Whether the server could not be reached: no answer came, or a proxy in
  /// front of it answered for it. The server's own errors carry a code.
  bool get unreachable =>
      code == network || (const {502, 503, 504}.contains(status) && code.startsWith('http_'));

  @override
  String toString() => 'ApiException($status $code)';
}

/// Sends requests and normalizes HTTP and decoding failures for each client.
class ApiTransport {
  ApiTransport(this.dio, {this.onSignInRequired});

  final Dio dio;
  final void Function()? onSignInRequired;

  Future<T> send<T>(Future<Response<Object?>> Function() request, T Function(Object? data) parse) async {
    try {
      final res = await request();
      return parse(res.data);
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) throw const ApiException(ApiException.network);
      final body = _errorBody(res.data);
      if (body case {'code': final String code}) {
        final params = body['params'];
        if (res.statusCode == 401 && code == 'sign_in_required') onSignInRequired?.call();
        throw ApiException(
          code,
          status: res.statusCode,
          params: params is Map<String, Object?> ? params : const {},
        );
      }
      throw ApiException('http_${res.statusCode}', status: res.statusCode);
    } on FormatException {
      throw const ApiException('bad_response');
    }
  }

  /// The error of a request that asked for bytes is JSON all the same.
  static Object? _errorBody(Object? data) {
    if (data is! List<int>) return data;
    try {
      return jsonDecode(utf8.decode(data));
    } on FormatException {
      return null;
    }
  }
}
