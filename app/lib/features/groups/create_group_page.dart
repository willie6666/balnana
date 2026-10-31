import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../core/session.dart';
import '../../data/api.dart';
import '../../data/known_groups.dart';
import '../../data/providers.dart';
import '../../ui/colors.dart';
import '../../ui/money.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/currency_field.dart';
import '../../ui/widgets/form_page.dart';
import '../../ui/widgets/icon_picker.dart';
import '../../ui/widgets/symbol_field.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _currency = TextEditingController();
  final _symbol = TextEditingController(text: r'$');
  final _me = TextEditingController();
  final _others = <TextEditingController>[TextEditingController()];

  /// The field "Add person" just made, which takes the focus.
  TextEditingController? _added;
  Color _color = brandSeed;

  /// Empty for none. Until one is chosen, it follows the name.
  String _icon = '';
  bool _iconChosen = false;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currency.text.isEmpty) _currency.text = localCurrency(Localizations.localeOf(context)) ?? '';
    if (_me.text.isEmpty) _me.text = ref.read(currentAccountProvider).value?.name ?? '';
  }

  @override
  void dispose() {
    for (final c in [_name, _currency, _symbol, _me, ..._others]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _create() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final api = ref.read(balnanaApiProvider);
    if (api == null) return;
    final currency = _currency.text.trim().toUpperCase();
    final symbol = _symbol.text.trim();
    final names = [_me.text.trim(), ..._others.map((c) => c.text.trim()).where((n) => n.isNotEmpty)];
    // Taken now: the page may be closed, or another server chosen, before
    // the answer comes, and the new group's link must not be lost with it.
    final from = ref.read(identityProvider);
    final signedIn = ref.read(signedInProvider);
    final known = ref.read(knownGroupsProvider.notifier);
    final container = ProviderScope.containerOf(context, listen: false);
    setState(() => _busy = true);
    try {
      final group = await api.createGroup(
        name: _name.text.trim(),
        emoji: _icon.isEmpty ? null : _icon,
        color: _color.toARGB32() & 0xFFFFFF,
        currency: currency,
        symbol: symbol.isEmpty ? null : symbol,
        minorDigits: defaultMinorDigits(currency),
        members: names,
      );
      // The creator is the first member. A signed-in account keeps its groups
      // on the server instead.
      if (from.server case final server? when !signedIn) {
        known.addOn(server, group.token, memberId: group.members.first.id);
      }
      container.invalidate(summariesProvider);
      if (mounted && ref.read(serverUrlProvider) == from.server) context.go('/g/${group.token}');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
  }

  void _suggestIcon(String name) {
    if (_iconChosen) return;
    final icon = suggestIcon(name) ?? '';
    if (icon != _icon) setState(() => _icon = icon);
  }

  String? _required(String? value) => (value ?? '').trim().isEmpty ? context.l10n.errorRequired : null;

  String? _uniqueName(String? value, TextEditingController self) {
    final name = (value ?? '').trim().toLowerCase();
    if (name.isEmpty) return null;
    final all = [_me, ..._others];
    for (final c in all) {
      if (c == self) break;
      if (c.text.trim().toLowerCase() == name) return context.l10n.errorDuplicateName;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FormPage(
      title: l10n.groupNew,
      actions: [
        TextButton.icon(
          onPressed: () => context.pushReplacement('/groups/import'),
          icon: const Icon(Icons.upload_file),
          label: Text(l10n.importAction),
        ),
      ],
      submitLabel: l10n.groupCreate,
      onSubmit: _create,
      busy: _busy,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconField(
                    icon: _icon,
                    color: _color,
                    allowNone: true,
                    onChanged: (icon) => setState(() {
                      _icon = icon;
                      _iconChosen = true;
                    }),
                  ),
                  const SizedBox(width: BSpace.s12),
                  Expanded(
                    child: TextFormField(
                      controller: _name,
                      autofocus: true,
                      onChanged: _suggestIcon,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [LengthLimitingTextInputFormatter(100)],
                      decoration: InputDecoration(labelText: l10n.groupName, hintText: l10n.groupNameHint),
                      validator: _required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BSpace.s16),
              CurrencyField(controller: _currency),
              const SizedBox(height: BSpace.s16),
              ListenableBuilder(
                listenable: _currency,
                builder: (context, _) {
                  final currency = _currency.text.trim().toUpperCase();
                  return SymbolField(
                    controller: _symbol,
                    currency: currency,
                    digits: defaultMinorDigits(currency),
                  );
                },
              ),
              FormSection(l10n.groupColor),
              ColorPicker(
                colors: BalnanaColors.palette,
                selected: _color,
                onSelected: (c) => setState(() => _color = c),
              ),
              FormSection(l10n.groupPeople),
              TextFormField(
                controller: _me,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                decoration: InputDecoration(
                  labelText: l10n.groupYourName,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: _required,
              ),
              for (final (i, c) in _others.indexed) ...[
                const SizedBox(height: BSpace.s12),
                TextFormField(
                  key: ObjectKey(c),
                  controller: c,
                  autofocus: identical(c, _added),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                  decoration: InputDecoration(
                    labelText: l10n.groupPersonName(i + 2),
                    prefixIcon: const Icon(Icons.person_outline),
                    suffixIcon: IconButton(
                      tooltip: l10n.commonRemove,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _others.remove(c);
                        c.dispose();
                      }),
                    ),
                  ),
                  validator: (v) => _uniqueName(v, c),
                ),
              ],
              const SizedBox(height: BSpace.s12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => setState(() => _others.add(_added = TextEditingController())),
                  icon: const Icon(Icons.person_add_alt),
                  label: Text(l10n.groupAddPerson),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: BSpace.s4),
                child: Text(
                  l10n.groupPeopleHelp,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
