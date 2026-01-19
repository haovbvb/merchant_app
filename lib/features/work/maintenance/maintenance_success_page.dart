import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';

class MaintenanceSuccessPage extends StatelessWidget {
  const MaintenanceSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.maintenanceSuccessTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/android/mipmap-xxhdpi/icon_result_completed_green.png',
                width: 140,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.maintenanceSuccessTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.maintenanceSuccessBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
