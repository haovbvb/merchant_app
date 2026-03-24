import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import 'auth_feature_contract.dart';
import 'presentation/login_page.dart';

class AuthFeatureModule implements AppFeatureModule {
  AuthFeatureModule();

  static const String _loginPath = '/auth/login';

  final AuthFeatureContract contract = AuthFeatureContract(
    loginPath: _loginPath,
    publicPaths: const {
      _loginPath,
    },
    routes: [
      GoRoute(
        path: _loginPath,
        builder: (context, state) => const LoginPage(),
      ),
    ],
    providers: {
      'authSessionProvider': AuthFeatureContract.placeholderProviderRef,
    },
    bindings: const [
      FeatureBinding(
        name: 'authStorageBinding',
        description: 'Injects auth persistence implementation.',
      ),
      FeatureBinding(
        name: 'authApiBinding',
        description: 'Injects authentication API client abstraction.',
      ),
    ],
    featureConfigSchema: const {
      'auth.enabled': FeatureConfigField.bool(
        description: 'Enable/disable auth feature at runtime.',
        defaultValue: true,
      ),
      'auth.requireSmsVerification': FeatureConfigField.bool(
        description: 'Require SMS verification during sign in.',
        defaultValue: false,
      ),
      'auth.loginPath': FeatureConfigField.string(
        description: 'Auth route path for login page.',
        defaultValue: _loginPath,
      ),
    },
  );

  @override
  String get key => 'feature_auth';

  @override
  Future<void> init() async {
    // Placeholder for auth module init.
  }

  @override
  Future<void> dispose() async {
    // Placeholder for auth module disposal.
  }
}
