import 'package:flutter/foundation.dart';

import 'json_fields.dart';

@immutable
class Page<T> {
  const Page(this.items, this.nextCursor);

  factory Page.fromJson(Object? data, T Function(Object?) parseItem) {
    final json = jsonObject(data);
    return Page([
      for (final item in requiredField<List<Object?>>(json, 'items')) parseItem(item),
    ], json['nextCursor'] == null ? null : requiredField<String>(json, 'nextCursor'));
  }

  final List<T> items;
  final String? nextCursor;
}
