import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabWork.
  ///
  /// In en, this message translates to:
  /// **'Workbench'**
  String get tabWork;

  /// No description provided for @tabMe.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabMe;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'This is a placeholder page. Evolve business capabilities inside feature_home.'**
  String get homePlaceholder;

  /// No description provided for @workTitle.
  ///
  /// In en, this message translates to:
  /// **'Workbench'**
  String get workTitle;

  /// No description provided for @workPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'This is a placeholder page. Evolve business capabilities inside feature_work.'**
  String get workPlaceholder;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Auth Login'**
  String get authLoginTitle;

  /// No description provided for @authModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Legacy Login Module'**
  String get authModuleTitle;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @accountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your account'**
  String get accountHint;

  /// No description provided for @accountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your account'**
  String get accountRequired;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Terms of Service and Privacy Policy'**
  String get agreeTerms;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @agreeTermsFirst.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms first'**
  String get agreeTermsFirst;

  /// No description provided for @exampleFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Example Feature'**
  String get exampleFeatureTitle;

  /// No description provided for @backTemplateHome.
  ///
  /// In en, this message translates to:
  /// **'Back to template home'**
  String get backTemplateHome;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @profileDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileDefaultName;

  /// No description provided for @profileMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get profileMessages;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileLanguageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageSetting;

  /// No description provided for @profileServiceAgreement.
  ///
  /// In en, this message translates to:
  /// **'Service Agreement'**
  String get profileServiceAgreement;

  /// No description provided for @profileAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAboutApp;

  /// No description provided for @profileEditNicknameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Nickname'**
  String get profileEditNicknameTitle;

  /// No description provided for @profileNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter nickname'**
  String get profileNicknameHint;

  /// No description provided for @profileNicknameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nickname cannot be empty'**
  String get profileNicknameEmpty;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileUserId.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String profileUserId(Object id);

  /// No description provided for @languageSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingsTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get languageChineseSimplified;

  /// No description provided for @serviceAgreementAndPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get serviceAgreementAndPrivacyTitle;

  /// No description provided for @userAgreement.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get userAgreement;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordCurrentAccount.
  ///
  /// In en, this message translates to:
  /// **'Current account: {account}'**
  String changePasswordCurrentAccount(Object account);

  /// No description provided for @changePasswordTips.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password with at least 6 characters, and keep it the same as the confirmation password.'**
  String get changePasswordTips;

  /// No description provided for @changePasswordOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordOldPassword;

  /// No description provided for @changePasswordOldPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get changePasswordOldPasswordHint;

  /// No description provided for @changePasswordNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNewPassword;

  /// No description provided for @changePasswordNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get changePasswordNewPasswordHint;

  /// No description provided for @changePasswordConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get changePasswordConfirmPassword;

  /// No description provided for @changePasswordConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password again'**
  String get changePasswordConfirmPasswordHint;

  /// No description provided for @changePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get changePasswordSubmit;

  /// No description provided for @changePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two new passwords do not match'**
  String get changePasswordMismatch;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get changePasswordFieldRequired;

  /// No description provided for @scanManualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual input'**
  String get scanManualInput;

  /// No description provided for @scanVehicleVin.
  ///
  /// In en, this message translates to:
  /// **'Vehicle VIN'**
  String get scanVehicleVin;

  /// No description provided for @scanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get scanConfirm;

  /// No description provided for @scanRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get scanRecorded;

  /// No description provided for @scanCameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission required'**
  String get scanCameraPermissionRequired;

  /// No description provided for @scanCameraPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Please allow camera access in system settings and try again.'**
  String get scanCameraPermissionDesc;

  /// No description provided for @scanTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get scanTakePhoto;

  /// No description provided for @scanChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get scanChooseFromGallery;

  /// No description provided for @aboutDebugEntryEnabled.
  ///
  /// In en, this message translates to:
  /// **'Debug entry enabled'**
  String get aboutDebugEntryEnabled;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'DEMO'**
  String get aboutAppName;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(Object version);

  /// No description provided for @messageCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Message Center'**
  String get messageCenterTitle;

  /// No description provided for @messageEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get messageEmpty;

  /// No description provided for @messageDetail.
  ///
  /// In en, this message translates to:
  /// **'Message Detail'**
  String get messageDetail;

  /// No description provided for @messageNoMore.
  ///
  /// In en, this message translates to:
  /// **'No more'**
  String get messageNoMore;

  /// No description provided for @showcaseStyleTokens.
  ///
  /// In en, this message translates to:
  /// **'Style Tokens'**
  String get showcaseStyleTokens;

  /// No description provided for @showcaseToolkit.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get showcaseToolkit;

  /// No description provided for @showcaseCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Current time: {value}'**
  String showcaseCurrentTime(Object value);

  /// No description provided for @showcaseScanParsed.
  ///
  /// In en, this message translates to:
  /// **'Parsed scan result: {value}'**
  String showcaseScanParsed(Object value);

  /// No description provided for @showcaseInteractions.
  ///
  /// In en, this message translates to:
  /// **'Common Interactions'**
  String get showcaseInteractions;

  /// No description provided for @showcaseToastDemo.
  ///
  /// In en, this message translates to:
  /// **'This toast comes from foundation'**
  String get showcaseToastDemo;

  /// No description provided for @showcaseConfirmDemoMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a confirm dialog demo from design_system.'**
  String get showcaseConfirmDemoMessage;

  /// No description provided for @showcaseMedia.
  ///
  /// In en, this message translates to:
  /// **'Media Widgets'**
  String get showcaseMedia;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
