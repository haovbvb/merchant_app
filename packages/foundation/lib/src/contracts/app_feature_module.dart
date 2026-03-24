abstract interface class AppFeatureModule {
  String get key;

  Future<void> init();
  Future<void> dispose();
}
