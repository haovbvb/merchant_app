// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabHome => 'Home';

  @override
  String get tabWork => 'Workbench';

  @override
  String get tabMe => 'Profile';

  @override
  String get homeTitle => 'Home';

  @override
  String get homePlaceholder =>
      'This is a placeholder page. Evolve business capabilities inside feature_home.';

  @override
  String get workTitle => 'Workbench';

  @override
  String get workPlaceholder =>
      'This is a placeholder page. Evolve business capabilities inside feature_work.';

  @override
  String get authLoginTitle => 'Auth Login';

  @override
  String get authModuleTitle => 'Legacy Login Module';

  @override
  String get accountLabel => 'Account';

  @override
  String get accountHint => 'Enter your account';

  @override
  String get accountRequired => 'Please enter your account';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get agreeTerms =>
      'I have read and agree to the Terms of Service and Privacy Policy';

  @override
  String get login => 'Login';

  @override
  String get agreeTermsFirst => 'Please agree to the terms first';

  @override
  String get exampleFeatureTitle => 'Example Feature';

  @override
  String get backTemplateHome => 'Back to template home';
}
