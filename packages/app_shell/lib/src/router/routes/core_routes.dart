import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../common/scan/qr_scan_page.dart';
import '../../debug/network/network_debug_detail_page.dart';
import '../../debug/network/network_debug_page.dart';
import '../../debug/showcase/framework_showcase_page.dart';
import '../../main_tabs/root_tab_scaffold.dart';
import '../../shell_route_paths.dart';

List<RouteBase> buildCoreRoutes() {
  return <RouteBase>[
    GoRoute(
      path: ShellRoutePaths.home,
      builder: (context, state) => const RootTabScaffold(),
    ),
    GoRoute(
      path: ShellRoutePaths.showcase,
      builder: (context, state) => const FrameworkShowcasePage(),
    ),
    GoRoute(
      path: ShellRoutePaths.networkDebug,
      builder: (context, state) => const NetworkDebugPage(),
    ),
    GoRoute(
      path: ShellRoutePaths.networkDebugDetail,
      builder: (context, state) {
        final entry = state.extra;
        if (entry is NetworkLogEntry) {
          return NetworkDebugDetailPage(entry: entry);
        }
        return const Scaffold(body: Center(child: Text('Invalid debug detail entry')));
      },
    ),
    GoRoute(
      path: ShellRoutePaths.webview,
      builder: (context, state) => const CommonWebViewPage(
        initialUrl: 'https://flutter.dev',
        title: 'Flutter WebView Demo',
      ),
    ),
    GoRoute(
      path: ShellRoutePaths.scan,
      builder: (context, state) => const QrScanPage(parseDeviceSn: true),
    ),
  ];
}
