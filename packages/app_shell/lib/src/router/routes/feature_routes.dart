import 'package:feature_auth/feature_auth.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:go_router/go_router.dart';

import '../../app_shell_feature_flags.dart';
import '../../example/example_feature_page.dart';
import '../../shell_route_paths.dart';

List<RouteBase> buildFeatureRoutes({
  required AppShellFeatureFlags featureFlags,
  required AuthFeatureModule authModule,
  required ProfileFeatureModule profileModule,
}) {
  final routes = <RouteBase>[];

  routes.addAll(profileModule.contract.routes);

  if (featureFlags.enableAuthFeature) {
    routes.addAll(authModule.contract.routes);
  }

  if (featureFlags.enableExampleFeature) {
    routes.add(
      GoRoute(
        path: ShellRoutePaths.example,
        builder: (context, state) => const ExampleFeaturePage(),
      ),
    );
  }

  return routes;
}
