import 'package:balnana/core/errors.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads an import preview', () {
    final p = ImportPreview.fromJson({
      'currency': 'TWD',
      'minorDigits': 2,
      'members': [
        {'name': 'Ana', 'balance': '12.50'},
        {'name': 'Ben', 'balance': '-12.50'},
      ],
      'expenses': 3,
      'payments': 1,
      'skipped': 0,
      'from': '2026-01-02T10:00:00Z',
    });
    expect(p.members.map((m) => (m.name, m.balance)), [('Ana', BigInt.from(1250)), ('Ben', BigInt.from(-1250))]);
    expect(p.from, DateTime.utc(2026, 1, 2, 10));
    expect(p.to, isNull);
  });

  test('says which line of an import failed and why', () {
    final l10n = AppLocalizationsEn();
    String message(String code, Map<String, Object?> params) =>
        errorMessage(l10n, ApiException(code, status: 400, params: params));
    expect(message('import_row', {'line': 7, 'problem': 'transfer'}), l10n.errorImportRow(7, l10n.errorImportTransfer));
    expect(message('import_row', {'line': 3, 'problem': 'invalid_title'}), l10n.errorImportRow(3, l10n.errorInvalidTitle));
    expect(message('import_file', {'problem': 'currency'}), l10n.errorImportCurrency);
    expect(message('import_file', {'problem': 'header'}), l10n.errorImportFile);
  });
}
