import 'package:app_shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShellApp(title: 'Universal App Template');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const AppEntryPoint());
}
