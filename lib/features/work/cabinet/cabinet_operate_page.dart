import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_authorization_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_detail_page.dart';

class CabinetOperatePage extends StatelessWidget {
  const CabinetOperatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetOperateTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.cabinetOperateAuthorization),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CabinetAuthorizationPage()),
            ),
          ),
          ListTile(
            title: Text(l10n.cabinetOperateOfflineDetail),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CabinetOfflineDetailPage()),
            ),
          ),
        ],
      ),
    );
  }
}
