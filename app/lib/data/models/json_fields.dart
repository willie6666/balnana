import '../../core/money.dart';

/// Reads one field of a JSON object, or throws [FormatException].
T requiredField<T>(Map<String, Object?> json, String key) {
  final v = json[key];
  if (v is! T) throw FormatException('field $key is missing or has the wrong type');
  return v;
}

T? optionalField<T>(Map<String, Object?> json, String key) {
  final v = json[key];
  return v is T ? v : null;
}

Map<String, Object?> jsonObject(Object? json) {
  if (json is! Map<String, Object?>) throw const FormatException('expected an object');
  return json;
}

List<Map<String, Object?>> objectList(Map<String, Object?> json, String key) =>
    requiredField<List<Object?>>(json, key).map(jsonObject).toList();

DateTime dateField(Map<String, Object?> json, String key) {
  final t = DateTime.tryParse(requiredField<String>(json, key));
  if (t == null) throw FormatException('field $key is not a date');
  return t;
}

DateTime? optionalDateField(Map<String, Object?> json, String key) =>
    json[key] == null ? null : dateField(json, key);

int currencyDigits(Map<String, Object?> json) {
  final digits = requiredField<int>(json, 'minorDigits');
  if (digits < 0 || digits > maxDigits) throw const FormatException('invalid minorDigits');
  return digits;
}

/// API totals and balances may exceed the limit for a single transaction.
BigInt parseMoneyField(String value, int digits, String key) {
  try {
    return parseAmount(value, digits, total: true);
  } on MoneyException {
    throw FormatException('field $key is not a money amount');
  }
}

BigInt moneyField(Map<String, Object?> json, String key, int digits) =>
    parseMoneyField(requiredField<String>(json, key), digits, key);
