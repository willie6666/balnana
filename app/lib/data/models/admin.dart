import 'package:flutter/foundation.dart';

import 'json_fields.dart';

/// The server's settings as the admin page shows them.
@immutable
class AdminSettings {
  const AdminSettings(this.settings, {this.envOnly = false});

  factory AdminSettings.fromJson(Object? data) {
    final json = jsonObject(data);
    return AdminSettings([
      for (final s in objectList(json, 'settings')) AdminSetting.fromJson(s),
    ], envOnly: optionalField<bool>(json, 'envOnly') ?? false);
  }

  final List<AdminSetting> settings;

  /// The server reads its settings from its environment alone, so none can
  /// be changed here.
  final bool envOnly;
}

/// One server setting on the admin page, by the environment variable that
/// sets it (see .env.example).
@immutable
class AdminSetting {
  const AdminSetting({
    required this.key,
    this.value,
    this.defaultValue = '',
    this.locked = false,
    this.secret = false,
    this.set = false,
  });

  factory AdminSetting.fromJson(Object? data) {
    final json = jsonObject(data);
    return AdminSetting(
      key: requiredField(json, 'key'),
      value: optionalField(json, 'value'),
      defaultValue: optionalField<String>(json, 'default') ?? '',
      locked: optionalField<bool>(json, 'locked') ?? false,
      secret: optionalField<bool>(json, 'secret') ?? false,
      set: optionalField<bool>(json, 'set') ?? false,
    );
  }

  final String key;

  /// The value in force; never sent for secrets.
  final String? value;
  final String defaultValue;

  /// Set by an environment variable on the server, which wins. With
  /// [AdminSettings.envOnly] every setting is.
  final bool locked;
  final bool secret;

  /// Something sets it: the environment or the admin page.
  final bool set;

  /// What is in force, the default when nothing sets it.
  String get effective => value ?? defaultValue;
}

/// One account, as the administrator sees it.
@immutable
class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    this.email,
    this.username,
    this.emailVerified = false,
    this.hasPassword = false,
    this.oauth = const [],
    this.groups = 0,
    required this.createdAt,
    this.planName,
    this.planExpiresAt,
  });

  factory AdminUser.fromJson(Object? data) {
    final json = jsonObject(data);
    return AdminUser(
      id: requiredField(json, 'id'),
      name: requiredField(json, 'name'),
      email: optionalField(json, 'email'),
      username: optionalField(json, 'username'),
      emailVerified: optionalField<bool>(json, 'emailVerified') ?? false,
      hasPassword: optionalField<bool>(json, 'hasPassword') ?? false,
      oauth: [...?optionalField<List<Object?>>(json, 'oauth')?.whereType<String>()],
      groups: optionalField<num>(json, 'groups')?.toInt() ?? 0,
      createdAt: dateField(json, 'createdAt'),
      planName: optionalField(json, 'planName'),
      planExpiresAt: optionalDateField(json, 'planExpiresAt'),
    );
  }

  final String id;
  final String name;
  final String? email;
  final String? username;
  final bool emailVerified;
  final bool hasPassword;

  /// The sign-in providers linked to the account, such as "google".
  final List<String> oauth;

  /// How many groups it is in.
  final int groups;
  final DateTime createdAt;

  /// The plan an entitlement gives it; null on the default plan.
  final String? planName;

  /// When [planName] ends; null when it doesn't.
  final DateTime? planExpiresAt;
}
