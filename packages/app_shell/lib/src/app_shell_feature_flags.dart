class AppShellFeatureFlags {
  const AppShellFeatureFlags({
    this.enableExampleFeature = true,
    this.enableAuthFeature = true,
    this.initialLocation = '/',
  });

  final bool enableExampleFeature;
  final bool enableAuthFeature;
  final String initialLocation;
}
