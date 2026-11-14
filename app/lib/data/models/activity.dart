import 'package:flutter/foundation.dart';

import 'json_fields.dart';

@immutable
class Activity {
  const Activity({
    required this.id,
    required this.action,
    this.actorMemberId,
    this.subjectId,
    required this.payload,
    required this.createdAt,
  });

  factory Activity.fromJson(Object? data) {
    final json = jsonObject(data);
    return Activity(
      id: requiredField(json, 'id'),
      action: requiredField(json, 'action'),
      actorMemberId: optionalField(json, 'actorMemberId'),
      subjectId: optionalField(json, 'subjectId'),
      payload: optionalField<Map<String, Object?>>(json, 'payload') ?? const {},
      createdAt: dateField(json, 'createdAt'),
    );
  }

  final String id;

  /// Such as `expense.created` or `member.added`.
  final String action;
  final String? actorMemberId;
  final String? subjectId;
  final Map<String, Object?> payload;
  final DateTime createdAt;

  String? text(String key) => payload[key] is String ? payload[key] as String : null;

  int? number(String key) => payload[key] is num ? (payload[key] as num).toInt() : null;
}
