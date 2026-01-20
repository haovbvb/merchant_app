import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/android/mipmap-xxhdpi/bg_about.webp',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: IconButton(
                icon: Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_arrow_left.webp',
                  width: 24,
                  height: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 120),
                Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_logo_login.png',
                  width: 88,
                  height: 88,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
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
                    return Text(
                      '${l10n.aboutVersionLabel} $version',
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 18,
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
                        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
                                  Text(
                                    date,
                                    style: const TextStyle(
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
      ),
    );
  }
}
