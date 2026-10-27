import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../money.dart';

/// The symbol a group's amounts start with: typed, or picked from the usual
/// ones for [currency]. Left empty, amounts use the currency's own symbol.
class SymbolField extends StatelessWidget {
  const SymbolField({super.key, required this.controller, required this.currency, required this.digits});

  final TextEditingController controller;
  final String currency;
  final int digits;

  /// As many characters as the server keeps.
  static const maxLength = 8;

  List<String> _choices(String locale) {
    final seen = <String>{};
    return [
      for (final s in ['\$', currencySymbol(locale, currency).trim(), currency, '€', '£', '¥'])
        if (s.isNotEmpty && seen.add(s)) s,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final symbol = controller.text.trim();
        final example = formatMoney(
          context,
          BigInt.from(123450) * BigInt.from(10).pow(digits) ~/ BigInt.from(100),
          digits,
          currency,
          symbol: symbol,
        );
        return TextFormField(
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\n')),
            LengthLimitingTextInputFormatter(maxLength),
          ],
          decoration: InputDecoration(
            labelText: l10n.groupSymbol,
            hintText: currencySymbol(locale, currency).trim(),
            helperText: l10n.groupSymbolExample(example),
            suffixIcon: PopupMenuButton<String>(
              tooltip: l10n.groupSymbolChoose,
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (s) => controller.value = TextEditingValue(
                text: s,
                selection: TextSelection.collapsed(offset: s.length),
              ),
              itemBuilder: (context) => [
                for (final s in _choices(locale))
                  CheckedPopupMenuItem(value: s, checked: s == symbol, child: Text(s)),
              ],
            ),
          ),
        );
      },
    );
  }
}
