import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether this is the iOS app, the one with the App Store and Sign in with
/// Apple.
bool get iosApp => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// One subscription in the App Store, at the price Apple shows this person.
class AppStoreOffer {
  const AppStoreOffer({
    required this.productId,
    required this.name,
    required this.price,
    required this.period,
  });

  factory AppStoreOffer.fromMap(Map<Object?, Object?> map) => AppStoreOffer(
    productId: map['productId'] as String,
    name: map['name'] as String,
    price: map['price'] as String,
    period: map['period'] as String,
  );

  final String productId;
  final String name;

  /// Formatted for this person's storefront, such as "US$4.99".
  final String price;

  /// How often it is charged, as ISO 8601: P1M, P1Y, P1W.
  final String period;

  /// Months between charges; null when it isn't a whole number of them.
  int? get months {
    final match = RegExp(r'^P(\d+)([MY])$').firstMatch(period);
    if (match == null) return null;
    return int.parse(match[1]!) * (match[2] == 'Y' ? 12 : 1);
  }
}

/// The App Store refused to go ahead, or something broke on the way.
class AppStoreException implements Exception {
  const AppStoreException({this.pending = false});

  /// The purchase waits for someone to approve it, such as Ask to Buy.
  final bool pending;
}

/// StoreKit 2, through AppStore.swift. Only the iOS app has it: elsewhere
/// the channel is missing, nothing is on sale and nothing is held.
///
/// Transactions come as the JWS Apple signed, which the server checks.
class AppStore {
  const AppStore();

  static const _channel = MethodChannel('balnana/app_store');
  static final _bought = StreamController<List<String>>.broadcast();

  /// Transactions finished outside the purchase screen: renewals, Ask to Buy
  /// approvals, and purchases made on another device.
  Stream<List<String>> get bought {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'purchased') _bought.add([...(call.arguments as List<Object?>).whereType<String>()]);
    });
    return _bought.stream;
  }

  /// What of [products] can be bought here: none in a build without StoreKit.
  /// Throws [AppStoreException] when the App Store can't be reached.
  Future<List<AppStoreOffer>> offers(List<String> products) async {
    try {
      final found = await _channel.invokeListMethod<Map<Object?, Object?>>('products', {'products': products});
      return [...?found?.map(AppStoreOffer.fromMap)];
    } on PlatformException {
      throw const AppStoreException();
    } on MissingPluginException {
      return const [];
    }
  }

  /// Opens the App Store's purchase sheet for the account [accountToken]
  /// names, and returns the signed transactions: none if the person changed
  /// their mind.
  Future<List<String>> buy(AppStoreOffer offer, String accountToken) async {
    try {
      final signed = await _channel.invokeListMethod<String>('buy', {
        'product': offer.productId,
        'account': accountToken,
      });
      return signed ?? const [];
    } on PlatformException catch (e) {
      throw AppStoreException(pending: e.code == 'pending');
    } on MissingPluginException {
      throw const AppStoreException();
    }
  }

  /// The signed transactions of the subscriptions this Apple ID holds now:
  /// none in a build without StoreKit. With [sync], asks Apple again first,
  /// which may ask the person to sign in: only when they asked to restore.
  Future<List<String>> purchases({bool sync = false}) async {
    try {
      return await _channel.invokeListMethod<String>('purchases', {'sync': sync}) ?? const [];
    } on PlatformException {
      throw const AppStoreException();
    } on MissingPluginException {
      return const [];
    }
  }
}

final appStoreProvider = Provider((_) => const AppStore());
