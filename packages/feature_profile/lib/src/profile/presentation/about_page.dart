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
      showToast('调试入口已打开');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
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
                  colors: [Color(0xFF2D3440), Color(0xFF5A6474)],
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
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apps,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'DEMO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Version $version',
                        style: const TextStyle(
                          color: Color(0xFF999999),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version ?? '-';
                      const date = 'Oct 30, 2023';
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFA4B51),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'V$version',
                                  style: const TextStyle(
                                    color: Color(0xFF0C0C0D),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  date,
                                  style: TextStyle(
                                    color: Color(0x4D0C0C0D),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFE6E6E6)),
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
