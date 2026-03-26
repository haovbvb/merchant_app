import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      color: AppColors.surfacePage,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_outlined, size: 56, color: AppColors.slate500),
              const SizedBox(height: 12),
              Text(l10n.homeTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                l10n.homePlaceholder,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
