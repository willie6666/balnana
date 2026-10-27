import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/page.dart';
import '../account/account_section.dart';
import '../account/sign_in_page.dart';

/// Opens the operator's privacy policy when the server names one, else the
/// app's own.
Future<void> openPrivacyPolicy(BuildContext context, WidgetRef ref) async {
  final url = ref.read(serverInfoProvider).value?.privacyUrl;
  if (url == null) {
    await context.push('/privacy');
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  final copied = context.l10n.aboutSourceCopied;
  if (await launchUrl(url, mode: LaunchMode.externalApplication)) return;
  await Clipboard.setData(ClipboardData(text: url.toString()));
  messenger.showSnackBar(SnackBar(content: Text(copied)));
}

/// /privacy: what Balnana stores and does with it. It speaks for the
/// software, not for whoever runs the server, so it points to the
/// operator's own policy when they set one.
class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final operator = ref.watch(serverInfoProvider).value?.privacyUrl;
    Widget section(String title, String body) => Padding(
      padding: const EdgeInsets.only(top: BSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: BSpace.s8),
          Text(body, style: text.bodyLarge),
        ],
      ),
    );
    return BPage(
      title: l10n.privacyTitle,
      children: [
        Text(l10n.privacyIntro, style: text.bodyLarge),
        if (operator != null) ...[
          const SizedBox(height: BSpace.s16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: () => openPrivacyPolicy(context, ref),
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.privacyOperatorPolicy),
            ),
          ),
        ],
        section(l10n.privacyStoredTitle, l10n.privacyStoredBody),
        section(l10n.privacyUseTitle, l10n.privacyUseBody),
        section(l10n.privacySharedTitle, l10n.privacySharedBody),
        section(l10n.privacyDeviceTitle, l10n.privacyDeviceBody),
        section(l10n.privacyDeleteTitle, l10n.privacyDeleteBody),
      ],
    );
  }
}

/// /delete-account: a page to link to from app stores, where people delete
/// their account without installing the app. Signed-out visitors are sent
/// to sign in first.
class DeleteAccountPage extends ConsumerWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final accounts = ref.watch(accountsModeProvider);
    final account = ref.watch(currentAccountProvider).value;
    return BPage(
      title: l10n.accountDelete,
      children: [
        if (!accounts)
          Text(l10n.accountDeletePageLinkMode, style: text.bodyLarge)
        else if (account == null) ...[
          Text(l10n.accountDeletePageSignedOut, style: text.bodyLarge),
          const SizedBox(height: BSpace.s24),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton(
              onPressed: () => context.go(signInPath('/delete-account')),
              child: Text(l10n.signIn),
            ),
          ),
        ] else ...[
          Text(account.email ?? account.username ?? account.name, style: text.titleMedium),
          const SizedBox(height: BSpace.s8),
          Text(l10n.accountDeleteBody, style: text.bodyLarge),
          const SizedBox(height: BSpace.s24),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => deleteAccount(context, ref),
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(l10n.accountDelete),
            ),
          ),
        ],
      ],
    );
  }
}
