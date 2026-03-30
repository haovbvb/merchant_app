import 'package:feature_home/feature_home.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('HomeFeatureModule exposes stable route contract', () {
    final module = HomeFeatureModule();
    final goRoutes = module.contract.routes.whereType<GoRoute>().toList();

    expect(goRoutes, isNotEmpty);
    expect(goRoutes.map((route) => route.path), contains(HomeRoutePaths.home));
  });
}
