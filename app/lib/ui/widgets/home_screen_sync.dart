import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/home_screen.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../core/session.dart';
import '../../data/providers.dart';
import '../money.dart';

/// Hands the home screen the groups as home shows them, whenever they or the
/// language change. Builds [child] unchanged.
class HomeScreenSync extends ConsumerStatefulWidget {
  const HomeScreenSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<HomeScreenSync> createState() => _HomeScreenSyncState();
}

class _HomeScreenSyncState extends ConsumerState<HomeScreenSync> {
  String? _sent;
  Identity? _who;

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeScreenProvider);
    if (home == null) return widget.child;
    final server = ref.watch(serverUrlProvider);
    final who = ref.watch(identityProvider);
    if (_who != who) {
      _who = who;
      _sent = null;
      home.clear();
    }
    final summaries = ref.watch(visibleSummariesProvider).value;
    if (server == null || summaries == null) return widget.child;

    final l10n = context.l10n;
    final groups = [
      for (final g in summaries.groups)
        (
          token: g.token,
          name: g.name,
          // Worded as the group list's pill.
          balance: switch (g.balance) {
            null => l10n.groupMemberCount(g.memberCount),
            final b => switch ((b.sign, formatMoney(context, b.abs(), g.minorDigits, g.currency, symbol: g.symbol))) {
              (1, final money) => l10n.pillOwed(money),
              (-1, final money) => l10n.pillOwe(money),
              _ => l10n.pillSettled,
            },
          },
          tone: g.balance?.sign ?? 0,
          shortcut: l10n.shortcutAddExpense(g.name),
        ),
    ];
    final labels = {'pick': l10n.widgetPickGroup, 'empty': l10n.widgetNoGroups, 'add': l10n.expenseAdd};
    final sent = jsonEncode([server, for (final g in groups) g.toString(), labels]);
    if (sent != _sent) {
      _sent = sent;
      home.update(server, groups, labels);
    }
    return widget.child;
  }
}
