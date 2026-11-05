import 'dart:convert';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/money.dart';
import '../../core/offline_cache.dart';
import '../../core/server.dart';
import '../../core/session.dart';
import '../../data/api.dart';
import '../../data/categories.dart';
import '../../data/models.dart';
import '../../data/pending_writes.dart';
import '../../data/providers.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/amount_field.dart';
import '../../ui/widgets/currency_field.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/form_page.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/member_picker.dart';
import '../group/group_page.dart';
import '../group/recurring_page.dart';
import 'location.dart';
import 'receipt.dart';

part 'details_fields.dart';
part 'editor_form.dart';
part 'foreign_field.dart';
part 'paid_by.dart';
part 'repeat_field.dart';
part 'split_rows.dart';

/// Adds an expense to a group, or edits one when [expenseId] is set, or
/// edits a recurring expense when [recurringId] is.
class ExpenseEditorPage extends ConsumerStatefulWidget {
  const ExpenseEditorPage({
    super.key,
    required this.token,
    this.expenseId,
    this.recurringId,
    this.repeat = false,
  });

  final String token;
  final String? expenseId;
  final String? recurringId;

  /// Starts a new expense repeating every month.
  final bool repeat;

  @override
  ConsumerState<ExpenseEditorPage> createState() => _ExpenseEditorPageState();
}

class _ExpenseEditorPageState extends ConsumerState<ExpenseEditorPage> {
  /// The version the form started from. Live updates bring newer ones, which
  /// replace it only when nothing was changed here or when asked to.
  Expense? _base;

  void _adopt(Expense expense) => setState(() => _base = expense);

  /// The recurring expense the form started from.
  RecurringExpense? _recurringBase;

  @override
  Widget build(BuildContext context) {
    final token = widget.token, expenseId = widget.expenseId;
    if (widget.recurringId case final id?) return _buildRecurring(id);
    final group = ref.watchCurrent(groupProvider(token));
    final expense = expenseId == null
        ? null
        : ref.watchCurrent(expenseProvider((token: token, id: expenseId)));
    final error = group.error ?? expense?.error;
    // A row of the list holds the whole expense, so the form opens from it at
    // once while the latest version loads.
    final listed = expense == null || expense.hasValue || expense.hasError
        ? null
        : ref
              .read(expensesProvider(token))
              .current(ref.read(identityProvider))
              .value
              ?.items
              .where((e) => e.id == expenseId)
              .firstOrNull;

    if (group.value case final g? when expense == null || expense.hasValue || listed != null) {
      final latest = expense?.value ?? listed;
      final base = _base ??= latest;
      if (base != null && !base.editable) return _newer();
      return GroupTheme(
        group: g,
        child: _Editor(
          key: ValueKey(base?.version),
          group: g,
          expense: base,
          hasReceipt: latest?.hasReceipt ?? false,
          newer: latest != null && latest.version != base?.version ? latest : null,
          onReload: _adopt,
          repeat: widget.repeat,
        ),
      );
    }
    return _waiting(error, () {
      ref.invalidate(groupProvider(token));
      if (expenseId != null) ref.invalidate(expenseProvider((token: token, id: expenseId)));
    });
  }

  Widget _buildRecurring(String id) {
    final token = widget.token;
    final group = ref.watchCurrent(groupProvider(token));
    final recurring = ref.watchCurrent(recurringOneProvider((token: token, id: id)));
    if (group.value case final g? when recurring.hasValue) {
      final base = _recurringBase ??= recurring.requireValue;
      if (!base.editable) return _newer();
      return GroupTheme(
        group: g,
        child: _Editor(
          key: ValueKey(('recurring', base.version)),
          group: g,
          expense: base.asExpense,
          recurring: base,
          hasReceipt: false,
          onReload: (_) {},
          onReloadRecurring: (r) => setState(() => _recurringBase = r),
        ),
      );
    }
    return _waiting(group.error ?? recurring.error, () {
      ref.invalidate(groupProvider(token));
      ref.invalidate(recurringOneProvider((token: token, id: id)));
    });
  }

  /// A newer app or server made this: the form could not save it back as it
  /// is, so it stays closed.
  Widget _newer() {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(leading: const CloseButton()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(BSpace.s16),
          child: EmptyState(
            icon: Icons.system_update_outlined,
            title: l10n.expenseNewerTitle,
            body: l10n.expenseNewerBody,
          ),
        ),
      ),
    );
  }

  /// A spinner while loading, or what went wrong.
  Widget _waiting(Object? error, VoidCallback retry) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(leading: const CloseButton()),
      body: Center(
        child: error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(BSpace.s16),
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.groupsUnreachableTitle,
                  body: error is ApiException && error.isNotFound && widget.recurringId != null
                      ? l10n.recurringMissing
                      : errorMessage(l10n, error),
                  action: FilledButton.tonal(onPressed: retry, child: Text(l10n.commonRetry)),
                ),
              ),
      ),
    );
  }
}

/// A currency symbol or unit beside a field, shown even while it is empty.
class FieldAffix extends StatelessWidget {
  const FieldAffix(this.text, {super.key, this.end = false, this.style});

  final String text;
  final bool end;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: end ? 4 : 12, end: end ? 12 : 4),
      child: Text(
        text,
        style: (style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
