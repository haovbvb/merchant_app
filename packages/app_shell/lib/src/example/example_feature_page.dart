import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import '../shell_route_paths.dart';

class ExampleFeaturePage extends StatelessWidget {
  const ExampleFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exampleFeatureTitle)),
      body: Center(
        child: FilledButton.tonal(
          onPressed: () => context.go(ShellRoutePaths.home),
          child: Text(l10n.backTemplateHome),
        ),
      ),
    );
  }
}
