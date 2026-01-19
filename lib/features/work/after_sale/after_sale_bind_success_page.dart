import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';

class AfterSaleBindSuccessPage extends StatelessWidget {
  const AfterSaleBindSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.afterSaleBindSuccessTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                l10n.afterSaleBindSuccessMessage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.afterSaleBindConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
