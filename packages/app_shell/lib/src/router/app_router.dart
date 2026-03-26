import 'package:feature_auth/feature_auth.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import '../app_shell_feature_flags.dart';
import '../shell_route_paths.dart';
import 'router_refresh_notifier.dart';
import 'routes/core_routes.dart';
import 'routes/feature_routes.dart';

GoRouter createAppRouter(AppShellFeatureFlags featureFlags) {
  final authModule = AuthFeatureModule();
  final profileModule = ProfileFeatureModule();
  final routes = <RouteBase>[
    ...buildCoreRoutes(),
    ...buildFeatureRoutes(
      featureFlags: featureFlags,
      authModule: authModule,
      profileModule: profileModule,
    ),
  ];

  final authRefreshNotifier = GoRouterRefreshNotifier(authNotifierProvider);

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
