import 'json_fields.dart';

/// How much of a limit is used. A null [limit] means there is none.
class PlanUsage {
  const PlanUsage({this.limit, this.used = 0});

  factory PlanUsage.fromJson(Object? data) {
    final json = jsonObject(data);
    return PlanUsage(
      limit: optionalField<num>(json, 'limit')?.toInt(),
      used: optionalField<num>(json, 'used')?.toInt() ?? 0,
    );
  }

  final int? limit;
  final int used;
}

/// What the server sells on Google Play, for an account that can buy it.
class PlayBilling {
  const PlayBilling({
    required this.accountId,
    required this.packageName,
    this.products = const [],
    this.subscribed = const [],
    this.onHold = const [],
  });

  factory PlayBilling.fromJson(Object? data) {
    final json = jsonObject(data);
    return PlayBilling(
      accountId: requiredField(json, 'accountId'),
      packageName: requiredField(json, 'packageName'),
      products: [...?optionalField<List<Object?>>(json, 'products')?.whereType<String>()],
      subscribed: [...?optionalField<List<Object?>>(json, 'subscribed')?.whereType<String>()],
      onHold: [...?optionalField<List<Object?>>(json, 'onHold')?.whereType<String>()],
    );
  }

  /// Goes with a purchase, for Google to say whose it is.
  final String accountId;
  final String packageName;
  final List<String> products;

  /// The products the account has a running subscription to.
  final List<String> subscribed;

  /// The products the account still holds but Google stopped charging for
  /// after a failed payment. Buying again would pay twice once it is fixed.
  final List<String> onHold;

  /// The products the account holds, whether or not they give a plan now.
  List<String> get held => [...subscribed, ...onHold];
}

/// The signed-in account's plan and how much of it is used.
class MyPlan {
  const MyPlan({
    required this.planName,
    this.paid = false,
    this.expiresAt,
    required this.joinedGroups,
    required this.sponsoredGroups,
    this.receiptsPerGroup,
    this.recurringPerGroup,
    this.membersPerGroup,
    this.reminders = false,
    this.play,
    this.paypal,
  });

  factory MyPlan.fromJson(Object? data) {
    final json = jsonObject(data);
    return MyPlan(
      planName: requiredField(json, 'planName'),
      paid: optionalField<bool>(json, 'paid') ?? false,
      expiresAt: optionalDateField(json, 'expiresAt'),
      joinedGroups: PlanUsage.fromJson(json['joinedGroups']),
      sponsoredGroups: PlanUsage.fromJson(json['sponsoredGroups']),
      receiptsPerGroup: optionalField<num>(json, 'receiptsPerGroup')?.toInt(),
      recurringPerGroup: optionalField<num>(json, 'recurringPerGroup')?.toInt(),
      membersPerGroup: optionalField<num>(json, 'membersPerGroup')?.toInt(),
      reminders: optionalField<bool>(json, 'reminders') ?? false,
      play: json['play'] == null ? null : PlayBilling.fromJson(json['play']),
      paypal: json['paypal'] == null ? null : PayPalBilling.fromJson(json['paypal']),
    );
  }

  final String planName;

  /// Whether an entitlement gives the plan, rather than the server's default.
  final bool paid;

  /// When the plan ends; null when it doesn't.
  final DateTime? expiresAt;
  final PlanUsage joinedGroups;
  final PlanUsage sponsoredGroups;

  /// Null means no limit.
  final int? receiptsPerGroup;

  /// Null means no limit.
  final int? recurringPerGroup;

  /// Null means no limit.
  final int? membersPerGroup;

  /// Whether groups sharing the plan can send payment reminders as
  /// notifications.
  final bool reminders;

  /// Null when the server doesn't sell on Google Play.
  final PlayBilling? play;

  /// Null when nothing can be bought through PayPal.
  final PayPalBilling? paypal;
}

/// What the account can buy through PayPal.
class PayPalBilling {
  const PayPalBilling({required this.offers, this.subscribed = const []});

