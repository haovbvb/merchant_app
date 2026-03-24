import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class WorkbenchTabPage extends StatelessWidget {
  const WorkbenchTabPage({super.key});

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
              const Icon(Icons.work_outline, size: 56, color: Color(0xFF64748B)),
              const SizedBox(height: 12),
              Text(l10n.workTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                l10n.workPlaceholder,
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
