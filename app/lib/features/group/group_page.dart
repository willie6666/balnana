import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../core/settings.dart';
import '../../data/api.dart';
import '../../data/known_groups.dart';
import '../../data/live.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/layout.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/member_avatar.dart';
import '../account/sign_in_page.dart';
import 'balances_tab.dart';
import 'expenses_tab.dart';
import 'identity_sheet.dart';

/// Who this app acts as in [token]'s group: the signed-in account's member,
/// or else the member this device picked. Null when neither is known.
String? myMemberId(WidgetRef ref, String token) {
  final fromAccount = ref.watch(groupProvider(token).select((g) => g.value?.myMemberId));
  if (fromAccount != null || ref.watch(signedInProvider)) return fromAccount;
  return ref.watch(
    knownGroupsProvider.select((list) {
      for (final g in list) {
        if (g.token == token) return g.memberId;
      }
      return null;
    }),
  );
}

/// [myMemberId] for one-off reads outside build.
String? myMemberIdRead(WidgetRef ref, String token) {
  final fromAccount = ref.read(groupProvider(token)).value?.myMemberId;
  if (fromAccount != null || ref.read(signedInProvider)) return fromAccount;
  return ref.read(knownGroupsProvider.notifier).byToken(token)?.memberId;
}

/// The link that opens [token]'s group, for sharing.
String groupLink(WidgetRef ref, String token) {
  final base = ref.read(serverInfoProvider).value?.publicUrl ?? ref.read(serverUrlProvider) ?? '';
  return '$base/g/$token';
}