  factory PayPalBilling.fromJson(Object? data) {
    final json = jsonObject(data);
    return PayPalBilling(
      offers: [
        for (final o in optionalField<List<Object?>>(json, 'offers') ?? const []) PayPalOffer.fromJson(o),
      ],
      subscribed: [...?optionalField<List<Object?>>(json, 'subscribed')?.whereType<String>()],
    );
  }

  final List<PayPalOffer> offers;

  /// The products the account has a subscription to.
  final List<String> subscribed;
}

/// A plan sold through PayPal, as a subscription or a one-off payment.
class PayPalOffer {
  const PayPalOffer({
    required this.product,
    required this.planName,
    required this.days,
    this.subscription = false,
    this.amount,
    this.currency,
  });

  factory PayPalOffer.fromJson(Object? data) {
    final json = jsonObject(data);
    return PayPalOffer(
      product: requiredField(json, 'product'),
      planName: requiredField(json, 'planName'),
      days: requiredField<num>(json, 'days').toInt(),
      subscription: optionalField<bool>(json, 'subscription') ?? false,
      amount: optionalField(json, 'amount'),
      currency: optionalField(json, 'currency'),
    );
  }

  /// What to ask the server to check out.
  final String product;
  final String planName;

  /// How long one payment lasts.
  final int days;
  final bool subscription;

  /// What a one-off payment costs; PayPal shows a subscription's price.
  final String? amount;
  final String? currency;
}

/// The limits that apply to a group and how much of them is used.
class GroupPlan {
  const GroupPlan({
    required this.planName,
    this.canSponsor = false,
    required this.members,
    required this.receipts,
    required this.recurring,
    this.reminders = false,
    this.sponsorMemberId,
  });

  factory GroupPlan.fromJson(Object? data) {
    final json = jsonObject(data);
    return GroupPlan(
      planName: requiredField(json, 'planName'),
      canSponsor: optionalField<bool>(json, 'canSponsor') ?? false,
      members: PlanUsage.fromJson(json['members']),
      receipts: PlanUsage.fromJson(json['receipts']),
      recurring: PlanUsage.fromJson(json['recurring']),
      reminders: optionalField<bool>(json, 'reminders') ?? false,
      sponsorMemberId: optionalField(json, 'sponsorMemberId'),
    );
  }

  final String planName;

  /// Whether the signed-in account could share its plan with the group.
  final bool canSponsor;
  final PlanUsage members;
  final PlanUsage receipts;
  final PlanUsage recurring;

  /// Whether the group can send payment reminders as notifications.
  final bool reminders;

  /// The member whose plan covers the group, if any.
  final String? sponsorMemberId;
}

/// What a plan allows. Null means no limit.
class PlanLimits {
  const PlanLimits({
    this.receiptsPerGroup,
    this.recurringPerGroup,
    this.joinedGroups,
    this.membersPerGroup,
    this.sponsoredGroups,
    this.reminders = false,
  });

  factory PlanLimits.fromJson(Object? data) {
    final json = jsonObject(data);
    return PlanLimits(
      receiptsPerGroup: optionalField<num>(json, 'receiptsPerGroup')?.toInt(),
      recurringPerGroup: optionalField<num>(json, 'recurringPerGroup')?.toInt(),
      joinedGroups: optionalField<num>(json, 'joinedGroups')?.toInt(),
      membersPerGroup: optionalField<num>(json, 'membersPerGroup')?.toInt(),
      sponsoredGroups: optionalField<num>(json, 'sponsoredGroups')?.toInt(),
      reminders: optionalField<bool>(json, 'reminders') ?? false,
    );
  }

  final int? receiptsPerGroup;
  final int? recurringPerGroup;
  final int? joinedGroups;
  final int? membersPerGroup;
  final int? sponsoredGroups;

  /// Whether its groups can send payment reminders as notifications.
  final bool reminders;

