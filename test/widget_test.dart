import 'package:app_shell/app_shell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/main.dart';

void main() {
  testWidgets('Loads template app shell home', (tester) async {
    await tester.pumpWidget(const AppEntryPoint());
    await tester.pumpAndSettle();

    expect(find.text('Auth Login'), findsOneWidget);
  });

  testWidgets('Module toggle off still boots to home', (tester) async {
    await tester.pumpWidget(
      const AppShellApp(
        featureFlags: AppShellFeatureFlags(enableExampleFeature: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Auth Login'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Config only can boot to auth login page', (tester) async {
    await tester.pumpWidget(
      const AppShellApp(
        featureFlags: AppShellFeatureFlags(
          enableAuthFeature: true,
          initialLocation: '/auth/login',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Auth Login'), findsOneWidget);
    expect(find.text('Legacy Login Module'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Config only can boot to example page', (tester) async {
    await tester.pumpWidget(
      const AppShellApp(
        featureFlags: AppShellFeatureFlags(
          enableExampleFeature: true,
          enableAuthFeature: false,
          initialLocation: '/example',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Example Feature'), findsOneWidget);
    expect(find.text('Back to template home'), findsOneWidget);
  });
}