Future<void> copyGroupLink(BuildContext context, WidgetRef ref, String token) async {
  final message = context.l10n.groupLinkCopied;
  await Clipboard.setData(ClipboardData(text: groupLink(ref, token)));
  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Wraps [child] in a theme seeded from the group's color.
class GroupTheme extends ConsumerWidget {
  const GroupTheme({super.key, required this.group, required this.child});

  final Group group;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final pureBlack = ref.watch(settingsProvider.select((s) => s.pureBlack));
    final scheme = ColorScheme.fromSeed(
      seedColor: paletteColor(group.color, group.token),
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    return Theme(
      data: buildTheme(scheme, pureBlack: pureBlack),
      child: child,
    );
  }
}

class GroupPage extends ConsumerStatefulWidget {
  const GroupPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends ConsumerState<GroupPage> {
  bool _askedIdentity = false;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    ref.listenManual(groupProvider(widget.token), (_, next) {
      final group = next.value;
      if (group != null) {
        _opened(group);
        _goLive();
      }
    }, fireImmediately: true);
    // A new session reloads everything already; follow the group as that account.
    ref.listenManual(apiProvider, (_, _) {
      _stopLive();
      _goLive();
    });
    // Phones and browsers keep hidden apps' connections only so long; catch up
    // when the app is shown again instead.
    _lifecycle = AppLifecycleListener(onHide: _stopLive, onShow: _goLive);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _stopLive();
    _reload?.cancel();
    super.dispose();
  }

  StreamSubscription<LiveEvent>? _live;
  Timer? _reload;

  /// Follows changes others make to the group while it is open and shown.
  void _goLive() {
    final dio = ref.read(apiProvider);
    if (_live != null || dio == null || ref.read(groupProvider(widget.token)).value == null) return;
    _live = ref.read(groupEventsProvider)(dio, widget.token).listen(_onLive, onDone: () => _live = null);
  }

  void _stopLive() {
    _live?.cancel();
    _live = null;
  }

  void _onLive(LiveEvent event) {
    // Every connection catches up, since what is shown may be cached from an
    // earlier visit or have changed between loading it and connecting. Gone
    // reloads too, to show why the group is no longer there. Changes often
    // come in a burst, such as an expense and its undo.
    _reload?.cancel();
    _reload = Timer(const Duration(milliseconds: 300), () {
      if (mounted) refreshGroup(ref, widget.token);
    });
  }

  /// Remembers a group opened from a link and asks who this device is. A
  /// signed-in account has its groups on the server instead.
  Future<void> _opened(Group group) async {
    // The server names the member only for a signed-in account; otherwise wait
    // for the account to load before deciding.
    if (group.myMemberId != null) return;
    final account = await ref.read(accountProvider.future).catchError((_) => null);
    if (!mounted || account != null) return;
    final known = ref.read(knownGroupsProvider.notifier);
    if (known.byToken(group.token) == null) {
      known.add(group.token);
      ref.invalidate(summariesProvider);
    }
    final me = group.member(known.byToken(group.token)?.memberId);
    if ((me == null || me.left) && !_askedIdentity) {
      _askedIdentity = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showIdentitySheet(context, group);
      });
    }
  }

  bool _sentToJoin = false;

  void _back() => context.canPop() ? context.pop() : context.go('/groups');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(groupProvider(widget.token));
    final group = async.value;

    if (group != null) _sentToJoin = false;
    if (group == null) {
      final Widget body;
      if (async.hasError && !async.isLoading) {
        final error = async.error;
        if (error is ApiException && error.code == 'not_a_member') {
          // The join page is a child route, so this page stays below it and
          // must send people there only once.
          if (!_sentToJoin) {
            _sentToJoin = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/g/${widget.token}/join');
            });
          }
          return Scaffold(
            appBar: AppBar(leading: BackButton(onPressed: _back)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (error is ApiException && error.code == 'sign_in_required') {
          return Scaffold(
            appBar: AppBar(leading: BackButton(onPressed: _back)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(BSpace.s16),
                child: EmptyState(
                  icon: Icons.lock_outline,
                  title: l10n.groupSignInTitle,
                  body: l10n.groupSignInBody,
                  action: FilledButton(
                    onPressed: () => context.go(signInPath('/g/${widget.token}')),
                    child: Text(l10n.signIn),
                  ),
                ),
              ),
            ),
          );
        }
        final missing = error is ApiException && error.isNotFound;
        body = EmptyState(
          icon: missing ? Icons.link_off : Icons.cloud_off_outlined,
          title: missing ? l10n.groupMissingTitle : l10n.groupsUnreachableTitle,
          body: missing ? l10n.groupMissingBody : errorMessage(l10n, error!),
          action: missing
              ? FilledButton.tonal(
                  onPressed: () {
                    ref.read(knownGroupsProvider.notifier).remove(widget.token);
                    context.go('/groups');
                  },
                  child: Text(l10n.groupForget),
                )
              : FilledButton.tonal(
                  onPressed: () => ref.invalidate(groupProvider(widget.token)),
                  child: Text(l10n.commonRetry),
                ),
        );
      } else {
        body = const CircularProgressIndicator();
      }
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: _back)),
        body: Center(
          child: Padding(padding: const EdgeInsets.all(BSpace.s16), child: body),
        ),
      );
    }

    return GroupTheme(
      group: group,
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: _back),
              titleSpacing: 0,
              title: Row(
                children: [
                  GroupBadge(
                    token: group.token,
                    name: group.name,
                    emoji: group.emoji,
                    color: group.color,
                    size: 36,
                  ),
                  const SizedBox(width: BSpace.s12),
                  Expanded(child: Text(group.name, overflow: TextOverflow.ellipsis)),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: l10n.statsTitle,
                  icon: const Icon(Icons.insights_outlined),
                  onPressed: () => context.push('/g/${group.token}/stats'),
                ),
                IconButton(
                  tooltip: l10n.groupShare,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => copyGroupLink(context, ref, group.token),
                ),
                IconButton(
                  tooltip: l10n.groupSettings,
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/g/${group.token}/settings'),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => context.push('/g/${group.token}/expenses/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.expenseAdd),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
                return NestedScrollView(
                  headerSliverBuilder: (context, _) => [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s8),
                      sliver: SliverToBoxAdapter(child: BalanceHero(group: group)),
                    ),
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabsHeader(
                          color: Theme.of(context).colorScheme.surface,
                          padding: side,
                          tabs: TabBar(
                            tabs: [
                              Tab(text: l10n.tabExpenses),
                              Tab(text: l10n.tabBalances),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      ExpensesTab(group: group, sidePadding: side),
                      BalancesTab(group: group, sidePadding: side),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TabsHeader extends SliverPersistentHeaderDelegate {
  _TabsHeader({required this.tabs, required this.color, required this.padding});

  final TabBar tabs;
  final Color color;
  final double padding;

  @override
  double get minExtent => tabs.preferredSize.height;

  @override
  double get maxExtent => tabs.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => ColoredBox(
    color: color,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: tabs,
    ),
  );

  @override
  bool shouldRebuild(_TabsHeader old) => old.tabs != tabs || old.color != color || old.padding != padding;
}

/// The top of a group page: where this device's member stands.
class BalanceHero extends ConsumerWidget {
  const BalanceHero({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final me = group.member(myMemberId(ref, group.token));

    final Widget content;
    if ((me == null || me.left) && ref.watch(signedInProvider)) {
      // An open group the account is not in yet.
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.heroJoinTitle, style: text.titleLarge?.copyWith(color: scheme.onPrimaryContainer)),
          const SizedBox(height: BSpace.s4),
          Text(l10n.heroJoinBody, style: text.bodyMedium?.copyWith(color: scheme.onPrimaryContainer)),
          const SizedBox(height: BSpace.s16),
          FilledButton(onPressed: () => context.push('/g/${group.token}/join'), child: Text(l10n.joinAction)),
        ],
      );
    } else if (me == null || me.left) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.heroWhoTitle, style: text.titleLarge?.copyWith(color: scheme.onPrimaryContainer)),
          const SizedBox(height: BSpace.s4),
          Text(l10n.heroWhoBody, style: text.bodyMedium?.copyWith(color: scheme.onPrimaryContainer)),
          const SizedBox(height: BSpace.s16),
          FilledButton(onPressed: () => showIdentitySheet(context, group), child: Text(l10n.heroWhoAction)),
        ],
      );
    } else {
      final balance = me.balance;
      final label = switch (balance.sign) {
        1 => l10n.heroOwed,
        -1 => l10n.heroOwe,
        _ => l10n.heroSettled,
      };
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MemberAvatar(member: me, size: 28),
              const SizedBox(width: BSpace.s8),
              Expanded(
                child: Text(
                  l10n.heroYouAre(me.name),
                  style: text.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: BSpace.s16),
          Text(label, style: text.titleMedium?.copyWith(color: scheme.onPrimaryContainer)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              formatMoney(context, balance.abs(), group.minorDigits, group.currency),
              style: text.moneyHero.copyWith(color: scheme.onPrimaryContainer),
            ),
          ),
          if (balance != BigInt.zero) ...[
            const SizedBox(height: BSpace.s12),
            FilledButton.icon(
              onPressed: () => DefaultTabController.of(context).animateTo(1),
              icon: const Icon(Icons.handshake_outlined),
              label: Text(l10n.settleUp),
            ),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(BSpace.s24),
      decoration: ShapeDecoration(
        color: scheme.primaryContainer,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.xl))),
      ),
      child: content,
    );
  }
}
