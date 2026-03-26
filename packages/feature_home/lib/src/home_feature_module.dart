import 'package:go_router/go_router.dart';

import 'home_feature_contract.dart';
import 'home_route_paths.dart';
import 'home_tab_page.dart';

class HomeFeatureModule {
  HomeFeatureModule();

  final HomeFeatureContract contract = HomeFeatureContract(
    routes: [
      GoRoute(
        path: HomeRoutePaths.home,
        builder: (context, state) => const HomeTabPage(),
      ),
    ],
  );
}
