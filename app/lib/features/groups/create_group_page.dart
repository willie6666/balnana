import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/known_groups.dart';
import '../../data/providers.dart';
import '../../ui/colors.dart';
import '../../ui/money.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/form_page.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _emoji = TextEditingController();
  final _currency = TextEditingController();
  final _me = TextEditingController();
  final _others = <TextEditingController>[TextEditingController()];

  /// The field "Add person" just made, which takes the focus.
  TextEditingController? _added;
  Color _color = BalnanaColors.palette.first;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currency.text.isEmpty) _currency.text = localCurrency(Localizations.localeOf(context));
  }

  @override
  void dispose() {
    for (final c in [_name, _emoji, _currency, _me, ..._others]) {
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
    final names = [_me.text.trim(), ..._others.map((c) => c.text.trim()).where((n) => n.isNotEmpty)];
    setState(() => _busy = true);
    try {
      final group = await api.createGroup(
        name: _name.text.trim(),
        emoji: _emoji.text.trim().isEmpty ? null : _emoji.text.trim(),
        color: _color.toARGB32() & 0xFFFFFF,
        currency: currency,
        minorDigits: defaultMinorDigits(currency),
        members: names,
      );
      // The creator is the first member.
      ref.read(knownGroupsProvider.notifier).add(group.token, memberId: group.members.first.id);
      ref.invalidate(summariesProvider);
      if (mounted) context.pushReplacement('/g/${group.token}');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
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
                  SizedBox(
                    width: 72,
                    child: TextFormField(
                      controller: _emoji,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                      inputFormatters: [LengthLimitingTextInputFormatter(8)],
                      decoration: InputDecoration(hintText: l10n.groupEmojiHint),
                    ),
                  ),
                  const SizedBox(width: BSpace.s12),
                  Expanded(
                    child: TextFormField(
                      controller: _name,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [LengthLimitingTextInputFormatter(100)],
                      decoration: InputDecoration(labelText: l10n.groupName, hintText: l10n.groupNameHint),
                      validator: _required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BSpace.s16),
              TextFormField(
                controller: _currency,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(labelText: l10n.groupCurrency, helperText: l10n.groupCurrencyHelp),
                validator: (v) =>
                    RegExp(r'^[A-Za-z]{3}$').hasMatch((v ?? '').trim()) ? null : l10n.errorInvalidCurrency,
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
                decoration: InputDecoration(labelText: l10n.groupYourName, prefixIcon: const Icon(Icons.person)),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
