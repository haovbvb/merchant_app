import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/app/theme.dart';
import 'package:merchant_app/features/debug/network/network_debug_floating_entry.dart';
import 'package:merchant_app/features/me/providers/language_notifier.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 预加载语言设置，确保应用启动时使用正确的语言
  await LanguagePreloader.preload();
  // ProviderScope 注入 Riverpod 的依赖树；MerchantApp 承载路由 / 主题等顶层配置。
  runApp(const ProviderScope(child: MerchantApp()));
}

final _lightThemeProvider = Provider<ThemeData>(
  (ref) => BaseTheme.lightTheme(),
);
final _darkThemeProvider = Provider<ThemeData>((ref) => BaseTheme.darkTheme());
final _themeModeProvider = NotifierProvider<_ThemeModeNotifier, ThemeMode>(
  _ThemeModeNotifier.new,
);

class MerchantApp extends ConsumerWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MaterialApp.router 使用 GoRouter 提供的 RouterConfig；主题、语言等均对接 Riverpod。
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      theme: ref.watch(_lightThemeProvider),
      darkTheme: ref.watch(_darkThemeProvider),
      themeMode: ref.watch(_themeModeProvider),
      locale: ref.watch(languageNotifierProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: Stack(
            children: [
              if (child != null) child,
              const NetworkDebugFloatingEntry(),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
}
