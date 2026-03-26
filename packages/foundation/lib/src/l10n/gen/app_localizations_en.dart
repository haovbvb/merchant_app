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

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRetry => 'Retry';

  @override
  String get profileDefaultName => 'Profile';

  @override
  String get profileMessages => 'Messages';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileLanguageSetting => 'Language';

  @override
  String get profileServiceAgreement => 'Service Agreement';

  @override
  String get profileAboutApp => 'About';

  @override
  String get profileEditNicknameTitle => 'Edit Nickname';

  @override
  String get profileNicknameHint => 'Please enter nickname';

  @override
  String get profileNicknameEmpty => 'Nickname cannot be empty';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String profileUserId(Object id) {
    return 'ID: $id';
  }

  @override
  String get languageSettingsTitle => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseSimplified => 'Simplified Chinese';

  @override
  String get serviceAgreementAndPrivacyTitle => 'Terms & Privacy';

  @override
  String get userAgreement => 'User Agreement';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String changePasswordCurrentAccount(Object account) {
    return 'Current account: $account';
  }

  @override
  String get changePasswordTips =>
      'Enter a new password with at least 6 characters, and keep it the same as the confirmation password.';

  @override
  String get changePasswordOldPassword => 'Current Password';

  @override
  String get changePasswordOldPasswordHint => 'Enter current password';

  @override
  String get changePasswordNewPassword => 'New Password';

  @override
  String get changePasswordNewPasswordHint => 'Enter new password';

  @override
  String get changePasswordConfirmPassword => 'Confirm Password';

  @override
  String get changePasswordConfirmPasswordHint => 'Enter new password again';

  @override
  String get changePasswordSubmit => 'Confirm';

  @override
  String get changePasswordMismatch => 'The two new passwords do not match';

  @override
  String get changePasswordSuccess => 'Password updated successfully';

  @override
  String get changePasswordFieldRequired => 'This field is required';

  @override
  String get scanManualInput => 'Manual input';

  @override
  String get scanVehicleVin => 'Vehicle VIN';

  @override
  String get scanConfirm => 'Confirm';

  @override
  String get scanRecorded => 'Recorded';

  @override
  String get scanCameraPermissionRequired => 'Camera permission required';

  @override
  String get scanCameraPermissionDesc =>
      'Please allow camera access in system settings and try again.';

  @override
  String get scanTakePhoto => 'Take photo';

  @override
  String get scanChooseFromGallery => 'Choose from gallery';

  @override
  String get aboutDebugEntryEnabled => 'Debug entry enabled';

  @override
  String get aboutAppName => 'DEMO';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get messageCenterTitle => 'Message Center';

  @override
  String get messageEmpty => 'No messages';

  @override
  String get messageDetail => 'Message Detail';

  @override
  String get messageNoMore => 'No more';

  @override
  String get showcaseStyleTokens => 'Style Tokens';

  @override
  String get showcaseToolkit => 'Utilities';

  @override
  String showcaseCurrentTime(Object value) {
    return 'Current time: $value';
  }

  @override
  String showcaseScanParsed(Object value) {
    return 'Parsed scan result: $value';
  }

  @override
  String get showcaseInteractions => 'Common Interactions';

  @override
  String get showcaseToastDemo => 'This toast comes from foundation';

  @override
  String get showcaseConfirmDemoMessage =>
      'This is a confirm dialog demo from design_system.';

  @override
  String get showcaseMedia => 'Media Widgets';
}
