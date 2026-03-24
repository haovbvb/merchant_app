enum NetworkEnvironment { production, testing }

class NetworkBaseUrlResolver {
  const NetworkBaseUrlResolver({
    required this.baseUrls,
  });

  final Map<NetworkEnvironment, String> baseUrls;

  String resolve(NetworkEnvironment environment) {
    final value = baseUrls[environment];
    if (value == null || value.isEmpty) {
      throw StateError('Missing base URL for environment: $environment');
    }
    return value;
  }
}

class NetworkEnvironmentConfig {
  NetworkEnvironmentConfig._();

  static const String _defaultProductionBaseUrl =
      'https://okla-admin-app.esquare-global.com';
  static const String _defaultTestingBaseUrl =
      'https://okla-admin-app.esquare-global.com';

  static final NetworkBaseUrlResolver _resolver = NetworkBaseUrlResolver(
    baseUrls: const {
      NetworkEnvironment.production: _defaultProductionBaseUrl,
      NetworkEnvironment.testing: _defaultTestingBaseUrl,
    },
  );

  static final NetworkEnvironment current = _resolveEnvironment(
    const String.fromEnvironment('NETWORK_ENV', defaultValue: 'production'),
  );

  static String get baseUrl {
    final override = const String.fromEnvironment(
      'NETWORK_BASE_URL',
      defaultValue: '',
    );
    if (override.isNotEmpty) {
      return override;
    }
    return _resolver.resolve(current);
  }

  static String urlOf(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$normalizedPath';
  }

  static NetworkEnvironment _resolveEnvironment(String raw) {
    switch (raw.toLowerCase()) {
      case 'testing':
      case 'test':
      case 'uat':
        return NetworkEnvironment.testing;
      case 'production':
      case 'prod':
      default:
        return NetworkEnvironment.production;
    }
  }
}
