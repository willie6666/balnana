import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/currencies.dart';
import '../../core/l10n.dart';
import '../money.dart';
import '../tokens.dart';

/// A group's currency code: typed, or picked from [currencies].
class CurrencyField extends StatelessWidget {
  const CurrencyField({super.key, required this.controller});

  final TextEditingController controller;

  static final _code = RegExp(r'^[A-Za-z]{3}$');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final name = currencies[controller.text.trim().toUpperCase()];
        return TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: InputDecoration(
            labelText: l10n.groupCurrency,
            helperText: name == null ? l10n.groupCurrencyHelp : l10n.groupCurrencyHelpNamed(name),
            helperMaxLines: 3,
            suffixIcon: IconButton(
              tooltip: l10n.currencyChoose,
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: () async {
                final picked = await showCurrencyPicker(context, current: controller.text.trim().toUpperCase());
                if (picked != null) {
                  controller.value = TextEditingValue(
                    text: picked,
                    selection: TextSelection.collapsed(offset: picked.length),
                  );
                }
              },
            ),
          ),
          validator: (v) => _code.hasMatch((v ?? '').trim()) ? null : l10n.errorInvalidCurrency,
        );
      },
    );
  }
}

/// A searchable list of [currencies]; returns the code picked. Three letters
/// that aren't in the list can be used as typed.
Future<String?> showCurrencyPicker(BuildContext context, {required String current}) =>
    showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _CurrencyPicker(current: current),
    );

class _CurrencyPicker extends StatefulWidget {
  const _CurrencyPicker({required this.current});

  final String current;

  @override
  State<_CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<_CurrencyPicker> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _pick(String code) => Navigator.of(context).pop(code);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context);
    final query = _query.text.trim().toLowerCase();
    final typed = RegExp(r'^[a-z]{3}$').hasMatch(query) ? query.toUpperCase() : null;
    final List<String> suggested;
    final List<String> all;
    if (query.isEmpty) {
      suggested = {
        if (widget.current.isNotEmpty) widget.current,
        localCurrency(locale),
        'USD',
        'EUR',
      }.toList();
      all = currencies.keys.toList();
    } else {
      suggested = [];
      all = [
        for (final MapEntry(key: code, value: name) in currencies.entries)
          if (code.toLowerCase().contains(query) || name.toLowerCase().contains(query)) code,
      ];
      // An exact code first.
      if (typed != null && all.remove(typed)) all.insert(0, typed);
    }
    final useTyped = typed != null && !currencies.containsKey(typed);

    Widget tile(String code) {
      final name = currencies[code];
      final symbol = currencySymbol(locale.toLanguageTag(), code).trim();
      final selected = code == widget.current;
      return ListTile(
        selected: selected,
        leading: SizedBox(
          width: 48,
          child: Text(code, style: text.titleMedium),
        ),
        title: Text(name ?? code),
        trailing: selected ? const Icon(Icons.check) : (symbol == code ? null : Text(symbol, style: text.bodyLarge)),
        onTap: () => _pick(code),
      );
    }

    Widget header(String label) => Padding(
      padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s16, BSpace.s16, BSpace.s4),
      child: Text(label, style: text.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
              child: Text(l10n.currencyChoose, style: text.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s12, BSpace.s16, BSpace.s8),
              child: SearchBar(
                controller: _query,
                hintText: l10n.currencySearchHint,
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (typed != null) {
                    _pick(typed);
                  } else if (all.length == 1) {
                    _pick(all.single);
                  }
                },
                trailing: [
                  if (_query.text.isNotEmpty)
                    IconButton(
                      tooltip: l10n.commonClear,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(_query.clear),
                    ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (useTyped)
                    SliverToBoxAdapter(
                      child: ListTile(
                        leading: const Icon(Icons.keyboard),
                        title: Text(l10n.currencyUseTyped(typed)),
                        onTap: () => _pick(typed),
                      ),
                    ),
                  if (suggested.isNotEmpty) ...[
                    SliverToBoxAdapter(child: header(l10n.currencySuggested)),
                    SliverList.builder(itemCount: suggested.length, itemBuilder: (context, i) => tile(suggested[i])),
                    SliverToBoxAdapter(child: header(l10n.currencyAll)),
                  ],
                  SliverList.builder(itemCount: all.length, itemBuilder: (context, i) => tile(all[i])),
                  if (all.isEmpty && !useTyped)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(BSpace.s24),
                        child: Text(l10n.currencyNoMatch, textAlign: TextAlign.center, style: text.bodyMedium),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
