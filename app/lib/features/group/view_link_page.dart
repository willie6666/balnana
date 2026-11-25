import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/grouped_list.dart';
import '../../ui/widgets/page.dart';
import 'group_page.dart';
import 'share_sheet.dart';

/// The address of a view-only link, for sharing.
String viewLinkUrl(WidgetRef ref, String viewToken) {
  final base = ref.read(serverPublicUrlProvider) ?? ref.read(serverUrlProvider) ?? '';
  return '$base/v/$viewToken';
}

/// Where a group's view-only link is made, shared, changed and turned off.
class ViewLinkPage extends ConsumerWidget {
  const ViewLinkPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final group = ref.watchCurrent(groupProvider(token));
    final link = ref.watchCurrent(viewLinkProvider(token));
    // Without billing any group may; with it, the group's plan says.
    final billing = ref.watch(serverInfoProvider.select((i) => i.value?.billing ?? false));
    final plan = billing ? ref.watchCurrent(groupPlanProvider(token)) : null;
    if (group.value case final g? when link.hasValue && (plan == null || plan.hasValue)) {
      return GroupTheme(
        group: g,
        child: _ViewLinkSettings(group: g, link: link.value, allowed: plan?.value?.viewLink ?? true),
      );
    }
    final error = group.error ?? link.error ?? plan?.error;
    return BPage(
      title: l10n.viewLinkTitle,
      fillRemaining: true,
      children: [
        if (error != null && !group.isLoading && !link.isLoading && !(plan?.isLoading ?? false))
          EmptyState(
            icon: Icons.cloud_off_outlined,
            title: l10n.groupsUnreachableTitle,
            body: errorMessage(l10n, error),
            action: FilledButton.tonal(
              onPressed: () {
                ref.invalidate(groupProvider(token));
                ref.invalidate(viewLinkProvider(token));
                ref.invalidate(groupPlanProvider(token));
              },
              child: Text(l10n.commonRetry),
            ),
          )
        else
          const CircularProgressIndicator(),
      ],
    );
  }
}

class _ViewLinkSettings extends ConsumerStatefulWidget {
  const _ViewLinkSettings({required this.group, required this.link, required this.allowed});

  final Group group;

  /// Null until one is made.
  final ViewLink? link;

  /// Whether the group's plan includes a view-only link.
  final bool allowed;

  @override
  ConsumerState<_ViewLinkSettings> createState() => _ViewLinkSettingsState();
}

class _ViewLinkSettingsState extends ConsumerState<_ViewLinkSettings> {
  // What a new link will be.
  var _live = true;
  var _show = const ViewLinkShow();
  DateTime? _expiresAt;
  var _busy = false;

