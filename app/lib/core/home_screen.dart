import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Android's home screen: shortcuts on the app icon and the group widget,
/// which Android draws without the app running. The app hands it what to
/// show, worded and formatted already.
class HomeScreen {
  const HomeScreen();

  static const _channel = MethodChannel('balnana/home');

  /// How many groups get a shortcut, in the order the person arranged them.
  /// Launchers show four or five.
  static const shortcuts = 4;

  /// Shows [groups] of [server] in the widgets placed for them, and the
  /// first [shortcuts] on the app icon. [labels] words what Android itself
  /// shows: `pick` and `empty` when a widget is placed, `add` for its "+".
  Future<void> update(String server, List<HomeScreenGroup> groups, Map<String, String> labels) async {
    try {
      await _channel.invokeMethod<void>('update', {
        'server': server,
        'groups': [for (final g in groups) g.toJson()],
        'labels': labels,
      });
    } on MissingPluginException {
      // Builds without the channel.
    } on PlatformException {
      // A launcher that refuses shortcuts still gets its widgets.
    }
  }
}

/// A group as the home screen shows it.
typedef HomeScreenGroup = ({String token, String name, String balance, int tone, String shortcut});

extension on HomeScreenGroup {
  Map<String, Object> toJson() => {
    'token': token,
    'name': name,
    'balance': balance,
    'tone': tone,
    'shortcut': shortcut,
  };
}

/// The home screen to keep up to date: Android's, set in main(), or none.
final homeScreenProvider = Provider<HomeScreen?>((ref) => null);

final _token = RegExp(r'^[A-Za-z0-9_-]{22}$');

/// Where a shortcut or the widget opens: balnana://app/open?server=…&token=…
/// gives the group, and `add=1` its new expense. One made for another server
/// opens home, since its token is not this server's to see.
String openPath(Map<String, String> query, String? server) {
  final token = query['token'];
  if (server == null || query['server'] != server || token == null || !_token.hasMatch(token)) return '/groups';
  return query['add'] == '1' ? '/g/$token/expenses/new' : '/g/$token';
}
