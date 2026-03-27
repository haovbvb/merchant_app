import 'package:design_system/design_system.dart';
import 'package:feature_profile/feature_profile.dart';
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
      child: _AppShellRoot(title: title, featureFlags: featureFlags),
    );
  }
}

class _AppShellRoot extends ConsumerStatefulWidget {
  const _AppShellRoot({required this.title, required this.featureFlags});

  final String title;
  final AppShellFeatureFlags featureFlags;

  @override
  ConsumerState<_AppShellRoot> createState() => _AppShellRootState();
}

class _AppShellRootState extends ConsumerState<_AppShellRoot> {
  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      await ref.read(languageNotifierProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageNotifierProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: widget.title,
      theme: AppTheme.light(),
      locale: locale,
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
      routerConfig: createAppRouter(widget.featureFlags),
    );
  }
}
