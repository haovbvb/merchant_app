import 'package:feature_work/feature_work.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('WorkFeatureModule exposes stable route contract', () {
    final module = WorkFeatureModule();
    final goRoutes = module.contract.routes.whereType<GoRoute>().toList();

    expect(goRoutes, isNotEmpty);
    expect(goRoutes.map((route) => route.path), contains(WorkRoutePaths.workbench));
  });
}
