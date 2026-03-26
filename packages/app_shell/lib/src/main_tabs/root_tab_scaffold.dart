import 'package:design_system/design_system.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_work/feature_work.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

final bottomNavIndexProvider = NotifierProvider<_BottomNavIndexNotifier, int>(
  _BottomNavIndexNotifier.new,
);

class RootTabScaffold extends ConsumerWidget {
  const RootTabScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final l10n = context.l10n;
    final tabs = <_TabConfig>[
      _TabConfig(
        label: l10n.tabHome,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        body: const HomeTabPage(),
      ),
      _TabConfig(
        label: l10n.tabWork,
        icon: Icons.work_outline,
        activeIcon: Icons.work,
        body: const WorkbenchTabPage(),
      ),
      _TabConfig(
        label: l10n.tabMe,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        body: const ProfileTabEntry(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs.map((tab) => tab.body).toList(growable: false),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) =>
              ref.read(bottomNavIndexProvider.notifier).setIndex(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textDisabled,
          items: tabs
              .map(
                (tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon ?? tab.icon),
                  label: tab.label,
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _BottomNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int value) => state = value;
}

class _TabConfig {
  const _TabConfig({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.body,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final Widget body;
}
