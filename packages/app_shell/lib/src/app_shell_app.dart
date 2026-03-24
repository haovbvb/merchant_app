import 'package:design_system/design_system.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import 'common/scan/qr_scan_page.dart';
import 'debug/network/network_debug_floating_entry.dart';
import 'main_tabs/root_tab_scaffold.dart';
import 'shell_route_paths.dart';

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
        routerConfig: _createRouter(featureFlags),
      ),
    );
  }
}

class AppShellFeatureFlags {
  const AppShellFeatureFlags({
    this.enableExampleFeature = true,
    this.enableAuthFeature = true,
    this.initialLocation = '/',
  });

  final bool enableExampleFeature;
  final bool enableAuthFeature;
  final String initialLocation;
}

GoRouter _createRouter(AppShellFeatureFlags featureFlags) {
  final authModule = AuthFeatureModule();
  final profileModule = ProfileFeatureModule();
  final routes = <RouteBase>[
    GoRoute(
      path: ShellRoutePaths.home,
      builder: (context, state) => const RootTabScaffold(),
    ),
    GoRoute(
      path: ShellRoutePaths.showcase,
      builder: (context, state) => const _FrameworkShowcasePage(),
    ),
    GoRoute(
      path: ShellRoutePaths.webview,
      builder: (context, state) => const CommonWebViewPage(
        initialUrl: 'https://flutter.dev',
        title: 'Flutter WebView Demo',
      ),
    ),
    GoRoute(
      path: ShellRoutePaths.scan,
      builder: (context, state) => const QrScanPage(parseDeviceSn: true),
    ),
  ];

  routes.addAll(profileModule.contract.routes);

  if (featureFlags.enableAuthFeature) {
    routes.addAll(authModule.contract.routes);
  }

  if (featureFlags.enableExampleFeature) {
    routes.add(
      GoRoute(
        path: ShellRoutePaths.example,
        builder: (context, state) => const _ExampleFeaturePage(),
      ),
    );
  }

  final authRefreshNotifier = _GoRouterRefreshNotifier(authNotifierProvider);

  return GoRouter(
    navigatorKey: AppNavigator.navigatorKey,
    initialLocation: featureFlags.initialLocation,
    routes: routes,
    redirect: (context, state) {
      if (!featureFlags.enableAuthFeature) {
        return null;
      }

      final ref = ProviderScope.containerOf(context, listen: false);
      final authState = ref.read(authNotifierProvider);
      final location = state.matchedLocation;
      final isLogin = location == authModule.contract.loginPath;

      final publicLocations = <String>{
        ...authModule.contract.publicPaths,
        ...profileModule.contract.publicPaths,
      };
      final isPublic = publicLocations.contains(location);

      if (!authState.isAuthenticated) {
        return isPublic ? null : authModule.contract.loginPath;
      }

      if (authState.isAuthenticated && isLogin) {
        return ShellRoutePaths.home;
      }

      return null;
    },
    refreshListenable: authRefreshNotifier,
  );
}

class _ExampleFeaturePage extends StatelessWidget {
  const _ExampleFeaturePage();

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

class _FrameworkShowcasePage extends StatelessWidget {
  const _FrameworkShowcasePage();

  @override
  Widget build(BuildContext context) {
    final nowText = DateFormatUtils.format(DateTime.now());
    final hashText = HashUtils.md5Lower32('universal-template');
    final parsedSn = ScanUtils.getDeviceSn('SN:DEMO-2026');

    return Scaffold(
      appBar: AppBar(title: const Text('Foundation / Design Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: '样式令牌',
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Primary',
                      style: TextStyle(color: AppColors.onColor(AppColors.primaryColor)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Secondary',
                      style: TextStyle(color: AppColors.onColor(AppColors.secondaryColor)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '工具能力',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前时间: $nowText'),
                const SizedBox(height: 6),
                Text('MD5: $hashText'),
                const SizedBox(height: 6),
                Text('扫码解析结果: $parsedSn'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '通用交互组件',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () {
                    Toast.show('这是来自 foundation 的 Toast');
                  },
                  child: const Text('Toast'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    Hud.show();
                    Future.delayed(const Duration(milliseconds: 800), Hud.dismiss);
                  },
                  child: const Text('HUD'),
                ),
                OutlinedButton(
                  onPressed: () {
                    ConfirmDialog.show(
                      context: context,
                      message: '这是 design_system 的确认弹窗示例。',
                      cancelText: '取消',
                      confirmText: '确认',
                    );
                  },
                  child: const Text('ConfirmDialog'),
                ),
                OutlinedButton(
                  onPressed: () {
                    context.go(ShellRoutePaths.webview);
                  },
                  child: const Text('CommonWebViewPage'),
                ),
                OutlinedButton(
                  onPressed: () {
                    context.go(ShellRoutePaths.scan);
                  },
                  child: const Text('QrScanPage'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: '媒体组件',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    PhotoGalleryViewer.show(context, const [
                      'https://picsum.photos/id/1015/1200/800',
                      'https://picsum.photos/id/1025/1200/800',
                    ]);
                  },
                  child: const Text('PhotoGalleryViewer'),
                ),
                OutlinedButton(
                  onPressed: () {
                    ImageSourceActionSheet.show(
                      context,
                      cameraLabel: '拍照',
                      galleryLabel: '从相册选择',
                      cancelLabel: '取消',
                    );
                  },
                  child: const Text('ImageSourceActionSheet'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this._provider);

  final NotifierProvider<AuthNotifier, UserState> _provider;
  ProviderSubscription<UserState>? _subscription;

  void _ensureSubscribed(BuildContext context) {
    if (_subscription != null) {
      return;
    }
    final container = ProviderScope.containerOf(context, listen: false);
    _subscription = container.listen<UserState>(
      _provider,
      (_, __) => notifyListeners(),
      fireImmediately: true,
    );
  }

  void _subscribeIfNeeded() {
    final context = AppNavigator.navigatorKey.currentContext;
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _subscribeIfNeeded());
      return;
    }
    _ensureSubscribed(context);
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _subscribeIfNeeded();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _subscription?.close();
      _subscription = null;
    }
  }
}