  String get _token => widget.group.token;

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  /// Runs [action] against the server, then shows the link as it is now.
  Future<void> _run(Future<void> Function(GroupApi api) action) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await action(groupApiOf(ref, _token));
      ref.invalidate(viewLinkProvider(_token));
      await ref.read(viewLinkProvider(_token).future);
    } on ApiException catch (e) {
      if (mounted) _snack(errorMessage(l10n, e));
    } on Object {
      // The link failing to load again shows on the page.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() =>
      _run((api) => api.createViewLink(live: _live, show: _show, expiresAt: _expiresAt));

  Future<void> _update(ViewLink link, {ViewLinkShow? show, DateTime? Function()? expiresAt}) => _run(
    (api) => api.updateViewLink(
      show: show ?? link.show,
      expiresAt: expiresAt == null ? link.expiresAt : expiresAt(),
    ),
  );

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.viewLinkTurnOffTitle),
        content: Text(l10n.viewLinkTurnOffBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.viewLinkTurnOff)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run((api) => api.deleteViewLink());
  }

  /// The day the link works through, or null to keep it working.
  Future<DateTime?> _pickExpiry(DateTime? current) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = current == null ? null : _lastDay(current);
    final day = await showDatePicker(
      context: context,
      initialDate: last == null || last.isBefore(today) ? today.add(const Duration(days: 30)) : last,
      firstDate: today,
      lastDate: DateTime(now.year + 10),
    );
    // It stops working when the day after starts.
    return day == null ? null : DateTime(day.year, day.month, day.day + 1);
  }

  /// The last day a link that stops at [expiresAt] works.
  static DateTime _lastDay(DateTime expiresAt) => expiresAt.toLocal().subtract(const Duration(seconds: 1));

  Future<void> _copy(String url) async {
    final message = context.l10n.viewLinkCopied;
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) _snack(message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String date(DateTime d) => DateFormat.yMMMd(locale).format(d.toLocal());
    String dateTime(DateTime d) => DateFormat.yMMMd(locale).add_jm().format(d.toLocal());
    final link = widget.link;
    final live = link?.live ?? _live;
    final show = link?.show ?? _show;
    final expiresAt = link == null ? _expiresAt : link.expiresAt;

    Future<void> setShow(ViewLinkShow next) async {
      if (link == null) {
        setState(() => _show = next);
      } else {
        await _update(link, show: next);
      }
    }

    // A link shows at least one of balances, expenses and spending; what an
    // expense shows needs the expenses.
    Widget toggle(
      IconData icon,
      String title,
      bool value,
      ViewLinkShow Function(bool) apply, {
      bool enabled = true,
      String? subtitle,
    }) {
      final canChange = enabled && !_busy && (!value || apply(false).showsSomething);
      return link == null
          ? GroupedSwitchTile(
              icon: icon,
              title: title,
              subtitle: subtitle,
              value: value,
              onChanged: canChange ? (v) => setShow(apply(v)) : null,
            )
          : GroupedSwitchTile.saving(
              icon: icon,
              title: title,
              subtitle: subtitle,
              value: value,
              onSave: canChange ? (v) => setShow(apply(v)) : null,
            );
    }

    final shows = GroupedList(
      title: l10n.viewLinkShows,
      children: [
        toggle(Icons.balance, l10n.viewBalances, show.balances, (v) => show.copyWith(balances: v)),
        toggle(
          Icons.receipt_long_outlined,
          l10n.tabExpenses,
          show.expenses,
          (v) => show.copyWith(expenses: v),
        ),
        toggle(Icons.pie_chart_outline, l10n.statsTitle, show.spending, (v) => show.copyWith(spending: v)),
        toggle(
          Icons.notes,
          l10n.viewLinkShowNotes,
          show.notes,
          (v) => show.copyWith(notes: v),
          enabled: show.expenses,
        ),
        toggle(
          Icons.place_outlined,
          l10n.viewLinkShowPlaces,
          show.places,
          (v) => show.copyWith(places: v),
          enabled: show.expenses,
        ),
        toggle(
          Icons.photo_outlined,
          l10n.viewLinkShowReceipts,
          show.receipts && live,
          (v) => show.copyWith(receipts: v),
          enabled: show.expenses && live,
          subtitle: live ? null : l10n.viewLinkReceiptsLiveOnly,
        ),
      ],
    );

    final expiry = GroupedList(
      children: [
        GroupedTile(
          icon: Icons.event_outlined,
          title: l10n.viewLinkExpiry,
          subtitle: expiresAt == null
              ? l10n.viewLinkNoExpiry
              : l10n.viewLinkExpiresOn(date(_lastDay(expiresAt))),
          trailing: expiresAt == null
              ? null
              : IconButton(
                  tooltip: l10n.viewLinkClearExpiry,
                  icon: const Icon(Icons.close),
                  onPressed: _busy
                      ? null
                      : () => link == null
                            ? setState(() => _expiresAt = null)
                            : _update(link, expiresAt: () => null),
                ),
          onTap: _busy
              ? null
              : () async {
                  final picked = await _pickExpiry(expiresAt);
                  if (picked == null || !mounted) return;
                  if (link == null) {
                    setState(() => _expiresAt = picked);
                  } else {
                    await _update(link, expiresAt: () => picked);
                  }
                },
        ),
      ],
    );

    final intro = Padding(
      padding: const EdgeInsets.fromLTRB(BSpace.s16, 0, BSpace.s16, BSpace.s24),
      child: Text(l10n.viewLinkIntro, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
    );

    if (link == null) {
      Widget kind(bool value, IconData icon, String title, String subtitle) => GroupedTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        trailing: Icon(
          value == _live ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: value == _live ? scheme.primary : scheme.onSurfaceVariant,
        ),
        onTap: () => setState(() => _live = value),
      );
      return BPage(
        title: l10n.viewLinkTitle,
        children: [
          intro,
          if (!widget.allowed)
            GroupedList(
              children: [
                GroupedTile(
                  icon: Icons.workspace_premium_outlined,
                  title: l10n.viewLinkNeedsPlan,
                  subtitle: l10n.viewLinkNeedsPlanHelp,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/plan'),
                ),
              ],
            ),
          GroupedList(
            title: l10n.viewLinkKind,
            children: [
              kind(true, Icons.sync, l10n.viewLinkLive, l10n.viewLinkLiveHelp),
              kind(false, Icons.history, l10n.viewLinkSnapshot, l10n.viewLinkSnapshotHelp),
            ],
          ),
          shows,
          expiry,
          FilledButton.icon(
            onPressed: widget.allowed && !_busy && _show.showsSomething ? _create : null,
            icon: const Icon(Icons.add_link),
            label: Text(l10n.viewLinkCreate),
          ),
        ],
      );
    }

    final url = viewLinkUrl(ref, link.token);
    final size = math.min(200.0, math.max(140.0, MediaQuery.sizeOf(context).height * 0.3));
    return BPage(
      title: l10n.viewLinkTitle,
      children: [
        intro,
        if (link.paused)
          GroupedList(
            children: [
              GroupedTile(
                icon: Icons.pause_circle_outline,
                title: l10n.viewPausedTitle,
                subtitle: l10n.viewLinkPausedHelp,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/plan'),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: BSpace.s24),
          child: Column(
            children: [
              QrCodeView(data: url, size: size, semanticLabel: l10n.viewLinkQrLabel(widget.group.name)),
              const SizedBox(height: BSpace.s12),
              SelectableText(
                url,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BSpace.s12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: BSpace.s8,
                runSpacing: BSpace.s8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _copy(url),
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.groupCopyLink),
                  ),
                  // The web has no share sheet that works everywhere.
                  if (!kIsWeb)
                    FilledButton.icon(
                      onPressed: () =>
                          SharePlus.instance.share(ShareParams(text: url, subject: widget.group.name)),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.groupShare),
                    ),
                ],
              ),
            ],
          ),
        ),
        GroupedList(
          children: [
            GroupedTile(
              icon: link.live ? Icons.sync : Icons.history,
              title: link.live
                  ? l10n.viewLinkLive
                  : l10n.viewLinkSnapshotOf(dateTime(link.snapshotAt ?? link.createdAt)),
              subtitle: link.live ? l10n.viewLinkLiveHelp : l10n.viewLinkSnapshotMade,
            ),
            GroupedTile(
              icon: Icons.visibility_outlined,
              title: switch (link.lastViewedAt) {
                final at? => l10n.viewLinkLastOpened(date(at)),
                null => l10n.viewLinkNeverOpened,
              },
            ),
          ],
        ),
        shows,
        expiry,
        GroupedList(
          children: [
            GroupedTile(
              icon: Icons.link_off,
              title: l10n.viewLinkTurnOff,
              subtitle: l10n.viewLinkTurnOffHelp,
              onTap: _busy ? null : _delete,
            ),
          ],
        ),
      ],
    );
  }
}
