import 'package:feature_profile/feature_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('ProfileFeatureModule exposes stable route and public path contract', () {
    final module = ProfileFeatureModule();
    final goRoutes = module.contract.routes.whereType<GoRoute>().toList();

    expect(goRoutes, isNotEmpty);
    expect(goRoutes.map((route) => route.path), contains(ProfileRoutePaths.userAgreement));
    expect(goRoutes.map((route) => route.path), contains(ProfileRoutePaths.privacyPolicy));
    expect(goRoutes.map((route) => route.path), contains(ProfileRoutePaths.serviceAgreement));

    expect(module.contract.publicPaths, contains(ProfileRoutePaths.userAgreement));
    expect(module.contract.publicPaths, contains(ProfileRoutePaths.privacyPolicy));
    expect(module.contract.publicPaths, contains(ProfileRoutePaths.serviceAgreement));
  });
}
