import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

import 'app_shell_feature_flags.dart';
import 'debug/network/network_debug_floating_entry.dart';
import 'router/app_router.dart';

class AppShellApp extends StatelessWidget {
  const AppShellApp({
    super.key,
    this.title = 'Universal App Template',
    this.featureFlags = const AppShellFeatureFlags(),
  });

  final String title;
  final AppShellFeatureFlags featureFlags;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: AppTheme.light(),
        locale: AppL10n.defaultLocale,
        supportedLocales: AppL10n.supportedLocales,
        localizationsDelegates: AppL10n.localizationsDelegates,
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              const NetworkDebugFloatingEntry(),
            ],
          );
        },
        routerConfig: createAppRouter(featureFlags),
      ),
    );
  }
}
