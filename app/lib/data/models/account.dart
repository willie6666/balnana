import 'package:flutter/foundation.dart';

import 'json_fields.dart';

/// A signed-in account (accounts mode).
@immutable
class User {
  const User({
    required this.id,
    this.email,
    this.username,
    this.emailVerified = false,
    this.pendingEmail,
    required this.name,
    this.locale,
    required this.hasPassword,
    this.totp = false,
    this.emailTwoFactor = false,
  });

  factory User.fromJson(Object? data) {
    final json = jsonObject(data);
    return User(
      id: requiredField(json, 'id'),
      email: optionalField(json, 'email'),
      username: optionalField(json, 'username'),
      emailVerified: optionalField<bool>(json, 'emailVerified') ?? false,
      pendingEmail: optionalField(json, 'pendingEmail'),
      name: requiredField(json, 'name'),
      locale: optionalField(json, 'locale'),
      hasPassword: optionalField<bool>(json, 'hasPassword') ?? false,
      totp: optionalField<bool>(json, 'totp') ?? false,
      emailTwoFactor: optionalField<bool>(json, 'emailTwoFactor') ?? false,
    );
  }

  final String id;
  final String? email;

  /// Set on accounts made without an email address.
  final String? username;
  final bool emailVerified;

  /// A new address waiting for its verification link to be opened; [email]
  /// stays in force until then.
  final String? pendingEmail;
  final String name;
  final String? locale;
  final bool hasPassword;

  /// Signing in with the password also asks for a code from an
  /// authenticator app.
  final bool totp;

  /// Signing in with the password also asks for a code sent by email.
  final bool emailTwoFactor;
}

/// The key of an authenticator app being added to the account.
@immutable
class TotpSetup {
  const TotpSetup({required this.secret, required this.uri});

  factory TotpSetup.fromJson(Object? data) {
    final json = jsonObject(data);
    return TotpSetup(secret: requiredField(json, 'secret'), uri: requiredField(json, 'uri'));
  }

  /// The key to type into the app.
  final String secret;

  /// The same as an otpauth:// link, for a QR code.
  final String uri;
}

/// A provider sign-in that matched an account by an address the account
/// never confirmed, waiting for the person to say what it is to them.
@immutable
class OAuthPending {
  const OAuthPending({
    required this.email,
    required this.provider,
    required this.hasPassword,
    required this.signup,
  });

  factory OAuthPending.fromJson(Object? data) {
    final json = jsonObject(data);
    return OAuthPending(
      email: requiredField(json, 'email'),
      provider: requiredField(json, 'provider'),
      hasPassword: requiredField(json, 'hasPassword'),
      signup: requiredField(json, 'signup'),
    );
  }

  final String email;

  /// The provider's id.
  final String provider;

  /// The account has a password, so linking can prove it is theirs.
  final bool hasPassword;

  /// A new account may be made instead.
  final bool signup;
}

/// An invitation to a group, sent by email (accounts mode).
@immutable
class InviteInfo {
  const InviteInfo({required this.email, required this.groupToken, required this.groupName, this.invitedBy});

  factory InviteInfo.fromJson(Object? data) {
    final json = jsonObject(data);
    return InviteInfo(
      email: requiredField(json, 'email'),
      groupToken: requiredField(json, 'groupToken'),
      groupName: requiredField(json, 'groupName'),
      invitedBy: optionalField(json, 'invitedBy'),
    );
  }

  final String email;
  final String groupToken;
  final String groupName;
  final String? invitedBy;
}
