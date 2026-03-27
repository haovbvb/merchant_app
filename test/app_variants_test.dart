import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:merchant_app/app_variants.dart';

void main() {
  testWidgets('Auth first variant boots to auth login', (tester) async {
    await tester.pumpWidget(const AuthFirstAppEntryPoint());
    await tester.pumpAndSettle();

    expect(find.text('Auth Login'), findsOneWidget);
    expect(find.text('Legacy Login Module'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Showcase first variant boots to showcase page', (tester) async {
    await initializeDateFormatting();

    await tester.pumpWidget(const ShowcaseFirstAppEntryPoint());
    await tester.pumpAndSettle();

    expect(find.text('Foundation / Design Showcase'), findsOneWidget);
    final hasChineseStyleLabel = find.text('样式令牌').evaluate().isNotEmpty;
    final hasEnglishStyleLabel = find
        .text('Style Tokens')
        .evaluate()
        .isNotEmpty;
    expect(hasChineseStyleLabel || hasEnglishStyleLabel, isTrue);
  });
}
