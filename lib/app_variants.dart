import 'package:app_shell/app_shell.dart';
import 'package:flutter/material.dart';

/// 变体 A：认证优先型应用（启动直达登录页）。
class AuthFirstAppEntryPoint extends StatelessWidget {
  const AuthFirstAppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShellApp(
      title: 'Auth First App',
      featureFlags: AppShellFeatureFlags(
        enableAuthFeature: true,
        initialLocation: '/auth/login',
      ),
    );
  }
}

/// 变体 B：内容展示型应用（启动直达基础能力示例页）。
class ShowcaseFirstAppEntryPoint extends StatelessWidget {
  const ShowcaseFirstAppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShellApp(
      title: 'Showcase First App',
      featureFlags: AppShellFeatureFlags(
        enableExampleFeature: true,
        enableAuthFeature: false,
        initialLocation: '/showcase',
      ),
    );
  }
}