  Map<String, Object?> toJson() => {
    'receiptsPerGroup': ?receiptsPerGroup,
    'recurringPerGroup': ?recurringPerGroup,
    'joinedGroups': ?joinedGroups,
    'membersPerGroup': ?membersPerGroup,
    'sponsoredGroups': ?sponsoredGroups,
    'reminders': reminders,
  };
}

/// A plan the administrator set up.
class Plan {
  const Plan({
    required this.id,
    required this.name,
    this.rank = 0,
    this.isDefault = false,
    this.limits = const PlanLimits(),
  });

  factory Plan.fromJson(Object? data) {
    final json = jsonObject(data);
    return Plan(
      id: requiredField(json, 'id'),
      name: requiredField(json, 'name'),
      rank: optionalField<num>(json, 'rank')?.toInt() ?? 0,
      isDefault: optionalField<bool>(json, 'isDefault') ?? false,
      limits: PlanLimits.fromJson(json['limits']),
    );
  }

  final String id;
  final String name;

  /// When someone has several plans, the highest counts.
  final int rank;

  /// The plan for groups without a sponsor.
  final bool isDefault;
  final PlanLimits limits;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'rank': rank,
    'isDefault': isDefault,
    'limits': limits.toJson(),
  };
}

/// What a payment has to be for to give a plan.
class PlanProduct {
  const PlanProduct({
    required this.provider,
    required this.product,
    required this.planId,
    required this.days,
    this.minAmount,
    this.currency,
    this.withoutTrial,
  });

  factory PlanProduct.fromJson(Object? data) {
    final json = jsonObject(data);
    return PlanProduct(
      provider: requiredField(json, 'provider'),
      product: requiredField(json, 'product'),
      planId: requiredField(json, 'planId'),
      days: (requiredField<num>(json, 'days')).toInt(),
      minAmount: optionalField(json, 'minAmount'),
      currency: optionalField(json, 'currency'),
      withoutTrial: optionalField(json, 'withoutTrial'),
    );
  }

  /// "kofi" or "play".
  final String provider;

  /// The Ko-fi tier or Play product; empty for any Ko-fi payment of at least
  /// [minAmount].
  final String product;
  final String planId;
  final int days;

  /// A decimal amount such as "5.00".
  final String? minAmount;
  final String? currency;

  /// For a PayPal plan with a free trial, the same plan without one, which
  /// accounts that have had a trial subscribe to.
  final String? withoutTrial;

  Map<String, Object?> toJson() => {
    'provider': provider,
    'product': product,
    'planId': planId,
    'days': days,
    'minAmount': ?minAmount,
    'currency': ?currency,
    'withoutTrial': ?withoutTrial,
  };
}

/// Everything the administrator can sell and what it allows.
class PlanCatalog {
  const PlanCatalog({
    this.plans = const [],
    this.products = const [],
    this.unverifiedPlanId,
    this.verifiedPlanId,
  });

  factory PlanCatalog.fromJson(Object? data) {
    final json = jsonObject(data);
    return PlanCatalog(
      unverifiedPlanId: optionalField<String>(json, 'unverifiedPlanId'),
      verifiedPlanId: optionalField<String>(json, 'verifiedPlanId'),
      plans: [
        for (final p in optionalField<List<Object?>>(json, 'plans') ?? const <Object?>[]) Plan.fromJson(p),
      ],
      products: [
        for (final p in optionalField<List<Object?>>(json, 'products') ?? const <Object?>[])
          PlanProduct.fromJson(p),
      ],
    );
  }

  final List<Plan> plans;
  final List<PlanProduct> products;
  final String? unverifiedPlanId;
  final String? verifiedPlanId;

  PlanCatalog copyWith({
    List<Plan>? plans,
    List<PlanProduct>? products,
    String? unverifiedPlanId,
    String? verifiedPlanId,
  }) => PlanCatalog(
    plans: plans ?? this.plans,
    products: products ?? this.products,
    unverifiedPlanId: unverifiedPlanId ?? this.unverifiedPlanId,
    verifiedPlanId: verifiedPlanId ?? this.verifiedPlanId,
  );

