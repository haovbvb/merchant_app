import 'package:go_router/go_router.dart';

class ProfileFeatureContract {
  const ProfileFeatureContract({
    required this.routes,
    required this.publicPaths,
  });

  final List<RouteBase> routes;
  final Set<String> publicPaths;
}
