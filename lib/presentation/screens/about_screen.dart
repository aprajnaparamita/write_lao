import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:write_lao/config/app_info.dart';
import 'package:write_lao/l10n/app_localizations.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appInfo = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            ClipOval(
              child: RotatedBox(
                quarterTurns: 1,
                child: Image.asset(
                  'assets/images/janet.webp',
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              l10n.aboutAppName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              formatAppVersion(appInfo),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutAuthor,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.aboutCopyright,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://writelao.xyz/support')),
                icon: const Icon(Icons.mail_outline),
                label: const Text('Contact Us'),
              ),
            ),

            const SizedBox(height: 12),

            // Apple App Store Guideline 5.1.1(ii) — Privacy Policy must be
            // readily accessible; 3.1.2(a) — Terms of Use should be linked.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('https://writelao.xyz/privacy_policy.html'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: Text(l10n.privacyPolicy),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('https://writelao.xyz/tos.html'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.gavel),
                label: Text(l10n.termsOfUse),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: Text(l10n.done),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
