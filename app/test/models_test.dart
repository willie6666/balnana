import 'package:balnana/core/money.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _expense([Map<String, Object?> extra = const {}]) => {
  'id': 'e1',
  'kind': 'expense',
  'title': 'Lunch',
  'amount': '10.00',
  'occurredAt': '2026-01-02T10:00:00Z',
  'splitMethod': 'equal',
  'payers': [
    {'memberId': 'a', 'amount': '10.00'},
  ],
  'splits': [
    {'memberId': 'a', 'amount': '10.00'},
  ],
  'createdAt': '2026-01-02T10:00:00Z',
  'updatedAt': '2026-01-02T10:00:00Z',
  'version': 1,
  ...extra,
};

void main() {
  test('what a newer server sends still reads, and is left alone', () {
    expect(Expense.fromJson(_expense(), 2).editable, isTrue);

    final kind = Expense.fromJson(_expense({'kind': 'gift'}), 2);
    expect(kind.kind, ExpenseKind.unknown);
    expect(kind.editable, isFalse);

    final method = Expense.fromJson(_expense({'splitMethod': 'percent'}), 2);
    expect(method.splitMethod, SplitMethod.unknown);
    expect(method.editable, isFalse);
  });

  test('client keys are random UUIDs', () {
    final key = newClientKey();
    expect(key, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    expect(newClientKey(), isNot(key));
  });
}