  Map<String, Object?> toJson() => {
    'unverifiedPlanId': ?unverifiedPlanId,
    'verifiedPlanId': ?verifiedPlanId,
    'plans': [for (final p in plans) p.toJson()],
    'products': [for (final p in products) p.toJson()],
  };
}

/// A plan an account was given, by an administrator or a payment.
class Entitlement {
  const Entitlement({
    required this.id,
    required this.planId,
    required this.planName,
    required this.source,
    this.note,
    required this.startsAt,
    this.expiresAt,
    this.revokedAt,
    required this.createdAt,
  });

  factory Entitlement.fromJson(Object? data) {
    final json = jsonObject(data);
    return Entitlement(
      id: requiredField(json, 'id'),
      planId: requiredField(json, 'planId'),
      planName: requiredField(json, 'planName'),
      source: requiredField(json, 'source'),
      note: optionalField(json, 'note'),
      startsAt: dateField(json, 'startsAt'),
      expiresAt: optionalDateField(json, 'expiresAt'),
      revokedAt: optionalDateField(json, 'revokedAt'),
      createdAt: dateField(json, 'createdAt'),
    );
  }

  final String id;
  final String planId;
  final String planName;

  /// "admin", "kofi" or "play".
  final String source;
  final String? note;
  final DateTime startsAt;

  /// Null when it doesn't end.
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final DateTime createdAt;

  /// Whether it still counts at [now].
  bool activeAt(DateTime now) =>
      revokedAt == null && !startsAt.isAfter(now) && (expiresAt == null || expiresAt!.isAfter(now));
}

/// A payment a provider told the server about.
class AdminPayment {
  const AdminPayment({
    required this.id,
    required this.provider,
    required this.kind,
    required this.state,
    this.email,
    this.payerName,
    this.amount,
    this.currency,
    this.product,
    this.items = const [],
    this.planId,
    this.days,
    this.userId,
    this.userName,
    required this.paidAt,
    this.reference,
  });

  factory AdminPayment.fromJson(Object? data) {
    final json = jsonObject(data);
    return AdminPayment(
      id: requiredField(json, 'id'),
      provider: requiredField(json, 'provider'),
      kind: requiredField(json, 'kind'),
      state: requiredField(json, 'state'),
      email: optionalField(json, 'email'),
      payerName: optionalField(json, 'payerName'),
      amount: optionalField(json, 'amount'),
      currency: optionalField(json, 'currency'),
      product: optionalField(json, 'product'),
      items: [
        for (final item in optionalField<List<Object?>>(json, 'items') ?? const [])
          PaymentItem.fromJson(item),
      ],
      planId: optionalField(json, 'planId'),
      days: optionalField<num>(json, 'days')?.toInt(),
      userId: optionalField(json, 'userId'),
      userName: optionalField(json, 'userName'),
      paidAt: dateField(json, 'paidAt'),
      reference: optionalField(json, 'reference'),
    );
  }

  final String id;
  final String provider;

  /// The provider's word for it, such as "Donation" or "Subscription".
  final String kind;

  /// "applied", "unclaimed" or "unmatched".
  final String state;
  final String? email;
  final String? payerName;
  final String? amount;
  final String? currency;
  final String? product;
  final List<PaymentItem> items;
  final String? planId;
  final int? days;
  final String? userId;
  final String? userName;
  final DateTime paidAt;

  /// The provider's ID for the transaction.
  final String? reference;
}

class PaymentItem {
  const PaymentItem({required this.product, required this.quantity});

  factory PaymentItem.fromJson(Object? data) {
    final json = jsonObject(data);
    return PaymentItem(
      product: requiredField(json, 'product'),
      quantity: requiredField<num>(json, 'quantity').toInt(),
    );
  }

  final String product;
  final int quantity;
}
