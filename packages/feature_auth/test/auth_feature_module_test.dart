import 'package:feature_auth/feature_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthFeatureModule exposes unified contract sample', () {
    final module = AuthFeatureModule();

    expect(module.key, 'feature_auth');
    expect(module.contract.routes, isNotEmpty);
    expect(module.contract.providers, contains('authSessionProvider'));
    expect(module.contract.bindings.map((e) => e.name), contains('authStorageBinding'));
    expect(module.contract.featureConfigSchema.keys, contains('auth.enabled'));
    expect(module.contract.featureConfigSchema.keys, contains('auth.loginPath'));
  });
}
