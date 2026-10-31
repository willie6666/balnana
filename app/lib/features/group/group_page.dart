import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../core/session.dart';
import '../../core/settings.dart';
import '../../data/api.dart';
import '../../data/home_group.dart';
import '../../data/known_groups.dart';
import '../../data/live.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/layout.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/member_avatar.dart';
import '../account/sign_in_page.dart';
import '../groups/group_switcher.dart';
import 'balances.dart';
import 'expenses_tab.dart';
import 'identity_sheet.dart';
import 'share_sheet.dart';
import 'spending_tab.dart';

/// Who this app acts as in [token]'s group: the signed-in account's member,
/// or else the member this device picked. Null when neither is known.
String? myMemberId(WidgetRef ref, String token) {
  final fromAccount = ref.watchCurrent(groupProvider(token)).value?.myMemberId;
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
  final fromAccount =
      ref.read(groupProvider(token)).current(ref.read(identityProvider)).value?.myMemberId;
  if (fromAccount != null || ref.read(signedInProvider)) return fromAccount;
  return ref.read(knownGroupsProvider.notifier).byToken(token)?.memberId;
}

/// The link that opens [token]'s group, for sharing.
String groupLink(WidgetRef ref, String token) {
  final base = ref.read(serverPublicUrlProvider) ?? ref.read(serverUrlProvider) ?? '';
  return '$base/g/$token';
}

Future<void> copyGroupLink(BuildContext context, WidgetRef ref, String token) async {
  final message = context.l10n.groupLinkCopied;
  await Clipboard.setData(ClipboardData(text: groupLink(ref, token)));
  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Hands [group]'s link to the system share sheet. The web has no sheet that
/// works everywhere, so there the link is copied instead.
Future<void> shareGroupLink(BuildContext context, WidgetRef ref, Group group) async {
  if (kIsWeb) return copyGroupLink(context, ref, group.token);
  await SharePlus.instance.share(ShareParams(text: groupLink(ref, group.token), subject: group.name));
}

/// Wraps [child] in a theme seeded from the group's color.
class GroupTheme extends ConsumerWidget {
  const GroupTheme({super.key, required this.group, required this.child});

  final Group group;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The wallpaper's colors, when chosen, color every page alike.
    if (WallpaperColors.of(context)) return child;
    final brightness = Theme.of(context).brightness;
    final pureBlack = ref.watch(settingsProvider.select((s) => s.pureBlack));
    final scheme = seedScheme(paletteColor(group.color, group.token), brightness);
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

  /// The server the group is on. Once another is chosen this page is left
  /// over from before, and the group's token is for this server alone.
  late final String? _server;

  bool get _here => mounted && ref.read(serverUrlProvider) == _server;

  @override
  void initState() {
    super.initState();
    _server = openGroup(ref, widget.token);
    ref.listenManual(groupProvider(widget.token), (_, next) {
      final group = next.value;
      if (group != null && _here) {
        _opened(group);
        _goLive();
        // Home opens this group next time.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_here) ref.read(currentGroupProvider.notifier).set(widget.token);
        });
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
    if (_live != null || dio == null || !_here || ref.read(groupProvider(widget.token)).value == null) return;
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
    if (!_here || account != null) return;
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

  /// A page for the group while it cannot be shown, from which to switch to another.
  Widget _blank(Widget body) => Scaffold(
    appBar: AppBar(automaticallyImplyLeading: false, title: const GroupSwitcher()),
    body: Center(
      child: Padding(padding: const EdgeInsets.all(BSpace.s16), child: body),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watchCurrent(groupProvider(widget.token));
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
              if (!mounted) return;
              // Not home any more, or closing the join page would come back here.
              if (ref.read(currentGroupProvider) == widget.token) ref.read(currentGroupProvider.notifier).set(null);
              context.go('/g/${widget.token}/join');
            });
          }
          return _blank(const CircularProgressIndicator());
        }
        if (error is ApiException && error.code == 'sign_in_required') {
          return _blank(
            EmptyState(
              icon: Icons.lock_outline,
              title: l10n.groupSignInTitle,
              body: l10n.groupSignInBody,
              action: FilledButton(
                onPressed: () => context.go(signInPath('/g/${widget.token}')),
                child: Text(l10n.signIn),
              ),
            ),
          );
        }
        // The server's own answer: a 404 from a proxy says nothing of the group.
        final missing = error is ApiException && error.code == 'not_found';
        body = EmptyState(
          icon: missing ? Icons.link_off : Icons.cloud_off_outlined,
          title: missing ? l10n.groupMissingTitle : l10n.groupsUnreachableTitle,
          body: missing ? l10n.groupMissingBody : errorMessage(l10n, error!),
          action: missing
              ? FilledButton.tonal(
                  onPressed: () {
                    ref.read(knownGroupsProvider.notifier).remove(widget.token);
                    if (ref.read(currentGroupProvider) == widget.token) {
                      ref.read(currentGroupProvider.notifier).set(null);
                    }
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
      return _blank(body);
    }

    return GroupTheme(
      group: group,
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: BSpace.s8,
              title: GroupSwitcher(group: group),
              actions: [
                IconButton(
                  tooltip: l10n.groupShare,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => showShareSheet(context, group),
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
                      sliver: SliverToBoxAdapter(child: BalanceCard(group: group)),
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
                              Tab(text: l10n.statsTitle),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      ExpensesTab(group: group, sidePadding: side),
                      SpendingTab(group: group, sidePadding: side),
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
