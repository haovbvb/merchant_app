import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import '../profile_route_paths.dart';

class ServiceAgreementPage extends StatelessWidget {
  const ServiceAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.serviceAgreementAndPrivacyTitle)),
      body: ListView(
        children: [
          Container(
            color: AppColors.surfaceCard,
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: Text(l10n.userAgreement),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(ProfileRoutePaths.userAgreement),
            ),
          ),
          const Divider(height: 1),
          Container(
            color: AppColors.surfaceCard,
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(ProfileRoutePaths.privacyPolicy),
            ),
          ),
        ],
      ),
    );
  }
}
