import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One way to pay on Google Play, at the price Play shows this person.
class PlayOffer {
  const PlayOffer({
    required this.productId,
    required this.offerToken,
    required this.name,
    required this.price,
    required this.period,
  });

  factory PlayOffer.fromMap(Map<Object?, Object?> map) => PlayOffer(
    productId: map['productId'] as String,
    offerToken: map['offerToken'] as String,
    name: map['name'] as String,
    price: map['price'] as String,
    period: map['period'] as String,
  );

  final String productId;
  final String offerToken;
  final String name;
  final String price;

  /// How often it is charged, as ISO 8601: P1M, P1Y.
  final String period;

  /// Months between charges; null when it isn't a whole number of them.
  int? get months {
    final match = RegExp(r'^P(\d+)([MY])$').firstMatch(period);
    if (match == null) return null;
    return int.parse(match[1]!) * (match[2] == 'Y' ? 12 : 1);
  }
}

/// Google Play refused to go ahead, or something broke on the way.
class PlayException implements Exception {
  const PlayException({this.owned = false});

  /// This Play account already holds the subscription.
  final bool owned;
}

/// Google Play's billing, through PlayBilling.kt. Only the Play build of the
/// Android app has it: elsewhere the channel is missing, nothing is on sale
/// and nothing is held.
class GooglePlay {
  const GooglePlay();

  static const _channel = MethodChannel('balnana/play_billing');

  /// What of [products] can be bought here; none when Play can't be reached.
  Future<List<PlayOffer>> offers(List<String> products) async {
    try {
      final found = await _channel.invokeListMethod<Map<Object?, Object?>>('products', {'products': products});
      return [...?found?.map(PlayOffer.fromMap)];
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  /// Opens Play's purchase screen for the account with the id [account], and
  /// returns the purchase tokens: none if the person changed their mind.
  Future<List<String>> buy(PlayOffer offer, String account) async {
    try {
      final tokens = await _channel.invokeListMethod<String>('buy', {
        'product': offer.productId,
        'offer': offer.offerToken,
        'account': account,
      });
      return tokens ?? const [];
    } on PlatformException catch (e) {
      throw PlayException(owned: e.code == 'owned');
    } on MissingPluginException {
      throw const PlayException();
    }
  }

  /// The tokens of the subscriptions this Play account holds.
  Future<List<String>> purchases() async {
    try {
      return await _channel.invokeListMethod<String>('purchases') ?? const [];
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }
}

final googlePlayProvider = Provider((_) => const GooglePlay());
