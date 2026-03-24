import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      color: const Color(0xFFF5F6F7),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_outlined, size: 56, color: Color(0xFF64748B)),
              const SizedBox(height: 12),
              Text(l10n.homeTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                l10n.homePlaceholder,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
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
