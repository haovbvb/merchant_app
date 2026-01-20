import 'package:flutter/material.dart';
import 'package:merchant_app/core/constants/legal_urls.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/widgets/common_webview_page.dart';

class ServiceAgreementPage extends StatelessWidget {
  const ServiceAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileUserAgreement)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(l10n.profileUserAgreement),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openWebView(
              context,
              title: l10n.profileUserAgreement,
              url: userAgreementUrl,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.profilePrivacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openWebView(
              context,
              title: l10n.profilePrivacyPolicy,
              url: privacyPolicyUrl,
            ),
          ),
        ],
      ),
    );
  }

  void _openWebView(
    BuildContext context, {
    required String title,
    required String url,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommonWebViewPage(initialUrl: url, title: title),
      ),
    );
  }
}
