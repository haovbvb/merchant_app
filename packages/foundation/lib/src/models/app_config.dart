class AppConfig {
  const AppConfig({
    required this.appName,
    required this.baseUrl,
    required this.env,
    required this.locale,
    required this.features,
  });

  final String appName;
  final String baseUrl;
  final String env;
  final String locale;
  final Map<String, bool> features;
}
