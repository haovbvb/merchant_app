import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foundation/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final Duration _debugTriggerDuration = const Duration(seconds: 3);
  DateTime? _versionPressStart;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  void _onVersionPointerDown(PointerDownEvent _) {
    _versionPressStart = DateTime.now();
  }

  void _onVersionPointerUpOrCancel() {
    final pressStart = _versionPressStart;
    _versionPressStart = null;
    if (pressStart == null) return;

    final pressedFor = DateTime.now().difference(pressStart);
    if (pressedFor >= _debugTriggerDuration) {
      NetworkDebugStore.instance.showFloatingEntry();
      showToast(context.l10n.aboutDebugEntryEnabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.profileAboutHeroStart, AppColors.profileAboutHeroEnd],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: MediaQuery.of(context).padding.top + 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 60),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.profileAboutIconBg,
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
                child: const Icon(
                  Icons.apps,
                  color: AppColors.surfaceCard,
                  size: 44,
                ),
              ),
              const SizedBox(height: AppDimens.p16),
              Text(
                l10n.aboutAppName,
                style: const TextStyle(
                  color: AppColors.surfaceCard,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimens.p6),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '-';
                  return Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _onVersionPointerDown,
                    onPointerUp: (_) => _onVersionPointerUpOrCancel(),
                    onPointerCancel: (_) => _onVersionPointerUpOrCancel(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p8,
                        vertical: AppDimens.p4,
                      ),
                      child: Text(
                        l10n.aboutVersion(version),
                        style: const TextStyle(
                          color: AppColors.textPlaceholder,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 104),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDimens.radius16),
                      topRight: Radius.circular(AppDimens.radius16),
                    ),
                  ),
                  child: FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version ?? '-';
                      final buildNumber = snapshot.data?.buildNumber ?? '-';
                      return Column(
                        children: [
                          const SizedBox(height: AppDimens.p20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.profileAboutVersionDot,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppDimens.p14),
                                Text(
                                  'V$version',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  buildNumber,
                                  style: const TextStyle(
                                    color: AppColors.textSubtle,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimens.p20),
                          AppDivider.thin(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
