abstract interface class AppLogger {
  void d(String message, {Map<String, Object?>? extra});
  void i(String message, {Map<String, Object?>? extra});
  void w(String message, {Map<String, Object?>? extra});
  void e(String message, {Object? error, StackTrace? stackTrace});
}
