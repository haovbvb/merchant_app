import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../constants/legal_urls.dart';

class ServiceAgreementPage extends StatelessWidget {
  const ServiceAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('服务协议与隐私政策')),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('用户协议'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openWebView(
                context,
                title: '用户协议',
                url: userAgreementUrl,
              ),
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('隐私政策'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openWebView(
                context,
                title: '隐私政策',
                url: privacyPolicyUrl,
              ),
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
