import 'package:go_router/go_router.dart';

class AuthFeatureContract {
  const AuthFeatureContract({
    required this.routes,
    required this.loginPath,
    required this.publicPaths,
    required this.providers,
    required this.bindings,
    required this.featureConfigSchema,
  });

  // This placeholder token documents provider wiring without binding to a concrete DI runtime type.
  static const String placeholderProviderRef = 'feature_auth.placeholder.provider';

  final List<RouteBase> routes;
  final String loginPath;
  final Set<String> publicPaths;
  final Map<String, String> providers;
  final List<FeatureBinding> bindings;
  final Map<String, FeatureConfigField> featureConfigSchema;
}

class FeatureBinding {
  const FeatureBinding({
    required this.name,
    required this.description,
  });

  final String name;
  final String description;
}

class FeatureConfigField {
  const FeatureConfigField._({
    required this.type,
    required this.description,
    required this.defaultValue,
  });

  const FeatureConfigField.bool({
    required String description,
    required bool defaultValue,
  }) : this._(
          type: ConfigValueType.bool,
          description: description,
          defaultValue: defaultValue,
        );

  const FeatureConfigField.string({
    required String description,
    required String defaultValue,
  }) : this._(
          type: ConfigValueType.string,
          description: description,
          defaultValue: defaultValue,
        );

  final ConfigValueType type;
  final String description;
  final Object defaultValue;
}

enum ConfigValueType {
  bool,
  string,
}