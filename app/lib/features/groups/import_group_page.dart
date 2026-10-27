import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/known_groups.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/money.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/form_page.dart';
import '../../ui/widgets/member_avatar.dart';

/// Creates a group from another app's export: pick the file, check what it
/// holds, say who you are, import.
class ImportGroupPage extends ConsumerStatefulWidget {
  const ImportGroupPage({super.key});

  @override
  ConsumerState<ImportGroupPage> createState() => _ImportGroupPageState();
}

class _ImportGroupPageState extends ConsumerState<ImportGroupPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  Uint8List? _file;
  ImportPreview? _preview;
  String? _me;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final l10n = context.l10n;
    final api = ref.read(balnanaApiProvider);
    if (api == null) return;
    final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['csv']);
    if (picked == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final bytes = await picked.readAsBytes();
      final preview = await api.previewImport(bytes);
      if (!mounted) return;
      final name = picked.name.replaceFirst(RegExp(r'\.csv$', caseSensitive: false), '').trim();
      final account = ref.read(currentAccountProvider).value?.name.toLowerCase();
      setState(() {
        _file = bytes;
        _preview = preview;
        _name.text = name.length > 100 ? name.substring(0, 100) : name;
        _me = preview.members.where((m) => m.name.toLowerCase() == account).firstOrNull?.name;
        _busy = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _file = null;
        _preview = null;
        _error = errorMessage(l10n, e);
        _busy = false;
      });
    }
  }

  Future<void> _import() async {
    final l10n = context.l10n;
    final api = ref.read(balnanaApiProvider);
    final file = _file, me = _me;
    if (api == null || file == null || !_form.currentState!.validate()) return;
    if (me == null) {
      setState(() => _error = l10n.errorImportMe);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final group = await api.importGroup(file, name: _name.text.trim(), me: me, untitled: l10n.importUntitled);
      // A signed-in account keeps its groups on the server instead.
      if (!ref.read(signedInProvider)) {
        final mine = group.members.where((m) => m.name.toLowerCase() == me.toLowerCase()).firstOrNull;
        ref.read(knownGroupsProvider.notifier).add(group.token, memberId: mine?.id);
      }
      ref.invalidate(summariesProvider);
      if (mounted) context.go('/g/${group.token}');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final preview = _preview;
    return FormPage(
      title: l10n.importTitle,
      submitLabel: preview == null ? null : l10n.importAction,
      onSubmit: _import,
      busy: _busy,
      children: [
        Text(l10n.importIntro, style: muted),
        const SizedBox(height: BSpace.s16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _pick,
            icon: const Icon(Icons.upload_file),
            label: Text(preview == null ? l10n.importChooseFile : l10n.importChooseOther),
          ),
        ),
        if (_busy && preview == null) ...[
          const SizedBox(height: BSpace.s16),
          Row(
            children: [
              const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: BSpace.s12),
              Text(l10n.importReading, style: muted),
            ],
          ),
        ],
        if (_error case final error?) ...[
          const SizedBox(height: BSpace.s16),
          Card.filled(
            color: theme.colorScheme.errorContainer,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(BSpace.s16),
              child: Text(error, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
            ),
          ),
        ],
        if (preview != null) ..._previewParts(context, preview),
      ],
    );
  }

  List<Widget> _previewParts(BuildContext context, ImportPreview preview) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final muted = text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final (from, to) = (preview.from, preview.to);
    return [
      const SizedBox(height: BSpace.s24),
      Form(
        key: _form,
        child: TextFormField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          decoration: InputDecoration(labelText: l10n.groupName),
          validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
        ),
      ),
      const SizedBox(height: BSpace.s16),
      Text(l10n.importSummary(preview.expenses, preview.payments), style: text.titleMedium),
      if (from != null && to != null)
        Text(
          l10n.importDates(
            DateFormat.yMMMd(locale).format(from.toLocal()),
            DateFormat.yMMMd(locale).format(to.toLocal()),
          ),
          style: muted,
        ),
      Text(l10n.importCurrency(preview.currency), style: muted),
      if (preview.skipped > 0) Text(l10n.importSkipped(preview.skipped), style: muted),
      FormSection(l10n.importWhoAreYou),
      RadioGroup<String>(
        groupValue: _me,
        onChanged: (v) => setState(() {
          _me = v;
          _error = null;
        }),
        child: Column(
          children: [
            for (final m in preview.members)
              RadioListTile<String>(
                value: m.name,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: MemberAvatar(member: Member(id: m.name, name: m.name, balance: m.balance)),
                title: Text(m.name),
                subtitle: Text(
                  formatMoney(context, m.balance, preview.minorDigits, preview.currency, signed: true),
                  style: text.bodyMedium?.copyWith(color: balanceColor(context, m.balance)),
                ),
              ),
          ],
        ),
      ),
    ];
  }
}
