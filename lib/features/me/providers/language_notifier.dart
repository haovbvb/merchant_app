import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/services/language_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用于在应用启动前预加载语言设置
class LanguagePreloader {
  static const _storageKey = 'app_language_code';
  static Locale? _cachedLocale;
  
  /// 预加载语言设置，应在 runApp 之前调用
  static Future<void> preload() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString(_storageKey);
    if (storedCode != null) {
      _cachedLocale = _resolveLocale(storedCode);
    }
  }
  
  static Locale? get cachedLocale => _cachedLocale;
  
  static Locale _resolveLocale(String languageCode) {
    if (languageCode.toLowerCase().startsWith('zh')) {
      return const Locale('zh');
    }
    return const Locale('en');
  }
}

final languageNotifierProvider = NotifierProvider<LanguageNotifier, Locale>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<Locale> {
  static const _storageKey = 'app_language_code';

  @override
  Locale build() {
    // 优先使用预加载的缓存语言
    final cached = LanguagePreloader.cachedLocale;
    if (cached != null) {
      LanguageStore.instance.update(cached.languageCode);
      return cached;
    }
    
    final fallback = _resolvePlatformLocale();
    LanguageStore.instance.update(fallback.languageCode);
    return fallback;
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) {
      return;
    }
    state = locale;
    LanguageStore.instance.update(locale.languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);
  }

  Locale _resolvePlatformLocale() {
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return _resolveLocale(platformLocale.languageCode);
  }

  Locale _resolveLocale(String? languageCode) {
    if (languageCode != null && languageCode.toLowerCase().startsWith('zh')) {
      return const Locale('zh');
    }
    return const Locale('en');
  }
}
