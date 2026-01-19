import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class ShipSuccessPage extends StatelessWidget {
  const ShipSuccessPage({super.key, required this.deviceType});

  final int deviceType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final deviceTitle = _deviceTitle(l10n, deviceType);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shipSuccessTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            Text(
              l10n.shipSuccessTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              deviceTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.shipSuccessBackAction),
            ),
          ],
        ),
      ),
    );
  }

  String _deviceTitle(AppLocalizations l10n, int type) {
    switch (type) {
      case 1:
        return l10n.batteryEntryTitle;
      case 2:
        return l10n.vehicleEntryTitle;
      case 3:
        return l10n.stationEntryTitle;
      default:
        return '-';
    }
  }
}
