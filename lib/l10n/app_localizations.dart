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
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @profileAvatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get profileAvatar;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Merchant!'**
  String get welcomeMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// Label for the home tab in the bottom navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// Label for the work tab in the bottom navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get tabWork;

  /// Label for the profile tab in the bottom navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabMe;

  /// Title displayed in the app bar when the home tab is active.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get homeTitle;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for bound vehicles'**
  String get homeSearchHint;

  /// No description provided for @homeFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeFilterAll;

  /// No description provided for @homeFilterNeedMaintenance.
  ///
  /// In en, this message translates to:
  /// **'To be maintained'**
  String get homeFilterNeedMaintenance;

  /// No description provided for @homeFilterNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get homeFilterNormal;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No nearby vehicles'**
  String get homeEmpty;

  /// Title displayed in the app bar when the work tab is active.
  ///
  /// In en, this message translates to:
  /// **'Workbench'**
  String get workTitle;

  /// Title displayed in the app bar when the profile tab is active.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get meTitle;

  /// Placeholder text for the work tab body.
  ///
  /// In en, this message translates to:
  /// **'Your workbench content will appear here soon.'**
  String get workInProgress;

  /// No description provided for @workbenchMonthlyIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Sales'**
  String get workbenchMonthlyIncomeTitle;

  /// No description provided for @workbenchMonthlyIncomeAmount.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get workbenchMonthlyIncomeAmount;

  /// No description provided for @workbenchOrderCount.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get workbenchOrderCount;

  /// No description provided for @workbenchShopSummary.
  ///
  /// In en, this message translates to:
  /// **'Shop Summary'**
  String get workbenchShopSummary;

  /// No description provided for @workbenchShopAll.
  ///
  /// In en, this message translates to:
  /// **'All Shops'**
  String get workbenchShopAll;

  /// No description provided for @workbenchShopDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get workbenchShopDirect;

  /// No description provided for @workbenchShopFranchise.
  ///
  /// In en, this message translates to:
  /// **'Franchise'**
  String get workbenchShopFranchise;

  /// No description provided for @workbenchRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get workbenchRefresh;

  /// No description provided for @workbenchThisMonthSales.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Sales'**
  String get workbenchThisMonthSales;

  /// No description provided for @workbenchTransactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Transaction Amount'**
  String get workbenchTransactionAmount;

  /// No description provided for @workbenchOrderQuantity.
  ///
  /// In en, this message translates to:
  /// **'Order Quantity'**
  String get workbenchOrderQuantity;

  /// No description provided for @workbenchChooseYourRole.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Role'**
  String get workbenchChooseYourRole;

  /// No description provided for @workbenchRoleSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get workbenchRoleSale;

  /// No description provided for @workbenchRoleOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get workbenchRoleOperations;

  /// No description provided for @workbenchRoleWarehouseKeeper.
  ///
  /// In en, this message translates to:
  /// **'Warehouse\nKeeper'**
  String get workbenchRoleWarehouseKeeper;

  /// No description provided for @workbenchShippingEntry.
  ///
  /// In en, this message translates to:
  /// **'Shipping Entry'**
  String get workbenchShippingEntry;

  /// No description provided for @workbenchDeviceIssue.
  ///
  /// In en, this message translates to:
  /// **'Device Issue'**
  String get workbenchDeviceIssue;

  /// No description provided for @workbenchDeviceReception.
  ///
  /// In en, this message translates to:
  /// **'Device Reception'**
  String get workbenchDeviceReception;

  /// No description provided for @workbenchInventoryCount.
  ///
  /// In en, this message translates to:
  /// **'Inventory Count'**
  String get workbenchInventoryCount;

  /// No description provided for @workbenchDeviceQuery.
  ///
  /// In en, this message translates to:
  /// **'Device Query'**
  String get workbenchDeviceQuery;

  /// No description provided for @workbenchSalesBinding.
  ///
  /// In en, this message translates to:
  /// **'Sales Binding'**
  String get workbenchSalesBinding;

  /// No description provided for @workbenchLeaseBinding.
  ///
  /// In en, this message translates to:
  /// **'Lease Binding'**
  String get workbenchLeaseBinding;

  /// No description provided for @workbenchSwapBinding.
  ///
  /// In en, this message translates to:
  /// **'Swap Binding'**
  String get workbenchSwapBinding;

  /// No description provided for @workbenchManualSwap.
  ///
  /// In en, this message translates to:
  /// **'Manual Swap'**
  String get workbenchManualSwap;

  /// No description provided for @workbenchSalesStatistics.
  ///
  /// In en, this message translates to:
  /// **'Sales Statistics'**
  String get workbenchSalesStatistics;

  /// No description provided for @workbenchDepositRefund.
  ///
  /// In en, this message translates to:
  /// **'Deposit Refund'**
  String get workbenchDepositRefund;

  /// No description provided for @workbenchOfflineUserRegistration.
  ///
  /// In en, this message translates to:
  /// **'Offline User\nRegistration'**
  String get workbenchOfflineUserRegistration;

  /// No description provided for @workbenchInstallmentPayment.
  ///
  /// In en, this message translates to:
  /// **'Installment\nPayment'**
  String get workbenchInstallmentPayment;

  /// No description provided for @workbenchUserQuery.
  ///
  /// In en, this message translates to:
  /// **'User Query'**
  String get workbenchUserQuery;

  /// No description provided for @workbenchScheduleMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Schedule\nMaintenance'**
  String get workbenchScheduleMaintenance;

  /// No description provided for @workbenchRepairRegistration.
  ///
  /// In en, this message translates to:
  /// **'Repair\nRegistration'**
  String get workbenchRepairRegistration;

  /// No description provided for @workbenchRoadsideAssistance.
  ///
  /// In en, this message translates to:
  /// **'Roadside\nAssistance'**
  String get workbenchRoadsideAssistance;

  /// No description provided for @workbenchDeviceUnbinding.
  ///
  /// In en, this message translates to:
  /// **'Device\nUnbinding'**
  String get workbenchDeviceUnbinding;

  /// No description provided for @workbenchAfterSalesBinding.
  ///
  /// In en, this message translates to:
  /// **'After-sales\nBinding'**
  String get workbenchAfterSalesBinding;

  /// No description provided for @workbenchCabinetOperation.
  ///
  /// In en, this message translates to:
  /// **'Cabinet\nOperation'**
  String get workbenchCabinetOperation;

  /// No description provided for @workbenchCabinetPutaway.
  ///
  /// In en, this message translates to:
  /// **'Cabinet\nPutaway'**
  String get workbenchCabinetPutaway;

  /// No description provided for @workbenchCabinetUnshelve.
  ///
  /// In en, this message translates to:
  /// **'Cabinet\nUnshelve'**
  String get workbenchCabinetUnshelve;

  /// No description provided for @workbenchStationRepairRegistration.
  ///
  /// In en, this message translates to:
  /// **'Station\nRepair'**
  String get workbenchStationRepairRegistration;

  /// No description provided for @workbenchStationQuery.
  ///
  /// In en, this message translates to:
  /// **'Station\nQuery'**
  String get workbenchStationQuery;

  /// Helper text in the profile tab.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal settings here.'**
  String get profileGreeting;

  /// No description provided for @profileEditNicknameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Nickname'**
  String get profileEditNicknameTitle;

  /// No description provided for @profileEditNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname'**
  String get profileEditNicknameHint;

  /// No description provided for @profileEditNicknameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname'**
  String get profileEditNicknameEmpty;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login;

  /// No description provided for @loginBrandTitle.
  ///
  /// In en, this message translates to:
  /// **'OKLA Merchant'**
  String get loginBrandTitle;

  /// No description provided for @loginHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username and password to continue.'**
  String get loginHint;

  /// No description provided for @loginAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter account'**
  String get loginAccountHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get loginPasswordHint;

  /// No description provided for @loginAgreeTermsToast.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms first'**
  String get loginAgreeTermsToast;

  /// No description provided for @loginButtonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get loginButtonConfirm;

  /// No description provided for @loginAgreePrefix.
  ///
  /// In en, this message translates to:
  /// **'I have read, and agree to '**
  String get loginAgreePrefix;

  /// No description provided for @loginAgreeAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get loginAgreeAnd;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get nameRequired;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Menu label for viewing messages in the profile tab.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get profileMessage;

  /// No description provided for @messageEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messageEmpty;

  /// Menu label for changing the account password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordOldLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordOldLabel;

  /// No description provided for @changePasswordOldHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get changePasswordOldHint;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get changePasswordNewHint;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'ID:'**
  String get changePasswordIdPrefix;

  /// No description provided for @changePasswordRuleHint.
  ///
  /// In en, this message translates to:
  /// **'The length of the new password is 8~16 characters and must contain numbers, letters or special characters'**
  String get changePasswordRuleHint;

  /// No description provided for @changePasswordConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get changePasswordConfirmAction;

  /// No description provided for @changePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get changePasswordSubmit;

  /// No description provided for @changePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get changePasswordRequired;

  /// No description provided for @changePasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get changePasswordTooShort;

  /// No description provided for @changePasswordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get changePasswordNotMatch;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get changePasswordSuccess;

  /// Menu label for selecting the application language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// Menu label for viewing the user agreement.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get profileUserAgreement;

  /// Menu label for viewing the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// Menu label for viewing information about the application.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// Label prefix for app version on About page.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// No description provided for @userListTitle.
  ///
  /// In en, this message translates to:
  /// **'User List'**
  String get userListTitle;

  /// No description provided for @userListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users'**
  String get userListEmpty;

  /// No description provided for @userSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter user ID / user name / phone'**
  String get userSearchHint;

  /// No description provided for @userSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching users'**
  String get userSearchEmpty;

  /// No description provided for @userSearchHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get userSearchHistoryTitle;

  /// No description provided for @userSearchHistoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get userSearchHistoryClear;

  /// No description provided for @userFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get userFilterAll;

  /// No description provided for @userFilterNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get userFilterNormal;

  /// No description provided for @userFilterEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get userFilterEnded;

  /// No description provided for @userFilterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get userFilterOverdue;

  /// No description provided for @userFilterDishonest.
  ///
  /// In en, this message translates to:
  /// **'Dishonest'**
  String get userFilterDishonest;

  /// No description provided for @userStatOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get userStatOrder;

  /// No description provided for @userStatConsumption.
  ///
  /// In en, this message translates to:
  /// **'Total Consumption'**
  String get userStatConsumption;

  /// No description provided for @userStatAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get userStatAssets;

  /// No description provided for @userTipNormal.
  ///
  /// In en, this message translates to:
  /// **'User account is in normal status'**
  String get userTipNormal;

  /// No description provided for @userTipEnded.
  ///
  /// In en, this message translates to:
  /// **'User services have ended'**
  String get userTipEnded;

  /// No description provided for @userTipOverdue.
  ///
  /// In en, this message translates to:
  /// **'User has overdue payments pending'**
  String get userTipOverdue;

  /// No description provided for @userTipDishonest.
  ///
  /// In en, this message translates to:
  /// **'User is flagged as dishonest'**
  String get userTipDishonest;

  /// No description provided for @userTabBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get userTabBasicInfo;

  /// No description provided for @userTabOrderRecords.
  ///
  /// In en, this message translates to:
  /// **'Order Records'**
  String get userTabOrderRecords;

  /// No description provided for @userTabPaymentRecords.
  ///
  /// In en, this message translates to:
  /// **'Payment Records'**
  String get userTabPaymentRecords;

  /// No description provided for @userTabSwapRecords.
  ///
  /// In en, this message translates to:
  /// **'Swap Records'**
  String get userTabSwapRecords;

  /// No description provided for @userOrderTabSale.
  ///
  /// In en, this message translates to:
  /// **'Sales Order'**
  String get userOrderTabSale;

  /// No description provided for @userOrderTabRent.
  ///
  /// In en, this message translates to:
  /// **'Rental Order'**
  String get userOrderTabRent;

  /// No description provided for @userOrderTabSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap Order'**
  String get userOrderTabSwap;

  /// No description provided for @userBasicVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get userBasicVehicle;

  /// No description provided for @userBasicBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get userBasicBattery;

  /// No description provided for @userBasicRegisterTime.
  ///
  /// In en, this message translates to:
  /// **'Registration Time'**
  String get userBasicRegisterTime;

  /// No description provided for @userBasicUserType.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userBasicUserType;

  /// No description provided for @userBasicBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get userBasicBirthday;

  /// No description provided for @userBasicPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get userBasicPhone;

  /// No description provided for @userBasicEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get userBasicEmail;

  /// No description provided for @userBasicPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get userBasicPhotos;

  /// No description provided for @userBasicRemark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get userBasicRemark;

  /// No description provided for @userBindSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get userBindSale;

  /// No description provided for @userBindRental.
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get userBindRental;

  /// No description provided for @userBindTimeSuffix.
  ///
  /// In en, this message translates to:
  /// **'bind'**
  String get userBindTimeSuffix;

  /// No description provided for @userTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get userTypeNormal;

  /// No description provided for @userTypeSenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get userTypeSenior;

  /// No description provided for @userTypeVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get userTypeVip;

  /// No description provided for @userPaymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get userPaymentType;

  /// No description provided for @userPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get userPaymentAmount;

  /// No description provided for @userPaymentTime.
  ///
  /// In en, this message translates to:
  /// **'Payment Time'**
  String get userPaymentTime;

  /// No description provided for @userPaymentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payment records'**
  String get userPaymentEmpty;

  /// No description provided for @userPaymentOrderNo.
  ///
  /// In en, this message translates to:
  /// **'Order No:'**
  String get userPaymentOrderNo;

  /// No description provided for @userPaymentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period:'**
  String get userPaymentPeriod;

  /// No description provided for @userSwapRecord.
  ///
  /// In en, this message translates to:
  /// **'Swap Record'**
  String get userSwapRecord;

  /// No description provided for @userSwapTime.
  ///
  /// In en, this message translates to:
  /// **'Swap Time'**
  String get userSwapTime;

  /// No description provided for @userSwapOldBattery.
  ///
  /// In en, this message translates to:
  /// **'Old Battery'**
  String get userSwapOldBattery;

  /// No description provided for @userSwapNewBattery.
  ///
  /// In en, this message translates to:
  /// **'New Battery'**
  String get userSwapNewBattery;

  /// No description provided for @userSwapEmpty.
  ///
  /// In en, this message translates to:
  /// **'No swap records'**
  String get userSwapEmpty;

  /// No description provided for @userSwapManual.
  ///
  /// In en, this message translates to:
  /// **'Manual swap'**
  String get userSwapManual;

  /// No description provided for @userSwapRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote swap'**
  String get userSwapRemote;

  /// No description provided for @userSwapBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth swap'**
  String get userSwapBluetooth;

  /// No description provided for @userSwapScan.
  ///
  /// In en, this message translates to:
  /// **'Scan swap'**
  String get userSwapScan;

  /// No description provided for @userSwapStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get userSwapStatusSuccess;

  /// No description provided for @userSwapStatusFail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get userSwapStatusFail;

  /// No description provided for @userSwapStatusPartSuccess.
  ///
  /// In en, this message translates to:
  /// **'Partially successful'**
  String get userSwapStatusPartSuccess;

  /// No description provided for @userSwapStatusSystemReject.
  ///
  /// In en, this message translates to:
  /// **'System reject'**
  String get userSwapStatusSystemReject;

  /// No description provided for @userSwapStationSn.
  ///
  /// In en, this message translates to:
  /// **'Station SN'**
  String get userSwapStationSn;

  /// No description provided for @userSwapOperator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get userSwapOperator;

  /// No description provided for @userSwapInBattery.
  ///
  /// In en, this message translates to:
  /// **'In battery'**
  String get userSwapInBattery;

  /// No description provided for @userSwapOutBattery.
  ///
  /// In en, this message translates to:
  /// **'Out battery'**
  String get userSwapOutBattery;

  /// No description provided for @userSwapError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get userSwapError;

  /// No description provided for @userDetailCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get userDetailCall;

  /// No description provided for @userDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'User Detail'**
  String get userDetailTitle;

  /// No description provided for @userDetailCardNum.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get userDetailCardNum;

  /// No description provided for @userDetailPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get userDetailPhone;

  /// No description provided for @userDetailIdNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get userDetailIdNumber;

  /// No description provided for @userDetailBindDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Bound Devices'**
  String get userDetailBindDevicesTitle;

  /// No description provided for @userDetailBatteryList.
  ///
  /// In en, this message translates to:
  /// **'Batteries'**
  String get userDetailBatteryList;

  /// No description provided for @userDetailVehicleList.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get userDetailVehicleList;

  /// No description provided for @userDetailBindEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bound devices'**
  String get userDetailBindEmpty;

  /// No description provided for @userDetailOrderList.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get userDetailOrderList;

  /// No description provided for @userDetailOrderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get userDetailOrderEmpty;

  /// No description provided for @userDetailOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get userDetailOrderAmount;

  /// No description provided for @userDetailOrderSale.
  ///
  /// In en, this message translates to:
  /// **'Sale Orders'**
  String get userDetailOrderSale;

  /// No description provided for @userDetailOrderRent.
  ///
  /// In en, this message translates to:
  /// **'Rent Orders'**
  String get userDetailOrderRent;

  /// No description provided for @userDetailOrderSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap Orders'**
  String get userDetailOrderSwap;

  /// No description provided for @orderLabelOrderTime.
  ///
  /// In en, this message translates to:
  /// **'Order Time'**
  String get orderLabelOrderTime;

  /// No description provided for @orderLabelDeviceSn.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get orderLabelDeviceSn;

  /// No description provided for @orderLabelModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get orderLabelModel;

  /// No description provided for @orderLabelAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get orderLabelAmount;

  /// No description provided for @orderLabelPayType.
  ///
  /// In en, this message translates to:
  /// **'Pay Type'**
  String get orderLabelPayType;

  /// No description provided for @orderLabelTerm.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get orderLabelTerm;

  /// No description provided for @orderLabelRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get orderLabelRate;

  /// No description provided for @orderLabelMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get orderLabelMonthly;

  /// No description provided for @orderLabelPackageName.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get orderLabelPackageName;

  /// No description provided for @orderLabelDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get orderLabelDeposit;

  /// No description provided for @orderLabelServiceDays.
  ///
  /// In en, this message translates to:
  /// **'Service Days'**
  String get orderLabelServiceDays;

  /// No description provided for @orderLabelRemainDays.
  ///
  /// In en, this message translates to:
  /// **'Remaining Days'**
  String get orderLabelRemainDays;

  /// No description provided for @orderLabelExpireDate.
  ///
  /// In en, this message translates to:
  /// **'Expire Date'**
  String get orderLabelExpireDate;

  /// No description provided for @orderLabelVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get orderLabelVehicle;

  /// No description provided for @orderLabelBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get orderLabelBattery;

  /// No description provided for @orderLabelSwapTimes.
  ///
  /// In en, this message translates to:
  /// **'Swap Times'**
  String get orderLabelSwapTimes;

  /// No description provided for @orderLabelRemainTimes.
  ///
  /// In en, this message translates to:
  /// **'Remaining Times'**
  String get orderLabelRemainTimes;

  /// No description provided for @orderUnitDays.
  ///
  /// In en, this message translates to:
  /// **' days'**
  String get orderUnitDays;

  /// No description provided for @orderUnitTimes.
  ///
  /// In en, this message translates to:
  /// **' times'**
  String get orderUnitTimes;

  /// No description provided for @orderPayCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get orderPayCash;

  /// No description provided for @orderPayOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get orderPayOnline;

  /// No description provided for @orderPayFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get orderPayFull;

  /// No description provided for @orderPayInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get orderPayInstallment;

  /// No description provided for @orderStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get orderStatusClosed;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusFullPayment.
  ///
  /// In en, this message translates to:
  /// **'Full Payment'**
  String get orderStatusFullPayment;

  /// No description provided for @orderStatusPaidUp.
  ///
  /// In en, this message translates to:
  /// **'Paid Up'**
  String get orderStatusPaidUp;

  /// No description provided for @orderStatusInstallments.
  ///
  /// In en, this message translates to:
  /// **'Installments'**
  String get orderStatusInstallments;

  /// No description provided for @orderStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get orderStatusOverdue;

  /// No description provided for @orderStatusDishonest.
  ///
  /// In en, this message translates to:
  /// **'Dishonest'**
  String get orderStatusDishonest;

  /// No description provided for @orderStatusInUse.
  ///
  /// In en, this message translates to:
  /// **'In Use'**
  String get orderStatusInUse;

  /// No description provided for @orderStatusEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get orderStatusEnded;

  /// No description provided for @orderVoucherUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload Voucher'**
  String get orderVoucherUpload;

  /// No description provided for @orderVoucherView.
  ///
  /// In en, this message translates to:
  /// **'View Voucher'**
  String get orderVoucherView;

  /// No description provided for @orderVoucherUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Select images to upload'**
  String get orderVoucherUploadHint;

  /// No description provided for @orderVoucherEmpty.
  ///
  /// In en, this message translates to:
  /// **'No voucher images'**
  String get orderVoucherEmpty;

  /// No description provided for @orderVoucherClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get orderVoucherClose;

  /// No description provided for @orderVoucherSelectEmpty.
  ///
  /// In en, this message translates to:
  /// **'No images selected'**
  String get orderVoucherSelectEmpty;

  /// No description provided for @orderVoucherUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Upload successful'**
  String get orderVoucherUploadSuccess;

  /// No description provided for @orderVoucherUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get orderVoucherUploadFailed;

  /// No description provided for @orderVoucherConfirmSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get orderVoucherConfirmSuccess;

  /// No description provided for @orderVoucherConfirmFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmation failed'**
  String get orderVoucherConfirmFailed;

  /// No description provided for @orderVoucherUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading vouchers'**
  String get orderVoucherUploading;

  /// No description provided for @orderVoucherUploadPartialFailed.
  ///
  /// In en, this message translates to:
  /// **'Some images failed to upload'**
  String get orderVoucherUploadPartialFailed;

  /// No description provided for @orderVoucherMaxCount.
  ///
  /// In en, this message translates to:
  /// **'Only 5 images can be uploaded'**
  String get orderVoucherMaxCount;

  /// No description provided for @orderVoucherPickCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get orderVoucherPickCamera;

  /// No description provided for @orderVoucherPickGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get orderVoucherPickGallery;

  /// No description provided for @orderVoucherPickCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get orderVoucherPickCancel;

  /// No description provided for @maintenanceBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Maintenance'**
  String get maintenanceBookTitle;

  /// No description provided for @maintenanceSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle SN / VIN'**
  String get maintenanceSnLabel;

  /// No description provided for @maintenanceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle sn / vin or scan QR code'**
  String get maintenanceSnHint;

  /// No description provided for @maintenanceFetchInfo.
  ///
  /// In en, this message translates to:
  /// **'Fetch Info'**
  String get maintenanceFetchInfo;

  /// No description provided for @maintenanceVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info'**
  String get maintenanceVehicleInfo;

  /// No description provided for @maintenanceEmptyInfo.
  ///
  /// In en, this message translates to:
  /// **'No vehicle parameter info'**
  String get maintenanceEmptyInfo;

  /// No description provided for @maintenanceNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Log'**
  String get maintenanceNoteLabel;

  /// No description provided for @maintenanceNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter maintenance log'**
  String get maintenanceNoteHint;

  /// No description provided for @maintenanceSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get maintenanceSubmit;

  /// No description provided for @maintenanceVehicleSn.
  ///
  /// In en, this message translates to:
  /// **'SN'**
  String get maintenanceVehicleSn;

  /// No description provided for @maintenanceVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get maintenanceVehicleModel;

  /// No description provided for @maintenanceVehicleCardNum.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get maintenanceVehicleCardNum;

  /// No description provided for @maintenanceVehicleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get maintenanceVehicleOwner;

  /// No description provided for @maintenanceVehiclePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get maintenanceVehiclePhone;

  /// No description provided for @maintenanceSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Success'**
  String get maintenanceSuccessTitle;

  /// No description provided for @maintenanceSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Success!'**
  String get maintenanceSuccessMessage;

  /// No description provided for @maintenanceSuccessBack.
  ///
  /// In en, this message translates to:
  /// **'Return to Workbench'**
  String get maintenanceSuccessBack;

  /// No description provided for @maintenanceBindUser.
  ///
  /// In en, this message translates to:
  /// **'Bind User'**
  String get maintenanceBindUser;

  /// No description provided for @maintenanceAppointmentNo.
  ///
  /// In en, this message translates to:
  /// **'Appointment No'**
  String get maintenanceAppointmentNo;

  /// No description provided for @maintenanceAppointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Appointment Date'**
  String get maintenanceAppointmentDate;

  /// No description provided for @maintenanceRecords.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Records'**
  String get maintenanceRecords;

  /// No description provided for @maintenanceRidingBehavior.
  ///
  /// In en, this message translates to:
  /// **'Riding behavior over the past 30 day'**
  String get maintenanceRidingBehavior;

  /// No description provided for @maintenanceAvgMileage.
  ///
  /// In en, this message translates to:
  /// **'AVG Mileage /daily'**
  String get maintenanceAvgMileage;

  /// No description provided for @maintenanceAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'AVG Speed'**
  String get maintenanceAvgSpeed;

  /// No description provided for @maintenanceAvgSwapCount.
  ///
  /// In en, this message translates to:
  /// **'AVG Swap Count'**
  String get maintenanceAvgSwapCount;

  /// No description provided for @maintenanceCostsTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Costs'**
  String get maintenanceCostsTitle;

  /// No description provided for @maintenanceTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total (\$)'**
  String get maintenanceTotalLabel;

  /// No description provided for @maintenanceTotalHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount  (No fee, fill in 0)'**
  String get maintenanceTotalHint;

  /// No description provided for @maintenancePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get maintenancePaymentMethods;

  /// No description provided for @maintenancePayCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get maintenancePayCash;

  /// No description provided for @maintenancePayOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get maintenancePayOnline;

  /// No description provided for @maintenanceUploadVoucher.
  ///
  /// In en, this message translates to:
  /// **'Upload Voucher'**
  String get maintenanceUploadVoucher;

  /// No description provided for @maintenanceMileageNotReached.
  ///
  /// In en, this message translates to:
  /// **'The vehicle mileage has not reached the maintenance mileage'**
  String get maintenanceMileageNotReached;

  /// No description provided for @repairRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Repair Records'**
  String get repairRecordTitle;

  /// No description provided for @repairRecordAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Repair Registration'**
  String get repairRecordAddTitle;

  /// No description provided for @repairRecordDeviceSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get repairRecordDeviceSnLabel;

  /// No description provided for @repairRecordDeviceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN or scan  QR code'**
  String get repairRecordDeviceSnHint;

  /// No description provided for @repairRecordStationSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Station SN'**
  String get repairRecordStationSnLabel;

  /// No description provided for @repairRecordStationSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station SN or scan QR code'**
  String get repairRecordStationSnHint;

  /// No description provided for @repairRecordFetchDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Fetch device info'**
  String get repairRecordFetchDeviceInfo;

  /// No description provided for @repairRecordDeviceInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Info'**
  String get repairRecordDeviceInfoTitle;

  /// No description provided for @repairRecordDeviceInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device parameter info'**
  String get repairRecordDeviceInfoEmpty;

  /// No description provided for @repairRecordProjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Repair Project'**
  String get repairRecordProjectLabel;

  /// No description provided for @repairRecordProjectHint.
  ///
  /// In en, this message translates to:
  /// **'Please select a repair project'**
  String get repairRecordProjectHint;

  /// No description provided for @repairRecordSelectProject.
  ///
  /// In en, this message translates to:
  /// **'Select Repair Project'**
  String get repairRecordSelectProject;

  /// No description provided for @repairRecordResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Repair Results'**
  String get repairRecordResultLabel;

  /// No description provided for @repairRecordResultHint.
  ///
  /// In en, this message translates to:
  /// **'Please select a repair  results'**
  String get repairRecordResultHint;

  /// No description provided for @repairRecordSelectResult.
  ///
  /// In en, this message translates to:
  /// **'Select Repair Result'**
  String get repairRecordSelectResult;

  /// No description provided for @repairRecordRemarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get repairRecordRemarkLabel;

  /// No description provided for @repairRecordRemarkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter rmark content'**
  String get repairRecordRemarkHint;

  /// No description provided for @repairRecordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get repairRecordSubmit;

  /// No description provided for @repairRecordSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get repairRecordSubmitSuccess;

  /// No description provided for @repairRecordDeviceModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get repairRecordDeviceModelLabel;

  /// No description provided for @repairRecordDeviceSpecLabel.
  ///
  /// In en, this message translates to:
  /// **'Specification'**
  String get repairRecordDeviceSpecLabel;

  /// No description provided for @repairRecordDeviceCardNumLabel.
  ///
  /// In en, this message translates to:
  /// **'Binding User ID'**
  String get repairRecordDeviceCardNumLabel;

  /// No description provided for @repairRecordDeviceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get repairRecordDeviceNameLabel;

  /// No description provided for @repairRecordDevicePlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get repairRecordDevicePlateNumber;

  /// No description provided for @repairRecordDeviceEntryTime.
  ///
  /// In en, this message translates to:
  /// **'Entry Time'**
  String get repairRecordDeviceEntryTime;

  /// No description provided for @repairRecordBound.
  ///
  /// In en, this message translates to:
  /// **'Bound'**
  String get repairRecordBound;

  /// No description provided for @repairRecordUnbound.
  ///
  /// In en, this message translates to:
  /// **'Unbound'**
  String get repairRecordUnbound;

  /// No description provided for @repairRecordCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get repairRecordCancel;

  /// No description provided for @repairRecordSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle SN'**
  String get repairRecordSnHint;

  /// No description provided for @repairRecordEmpty.
  ///
  /// In en, this message translates to:
  /// **'No repair records'**
  String get repairRecordEmpty;

  /// No description provided for @repairRecordStatusFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get repairRecordStatusFinish;

  /// No description provided for @repairRecordStatusLack.
  ///
  /// In en, this message translates to:
  /// **'Lack'**
  String get repairRecordStatusLack;

  /// No description provided for @repairRecordStatusDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get repairRecordStatusDiscard;

  /// No description provided for @repairRecordDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Repair Record Detail'**
  String get repairRecordDetailTitle;

  /// No description provided for @repairRecordOperator.
  ///
  /// In en, this message translates to:
  /// **'Repair Operator'**
  String get repairRecordOperator;

  /// No description provided for @maintenanceViewDetail.
  ///
  /// In en, this message translates to:
  /// **'View more detail'**
  String get maintenanceViewDetail;

  /// No description provided for @afterSaleBindTitle.
  ///
  /// In en, this message translates to:
  /// **'After-sales Binding'**
  String get afterSaleBindTitle;

  /// No description provided for @afterSaleBindUserSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get afterSaleBindUserSectionTitle;

  /// No description provided for @afterSaleBindCardNumLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get afterSaleBindCardNumLabel;

  /// No description provided for @afterSaleBindCardNumHint.
  ///
  /// In en, this message translates to:
  /// **'Enter User ID or scan QR code'**
  String get afterSaleBindCardNumHint;

  /// No description provided for @afterSaleBindUserInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get afterSaleBindUserInfoTitle;

  /// No description provided for @afterSaleBindUserInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No user info'**
  String get afterSaleBindUserInfoEmpty;

  /// No description provided for @afterSaleBindSelectableOrders.
  ///
  /// In en, this message translates to:
  /// **'After-sales Order'**
  String get afterSaleBindSelectableOrders;

  /// No description provided for @afterSaleBindNoOrders.
  ///
  /// In en, this message translates to:
  /// **'Select after-sales order to bind'**
  String get afterSaleBindNoOrders;

  /// No description provided for @afterSaleBindSelectOrder.
  ///
  /// In en, this message translates to:
  /// **'Select After-sales Order'**
  String get afterSaleBindSelectOrder;

  /// No description provided for @afterSaleBindReselect.
  ///
  /// In en, this message translates to:
  /// **'Reselect'**
  String get afterSaleBindReselect;

  /// No description provided for @afterSaleBindOrderNo.
  ///
  /// In en, this message translates to:
  /// **'Order NO'**
  String get afterSaleBindOrderNo;

  /// No description provided for @afterSaleBindOrderType.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get afterSaleBindOrderType;

  /// No description provided for @afterSaleBindOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get afterSaleBindOrderStatus;

  /// No description provided for @afterSaleBindApplicableDevices.
  ///
  /// In en, this message translates to:
  /// **'Applicable devices'**
  String get afterSaleBindApplicableDevices;

  /// No description provided for @afterSaleBindDeviceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get afterSaleBindDeviceSectionTitle;

  /// No description provided for @afterSaleBindDeviceSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get afterSaleBindDeviceSnLabel;

  /// No description provided for @afterSaleBindDeviceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device sn or scan QR code'**
  String get afterSaleBindDeviceSnHint;

  /// No description provided for @afterSaleBindDeviceInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Details'**
  String get afterSaleBindDeviceInfoTitle;

  /// No description provided for @afterSaleBindDeviceInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device parameter info'**
  String get afterSaleBindDeviceInfoEmpty;

  /// No description provided for @afterSaleBindConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get afterSaleBindConfirm;

  /// No description provided for @afterSaleBindSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Binding Success'**
  String get afterSaleBindSuccessTitle;

  /// No description provided for @afterSaleBindSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The device has been bound successfully.'**
  String get afterSaleBindSuccessMessage;

  /// No description provided for @afterSaleBindUserIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get afterSaleBindUserIdLabel;

  /// No description provided for @afterSaleBindUserNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get afterSaleBindUserNameLabel;

  /// No description provided for @afterSaleBindUserPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get afterSaleBindUserPhoneLabel;

  /// No description provided for @afterSaleBindBatteryLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get afterSaleBindBatteryLabel;

  /// No description provided for @afterSaleBindVehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get afterSaleBindVehicleLabel;

  /// No description provided for @afterSaleBindModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get afterSaleBindModelLabel;

  /// No description provided for @afterSaleBindSpecLabel.
  ///
  /// In en, this message translates to:
  /// **'Spec'**
  String get afterSaleBindSpecLabel;

  /// No description provided for @afterSaleBindOrderTypeSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get afterSaleBindOrderTypeSale;

  /// No description provided for @afterSaleBindOrderTypeLease.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get afterSaleBindOrderTypeLease;

  /// No description provided for @afterSaleBindOrderStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get afterSaleBindOrderStatusPaid;

  /// No description provided for @afterSaleBindOrderStatusInstallment.
  ///
  /// In en, this message translates to:
  /// **'In-progress'**
  String get afterSaleBindOrderStatusInstallment;

  /// No description provided for @afterSaleBindOrderStatusLease.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get afterSaleBindOrderStatusLease;

  /// No description provided for @afterSaleBindVin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get afterSaleBindVin;

  /// No description provided for @afterSaleBindPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get afterSaleBindPlateNumber;

  /// No description provided for @afterSaleBindSoc.
  ///
  /// In en, this message translates to:
  /// **'SOC'**
  String get afterSaleBindSoc;

  /// No description provided for @afterSaleBindSoh.
  ///
  /// In en, this message translates to:
  /// **'SOH'**
  String get afterSaleBindSoh;

  /// No description provided for @afterSaleBindCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get afterSaleBindCycle;

  /// No description provided for @afterSaleBindCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get afterSaleBindCancel;

  /// No description provided for @afterSaleBindUnableToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit'**
  String get afterSaleBindUnableToSubmit;

  /// No description provided for @afterSaleBindDeviceMismatch.
  ///
  /// In en, this message translates to:
  /// **'The device model does not match the device model used in the order, please modify it and try again'**
  String get afterSaleBindDeviceMismatch;

  /// No description provided for @afterSaleBindOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get afterSaleBindOk;

  /// No description provided for @unbindDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Unbinding'**
  String get unbindDeviceTitle;

  /// No description provided for @unbindDeviceUserIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get unbindDeviceUserIdLabel;

  /// No description provided for @unbindDeviceUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter User ID or scan QR code'**
  String get unbindDeviceUserIdHint;

  /// No description provided for @unbindDeviceDeviceSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get unbindDeviceDeviceSnLabel;

  /// No description provided for @unbindDeviceDeviceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN or scan QR code'**
  String get unbindDeviceDeviceSnHint;

  /// No description provided for @unbindDeviceCheckRemarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Check Status'**
  String get unbindDeviceCheckRemarkLabel;

  /// No description provided for @unbindDeviceCheckRemarkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device status'**
  String get unbindDeviceCheckRemarkHint;

  /// No description provided for @unbindDeviceReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reason for Unbinding / Remarks'**
  String get unbindDeviceReasonTitle;

  /// No description provided for @unbindDeviceReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Unbinding / Remarks'**
  String get unbindDeviceReasonHint;

  /// No description provided for @unbindDeviceReasonInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Unbinding / Remarks'**
  String get unbindDeviceReasonInputHint;

  /// No description provided for @unbindDeviceCommonReasons.
  ///
  /// In en, this message translates to:
  /// **'Common Reasons'**
  String get unbindDeviceCommonReasons;

  /// No description provided for @unbindDeviceReason1.
  ///
  /// In en, this message translates to:
  /// **'User logs out, device works fine'**
  String get unbindDeviceReason1;

  /// No description provided for @unbindDeviceReason2.
  ///
  /// In en, this message translates to:
  /// **'Equipment failure'**
  String get unbindDeviceReason2;

  /// No description provided for @unbindDeviceReason3.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get unbindDeviceReason3;

  /// No description provided for @unbindDeviceConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get unbindDeviceConfirmButton;

  /// No description provided for @unbindDeviceUnfinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfinished maintenance order'**
  String get unbindDeviceUnfinishedTitle;

  /// No description provided for @unbindDeviceUnfinishedDesc.
  ///
  /// In en, this message translates to:
  /// **'Unfinished maintenance order detected. Continue unbind?'**
  String get unbindDeviceUnfinishedDesc;

  /// No description provided for @unbindDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm unbind'**
  String get unbindDeviceConfirm;

  /// No description provided for @unbindDeviceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Unbind success'**
  String get unbindDeviceSuccess;

  /// No description provided for @unbindDeviceMissingUserId.
  ///
  /// In en, this message translates to:
  /// **'Please enter card number'**
  String get unbindDeviceMissingUserId;

  /// No description provided for @unbindDeviceMissingDeviceSn.
  ///
  /// In en, this message translates to:
  /// **'Please enter device SN'**
  String get unbindDeviceMissingDeviceSn;

  /// No description provided for @unbindDeviceMissingCheckRemark.
  ///
  /// In en, this message translates to:
  /// **'Please enter check remark'**
  String get unbindDeviceMissingCheckRemark;

  /// No description provided for @unbindDeviceMissingReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter unbind reason'**
  String get unbindDeviceMissingReason;

  /// No description provided for @warehouseInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Inventory'**
  String get warehouseInventoryTitle;

  /// No description provided for @warehouseInventoryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Detail'**
  String get warehouseInventoryDetailTitle;

  /// No description provided for @warehouseInventoryNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Inventory No'**
  String get warehouseInventoryNoLabel;

  /// No description provided for @warehouseInventoryWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouseInventoryWarehouseLabel;

  /// No description provided for @warehouseInventoryTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Device Type'**
  String get warehouseInventoryTypeLabel;

  /// No description provided for @warehouseInventoryStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get warehouseInventoryStatusLabel;

  /// No description provided for @warehouseInventoryDetailListTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Items'**
  String get warehouseInventoryDetailListTitle;

  /// No description provided for @warehouseInventoryDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'No inventory items'**
  String get warehouseInventoryDetailEmpty;

  /// No description provided for @warehouseInventoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No inventory records'**
  String get warehouseInventoryEmpty;

  /// No description provided for @warehouseInventoryRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get warehouseInventoryRevoke;

  /// No description provided for @warehouseInventoryComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get warehouseInventoryComplete;

  /// No description provided for @warehouseInventorySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Search'**
  String get warehouseInventorySearchTitle;

  /// No description provided for @warehouseInventorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter SN or inventory number'**
  String get warehouseInventorySearchHint;

  /// No description provided for @warehouseInventorySearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get warehouseInventorySearchEmpty;

  /// No description provided for @warehouseSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get warehouseSearchAction;

  /// No description provided for @warehouseInventoryScanStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan Status'**
  String get warehouseInventoryScanStatusLabel;

  /// No description provided for @warehouseInventoryScanStatusScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get warehouseInventoryScanStatusScanned;

  /// No description provided for @warehouseInventoryScanStatusSurplus.
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get warehouseInventoryScanStatusSurplus;

  /// No description provided for @warehouseInventoryScanStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get warehouseInventoryScanStatusPending;

  /// No description provided for @warehouseInventoryScanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get warehouseInventoryScanAction;

  /// No description provided for @warehouseInventoryEnterSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN'**
  String get warehouseInventoryEnterSnHint;

  /// No description provided for @warehouseInventoryManualInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN'**
  String get warehouseInventoryManualInputHint;

  /// No description provided for @warehouseInventoryScanManual.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get warehouseInventoryScanManual;

  /// No description provided for @warehouseInventoryScanSuccess.
  ///
  /// In en, this message translates to:
  /// **'Scan success'**
  String get warehouseInventoryScanSuccess;

  /// No description provided for @warehouseInventoryScanRepeat.
  ///
  /// In en, this message translates to:
  /// **'Already scanned'**
  String get warehouseInventoryScanRepeat;

  /// No description provided for @warehouseInventoryScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed'**
  String get warehouseInventoryScanFailed;

  /// No description provided for @warehouseInventoryBatchComplete.
  ///
  /// In en, this message translates to:
  /// **'Batch scan completed'**
  String get warehouseInventoryBatchComplete;

  /// No description provided for @warehouseInventoryRevokeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke inventory'**
  String get warehouseInventoryRevokeConfirmTitle;

  /// No description provided for @warehouseInventoryRevokeConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to revoke this inventory?'**
  String get warehouseInventoryRevokeConfirmDesc;

  /// No description provided for @warehouseInventoryCompleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete inventory'**
  String get warehouseInventoryCompleteConfirmTitle;

  /// No description provided for @warehouseInventoryCompleteConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to complete this inventory?'**
  String get warehouseInventoryCompleteConfirmDesc;

  /// No description provided for @warehouseTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get warehouseTabAll;

  /// No description provided for @warehouseTabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get warehouseTabCompleted;

  /// No description provided for @warehouseTabUnfinished.
  ///
  /// In en, this message translates to:
  /// **'Unfinished'**
  String get warehouseTabUnfinished;

  /// No description provided for @warehouseTabRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get warehouseTabRevoked;

  /// No description provided for @warehouseDeviceTypeBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get warehouseDeviceTypeBattery;

  /// No description provided for @warehouseDeviceTypeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get warehouseDeviceTypeVehicle;

  /// No description provided for @warehouseDeviceTypeStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get warehouseDeviceTypeStation;

  /// No description provided for @warehouseInventoryStatusUnfinished.
  ///
  /// In en, this message translates to:
  /// **'Unfinished'**
  String get warehouseInventoryStatusUnfinished;

  /// No description provided for @warehouseInventoryStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get warehouseInventoryStatusCompleted;

  /// No description provided for @warehouseInventoryStatusRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get warehouseInventoryStatusRevoked;

  /// No description provided for @inventoryCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Count'**
  String get inventoryCountTitle;

  /// No description provided for @inventorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter inventory number to search'**
  String get inventorySearchHint;

  /// No description provided for @inventoryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No information about Inventory'**
  String get inventoryEmptyHint;

  /// No description provided for @inventoryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Count Detail'**
  String get inventoryDetailTitle;

  /// No description provided for @inventoryCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Inventory Count'**
  String get inventoryCreateTitle;

  /// No description provided for @inventorySelectWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Select Warehouse'**
  String get inventorySelectWarehouse;

  /// No description provided for @inventoryScanToReceive.
  ///
  /// In en, this message translates to:
  /// **'Scan to receive'**
  String get inventoryScanToReceive;

  /// No description provided for @inventoryStatusInventoryed.
  ///
  /// In en, this message translates to:
  /// **'Inventoryed'**
  String get inventoryStatusInventoryed;

  /// No description provided for @inventoryStatusNotCounted.
  ///
  /// In en, this message translates to:
  /// **'Not counted'**
  String get inventoryStatusNotCounted;

  /// No description provided for @inventoryStatusNotInStock.
  ///
  /// In en, this message translates to:
  /// **'Not in stock'**
  String get inventoryStatusNotInStock;

  /// No description provided for @inventoryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Inventory Completed'**
  String get inventoryCompleted;

  /// No description provided for @selectDeviceType.
  ///
  /// In en, this message translates to:
  /// **'Select Device Type'**
  String get selectDeviceType;

  /// No description provided for @warehouseTransportTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Transfer'**
  String get warehouseTransportTitle;

  /// No description provided for @warehouseTransportDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Detail'**
  String get warehouseTransportDetailTitle;

  /// No description provided for @warehouseTransportTransferNo.
  ///
  /// In en, this message translates to:
  /// **'Transfer No'**
  String get warehouseTransportTransferNo;

  /// No description provided for @warehouseTransportDeviceType.
  ///
  /// In en, this message translates to:
  /// **'Device Type'**
  String get warehouseTransportDeviceType;

  /// No description provided for @warehouseTransportFrom.
  ///
  /// In en, this message translates to:
  /// **'From Warehouse'**
  String get warehouseTransportFrom;

  /// No description provided for @warehouseTransportTo.
  ///
  /// In en, this message translates to:
  /// **'To Warehouse'**
  String get warehouseTransportTo;

  /// No description provided for @warehouseTransportTrackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking Number'**
  String get warehouseTransportTrackingNumber;

  /// No description provided for @warehouseTransportStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get warehouseTransportStatus;

  /// No description provided for @warehouseTransportDeviceListTitle.
  ///
  /// In en, this message translates to:
  /// **'Device List'**
  String get warehouseTransportDeviceListTitle;

  /// No description provided for @warehouseTransportOperateTime.
  ///
  /// In en, this message translates to:
  /// **'Operate Time'**
  String get warehouseTransportOperateTime;

  /// No description provided for @warehouseTransportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transfer records'**
  String get warehouseTransportEmpty;

  /// No description provided for @warehouseTransportCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Transfer'**
  String get warehouseTransportCreateTitle;

  /// No description provided for @warehouseTransportSendWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Send Warehouse'**
  String get warehouseTransportSendWarehouse;

  /// No description provided for @warehouseTransportReceiveWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Receive Warehouse'**
  String get warehouseTransportReceiveWarehouse;

  /// No description provided for @warehouseTransportSelectReceiveWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Select receive warehouse'**
  String get warehouseTransportSelectReceiveWarehouse;

  /// No description provided for @warehouseTransportAddDevice.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get warehouseTransportAddDevice;

  /// No description provided for @warehouseTransportInputDeviceSn.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN'**
  String get warehouseTransportInputDeviceSn;

  /// No description provided for @warehouseTransportCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get warehouseTransportCreateAction;

  /// No description provided for @warehouseTransportReceiveAction.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get warehouseTransportReceiveAction;

  /// No description provided for @warehouseTransportWithdrawAction.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get warehouseTransportWithdrawAction;

  /// No description provided for @warehouseTransportEditTrackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Edit Tracking'**
  String get warehouseTransportEditTrackingNumber;

  /// No description provided for @warehouseTransportBatchReceiveComplete.
  ///
  /// In en, this message translates to:
  /// **'Batch receive completed'**
  String get warehouseTransportBatchReceiveComplete;

  /// No description provided for @warehouseTransportSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Search'**
  String get warehouseTransportSearchTitle;

  /// No description provided for @warehouseTransportSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter transfer no or keyword'**
  String get warehouseTransportSearchHint;

  /// No description provided for @warehouseTransportSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get warehouseTransportSearchEmpty;

  /// No description provided for @warehouseTransportCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get warehouseTransportCountLabel;

  /// No description provided for @warehouseTransportReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get warehouseTransportReceivedLabel;

  /// No description provided for @warehouseTransportWithdrawLabel.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get warehouseTransportWithdrawLabel;

  /// No description provided for @deviceIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Issue'**
  String get deviceIssueTitle;

  /// No description provided for @deviceReceiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Receive'**
  String get deviceReceiveTitle;

  /// No description provided for @deviceIssueSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the in/out number to search'**
  String get deviceIssueSearchHint;

  /// No description provided for @deviceIssueEmpty.
  ///
  /// In en, this message translates to:
  /// **'No information about device issue'**
  String get deviceIssueEmpty;

  /// No description provided for @deviceIssueCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get deviceIssueCreate;

  /// No description provided for @deviceIssueStatusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get deviceIssueStatusInTransit;

  /// No description provided for @deviceIssueStatusReceiveAll.
  ///
  /// In en, this message translates to:
  /// **'Receive all'**
  String get deviceIssueStatusReceiveAll;

  /// No description provided for @deviceIssueStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial reception'**
  String get deviceIssueStatusPartial;

  /// No description provided for @deviceIssueStatusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdraw all'**
  String get deviceIssueStatusWithdrawn;

  /// No description provided for @deviceIssueQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get deviceIssueQuantity;

  /// No description provided for @deviceIssueReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get deviceIssueReceived;

  /// No description provided for @deviceIssueWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get deviceIssueWithdrawn;

  /// No description provided for @deviceIssueSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No relevant information found'**
  String get deviceIssueSearchEmpty;

  /// No description provided for @deviceIssueWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Issue warehouse'**
  String get deviceIssueWarehouse;

  /// No description provided for @deviceReceiveWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Receiving warehouse'**
  String get deviceReceiveWarehouse;

  /// No description provided for @deviceIssuePleaseSelectWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Please select a warehouse'**
  String get deviceIssuePleaseSelectWarehouse;

  /// No description provided for @deviceIssueTrackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking number'**
  String get deviceIssueTrackingNumber;

  /// No description provided for @deviceIssuePleaseEnterTracking.
  ///
  /// In en, this message translates to:
  /// **'Please enter the tracking number'**
  String get deviceIssuePleaseEnterTracking;

  /// No description provided for @deviceIssueEnterTracking.
  ///
  /// In en, this message translates to:
  /// **'Enter Tracking Number'**
  String get deviceIssueEnterTracking;

  /// No description provided for @deviceIssueSelectBattery.
  ///
  /// In en, this message translates to:
  /// **'Select Battery'**
  String get deviceIssueSelectBattery;

  /// No description provided for @deviceIssueSelectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get deviceIssueSelectVehicle;

  /// No description provided for @deviceIssueSelectStation.
  ///
  /// In en, this message translates to:
  /// **'Select Station'**
  String get deviceIssueSelectStation;

  /// No description provided for @deviceIssueSelectDevice.
  ///
  /// In en, this message translates to:
  /// **'Select Device'**
  String get deviceIssueSelectDevice;

  /// No description provided for @deviceIssueEnterSn.
  ///
  /// In en, this message translates to:
  /// **'Enter Device SN'**
  String get deviceIssueEnterSn;

  /// No description provided for @deviceIssueScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get deviceIssueScanQrCode;

  /// No description provided for @deviceIssueTotalIssued.
  ///
  /// In en, this message translates to:
  /// **'Total Issued'**
  String get deviceIssueTotalIssued;

  /// No description provided for @deviceIssueCreateBattery.
  ///
  /// In en, this message translates to:
  /// **'Create Battery Issue'**
  String get deviceIssueCreateBattery;

  /// No description provided for @deviceIssueCreateVehicle.
  ///
  /// In en, this message translates to:
  /// **'Create Vehicle Issue'**
  String get deviceIssueCreateVehicle;

  /// No description provided for @deviceIssueCreateStation.
  ///
  /// In en, this message translates to:
  /// **'Create Station Issue'**
  String get deviceIssueCreateStation;

  /// No description provided for @deviceIssueChooseWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Choose Warehouse'**
  String get deviceIssueChooseWarehouse;

  /// No description provided for @deviceIssueSearchWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Enter warehouse name to search'**
  String get deviceIssueSearchWarehouse;

  /// No description provided for @deviceIssueAllCity.
  ///
  /// In en, this message translates to:
  /// **'All City'**
  String get deviceIssueAllCity;

  /// No description provided for @deviceIssueEnterDeviceSn.
  ///
  /// In en, this message translates to:
  /// **'Enter Device SN'**
  String get deviceIssueEnterDeviceSn;

  /// No description provided for @deviceIssueDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Details'**
  String get deviceIssueDetailTitle;

  /// No description provided for @deviceReceiveDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Details'**
  String get deviceReceiveDetailTitle;

  /// No description provided for @deviceReceiveSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the in/out number to search'**
  String get deviceReceiveSearchHint;

  /// No description provided for @deviceReceiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'No information about device reception'**
  String get deviceReceiveEmpty;

  /// No description provided for @deviceReceiveScanToReceive.
  ///
  /// In en, this message translates to:
  /// **'Scan to receive'**
  String get deviceReceiveScanToReceive;

  /// No description provided for @deviceReceiveManualInput.
  ///
  /// In en, this message translates to:
  /// **'Manually enter device SN'**
  String get deviceReceiveManualInput;

  /// No description provided for @deviceReceiveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Received successfully'**
  String get deviceReceiveSuccess;

  /// No description provided for @deviceReceiveNotBelong.
  ///
  /// In en, this message translates to:
  /// **'The device does not belong to this document'**
  String get deviceReceiveNotBelong;

  /// No description provided for @deviceReceiveAction.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get deviceReceiveAction;

  /// No description provided for @deviceReceiveWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get deviceReceiveWithdraw;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get searchHistory;

  /// No description provided for @scanPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanPageTitle;

  /// No description provided for @scanFlashOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on flash'**
  String get scanFlashOn;

  /// No description provided for @scanFlashOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off flash'**
  String get scanFlashOff;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Align the QR code within the frame'**
  String get scanHint;

  /// No description provided for @scanManualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual input'**
  String get scanManualInput;

  /// No description provided for @scanInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get scanInputHint;

  /// No description provided for @scanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get scanConfirm;

  /// No description provided for @scanSuccessEntry.
  ///
  /// In en, this message translates to:
  /// **'Successful entry, continue entering'**
  String get scanSuccessEntry;

  /// No description provided for @scanCameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera permission required'**
  String get scanCameraPermissionTitle;

  /// No description provided for @scanCameraPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Please allow camera access in system settings to scan QR codes.'**
  String get scanCameraPermissionDesc;

  /// No description provided for @scanPermissionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get scanPermissionRetry;

  /// No description provided for @scanOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get scanOpenSettings;

  /// No description provided for @bluetoothPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission required'**
  String get bluetoothPermissionTitle;

  /// No description provided for @bluetoothPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Please allow Bluetooth permissions in system settings to connect devices.'**
  String get bluetoothPermissionDesc;

  /// No description provided for @bluetoothPermissionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get bluetoothPermissionRetry;

  /// No description provided for @bluetoothOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get bluetoothOpenSettings;

  /// No description provided for @scanNoChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese characters are not supported'**
  String get scanNoChinese;

  /// No description provided for @qrcodeListTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Code List'**
  String get qrcodeListTitle;

  /// No description provided for @qrcodeListConfirm.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get qrcodeListConfirm;

  /// No description provided for @qrcodeBatchScan.
  ///
  /// In en, this message translates to:
  /// **'Batch Scan'**
  String get qrcodeBatchScan;

  /// No description provided for @qrcodeListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device SNs yet. Please scan or enter a device SN.'**
  String get qrcodeListEmpty;

  /// No description provided for @qrcodeSameAsPrevious.
  ///
  /// In en, this message translates to:
  /// **'Same as the previous code.'**
  String get qrcodeSameAsPrevious;

  /// No description provided for @qrcodeMaxDevice.
  ///
  /// In en, this message translates to:
  /// **'Maximum device count reached.'**
  String get qrcodeMaxDevice;

  /// No description provided for @deviceSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Search'**
  String get deviceSearchTitle;

  /// No description provided for @deviceSearchHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get deviceSearchHistoryTitle;

  /// No description provided for @deviceSearchHistoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get deviceSearchHistoryClear;

  /// No description provided for @qrcodeDeviceTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Type'**
  String get qrcodeDeviceTypeTitle;

  /// No description provided for @qrcodeDeviceTypeBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get qrcodeDeviceTypeBattery;

  /// No description provided for @qrcodeDeviceTypeCabinet.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get qrcodeDeviceTypeCabinet;

  /// No description provided for @qrcodeDeviceTypeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get qrcodeDeviceTypeVehicle;

  /// No description provided for @qrcodeDeviceTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get qrcodeDeviceTypeAll;

  /// No description provided for @qrcodeInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get qrcodeInputHint;

  /// No description provided for @qrcodeResolveAction.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get qrcodeResolveAction;

  /// No description provided for @qrcodeResolveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Resolved successfully'**
  String get qrcodeResolveSuccess;

  /// No description provided for @qrcodeResolveFailed.
  ///
  /// In en, this message translates to:
  /// **'Resolve failed'**
  String get qrcodeResolveFailed;

  /// No description provided for @deviceSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN or keyword'**
  String get deviceSearchHint;

  /// No description provided for @deviceSearchStationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station SN or scan QR code'**
  String get deviceSearchStationHint;

  /// No description provided for @deviceSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get deviceSearchEmpty;

  /// No description provided for @deviceDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Detail'**
  String get deviceDetailTitle;

  /// No description provided for @deviceDetailSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN'**
  String get deviceDetailSearchHint;

  /// No description provided for @deviceDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device information'**
  String get deviceDetailEmpty;

  /// No description provided for @deviceDetailChargeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Charge History'**
  String get deviceDetailChargeHistoryTitle;

  /// No description provided for @deviceDetailChargeHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No charge history'**
  String get deviceDetailChargeHistoryEmpty;

  /// No description provided for @deviceDetailChargeValue.
  ///
  /// In en, this message translates to:
  /// **'Charge Value'**
  String get deviceDetailChargeValue;

  /// No description provided for @deviceDetailChargeTime.
  ///
  /// In en, this message translates to:
  /// **'Charge Time'**
  String get deviceDetailChargeTime;

  /// No description provided for @deviceDetailSoc.
  ///
  /// In en, this message translates to:
  /// **'SOC'**
  String get deviceDetailSoc;

  /// No description provided for @deviceDetailCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get deviceDetailCycle;

  /// No description provided for @deviceDetailMile.
  ///
  /// In en, this message translates to:
  /// **'Total Mile'**
  String get deviceDetailMile;

  /// No description provided for @deviceDetailTodayMile.
  ///
  /// In en, this message translates to:
  /// **'Today Mile'**
  String get deviceDetailTodayMile;

  /// No description provided for @deviceDetailAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Avg Speed'**
  String get deviceDetailAvgSpeed;

  /// No description provided for @deviceDetailSignalTime.
  ///
  /// In en, this message translates to:
  /// **'Signal Time'**
  String get deviceDetailSignalTime;

  /// No description provided for @deviceDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Discharge Status'**
  String get deviceDetailStatus;

  /// No description provided for @deviceDetailLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get deviceDetailLocation;

  /// No description provided for @deviceDetailViewMap.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get deviceDetailViewMap;

  /// No description provided for @deviceDetailToggleDischarge.
  ///
  /// In en, this message translates to:
  /// **'Toggle Discharge'**
  String get deviceDetailToggleDischarge;

  /// No description provided for @deviceDetailDischargeOn.
  ///
  /// In en, this message translates to:
  /// **'Discharging'**
  String get deviceDetailDischargeOn;

  /// No description provided for @deviceDetailDischargeOff.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get deviceDetailDischargeOff;

  /// No description provided for @deviceDetailOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get deviceDetailOnline;

  /// No description provided for @deviceDetailOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get deviceDetailOffline;

  /// No description provided for @deviceDetailToggleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Operation succeeded'**
  String get deviceDetailToggleSuccess;

  /// No description provided for @deviceDetailToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get deviceDetailToggleFailed;

  /// No description provided for @deviceDetailTabBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get deviceDetailTabBattery;

  /// No description provided for @deviceDetailTabVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get deviceDetailTabVehicle;

  /// No description provided for @deviceDetailTabCabinet.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get deviceDetailTabCabinet;

  /// No description provided for @deviceDetailBatteryBaseInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery Info'**
  String get deviceDetailBatteryBaseInfoTitle;

  /// No description provided for @deviceDetailVehicleBaseInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info'**
  String get deviceDetailVehicleBaseInfoTitle;

  /// No description provided for @deviceDetailCabinetBaseInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Info'**
  String get deviceDetailCabinetBaseInfoTitle;

  /// No description provided for @deviceDetailFixRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fix Records'**
  String get deviceDetailFixRecordsTitle;

  /// No description provided for @deviceDetailFixRecordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fix records'**
  String get deviceDetailFixRecordsEmpty;

  /// No description provided for @deviceDetailSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get deviceDetailSale;

  /// No description provided for @deviceDetailLease.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get deviceDetailLease;

  /// No description provided for @deviceDetailFixResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Fix Result'**
  String get deviceDetailFixResultLabel;

  /// No description provided for @deviceDetailFixManLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixer'**
  String get deviceDetailFixManLabel;

  /// No description provided for @deviceDetailFixRemarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Fix Remark'**
  String get deviceDetailFixRemarkLabel;

  /// No description provided for @deviceDetailFixTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fix Time'**
  String get deviceDetailFixTimeLabel;

  /// No description provided for @deviceDetailMaintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Records'**
  String get deviceDetailMaintenanceTitle;

  /// No description provided for @deviceDetailMaintenanceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No maintenance records'**
  String get deviceDetailMaintenanceEmpty;

  /// No description provided for @deviceDetailMaintenanceUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintainer'**
  String get deviceDetailMaintenanceUserLabel;

  /// No description provided for @deviceDetailMaintenanceLogLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Log'**
  String get deviceDetailMaintenanceLogLabel;

  /// No description provided for @deviceDetailMaintenanceTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Time'**
  String get deviceDetailMaintenanceTimeLabel;

  /// No description provided for @deviceDetailCabinPortTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabin Ports'**
  String get deviceDetailCabinPortTitle;

  /// No description provided for @deviceDetailCabinPortEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cabin port info'**
  String get deviceDetailCabinPortEmpty;

  /// No description provided for @deviceDetailCabinOpenDoor.
  ///
  /// In en, this message translates to:
  /// **'Open Door'**
  String get deviceDetailCabinOpenDoor;

  /// No description provided for @deviceDetailCabinOpenBackDoor.
  ///
  /// In en, this message translates to:
  /// **'Open Back Door'**
  String get deviceDetailCabinOpenBackDoor;

  /// No description provided for @deviceDetailCabinOpenDoorSuccess.
  ///
  /// In en, this message translates to:
  /// **'Door opened'**
  String get deviceDetailCabinOpenDoorSuccess;

  /// No description provided for @deviceDetailCabinOpenDoorFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open door'**
  String get deviceDetailCabinOpenDoorFailed;

  /// No description provided for @deviceDetailCabinOpenBackDoorSuccess.
  ///
  /// In en, this message translates to:
  /// **'Back door opened'**
  String get deviceDetailCabinOpenBackDoorSuccess;

  /// No description provided for @deviceDetailCabinOpenBackDoorFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open back door'**
  String get deviceDetailCabinOpenBackDoorFailed;

  /// No description provided for @deviceDetailSnLabel.
  ///
  /// In en, this message translates to:
  /// **'SN'**
  String get deviceDetailSnLabel;

  /// No description provided for @deviceDetailVinLabel.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get deviceDetailVinLabel;

  /// No description provided for @deviceDetailCarNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get deviceDetailCarNumberLabel;

  /// No description provided for @deviceDetailModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get deviceDetailModelLabel;

  /// No description provided for @deviceDetailSpecLabel.
  ///
  /// In en, this message translates to:
  /// **'Spec'**
  String get deviceDetailSpecLabel;

  /// No description provided for @deviceDetailOwnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get deviceDetailOwnerLabel;

  /// No description provided for @deviceDetailPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get deviceDetailPhoneLabel;

  /// No description provided for @deviceDetailInsuranceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Insurance number'**
  String get deviceDetailInsuranceNumberLabel;

  /// No description provided for @deviceDetailBindingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Binding time'**
  String get deviceDetailBindingTimeLabel;

  /// No description provided for @deviceDetailMotorNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Motor No.'**
  String get deviceDetailMotorNumberLabel;

  /// No description provided for @deviceDetailControllerSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Controller SN'**
  String get deviceDetailControllerSnLabel;

  /// No description provided for @deviceDetailBatterySnLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery SN'**
  String get deviceDetailBatterySnLabel;

  /// No description provided for @deviceDetailStationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get deviceDetailStationNameLabel;

  /// No description provided for @deviceDetailStationStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Station Status'**
  String get deviceDetailStationStatusLabel;

  /// No description provided for @deviceDetailStationAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Station Address'**
  String get deviceDetailStationAddressLabel;

  /// No description provided for @deviceDetailStationOnlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Online Status'**
  String get deviceDetailStationOnlineLabel;

  /// No description provided for @deviceDetailPortNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Port No.'**
  String get deviceDetailPortNoLabel;

  /// No description provided for @deviceDetailPortNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Port Name'**
  String get deviceDetailPortNameLabel;

  /// No description provided for @deviceDetailCabinBatterySn.
  ///
  /// In en, this message translates to:
  /// **'Cabin Battery'**
  String get deviceDetailCabinBatterySn;

  /// No description provided for @deviceDetailCabinSoc.
  ///
  /// In en, this message translates to:
  /// **'Cabin SOC'**
  String get deviceDetailCabinSoc;

  /// No description provided for @deviceDetailCabinPortStatus.
  ///
  /// In en, this message translates to:
  /// **'Port Status'**
  String get deviceDetailCabinPortStatus;

  /// No description provided for @deviceDetailDoorStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Door Status'**
  String get deviceDetailDoorStatusLabel;

  /// No description provided for @deviceDetailLockStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Lock Status'**
  String get deviceDetailLockStatusLabel;

  /// No description provided for @deviceDetailChargeStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge Status'**
  String get deviceDetailChargeStatusLabel;

  /// No description provided for @deviceDetailVoltageLabel.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get deviceDetailVoltageLabel;

  /// No description provided for @deviceDetailTemperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get deviceDetailTemperatureLabel;

  /// No description provided for @vehicleSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Search'**
  String get vehicleSearchTitle;

  /// No description provided for @vehicleSearchDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get vehicleSearchDistanceLabel;

  /// No description provided for @vehicleSearchBindIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Bind ID'**
  String get vehicleSearchBindIdLabel;

  /// No description provided for @vehicleSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle SN or keyword'**
  String get vehicleSearchHint;

  /// No description provided for @vehicleSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get vehicleSearchEmpty;

  /// No description provided for @shippingEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping Entry'**
  String get shippingEntryTitle;

  /// No description provided for @shippingEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the device model to be entered'**
  String get shippingEntrySubtitle;

  /// No description provided for @shippingEntryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device models'**
  String get shippingEntryEmpty;

  /// No description provided for @deviceTypeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get deviceTypeVehicle;

  /// No description provided for @deviceTypeBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get deviceTypeBattery;

  /// No description provided for @deviceTypeStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get deviceTypeStation;

  /// No description provided for @batteryEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery Entry'**
  String get batteryEntryTitle;

  /// No description provided for @vehicleEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Entry'**
  String get vehicleEntryTitle;

  /// No description provided for @stationEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Entry'**
  String get stationEntryTitle;

  /// No description provided for @batteryShipTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery Shipment'**
  String get batteryShipTitle;

  /// No description provided for @entrySnLabel.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get entrySnLabel;

  /// No description provided for @entrySnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan device SN'**
  String get entrySnHint;

  /// No description provided for @entrySubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get entrySubmitAction;

  /// No description provided for @entryModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get entryModelLabel;

  /// No description provided for @entryDeviceListTitle.
  ///
  /// In en, this message translates to:
  /// **'Device List'**
  String get entryDeviceListTitle;

  /// No description provided for @entryScanAdd.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get entryScanAdd;

  /// No description provided for @entryManualAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get entryManualAdd;

  /// No description provided for @entryListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No devices added'**
  String get entryListEmpty;

  /// No description provided for @entryImeiLabel.
  ///
  /// In en, this message translates to:
  /// **'IMEI'**
  String get entryImeiLabel;

  /// No description provided for @entryIccidLabel.
  ///
  /// In en, this message translates to:
  /// **'ICCID'**
  String get entryIccidLabel;

  /// No description provided for @entryVinLabel.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get entryVinLabel;

  /// No description provided for @entryCtrlIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Controller ID'**
  String get entryCtrlIdLabel;

  /// No description provided for @entryLockDevIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Lock Device ID'**
  String get entryLockDevIdLabel;

  /// No description provided for @entryEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get entryEditAction;

  /// No description provided for @entryDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get entryDeleteAction;

  /// No description provided for @entryAddDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get entryAddDeviceTitle;

  /// No description provided for @entryEditDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Device'**
  String get entryEditDeviceTitle;

  /// No description provided for @entryConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get entryConfirmAction;

  /// No description provided for @entryModelRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a model'**
  String get entryModelRequired;

  /// No description provided for @entrySubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get entrySubmitSuccess;

  /// No description provided for @entryVinRequired.
  ///
  /// In en, this message translates to:
  /// **'VIN is required'**
  String get entryVinRequired;

  /// No description provided for @entrySubmitDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Submission complete'**
  String get entrySubmitDoneTitle;

  /// No description provided for @entrySubmitDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Registration succeeded. Go to transfer?'**
  String get entrySubmitDoneMessage;

  /// No description provided for @entryGoToTransferAction.
  ///
  /// In en, this message translates to:
  /// **'Go to Transfer'**
  String get entryGoToTransferAction;

  /// No description provided for @entryStayAction.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get entryStayAction;

  /// No description provided for @entryDimensionLabel.
  ///
  /// In en, this message translates to:
  /// **'Dimension'**
  String get entryDimensionLabel;

  /// No description provided for @entryNetWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Weight'**
  String get entryNetWeightLabel;

  /// No description provided for @entryManualEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get entryManualEntryButton;

  /// No description provided for @entryScanEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Scan Entry'**
  String get entryScanEntryButton;

  /// No description provided for @entryEmptyDeviceHint.
  ///
  /// In en, this message translates to:
  /// **'There is no device letter yet,\nplease scan or receive the device SN to enter'**
  String get entryEmptyDeviceHint;

  /// No description provided for @entryManualEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get entryManualEntryTitle;

  /// No description provided for @entryStationSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Station SN'**
  String get entryStationSnLabel;

  /// No description provided for @entryStationSnHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter station SN'**
  String get entryStationSnHint;

  /// No description provided for @entryBatterySnLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery SN'**
  String get entryBatterySnLabel;

  /// No description provided for @entryBatterySnHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter battery SN'**
  String get entryBatterySnHint;

  /// No description provided for @entryVehicleSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle SN'**
  String get entryVehicleSnLabel;

  /// No description provided for @entryVehicleSnHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle SN'**
  String get entryVehicleSnHint;

  /// No description provided for @entryImeiHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter IMEI code (optional)'**
  String get entryImeiHint;

  /// No description provided for @entryIccidHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter ICCID code (optional)'**
  String get entryIccidHint;

  /// No description provided for @entrySnRequired.
  ///
  /// In en, this message translates to:
  /// **'SN is required'**
  String get entrySnRequired;

  /// No description provided for @entryConfirmSubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Submission?'**
  String get entryConfirmSubmitTitle;

  /// No description provided for @entryConfirmSubmitPrefix.
  ///
  /// In en, this message translates to:
  /// **'A total of '**
  String get entryConfirmSubmitPrefix;

  /// No description provided for @entryConfirmSubmitSuffix.
  ///
  /// In en, this message translates to:
  /// **' are being submitted for entry. Once submitted, it will be reflected in the system and cannot be revised.'**
  String get entryConfirmSubmitSuffix;

  /// No description provided for @entrySubmissionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Submission Completed!'**
  String get entrySubmissionCompleted;

  /// No description provided for @entryShipPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to ship the batteries entered this time to the agent?'**
  String get entryShipPromptMessage;

  /// No description provided for @entryCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get entryCloseButton;

  /// No description provided for @entryShipButton.
  ///
  /// In en, this message translates to:
  /// **'Ship'**
  String get entryShipButton;

  /// No description provided for @entryReturnToWorkbench.
  ///
  /// In en, this message translates to:
  /// **'Return to Workbench'**
  String get entryReturnToWorkbench;

  /// No description provided for @shipDeviceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Device Type'**
  String get shipDeviceTypeLabel;

  /// No description provided for @shipDeviceTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select device type'**
  String get shipDeviceTypeRequired;

  /// No description provided for @shipNextAction.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get shipNextAction;

  /// No description provided for @shipSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment Success'**
  String get shipSuccessTitle;

  /// No description provided for @shipSuccessBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get shipSuccessBackAction;

  /// No description provided for @warehouseTransportTabInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get warehouseTransportTabInTransit;

  /// No description provided for @warehouseTransportTabReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get warehouseTransportTabReceived;

  /// No description provided for @warehouseTransportTabPartial.
  ///
  /// In en, this message translates to:
  /// **'Partially received'**
  String get warehouseTransportTabPartial;

  /// No description provided for @warehouseTransportTabWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get warehouseTransportTabWithdrawn;

  /// No description provided for @warehouseTransportStatusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get warehouseTransportStatusInTransit;

  /// No description provided for @warehouseTransportStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get warehouseTransportStatusReceived;

  /// No description provided for @warehouseTransportStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partially received'**
  String get warehouseTransportStatusPartial;

  /// No description provided for @warehouseTransportStatusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get warehouseTransportStatusWithdrawn;

  /// No description provided for @roadsideTitle.
  ///
  /// In en, this message translates to:
  /// **'Roadside Assistance'**
  String get roadsideTitle;

  /// No description provided for @roadsideTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get roadsideTabAll;

  /// No description provided for @roadsideTabWaiting.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get roadsideTabWaiting;

  /// No description provided for @roadsideTabProcessing.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get roadsideTabProcessing;

  /// No description provided for @roadsideTabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get roadsideTabCompleted;

  /// No description provided for @roadsideEmpty.
  ///
  /// In en, this message translates to:
  /// **'No roadside orders'**
  String get roadsideEmpty;

  /// No description provided for @roadsideStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get roadsideStatusWaiting;

  /// No description provided for @roadsideStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get roadsideStatusProcessing;

  /// No description provided for @roadsideStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get roadsideStatusCompleted;

  /// No description provided for @roadsideResultReturnFactory.
  ///
  /// In en, this message translates to:
  /// **'Return to factory'**
  String get roadsideResultReturnFactory;

  /// No description provided for @roadsideResultCompleted.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get roadsideResultCompleted;

  /// No description provided for @roadsideTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported At'**
  String get roadsideTimeLabel;

  /// No description provided for @roadsideResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get roadsideResultLabel;

  /// No description provided for @roadsideDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Roadside Order Detail'**
  String get roadsideDetailTitle;

  /// No description provided for @roadsideDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'No detail available'**
  String get roadsideDetailEmpty;

  /// No description provided for @roadsideDealAction.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get roadsideDealAction;

  /// No description provided for @roadsidePayAction.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get roadsidePayAction;

  /// No description provided for @roadsidePayFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get roadsidePayFeeLabel;

  /// No description provided for @roadsidePayTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get roadsidePayTypeLabel;

  /// No description provided for @roadsidePayTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get roadsidePayTypeCash;

  /// No description provided for @roadsidePayTypeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get roadsidePayTypeOnline;

  /// No description provided for @roadsideAttachmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get roadsideAttachmentLabel;

  /// No description provided for @roadsideUploadAction.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get roadsideUploadAction;

  /// No description provided for @roadsidePaySuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get roadsidePaySuccess;

  /// No description provided for @roadsidePayFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get roadsidePayFailed;

  /// No description provided for @roadsideConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get roadsideConfirm;

  /// No description provided for @roadsideStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get roadsideStatusLabel;

  /// No description provided for @roadsideDeviceSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get roadsideDeviceSnLabel;

  /// No description provided for @roadsideDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get roadsideDescLabel;

  /// No description provided for @roadsideReporterLabel.
  ///
  /// In en, this message translates to:
  /// **'Reporter'**
  String get roadsideReporterLabel;

  /// No description provided for @roadsideReportTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported At'**
  String get roadsideReportTimeLabel;

  /// No description provided for @roadsideLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get roadsideLocationLabel;

  /// No description provided for @roadsideProcessTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get roadsideProcessTitle;

  /// No description provided for @roadsideProcessResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get roadsideProcessResult;

  /// No description provided for @roadsideProcessDesc.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get roadsideProcessDesc;

  /// No description provided for @roadsideProcessTime.
  ///
  /// In en, this message translates to:
  /// **'Processed At'**
  String get roadsideProcessTime;

  /// No description provided for @roadsideDealTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing Result'**
  String get roadsideDealTitle;

  /// No description provided for @roadsideDealResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get roadsideDealResultLabel;

  /// No description provided for @roadsideDealDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get roadsideDealDescLabel;

  /// No description provided for @roadsideDealDescHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the description...'**
  String get roadsideDealDescHint;

  /// No description provided for @roadsideUploadLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload Images'**
  String get roadsideUploadLabel;

  /// No description provided for @roadsideDealSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted successfully'**
  String get roadsideDealSuccess;

  /// No description provided for @roadsideDealFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get roadsideDealFailed;

  /// No description provided for @roadsideRescueResult.
  ///
  /// In en, this message translates to:
  /// **'Rescue Result'**
  String get roadsideRescueResult;

  /// No description provided for @roadsidePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get roadsidePhotoLabel;

  /// No description provided for @roadsideSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get roadsideSubmitButton;

  /// No description provided for @roadsideDescRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get roadsideDescRequired;

  /// No description provided for @roadsideDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get roadsideDescriptionTitle;

  /// No description provided for @roadsideFounderLabel.
  ///
  /// In en, this message translates to:
  /// **'Founder'**
  String get roadsideFounderLabel;

  /// No description provided for @roadsideCreationTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Creation Time'**
  String get roadsideCreationTimeLabel;

  /// No description provided for @roadsideReportSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Report Source'**
  String get roadsideReportSourceLabel;

  /// No description provided for @roadsideSourceApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get roadsideSourceApp;

  /// No description provided for @roadsideSourceWeb.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get roadsideSourceWeb;

  /// No description provided for @roadsideProcessingResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing Result'**
  String get roadsideProcessingResultTitle;

  /// No description provided for @roadsideCostsTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Costs'**
  String get roadsideCostsTitle;

  /// No description provided for @roadsideTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get roadsideTotalLabel;

  /// No description provided for @roadsidePaymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get roadsidePaymentMethodLabel;

  /// No description provided for @roadsideUploadVoucherLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload Voucher'**
  String get roadsideUploadVoucherLabel;

  /// No description provided for @roadsideNotPayingYet.
  ///
  /// In en, this message translates to:
  /// **'Not Paying Yet'**
  String get roadsideNotPayingYet;

  /// No description provided for @roadsideConfirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get roadsideConfirmPayment;

  /// No description provided for @offlineRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline User Registration'**
  String get offlineRegisterTitle;

  /// No description provided for @offlineRegisterAreaCode.
  ///
  /// In en, this message translates to:
  /// **'Select country/area code'**
  String get offlineRegisterAreaCode;

  /// No description provided for @offlineRegisterPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get offlineRegisterPhone;

  /// No description provided for @offlineRegisterPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get offlineRegisterPhoneHint;

  /// No description provided for @offlineRegisterSmsCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get offlineRegisterSmsCode;

  /// No description provided for @offlineRegisterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get offlineRegisterCodeHint;

  /// No description provided for @offlineRegisterSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get offlineRegisterSendCode;

  /// No description provided for @offlineRegisterPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get offlineRegisterPassword;

  /// No description provided for @offlineRegisterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get offlineRegisterPasswordHint;

  /// No description provided for @offlineRegisterFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get offlineRegisterFirstName;

  /// No description provided for @offlineRegisterFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get offlineRegisterFirstNameHint;

  /// No description provided for @offlineRegisterLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get offlineRegisterLastName;

  /// No description provided for @offlineRegisterLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get offlineRegisterLastNameHint;

  /// No description provided for @offlineRegisterUsername.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get offlineRegisterUsername;

  /// No description provided for @offlineRegisterUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Used for logging'**
  String get offlineRegisterUsernameHint;

  /// No description provided for @offlineRegisterBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get offlineRegisterBirthday;

  /// No description provided for @offlineRegisterBirthdayHint.
  ///
  /// In en, this message translates to:
  /// **'Select your birthday'**
  String get offlineRegisterBirthdayHint;

  /// No description provided for @offlineRegisterEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get offlineRegisterEmail;

  /// No description provided for @offlineRegisterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get offlineRegisterEmailHint;

  /// No description provided for @offlineRegisterReferrer.
  ///
  /// In en, this message translates to:
  /// **'Referrer'**
  String get offlineRegisterReferrer;

  /// No description provided for @offlineRegisterReferrerHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the referrer id or scan code'**
  String get offlineRegisterReferrerHint;

  /// No description provided for @offlineRegisterSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country / Region'**
  String get offlineRegisterSelectCountry;

  /// No description provided for @offlineRegisterSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get offlineRegisterSubmit;

  /// No description provided for @offlineRegisterPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone'**
  String get offlineRegisterPhoneRequired;

  /// No description provided for @offlineRegisterCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter code'**
  String get offlineRegisterCodeRequired;

  /// No description provided for @offlineRegisterPasswordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8-16 characters'**
  String get offlineRegisterPasswordInvalid;

  /// No description provided for @offlineRegisterFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter first name'**
  String get offlineRegisterFirstNameRequired;

  /// No description provided for @offlineRegisterLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter last name'**
  String get offlineRegisterLastNameRequired;

  /// No description provided for @offlineRegisterUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get offlineRegisterUsernameRequired;

  /// No description provided for @offlineRegisterEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get offlineRegisterEmailInvalid;

  /// No description provided for @offlineRegisterSendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code sent'**
  String get offlineRegisterSendSuccess;

  /// No description provided for @offlineRegisterSendFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code'**
  String get offlineRegisterSendFail;

  /// No description provided for @offlineRegisterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get offlineRegisterSuccess;

  /// No description provided for @offlineRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get offlineRegisterFailed;

  /// No description provided for @sellBindTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Binding'**
  String get sellBindTitle;

  /// No description provided for @sellBindPlanSection.
  ///
  /// In en, this message translates to:
  /// **'Service Plan'**
  String get sellBindPlanSection;

  /// No description provided for @sellBindDeviceSection.
  ///
  /// In en, this message translates to:
  /// **'Device Info'**
  String get sellBindDeviceSection;

  /// No description provided for @sellBindDeviceSn.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get sellBindDeviceSn;

  /// No description provided for @sellBindDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Details'**
  String get sellBindDeviceInfo;

  /// No description provided for @sellBindUserSection.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get sellBindUserSection;

  /// No description provided for @sellBindCardNum.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get sellBindCardNum;

  /// No description provided for @sellBindFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get sellBindFirstName;

  /// No description provided for @sellBindLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get sellBindLastName;

  /// No description provided for @sellBindPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get sellBindPhone;

  /// No description provided for @sellBindIdNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get sellBindIdNumber;

  /// No description provided for @sellBindEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get sellBindEmail;

  /// No description provided for @sellBindBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get sellBindBirthday;

  /// No description provided for @sellBindAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get sellBindAddress;

  /// No description provided for @sellBindAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get sellBindAttachment;

  /// No description provided for @sellBindCardImage.
  ///
  /// In en, this message translates to:
  /// **'Card Photo'**
  String get sellBindCardImage;

  /// No description provided for @sellBindPersonImage.
  ///
  /// In en, this message translates to:
  /// **'User Photo'**
  String get sellBindPersonImage;

  /// No description provided for @sellBindPaymentSection.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get sellBindPaymentSection;

  /// No description provided for @sellBindPayCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get sellBindPayCash;

  /// No description provided for @sellBindPayOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get sellBindPayOnline;

  /// No description provided for @sellBindPayFull.
  ///
  /// In en, this message translates to:
  /// **'Full Payment'**
  String get sellBindPayFull;

  /// No description provided for @sellBindPayInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get sellBindPayInstallment;

  /// No description provided for @sellBindSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get sellBindSubmit;

  /// No description provided for @sellBindDeviceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device info'**
  String get sellBindDeviceEmpty;

  /// No description provided for @sellBindPlanSearch.
  ///
  /// In en, this message translates to:
  /// **'Search plan name'**
  String get sellBindPlanSearch;

  /// No description provided for @sellBindPlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plans'**
  String get sellBindPlanEmpty;

  /// No description provided for @sellBindPlanPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sellBindPlanPrice;

  /// No description provided for @sellBindSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get sellBindSuccess;

  /// No description provided for @sellBindFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get sellBindFailed;

  /// No description provided for @sellBindPlanHint.
  ///
  /// In en, this message translates to:
  /// **'Select plan'**
  String get sellBindPlanHint;

  /// No description provided for @sellBindPlanPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get sellBindPlanPeriod;

  /// No description provided for @sellBindPackage.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get sellBindPackage;

  /// No description provided for @sellBindPackageHint.
  ///
  /// In en, this message translates to:
  /// **'Search Package'**
  String get sellBindPackageHint;

  /// No description provided for @sellBindNoPackageInfo.
  ///
  /// In en, this message translates to:
  /// **'No package info'**
  String get sellBindNoPackageInfo;

  /// No description provided for @sellBindDeviceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN or scan'**
  String get sellBindDeviceSnHint;

  /// No description provided for @sellBindNoDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'No device info'**
  String get sellBindNoDeviceInfo;

  /// No description provided for @sellBindChoosePackage.
  ///
  /// In en, this message translates to:
  /// **'Choose Package'**
  String get sellBindChoosePackage;

  /// No description provided for @sellBindPackageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get sellBindPackageSearchHint;

  /// No description provided for @sellBindSelectApplicant.
  ///
  /// In en, this message translates to:
  /// **'Select Applicant'**
  String get sellBindSelectApplicant;

  /// No description provided for @sellBindUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter User ID or scan'**
  String get sellBindUserIdHint;

  /// No description provided for @sellBindAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sellBindAccount;

  /// No description provided for @sellBindNid.
  ///
  /// In en, this message translates to:
  /// **'NID'**
  String get sellBindNid;

  /// No description provided for @sellBindUploadNidPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload NID Photo'**
  String get sellBindUploadNidPhoto;

  /// No description provided for @sellBindNidPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Please upload the front and back of your NID'**
  String get sellBindNidPhotoHint;

  /// No description provided for @sellBindPersonalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Personal Photo'**
  String get sellBindPersonalPhoto;

  /// No description provided for @sellBindSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit successfully'**
  String get sellBindSuccessTitle;

  /// No description provided for @sellBindSuccessMessageOnline.
  ///
  /// In en, this message translates to:
  /// **'The package has been successfully bound.\nPlease remind the user to pay the package fee in the app.\nThe package will take effect after payment.'**
  String get sellBindSuccessMessageOnline;

  /// No description provided for @sellBindSuccessMessageCash.
  ///
  /// In en, this message translates to:
  /// **'The package has been successfully bound.\nPlease submit the contract voucher to the backend in time.'**
  String get sellBindSuccessMessageCash;

  /// No description provided for @sellBindDocumentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document Number'**
  String get sellBindDocumentNumber;

  /// No description provided for @sellBindCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get sellBindCopied;

  /// No description provided for @sellBindReturnWorkbench.
  ///
  /// In en, this message translates to:
  /// **'Return to Workbench'**
  String get sellBindReturnWorkbench;

  /// No description provided for @sellBindUnableSubmit.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit'**
  String get sellBindUnableSubmit;

  /// No description provided for @sellBindModelMismatch.
  ///
  /// In en, this message translates to:
  /// **'Model mismatch'**
  String get sellBindModelMismatch;

  /// No description provided for @sellBindSelectPayment.
  ///
  /// In en, this message translates to:
  /// **'Select Payment'**
  String get sellBindSelectPayment;

  /// No description provided for @sellBindPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get sellBindPaymentMethods;

  /// No description provided for @sellBindPaymentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Payment Period'**
  String get sellBindPaymentPeriod;

  /// No description provided for @sellBindFinancial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get sellBindFinancial;

  /// No description provided for @sellBindPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get sellBindPrincipal;

  /// No description provided for @sellBindTotalInterest.
  ///
  /// In en, this message translates to:
  /// **'Total Interest'**
  String get sellBindTotalInterest;

  /// No description provided for @sellBindTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get sellBindTotal;

  /// No description provided for @sellBindPeriods.
  ///
  /// In en, this message translates to:
  /// **'Periods'**
  String get sellBindPeriods;

  /// No description provided for @sellBindAnnualRate.
  ///
  /// In en, this message translates to:
  /// **'Annual Interest Rate'**
  String get sellBindAnnualRate;

  /// No description provided for @sellBindNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get sellBindNext;

  /// No description provided for @sellBindSelectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get sellBindSelectPeriod;

  /// No description provided for @sellBindEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get sellBindEmailHint;

  /// No description provided for @sellBindAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get sellBindAddressHint;

  /// No description provided for @rentBindTitle.
  ///
  /// In en, this message translates to:
  /// **'Lease Binding'**
  String get rentBindTitle;

  /// No description provided for @rentBindDeviceSection.
  ///
  /// In en, this message translates to:
  /// **'Device Info'**
  String get rentBindDeviceSection;

  /// No description provided for @rentBindDeviceSn.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get rentBindDeviceSn;

  /// No description provided for @rentBindDeviceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device sn or scan QR code'**
  String get rentBindDeviceSnHint;

  /// No description provided for @rentBindDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Details'**
  String get rentBindDeviceInfo;

  /// No description provided for @rentBindNoDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'No device parameter info'**
  String get rentBindNoDeviceInfo;

  /// No description provided for @rentBindUserSection.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get rentBindUserSection;

  /// No description provided for @rentBindCardNum.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get rentBindCardNum;

  /// No description provided for @rentBindFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get rentBindFirstName;

  /// No description provided for @rentBindLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get rentBindLastName;

  /// No description provided for @rentBindPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get rentBindPhone;

  /// No description provided for @rentBindIdNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get rentBindIdNumber;

  /// No description provided for @rentBindEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get rentBindEmail;

  /// No description provided for @rentBindBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get rentBindBirthday;

  /// No description provided for @rentBindAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get rentBindAddress;

  /// No description provided for @rentBindAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get rentBindAttachment;

  /// No description provided for @rentBindCardImage.
  ///
  /// In en, this message translates to:
  /// **'Card Photo'**
  String get rentBindCardImage;

  /// No description provided for @rentBindPersonImage.
  ///
  /// In en, this message translates to:
  /// **'User Photo'**
  String get rentBindPersonImage;

  /// No description provided for @rentBindPaymentSection.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get rentBindPaymentSection;

  /// No description provided for @rentBindPayCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get rentBindPayCash;

  /// No description provided for @rentBindPayOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get rentBindPayOnline;

  /// No description provided for @rentBindPayFull.
  ///
  /// In en, this message translates to:
  /// **'Full Payment'**
  String get rentBindPayFull;

  /// No description provided for @rentBindSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get rentBindSubmit;

  /// No description provided for @rentBindDeviceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device info'**
  String get rentBindDeviceEmpty;

  /// No description provided for @rentBindSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get rentBindSuccess;

  /// No description provided for @rentBindFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get rentBindFailed;

  /// No description provided for @rentBindPackEmpty.
  ///
  /// In en, this message translates to:
  /// **'No packages'**
  String get rentBindPackEmpty;

  /// No description provided for @rentBindPackAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get rentBindPackAmount;

  /// No description provided for @rentBindPackage.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get rentBindPackage;

  /// No description provided for @rentBindPackageHint.
  ///
  /// In en, this message translates to:
  /// **'Select the lease package'**
  String get rentBindPackageHint;

  /// No description provided for @rentBindNoPackageInfo.
  ///
  /// In en, this message translates to:
  /// **'No package info'**
  String get rentBindNoPackageInfo;

  /// No description provided for @rentBindSelectPackage.
  ///
  /// In en, this message translates to:
  /// **'Select Package'**
  String get rentBindSelectPackage;

  /// No description provided for @rentBindServicePeriod.
  ///
  /// In en, this message translates to:
  /// **'Service Period'**
  String get rentBindServicePeriod;

  /// No description provided for @rentBindDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get rentBindDeposit;

  /// No description provided for @rentBindReselect.
  ///
  /// In en, this message translates to:
  /// **'Reselect'**
  String get rentBindReselect;

  /// No description provided for @rentBindSelectApplicant.
  ///
  /// In en, this message translates to:
  /// **'Select Applicant'**
  String get rentBindSelectApplicant;

  /// No description provided for @rentBindUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the user ID or scan QR code'**
  String get rentBindUserIdHint;

  /// No description provided for @rentBindAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get rentBindAccount;

  /// No description provided for @rentBindNid.
  ///
  /// In en, this message translates to:
  /// **'NID'**
  String get rentBindNid;

  /// No description provided for @rentBindUploadNidPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload NID Photo'**
  String get rentBindUploadNidPhoto;

  /// No description provided for @rentBindNidPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Front and back ID photos'**
  String get rentBindNidPhotoHint;

  /// No description provided for @rentBindPersonalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Personal Photo'**
  String get rentBindPersonalPhoto;

  /// No description provided for @rentBindEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Fill in your email address'**
  String get rentBindEmailHint;

  /// No description provided for @rentBindAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Fill in your email address'**
  String get rentBindAddressHint;

  /// No description provided for @rentBindSelectPayment.
  ///
  /// In en, this message translates to:
  /// **'Select Payment'**
  String get rentBindSelectPayment;

  /// No description provided for @rentBindPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get rentBindPaymentMethods;

  /// No description provided for @rentBindPaymentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Payment Period'**
  String get rentBindPaymentPeriod;

  /// No description provided for @rentBindLeaseAmount.
  ///
  /// In en, this message translates to:
  /// **'Lease Amount'**
  String get rentBindLeaseAmount;

  /// No description provided for @rentBindTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get rentBindTotal;

  /// No description provided for @rentBindConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get rentBindConfirm;

  /// No description provided for @rentBindSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit successfully'**
  String get rentBindSuccessTitle;

  /// No description provided for @rentBindSuccessMessageOnline.
  ///
  /// In en, this message translates to:
  /// **'Please proceed to the User App for payment in'**
  String get rentBindSuccessMessageOnline;

  /// No description provided for @rentBindSuccessMessageCash.
  ///
  /// In en, this message translates to:
  /// **'Please enter the order record and submit the contract voucher within'**
  String get rentBindSuccessMessageCash;

  /// No description provided for @rentBindDocumentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document Number'**
  String get rentBindDocumentNumber;

  /// No description provided for @rentBindCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get rentBindCopied;

  /// No description provided for @rentBindReturnWorkbench.
  ///
  /// In en, this message translates to:
  /// **'Return to Workbench'**
  String get rentBindReturnWorkbench;

  /// No description provided for @swapBindTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap Binding'**
  String get swapBindTitle;

  /// No description provided for @swapBindUserSection.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get swapBindUserSection;

  /// No description provided for @swapBindCardNum.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get swapBindCardNum;

  /// No description provided for @swapBindVehicleSection.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get swapBindVehicleSection;

  /// No description provided for @swapBindBatterySection.
  ///
  /// In en, this message translates to:
  /// **'Batteries'**
  String get swapBindBatterySection;

  /// No description provided for @swapBindLoadPackages.
  ///
  /// In en, this message translates to:
  /// **'Load Packages'**
  String get swapBindLoadPackages;

  /// No description provided for @swapBindPaymentSection.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get swapBindPaymentSection;

  /// No description provided for @swapBindPayCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get swapBindPayCash;

  /// No description provided for @swapBindPayOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get swapBindPayOnline;

  /// No description provided for @swapBindSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get swapBindSubmit;

  /// No description provided for @swapBindSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get swapBindSuccess;

  /// No description provided for @swapBindFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get swapBindFailed;

  /// No description provided for @swapBindVehicleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No vehicles'**
  String get swapBindVehicleEmpty;

  /// No description provided for @swapBindBatteryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No batteries'**
  String get swapBindBatteryEmpty;

  /// No description provided for @swapBindPackEmpty.
  ///
  /// In en, this message translates to:
  /// **'No packages'**
  String get swapBindPackEmpty;

  /// No description provided for @swapBindPackAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get swapBindPackAmount;

  /// No description provided for @swapBindUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get swapBindUserId;

  /// No description provided for @swapBindUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter User ID or scan QR code'**
  String get swapBindUserIdHint;

  /// No description provided for @swapBindUserEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter User ID to search'**
  String get swapBindUserEmpty;

  /// No description provided for @swapBindBindVehicle.
  ///
  /// In en, this message translates to:
  /// **'Bind Vehicle'**
  String get swapBindBindVehicle;

  /// No description provided for @swapBindSelectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get swapBindSelectVehicle;

  /// No description provided for @swapBindSelectVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get swapBindSelectVehicleTitle;

  /// No description provided for @swapBindBindBattery.
  ///
  /// In en, this message translates to:
  /// **'Bind Battery'**
  String get swapBindBindBattery;

  /// No description provided for @swapBindSelectBattery.
  ///
  /// In en, this message translates to:
  /// **'Select Battery'**
  String get swapBindSelectBattery;

  /// No description provided for @swapBindSelectBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Battery'**
  String get swapBindSelectBatteryTitle;

  /// No description provided for @swapBindPackage.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get swapBindPackage;

  /// No description provided for @swapBindSelectPackage.
  ///
  /// In en, this message translates to:
  /// **'Select Package'**
  String get swapBindSelectPackage;

  /// No description provided for @swapBindSelectPackageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Package'**
  String get swapBindSelectPackageTitle;

  /// No description provided for @swapBindReselect.
  ///
  /// In en, this message translates to:
  /// **'Reselect'**
  String get swapBindReselect;

  /// No description provided for @swapBindAvailableBattery.
  ///
  /// In en, this message translates to:
  /// **'Available Battery'**
  String get swapBindAvailableBattery;

  /// No description provided for @swapBindAvailableVehicles.
  ///
  /// In en, this message translates to:
  /// **'Available Vehicles'**
  String get swapBindAvailableVehicles;

  /// No description provided for @swapBindServicePeriod.
  ///
  /// In en, this message translates to:
  /// **'Service Period'**
  String get swapBindServicePeriod;

  /// No description provided for @swapBindSwapTime.
  ///
  /// In en, this message translates to:
  /// **'Swap Time'**
  String get swapBindSwapTime;

  /// No description provided for @swapBindSelectPayment.
  ///
  /// In en, this message translates to:
  /// **'Select Payment'**
  String get swapBindSelectPayment;

  /// No description provided for @swapBindPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get swapBindPaymentMethods;

  /// No description provided for @swapBindPaymentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Payment Period'**
  String get swapBindPaymentPeriod;

  /// No description provided for @swapBindRemainingDays.
  ///
  /// In en, this message translates to:
  /// **'Remaining Rental days'**
  String get swapBindRemainingDays;

  /// No description provided for @swapBindSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit successfully'**
  String get swapBindSuccessTitle;

  /// No description provided for @swapBindSuccessOnlineHint.
  ///
  /// In en, this message translates to:
  /// **'Please proceed to the User App for payment in'**
  String get swapBindSuccessOnlineHint;

  /// No description provided for @swapBindSuccessCashHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the order record and submit the contract voucher within'**
  String get swapBindSuccessCashHint;

  /// No description provided for @swapBindDocumentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document Number'**
  String get swapBindDocumentNumber;

  /// No description provided for @swapBindCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get swapBindCopied;

  /// No description provided for @swapBindReturnWorkbench.
  ///
  /// In en, this message translates to:
  /// **'Return to Workbench'**
  String get swapBindReturnWorkbench;

  /// No description provided for @depositRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Refund'**
  String get depositRefundTitle;

  /// No description provided for @depositRefundCardNum.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get depositRefundCardNum;

  /// No description provided for @depositRefundUserInfo.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get depositRefundUserInfo;

  /// No description provided for @depositRefundOrderSection.
  ///
  /// In en, this message translates to:
  /// **'Deposit Refund Order'**
  String get depositRefundOrderSection;

  /// No description provided for @depositRefundVoucher.
  ///
  /// In en, this message translates to:
  /// **'Deposit Voucher'**
  String get depositRefundVoucher;

  /// No description provided for @depositRefundVoucherConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Voucher checked'**
  String get depositRefundVoucherConfirmed;

  /// No description provided for @depositRefundRemark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get depositRefundRemark;

  /// No description provided for @depositRefundSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get depositRefundSubmit;

  /// No description provided for @depositRefundUserEmpty.
  ///
  /// In en, this message translates to:
  /// **'No user info'**
  String get depositRefundUserEmpty;

  /// No description provided for @depositRefundUserName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get depositRefundUserName;

  /// No description provided for @depositRefundUserPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get depositRefundUserPhone;

  /// No description provided for @depositRefundUserCardNum.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get depositRefundUserCardNum;

  /// No description provided for @depositRefundSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get depositRefundSuccess;

  /// No description provided for @depositRefundFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get depositRefundFailed;

  /// No description provided for @depositRefundOrderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get depositRefundOrderEmpty;

  /// No description provided for @depositRefundAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposit refund amount'**
  String get depositRefundAmount;

  /// No description provided for @depositRefundUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get depositRefundUserId;

  /// No description provided for @depositRefundUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter User ID or scan QR code'**
  String get depositRefundUserIdHint;

  /// No description provided for @depositRefundSelectOrder.
  ///
  /// In en, this message translates to:
  /// **'Select the refund order'**
  String get depositRefundSelectOrder;

  /// No description provided for @depositRefundSelectOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Deposit Refund Order'**
  String get depositRefundSelectOrderTitle;

  /// No description provided for @depositRefundReselect.
  ///
  /// In en, this message translates to:
  /// **'Reselect'**
  String get depositRefundReselect;

  /// No description provided for @depositRefundUnbindingTime.
  ///
  /// In en, this message translates to:
  /// **'Unbinding time'**
  String get depositRefundUnbindingTime;

  /// No description provided for @depositRefundDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositRefundDeposit;

  /// No description provided for @depositRefundRecycled.
  ///
  /// In en, this message translates to:
  /// **'Recycled'**
  String get depositRefundRecycled;

  /// No description provided for @depositRefundViewVoucher.
  ///
  /// In en, this message translates to:
  /// **'View Voucher'**
  String get depositRefundViewVoucher;

  /// No description provided for @depositRefundRemarkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the remarks'**
  String get depositRefundRemarkHint;

  /// No description provided for @depositRefundSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Refund Successful!'**
  String get depositRefundSuccessTitle;

  /// No description provided for @depositRefundReturnWorkbench.
  ///
  /// In en, this message translates to:
  /// **'Return to Workbench'**
  String get depositRefundReturnWorkbench;

  /// No description provided for @installmentPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Installment Payment'**
  String get installmentPayTitle;

  /// No description provided for @installmentPayCardNum.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get installmentPayCardNum;

  /// No description provided for @installmentPayUserInfo.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get installmentPayUserInfo;

  /// No description provided for @installmentPayUserEmpty.
  ///
  /// In en, this message translates to:
  /// **'No user info'**
  String get installmentPayUserEmpty;

  /// No description provided for @installmentPayUserName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get installmentPayUserName;

  /// No description provided for @installmentPayUserPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get installmentPayUserPhone;

  /// No description provided for @installmentPayTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get installmentPayTotalAmount;

  /// No description provided for @installmentPayOrderSection.
  ///
  /// In en, this message translates to:
  /// **'Installment Orders'**
  String get installmentPayOrderSection;

  /// No description provided for @installmentPayOrderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get installmentPayOrderEmpty;

  /// No description provided for @installmentPayOrderNo.
  ///
  /// In en, this message translates to:
  /// **'Order No'**
  String get installmentPayOrderNo;

  /// No description provided for @installmentPayPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get installmentPayPeriod;

  /// No description provided for @installmentPayRemainPeriod.
  ///
  /// In en, this message translates to:
  /// **'Remaining Periods'**
  String get installmentPayRemainPeriod;

  /// No description provided for @installmentPayRemainPay.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get installmentPayRemainPay;

  /// No description provided for @installmentPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get installmentPayAmount;

  /// No description provided for @installmentPayAttachment.
  ///
  /// In en, this message translates to:
  /// **'Voucher'**
  String get installmentPayAttachment;

  /// No description provided for @installmentPayAddAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Voucher'**
  String get installmentPayAddAttachment;

  /// No description provided for @installmentPaySubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get installmentPaySubmit;

  /// No description provided for @installmentPaySuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get installmentPaySuccess;

  /// No description provided for @installmentPayFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get installmentPayFailed;

  /// No description provided for @installmentPayUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get installmentPayUploadFailed;

  /// No description provided for @installmentPayUploadPartialFailed.
  ///
  /// In en, this message translates to:
  /// **'Some uploads failed'**
  String get installmentPayUploadPartialFailed;

  /// No description provided for @installmentPayUploadLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 images'**
  String get installmentPayUploadLimit;

  /// No description provided for @installmentPayUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get installmentPayUserId;

  /// No description provided for @installmentPayUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter User ID or scan QR code'**
  String get installmentPayUserIdHint;

  /// No description provided for @installmentPayOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get installmentPayOrder;

  /// No description provided for @installmentPayTotalConsumption.
  ///
  /// In en, this message translates to:
  /// **'Total Consumption'**
  String get installmentPayTotalConsumption;

  /// No description provided for @installmentPayAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get installmentPayAssets;

  /// No description provided for @installmentPayNoOverdue.
  ///
  /// In en, this message translates to:
  /// **'Orders currently in installments have no overdue records'**
  String get installmentPayNoOverdue;

  /// No description provided for @installmentPayPaymentOrder.
  ///
  /// In en, this message translates to:
  /// **'Payment Order'**
  String get installmentPayPaymentOrder;

  /// No description provided for @installmentPaySelectOrder.
  ///
  /// In en, this message translates to:
  /// **'Select payment order'**
  String get installmentPaySelectOrder;

  /// No description provided for @installmentPaySelectOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Order'**
  String get installmentPaySelectOrderTitle;

  /// No description provided for @installmentPayReselect.
  ///
  /// In en, this message translates to:
  /// **'Reselect'**
  String get installmentPayReselect;

  /// No description provided for @installmentPayDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get installmentPayDevice;

  /// No description provided for @installmentPayDueDate.
  ///
  /// In en, this message translates to:
  /// **'The latest due date'**
  String get installmentPayDueDate;

  /// No description provided for @installmentPayMonthlyAmount.
  ///
  /// In en, this message translates to:
  /// **'Monthly repayment amount'**
  String get installmentPayMonthlyAmount;

  /// No description provided for @installmentPayRemainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining amount'**
  String get installmentPayRemainingAmount;

  /// No description provided for @installmentPayRemainingInstallments.
  ///
  /// In en, this message translates to:
  /// **'Remaining installments'**
  String get installmentPayRemainingInstallments;

  /// No description provided for @installmentPayVoucher.
  ///
  /// In en, this message translates to:
  /// **'Payment Voucher'**
  String get installmentPayVoucher;

  /// No description provided for @installmentPaySuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit successfully'**
  String get installmentPaySuccessTitle;

  /// No description provided for @installmentPaySuccessHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the order record page to view'**
  String get installmentPaySuccessHint;

  /// No description provided for @installmentPayDocumentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document Number'**
  String get installmentPayDocumentNumber;

  /// No description provided for @installmentPayCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get installmentPayCopied;

  /// No description provided for @installmentPayReturnWorkbench.
  ///
  /// In en, this message translates to:
  /// **'Return to Workbench'**
  String get installmentPayReturnWorkbench;

  /// No description provided for @merchantReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Swap'**
  String get merchantReplaceTitle;

  /// No description provided for @merchantReplaceCardNum.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get merchantReplaceCardNum;

  /// No description provided for @merchantReplaceOldSn.
  ///
  /// In en, this message translates to:
  /// **'Old Battery SN'**
  String get merchantReplaceOldSn;

  /// No description provided for @merchantReplaceNewSn.
  ///
  /// In en, this message translates to:
  /// **'New Battery SN'**
  String get merchantReplaceNewSn;

  /// No description provided for @merchantReplaceReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get merchantReplaceReason;

  /// No description provided for @merchantReplaceSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get merchantReplaceSubmit;

  /// No description provided for @merchantReplaceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get merchantReplaceSuccess;

  /// No description provided for @merchantReplaceFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get merchantReplaceFailed;

  /// No description provided for @merchantReplaceSameSn.
  ///
  /// In en, this message translates to:
  /// **'New battery cannot be same as old'**
  String get merchantReplaceSameSn;

  /// No description provided for @merchantReplaceUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get merchantReplaceUserId;

  /// No description provided for @merchantReplaceUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter User ID or scan QR code'**
  String get merchantReplaceUserIdHint;

  /// No description provided for @merchantReplaceBoundBatterySn.
  ///
  /// In en, this message translates to:
  /// **'Bound Battery SN'**
  String get merchantReplaceBoundBatterySn;

  /// No description provided for @merchantReplaceBatterySnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter battery SN or scan QR code'**
  String get merchantReplaceBatterySnHint;

  /// No description provided for @merchantReplaceNewBattery.
  ///
  /// In en, this message translates to:
  /// **'New Battery'**
  String get merchantReplaceNewBattery;

  /// No description provided for @merchantReplaceReasons.
  ///
  /// In en, this message translates to:
  /// **'Reasons'**
  String get merchantReplaceReasons;

  /// No description provided for @merchantReplaceReasonsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter reasons for battery swapping'**
  String get merchantReplaceReasonsHint;

  /// No description provided for @saleSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Summary'**
  String get saleSummaryTitle;

  /// No description provided for @saleSummaryDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get saleSummaryDateRange;

  /// No description provided for @saleSummarySelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get saleSummarySelectDate;

  /// No description provided for @saleSummaryPayWayAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get saleSummaryPayWayAll;

  /// No description provided for @saleSummaryPayWayCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get saleSummaryPayWayCash;

  /// No description provided for @saleSummaryPayWayOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get saleSummaryPayWayOnline;

  /// No description provided for @saleSummarySummarySection.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get saleSummarySummarySection;

  /// No description provided for @saleSummaryIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get saleSummaryIncome;

  /// No description provided for @saleSummaryOrderCount.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get saleSummaryOrderCount;

  /// No description provided for @saleSummaryAvgOrder.
  ///
  /// In en, this message translates to:
  /// **'Average Order'**
  String get saleSummaryAvgOrder;

  /// No description provided for @saleSummarySignRate.
  ///
  /// In en, this message translates to:
  /// **'Sign Rate'**
  String get saleSummarySignRate;

  /// No description provided for @saleSummaryIncomeRank.
  ///
  /// In en, this message translates to:
  /// **'Income Rank'**
  String get saleSummaryIncomeRank;

  /// No description provided for @saleSummaryNumRank.
  ///
  /// In en, this message translates to:
  /// **'Order Rank'**
  String get saleSummaryNumRank;

  /// No description provided for @saleSummaryChartHint.
  ///
  /// In en, this message translates to:
  /// **'Chart data points'**
  String get saleSummaryChartHint;

  /// No description provided for @saleSummaryListSection.
  ///
  /// In en, this message translates to:
  /// **'Order List'**
  String get saleSummaryListSection;

  /// No description provided for @saleSummaryListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get saleSummaryListEmpty;

  /// No description provided for @saleSummaryOrderNo.
  ///
  /// In en, this message translates to:
  /// **'Order No'**
  String get saleSummaryOrderNo;

  /// No description provided for @saleSummaryAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get saleSummaryAmount;

  /// No description provided for @saleSummaryPayWay.
  ///
  /// In en, this message translates to:
  /// **'Pay Way'**
  String get saleSummaryPayWay;

  /// No description provided for @saleSummaryTotalSalesAmount.
  ///
  /// In en, this message translates to:
  /// **'Total sales amount(\$)'**
  String get saleSummaryTotalSalesAmount;

  /// No description provided for @saleSummaryTransactionOrder.
  ///
  /// In en, this message translates to:
  /// **'Transaction order'**
  String get saleSummaryTransactionOrder;

  /// No description provided for @saleSummarySigningRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Signing rate & Order value'**
  String get saleSummarySigningRateTitle;

  /// No description provided for @saleSummaryOrderSigningRate.
  ///
  /// In en, this message translates to:
  /// **'Order signing rate'**
  String get saleSummaryOrderSigningRate;

  /// No description provided for @saleSummaryAverageOrderPrice.
  ///
  /// In en, this message translates to:
  /// **'Average order price'**
  String get saleSummaryAverageOrderPrice;

  /// No description provided for @saleSummarySalesAmount.
  ///
  /// In en, this message translates to:
  /// **'Sales Amount'**
  String get saleSummarySalesAmount;

  /// No description provided for @saleSummaryTransactionOrderTab.
  ///
  /// In en, this message translates to:
  /// **'Transaction Order'**
  String get saleSummaryTransactionOrderTab;

  /// No description provided for @saleSummarySalesData.
  ///
  /// In en, this message translates to:
  /// **'Sales Data'**
  String get saleSummarySalesData;

  /// No description provided for @saleSummaryAfterSalesData.
  ///
  /// In en, this message translates to:
  /// **'After-Sales Data'**
  String get saleSummaryAfterSalesData;

  /// No description provided for @saleSummarySelectData.
  ///
  /// In en, this message translates to:
  /// **'Select Data Type'**
  String get saleSummarySelectData;

  /// No description provided for @saleSummaryViewVoucher.
  ///
  /// In en, this message translates to:
  /// **'View Voucher'**
  String get saleSummaryViewVoucher;

  /// No description provided for @cabinetPutawayTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Putaway'**
  String get cabinetPutawayTitle;

  /// No description provided for @cabinetPutawaySn.
  ///
  /// In en, this message translates to:
  /// **'Station SN'**
  String get cabinetPutawaySn;

  /// No description provided for @cabinetPutawayInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Info'**
  String get cabinetPutawayInfoTitle;

  /// No description provided for @cabinetPutawayInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Station info'**
  String get cabinetPutawayInfoEmpty;

  /// No description provided for @cabinetPutawayName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get cabinetPutawayName;

  /// No description provided for @cabinetPutawayModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get cabinetPutawayModel;

  /// No description provided for @cabinetPutawaySpec.
  ///
  /// In en, this message translates to:
  /// **'Spec'**
  String get cabinetPutawaySpec;

  /// No description provided for @cabinetPutawayAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get cabinetPutawayAddress;

  /// No description provided for @cabinetPutawayLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get cabinetPutawayLatitude;

  /// No description provided for @cabinetPutawayLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get cabinetPutawayLongitude;

  /// No description provided for @cabinetPutawaySnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station SN or scan QR code'**
  String get cabinetPutawaySnHint;

  /// No description provided for @cabinetPutawayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station name'**
  String get cabinetPutawayNameHint;

  /// No description provided for @cabinetPutawayAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station address'**
  String get cabinetPutawayAddressHint;

  /// No description provided for @cabinetPutawayCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get cabinetPutawayCoordinates;

  /// No description provided for @cabinetPutawayTimesPerDay.
  ///
  /// In en, this message translates to:
  /// **'times/day'**
  String get cabinetPutawayTimesPerDay;

  /// No description provided for @cabinetPutawaySwapTime.
  ///
  /// In en, this message translates to:
  /// **'Battery Exchange Indicator'**
  String get cabinetPutawaySwapTime;

  /// No description provided for @cabinetPutawayStoreNum.
  ///
  /// In en, this message translates to:
  /// **'Slots'**
  String get cabinetPutawayStoreNum;

  /// No description provided for @cabinetPutawayImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get cabinetPutawayImages;

  /// No description provided for @cabinetPutawayAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get cabinetPutawayAddImage;

  /// No description provided for @cabinetPutawayImageLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to 4 images'**
  String get cabinetPutawayImageLimit;

  /// No description provided for @cabinetPutawaySubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get cabinetPutawaySubmit;

  /// No description provided for @cabinetPutawaySuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get cabinetPutawaySuccess;

  /// No description provided for @cabinetPutawayFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get cabinetPutawayFailed;

  /// No description provided for @cabinetUnshelveTitle.
  ///
  /// In en, this message translates to:
  /// **'Retire Station'**
  String get cabinetUnshelveTitle;

  /// No description provided for @cabinetUnshelveSn.
  ///
  /// In en, this message translates to:
  /// **'Station SN'**
  String get cabinetUnshelveSn;

  /// No description provided for @cabinetUnshelveSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station SN or scan QR code'**
  String get cabinetUnshelveSnHint;

  /// No description provided for @cabinetUnshelveInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Info'**
  String get cabinetUnshelveInfoTitle;

  /// No description provided for @cabinetUnshelveInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device parameter info'**
  String get cabinetUnshelveInfoEmpty;

  /// No description provided for @cabinetUnshelveName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get cabinetUnshelveName;

  /// No description provided for @cabinetUnshelveModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get cabinetUnshelveModel;

  /// No description provided for @cabinetUnshelveReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get cabinetUnshelveReason;

  /// No description provided for @cabinetUnshelveReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reasons For Retirement'**
  String get cabinetUnshelveReasonLabel;

  /// No description provided for @cabinetUnshelveReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter reasons'**
  String get cabinetUnshelveReasonHint;

  /// No description provided for @cabinetUnshelveCommonReasons.
  ///
  /// In en, this message translates to:
  /// **'Common Reasons'**
  String get cabinetUnshelveCommonReasons;

  /// No description provided for @cabinetUnshelveReason1.
  ///
  /// In en, this message translates to:
  /// **'The point dealer does not renew the contract'**
  String get cabinetUnshelveReason1;

  /// No description provided for @cabinetUnshelveReason2.
  ///
  /// In en, this message translates to:
  /// **'Efficiency is not up to standard'**
  String get cabinetUnshelveReason2;

  /// No description provided for @cabinetUnshelveReason3.
  ///
  /// In en, this message translates to:
  /// **'Device damage and retire to repair'**
  String get cabinetUnshelveReason3;

  /// No description provided for @cabinetUnshelveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Retire?'**
  String get cabinetUnshelveConfirmTitle;

  /// No description provided for @cabinetUnshelveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'After deactivation, the operating hours of the station will be cleared. If relisted, please modify the operating hours in management portal.'**
  String get cabinetUnshelveConfirmMessage;

  /// No description provided for @cabinetUnshelveSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get cabinetUnshelveSubmit;

  /// No description provided for @cabinetUnshelveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get cabinetUnshelveSuccess;

  /// No description provided for @cabinetUnshelveFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get cabinetUnshelveFailed;

  /// No description provided for @cabinetAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Station operation authorization'**
  String get cabinetAuthTitle;

  /// No description provided for @cabinetAuthStationLabel.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get cabinetAuthStationLabel;

  /// No description provided for @cabinetAuthSelectStation.
  ///
  /// In en, this message translates to:
  /// **'Select a station'**
  String get cabinetAuthSelectStation;

  /// No description provided for @cabinetAuthSelectStationTitle.
  ///
  /// In en, this message translates to:
  /// **'Select station'**
  String get cabinetAuthSelectStationTitle;

  /// No description provided for @cabinetAuthStationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station SN or scan QR code'**
  String get cabinetAuthStationSearchHint;

  /// No description provided for @cabinetAuthSelectStationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a station'**
  String get cabinetAuthSelectStationRequired;

  /// No description provided for @cabinetAuthPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Authorized person'**
  String get cabinetAuthPersonLabel;

  /// No description provided for @cabinetAuthSelectPerson.
  ///
  /// In en, this message translates to:
  /// **'Select authorized person'**
  String get cabinetAuthSelectPerson;

  /// No description provided for @cabinetAuthSelectPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Select authorized person'**
  String get cabinetAuthSelectPersonTitle;

  /// No description provided for @cabinetAuthPersonSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter user name or phone number'**
  String get cabinetAuthPersonSearchHint;

  /// No description provided for @cabinetAuthSelectPersonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select authorized person'**
  String get cabinetAuthSelectPersonRequired;

  /// No description provided for @cabinetAuthTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Authorization time'**
  String get cabinetAuthTimeLabel;

  /// No description provided for @cabinetAuthConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Authorization'**
  String get cabinetAuthConfirmButton;

  /// No description provided for @cabinetAuthRecordButton.
  ///
  /// In en, this message translates to:
  /// **'Authorized Record'**
  String get cabinetAuthRecordButton;

  /// No description provided for @cabinetAuthRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Authorized Record'**
  String get cabinetAuthRecordTitle;

  /// No description provided for @cabinetAuthCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Authorization'**
  String get cabinetAuthCancelTitle;

  /// No description provided for @cabinetAuthCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this authorization?'**
  String get cabinetAuthCancelConfirm;

  /// No description provided for @cabinetAuthCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Authorization cancelled'**
  String get cabinetAuthCancelSuccess;

  /// No description provided for @cabinetAuthCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel authorization'**
  String get cabinetAuthCancelFailed;

  /// No description provided for @cabinetAuthAllPort.
  ///
  /// In en, this message translates to:
  /// **'All port'**
  String get cabinetAuthAllPort;

  /// No description provided for @cabinetAuthFaultPort.
  ///
  /// In en, this message translates to:
  /// **'Fault port'**
  String get cabinetAuthFaultPort;

  /// No description provided for @cabinetAuthDisablePort.
  ///
  /// In en, this message translates to:
  /// **'Disable port'**
  String get cabinetAuthDisablePort;

  /// No description provided for @cabinetAuthSwapStandard.
  ///
  /// In en, this message translates to:
  /// **'Swap standard'**
  String get cabinetAuthSwapStandard;

  /// No description provided for @cabinetAuthWorkAccount.
  ///
  /// In en, this message translates to:
  /// **'Operation and maintenance work account'**
  String get cabinetAuthWorkAccount;

  /// No description provided for @cabinetAuthValidityPeriod.
  ///
  /// In en, this message translates to:
  /// **'Validity period'**
  String get cabinetAuthValidityPeriod;

  /// No description provided for @cabinetAuthSn.
  ///
  /// In en, this message translates to:
  /// **'Station SN'**
  String get cabinetAuthSn;

  /// No description provided for @cabinetAuthQueryCabinet.
  ///
  /// In en, this message translates to:
  /// **'Query Cabinets'**
  String get cabinetAuthQueryCabinet;

  /// No description provided for @cabinetAuthQueryRecord.
  ///
  /// In en, this message translates to:
  /// **'Query Records'**
  String get cabinetAuthQueryRecord;

  /// No description provided for @cabinetAuthCabinetList.
  ///
  /// In en, this message translates to:
  /// **'Station List'**
  String get cabinetAuthCabinetList;

  /// No description provided for @cabinetAuthUserSection.
  ///
  /// In en, this message translates to:
  /// **'Authorized Users'**
  String get cabinetAuthUserSection;

  /// No description provided for @cabinetAuthUserKeyword.
  ///
  /// In en, this message translates to:
  /// **'User Keyword'**
  String get cabinetAuthUserKeyword;

  /// No description provided for @cabinetAuthQueryUser.
  ///
  /// In en, this message translates to:
  /// **'Query Users'**
  String get cabinetAuthQueryUser;

  /// No description provided for @cabinetAuthAuthorizeSection.
  ///
  /// In en, this message translates to:
  /// **'Authorize'**
  String get cabinetAuthAuthorizeSection;

  /// No description provided for @cabinetAuthAccountNo.
  ///
  /// In en, this message translates to:
  /// **'Account No'**
  String get cabinetAuthAccountNo;

  /// No description provided for @cabinetAuthBeginTime.
  ///
  /// In en, this message translates to:
  /// **'Begin Time'**
  String get cabinetAuthBeginTime;

  /// No description provided for @cabinetAuthEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get cabinetAuthEndTime;

  /// No description provided for @cabinetAuthSubmit.
  ///
  /// In en, this message translates to:
  /// **'Authorize'**
  String get cabinetAuthSubmit;

  /// No description provided for @cabinetAuthSuccess.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get cabinetAuthSuccess;

  /// No description provided for @cabinetAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authorization failed'**
  String get cabinetAuthFailed;

  /// No description provided for @cabinetAuthCancelSection.
  ///
  /// In en, this message translates to:
  /// **'Cancel Authorization'**
  String get cabinetAuthCancelSection;

  /// No description provided for @cabinetAuthPermissionId.
  ///
  /// In en, this message translates to:
  /// **'Permission ID'**
  String get cabinetAuthPermissionId;

  /// No description provided for @cabinetAuthCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cabinetAuthCancel;

  /// No description provided for @cabinetAuthRecordSection.
  ///
  /// In en, this message translates to:
  /// **'Authorization Records'**
  String get cabinetAuthRecordSection;

  /// No description provided for @cabinetOperateTitle.
  ///
  /// In en, this message translates to:
  /// **'Staion Operation'**
  String get cabinetOperateTitle;

  /// No description provided for @cabinetOperateStationOperation.
  ///
  /// In en, this message translates to:
  /// **'Staion Operation'**
  String get cabinetOperateStationOperation;

  /// No description provided for @cabinetOperateBluetoothAuth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth key authorization'**
  String get cabinetOperateBluetoothAuth;

  /// No description provided for @cabinetOperateAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Station operation authorization'**
  String get cabinetOperateAuthorization;

  /// No description provided for @cabinetOperateOpenDoor.
  ///
  /// In en, this message translates to:
  /// **'Open Cabinet Door'**
  String get cabinetOperateOpenDoor;

  /// No description provided for @cabinetOperateOpenDoorConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Open Door'**
  String get cabinetOperateOpenDoorConfirmTitle;

  /// No description provided for @cabinetOperateOpenDoorConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to open the cabinet back door?'**
  String get cabinetOperateOpenDoorConfirmContent;

  /// No description provided for @cabinetOperateOpenDoorSuccess.
  ///
  /// In en, this message translates to:
  /// **'Door opened successfully'**
  String get cabinetOperateOpenDoorSuccess;

  /// No description provided for @cabinetOperateOpenDoorFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open door'**
  String get cabinetOperateOpenDoorFailed;

  /// No description provided for @cabinetOperateOfflineOM.
  ///
  /// In en, this message translates to:
  /// **'Offline station O&M'**
  String get cabinetOperateOfflineOM;

  /// No description provided for @cabinetOperateOfflineDetail.
  ///
  /// In en, this message translates to:
  /// **'Offline Detail'**
  String get cabinetOperateOfflineDetail;

  /// No description provided for @cabinetOfflineDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Offline Detail'**
  String get cabinetOfflineDetailTitle;

  /// No description provided for @cabinetOfflineFaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Offline Fault'**
  String get cabinetOfflineFaultTitle;

  /// No description provided for @cabinetOfflinePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get cabinetOfflinePlaceholder;

  /// No description provided for @cabinetOfflineSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Station SN'**
  String get cabinetOfflineSnLabel;

  /// No description provided for @cabinetOfflinePidLabel.
  ///
  /// In en, this message translates to:
  /// **'Station PID'**
  String get cabinetOfflinePidLabel;

  /// No description provided for @cabinetOfflineName.
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get cabinetOfflineName;

  /// No description provided for @cabinetOfflineAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get cabinetOfflineAddressLabel;

  /// No description provided for @cabinetOfflineStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get cabinetOfflineStatusLabel;

  /// No description provided for @cabinetOfflineLastHbLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Heartbeat'**
  String get cabinetOfflineLastHbLabel;

  /// No description provided for @cabinetOfflineLockDevId.
  ///
  /// In en, this message translates to:
  /// **'lockDevId'**
  String get cabinetOfflineLockDevId;

  /// No description provided for @cabinetOfflineLockIcId.
  ///
  /// In en, this message translates to:
  /// **'lockIcId'**
  String get cabinetOfflineLockIcId;

  /// No description provided for @cabinetOfflineSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Secret Key'**
  String get cabinetOfflineSecretKey;

  /// No description provided for @cabinetOfflineQueryAction.
  ///
  /// In en, this message translates to:
  /// **'Query'**
  String get cabinetOfflineQueryAction;

  /// No description provided for @cabinetOfflineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No offline info'**
  String get cabinetOfflineEmpty;

  /// No description provided for @cabinetOfflineFaultEntry.
  ///
  /// In en, this message translates to:
  /// **'View Faults'**
  String get cabinetOfflineFaultEntry;

  /// No description provided for @cabinetOfflineRealtimeTab.
  ///
  /// In en, this message translates to:
  /// **'Realtime'**
  String get cabinetOfflineRealtimeTab;

  /// No description provided for @cabinetOfflineWarehouseTab.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get cabinetOfflineWarehouseTab;

  /// No description provided for @cabinetOfflineWarehouseEmpty.
  ///
  /// In en, this message translates to:
  /// **'No warehouse info'**
  String get cabinetOfflineWarehouseEmpty;

  /// No description provided for @cabinetOfflineWarehouseTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cabinetOfflineWarehouseTotal;

  /// No description provided for @cabinetOfflineWarehouseCityCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'City code'**
  String get cabinetOfflineWarehouseCityCodeLabel;

  /// No description provided for @cabinetOfflineWarehouseLatLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get cabinetOfflineWarehouseLatLabel;

  /// No description provided for @cabinetOfflineWarehouseLngLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get cabinetOfflineWarehouseLngLabel;

  /// No description provided for @cabinetOfflineWarehouseOpPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator phone'**
  String get cabinetOfflineWarehouseOpPhoneLabel;

  /// No description provided for @cabinetOfflineWarehouseOpNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator name'**
  String get cabinetOfflineWarehouseOpNameLabel;

  /// No description provided for @cabinetOfflineWarehouseCreateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Created time'**
  String get cabinetOfflineWarehouseCreateTimeLabel;

  /// No description provided for @cabinetOfflinePortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get cabinetOfflinePortLabel;

  /// No description provided for @cabinetOfflineDeviceInfoTab.
  ///
  /// In en, this message translates to:
  /// **'Device Info'**
  String get cabinetOfflineDeviceInfoTab;

  /// No description provided for @cabinetOfflineSlotModel.
  ///
  /// In en, this message translates to:
  /// **'Slot Model'**
  String get cabinetOfflineSlotModel;

  /// No description provided for @cabinetOfflineSwapThreshold.
  ///
  /// In en, this message translates to:
  /// **'Swap Threshold'**
  String get cabinetOfflineSwapThreshold;

  /// No description provided for @cabinetOfflineApn.
  ///
  /// In en, this message translates to:
  /// **'APN'**
  String get cabinetOfflineApn;

  /// No description provided for @cabinetOfflineVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get cabinetOfflineVolume;

  /// No description provided for @cabinetOfflinePlatformUrl.
  ///
  /// In en, this message translates to:
  /// **'Platform URL'**
  String get cabinetOfflinePlatformUrl;

  /// No description provided for @cabinetOfflineRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get cabinetOfflineRestart;

  /// No description provided for @cabinetOfflineOpenDoor.
  ///
  /// In en, this message translates to:
  /// **'Open Door'**
  String get cabinetOfflineOpenDoor;

  /// No description provided for @cabinetOfflineRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restart'**
  String get cabinetOfflineRestartTitle;

  /// No description provided for @cabinetOfflineRestartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restart the cabinet?'**
  String get cabinetOfflineRestartConfirm;

  /// No description provided for @cabinetOfflineOpenDoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Open Door'**
  String get cabinetOfflineOpenDoorTitle;

  /// No description provided for @cabinetOfflineOpenDoorConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to open the door? Please ensure Bluetooth is connected.'**
  String get cabinetOfflineOpenDoorConfirm;

  /// No description provided for @cabinetOfflineSmokeAlarm.
  ///
  /// In en, this message translates to:
  /// **'Smoke Alarm'**
  String get cabinetOfflineSmokeAlarm;

  /// No description provided for @cabinetOfflineWaterAlarm.
  ///
  /// In en, this message translates to:
  /// **'Water Leak Alarm'**
  String get cabinetOfflineWaterAlarm;

  /// No description provided for @cabinetOfflineChargerStatus.
  ///
  /// In en, this message translates to:
  /// **'Charger Status'**
  String get cabinetOfflineChargerStatus;

  /// No description provided for @cabinetOfflineNoAlarm.
  ///
  /// In en, this message translates to:
  /// **'No Alarm'**
  String get cabinetOfflineNoAlarm;

  /// No description provided for @cabinetOfflineNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get cabinetOfflineNormal;

  /// No description provided for @cabinetOfflineCabinEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cabin info'**
  String get cabinetOfflineCabinEmpty;

  /// No description provided for @cabinetOfflineCabinSlot.
  ///
  /// In en, this message translates to:
  /// **'Slot {portNo}'**
  String cabinetOfflineCabinSlot(int portNo);

  /// No description provided for @cabinetOfflineCabinCanUse.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get cabinetOfflineCabinCanUse;

  /// No description provided for @cabinetOfflineCabinNoUse.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get cabinetOfflineCabinNoUse;

  /// No description provided for @cabinetOfflineCabinNoBattery.
  ///
  /// In en, this message translates to:
  /// **'No Battery'**
  String get cabinetOfflineCabinNoBattery;

  /// No description provided for @cabinetOfflineCabinOpenDoor.
  ///
  /// In en, this message translates to:
  /// **'Open Door'**
  String get cabinetOfflineCabinOpenDoor;

  /// No description provided for @cabinetOfflineCabinCloseDoor.
  ///
  /// In en, this message translates to:
  /// **'Close Door'**
  String get cabinetOfflineCabinCloseDoor;

  /// No description provided for @cabinetOfflineCabinEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get cabinetOfflineCabinEnable;

  /// No description provided for @cabinetOfflineCabinDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get cabinetOfflineCabinDisable;

  /// No description provided for @cabinetOfflineCabinCheckFault.
  ///
  /// In en, this message translates to:
  /// **'Check Fault'**
  String get cabinetOfflineCabinCheckFault;

  /// No description provided for @cabinetOfflineCabinOperateTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabin Operation'**
  String get cabinetOfflineCabinOperateTitle;

  /// No description provided for @cabinetOfflineBleConnected.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Connected'**
  String get cabinetOfflineBleConnected;

  /// No description provided for @cabinetOfflineBleDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Disconnected'**
  String get cabinetOfflineBleDisconnected;

  /// No description provided for @cabinetOfflineFaultEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fault records'**
  String get cabinetOfflineFaultEmpty;

  /// No description provided for @cabinetOfflineFaultSnLabel.
  ///
  /// In en, this message translates to:
  /// **'SN'**
  String get cabinetOfflineFaultSnLabel;

  /// No description provided for @cabinetOfflineFaultPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get cabinetOfflineFaultPortLabel;

  /// No description provided for @cabinetOfflineFaultTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get cabinetOfflineFaultTimeLabel;

  /// No description provided for @cabinetOfflineFaultSiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get cabinetOfflineFaultSiteLabel;

  /// No description provided for @vcuSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'VCU Search'**
  String get vcuSearchTitle;

  /// No description provided for @vcuControlTitle.
  ///
  /// In en, this message translates to:
  /// **'VCU Control'**
  String get vcuControlTitle;

  /// No description provided for @vcuVinLabel.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get vcuVinLabel;

  /// No description provided for @vcuCommandLabel.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get vcuCommandLabel;

  /// No description provided for @vcuSendCommand.
  ///
  /// In en, this message translates to:
  /// **'Send Command'**
  String get vcuSendCommand;

  /// No description provided for @vcuSendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Command sent'**
  String get vcuSendSuccess;

  /// No description provided for @vcuSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Command failed'**
  String get vcuSendFailed;

  /// No description provided for @vcuLoadVersions.
  ///
  /// In en, this message translates to:
  /// **'Load Versions'**
  String get vcuLoadVersions;

  /// No description provided for @vcuVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get vcuVersionLabel;

  /// No description provided for @vcuControlTab.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get vcuControlTab;

  /// No description provided for @vcuHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get vcuHistoryTab;

  /// No description provided for @vcuHistoryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get vcuHistoryFilterAll;

  /// No description provided for @vcuHistoryFilterRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get vcuHistoryFilterRequest;

  /// No description provided for @vcuHistoryFilterResponse.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get vcuHistoryFilterResponse;

  /// No description provided for @vcuHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get vcuHistoryEmpty;

  /// No description provided for @vcuHistoryStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get vcuHistoryStatusSuccess;

  /// No description provided for @vcuHistoryStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get vcuHistoryStatusFailed;

  /// No description provided for @promoteWebTitle.
  ///
  /// In en, this message translates to:
  /// **'Promote Web'**
  String get promoteWebTitle;

  /// No description provided for @promoteWebUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get promoteWebUrlLabel;

  /// No description provided for @promoteWebParseMode.
  ///
  /// In en, this message translates to:
  /// **'Parse Mode'**
  String get promoteWebParseMode;

  /// No description provided for @promoteWebOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get promoteWebOpen;

  /// No description provided for @batteryLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery Location'**
  String get batteryLocationTitle;

  /// No description provided for @batteryLocationSn.
  ///
  /// In en, this message translates to:
  /// **'Battery SN'**
  String get batteryLocationSn;

  /// No description provided for @batteryLocationQuery.
  ///
  /// In en, this message translates to:
  /// **'Query Location'**
  String get batteryLocationQuery;

  /// No description provided for @batteryLocationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No location data'**
  String get batteryLocationEmpty;

  /// No description provided for @addressPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressPickerTitle;

  /// No description provided for @addressPickerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get addressPickerConfirm;

  /// No description provided for @addressPickerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Move map to pick a location'**
  String get addressPickerEmpty;

  /// No description provided for @addressPickerCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get addressPickerCoordinates;

  /// No description provided for @addressPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search location'**
  String get addressPickerSearchHint;

  /// No description provided for @bluetoothAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Authorization'**
  String get bluetoothAuthTitle;

  /// No description provided for @bluetoothAuthFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Bluetooth key'**
  String get bluetoothAuthFindTitle;

  /// No description provided for @bluetoothAuthBluetoothLabel.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetoothAuthBluetoothLabel;

  /// No description provided for @bluetoothAuthAvailableDevices.
  ///
  /// In en, this message translates to:
  /// **'Available devices'**
  String get bluetoothAuthAvailableDevices;

  /// No description provided for @bluetoothAuthScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get bluetoothAuthScanning;

  /// No description provided for @bluetoothAuthNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get bluetoothAuthNoDevices;

  /// No description provided for @bluetoothAuthConnected.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth key is connected'**
  String get bluetoothAuthConnected;

  /// No description provided for @bluetoothAuthAuthorizedStation.
  ///
  /// In en, this message translates to:
  /// **'Authorized Station'**
  String get bluetoothAuthAuthorizedStation;

  /// No description provided for @bluetoothAuthSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station SN or scan QR code'**
  String get bluetoothAuthSnHint;

  /// No description provided for @bluetoothAuthSnRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter station SN'**
  String get bluetoothAuthSnRequired;

  /// No description provided for @bluetoothAuthOpenButton.
  ///
  /// In en, this message translates to:
  /// **'Opening Authorization'**
  String get bluetoothAuthOpenButton;

  /// No description provided for @bluetoothAuthClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear Authorization'**
  String get bluetoothAuthClearButton;

  /// No description provided for @bluetoothAuthConfirmOpen.
  ///
  /// In en, this message translates to:
  /// **'The station door can be opened within 24 hours after authorization. Are you sure to authorized?'**
  String get bluetoothAuthConfirmOpen;

  /// No description provided for @bluetoothAuthConfirmClear.
  ///
  /// In en, this message translates to:
  /// **'Make sure to clear the bluetooth key authorization??'**
  String get bluetoothAuthConfirmClear;

  /// No description provided for @bluetoothAuthCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancle'**
  String get bluetoothAuthCancel;

  /// No description provided for @bluetoothAuthConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get bluetoothAuthConfirm;

  /// No description provided for @bluetoothAuthClearSuccess.
  ///
  /// In en, this message translates to:
  /// **'Authorization cleared'**
  String get bluetoothAuthClearSuccess;

  /// No description provided for @bluetoothAuthClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Clear authorization failed'**
  String get bluetoothAuthClearFailed;

  /// No description provided for @bluetoothAuthTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get bluetoothAuthTipsTitle;

  /// No description provided for @bluetoothAuthTip1.
  ///
  /// In en, this message translates to:
  /// **'Please make sure that the Bluetooth key is turned on and connected, and there is a Bluetooth logo on the key display;'**
  String get bluetoothAuthTip1;

  /// No description provided for @bluetoothAuthTip2.
  ///
  /// In en, this message translates to:
  /// **'Before adding a new authorization, it is recommended to clear the authorization once and clear the records that are not needed;'**
  String get bluetoothAuthTip2;

  /// No description provided for @bluetoothAuthTip3.
  ///
  /// In en, this message translates to:
  /// **'After successful authorization, you can turn off the Bluetooth of the mobile phone;'**
  String get bluetoothAuthTip3;

  /// No description provided for @bluetoothAuthTip4.
  ///
  /// In en, this message translates to:
  /// **'ress the key Bluetooth button, the indicator light enters the flash state to unlock the lock;'**
  String get bluetoothAuthTip4;

  /// No description provided for @bluetoothAuthTip5.
  ///
  /// In en, this message translates to:
  /// **'Press the key Bluetooth button, the indicator light enters the flash state to unlock the lock;'**
  String get bluetoothAuthTip5;

  /// No description provided for @bluetoothAuthTip6.
  ///
  /// In en, this message translates to:
  /// **'The validity period of the authorization is preset to 24 hours after the authorization is successful;'**
  String get bluetoothAuthTip6;

  /// No description provided for @bluetoothAuthSn.
  ///
  /// In en, this message translates to:
  /// **'Station SN'**
  String get bluetoothAuthSn;

  /// No description provided for @bluetoothAuthPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get bluetoothAuthPhone;

  /// No description provided for @bluetoothAuthKeyId.
  ///
  /// In en, this message translates to:
  /// **'Key ID'**
  String get bluetoothAuthKeyId;

  /// No description provided for @bluetoothAuthDays.
  ///
  /// In en, this message translates to:
  /// **'Authorization Days'**
  String get bluetoothAuthDays;

  /// No description provided for @bluetoothAuthQueryLock.
  ///
  /// In en, this message translates to:
  /// **'Query Lock ID'**
  String get bluetoothAuthQueryLock;

  /// No description provided for @bluetoothAuthQueryUid.
  ///
  /// In en, this message translates to:
  /// **'Query UID'**
  String get bluetoothAuthQueryUid;

  /// No description provided for @bluetoothAuthLockInfo.
  ///
  /// In en, this message translates to:
  /// **'Lock Info'**
  String get bluetoothAuthLockInfo;

  /// No description provided for @bluetoothAuthUid.
  ///
  /// In en, this message translates to:
  /// **'User UID'**
  String get bluetoothAuthUid;

  /// No description provided for @bluetoothAuthSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Authorization'**
  String get bluetoothAuthSubmit;

  /// No description provided for @bluetoothAuthSuccess.
  ///
  /// In en, this message translates to:
  /// **'Authorization submitted'**
  String get bluetoothAuthSuccess;

  /// No description provided for @bluetoothAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authorization failed'**
  String get bluetoothAuthFailed;

  /// No description provided for @bluetoothAuthMissingInput.
  ///
  /// In en, this message translates to:
  /// **'Please fill SN, phone, and key ID'**
  String get bluetoothAuthMissingInput;

  /// No description provided for @bluetoothOperateTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Operations'**
  String get bluetoothOperateTitle;

  /// No description provided for @bluetoothOperateTip.
  ///
  /// In en, this message translates to:
  /// **'Supports BLE scan/connect and authorization commands. Please stay near the device and keep Bluetooth on.'**
  String get bluetoothOperateTip;

  /// No description provided for @bluetoothOperateTodoList.
  ///
  /// In en, this message translates to:
  /// **'• Scan and connect a device\n• Read Key ID / authorize / clear / set validity\n• Send HEX commands and view logs'**
  String get bluetoothOperateTodoList;

  /// No description provided for @deviceDetailTabBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get deviceDetailTabBasicInfo;

  /// No description provided for @deviceDetailTabPortDetail.
  ///
  /// In en, this message translates to:
  /// **'Port Detail'**
  String get deviceDetailTabPortDetail;

  /// No description provided for @deviceDetailTabAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get deviceDetailTabAddress;

  /// No description provided for @deviceDetailTabRepairRecords.
  ///
  /// In en, this message translates to:
  /// **'Repair Records'**
  String get deviceDetailTabRepairRecords;

  /// No description provided for @deviceDetailTabMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get deviceDetailTabMaintenance;

  /// No description provided for @deviceDetailInputTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Input Time'**
  String get deviceDetailInputTimeLabel;

  /// No description provided for @deviceDetailBindingStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Binding State'**
  String get deviceDetailBindingStateLabel;

  /// No description provided for @deviceDetailOnboarded.
  ///
  /// In en, this message translates to:
  /// **'Onboarded'**
  String get deviceDetailOnboarded;

  /// No description provided for @deviceDetailNotBoarded.
  ///
  /// In en, this message translates to:
  /// **'Not Boarded'**
  String get deviceDetailNotBoarded;

  /// No description provided for @deviceDetailOnboardedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Onboarded Time'**
  String get deviceDetailOnboardedTimeLabel;

  /// No description provided for @deviceDetailResponsibleLabel.
  ///
  /// In en, this message translates to:
  /// **'Responsible'**
  String get deviceDetailResponsibleLabel;

  /// No description provided for @deviceDetailPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get deviceDetailPhotoLabel;

  /// No description provided for @deviceDetailBatterySocLabel.
  ///
  /// In en, this message translates to:
  /// **'SOC'**
  String get deviceDetailBatterySocLabel;

  /// No description provided for @deviceDetailBatteryCycleLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycle Count'**
  String get deviceDetailBatteryCycleLabel;

  /// No description provided for @deviceDetailBatteryMileLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Mileage'**
  String get deviceDetailBatteryMileLabel;

  /// No description provided for @deviceDetailBatteryTodayMileLabel.
  ///
  /// In en, this message translates to:
  /// **'Today Mileage'**
  String get deviceDetailBatteryTodayMileLabel;

  /// No description provided for @deviceDetailBatteryAvgSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg Speed'**
  String get deviceDetailBatteryAvgSpeedLabel;

  /// No description provided for @deviceDetailBatteryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get deviceDetailBatteryColorLabel;

  /// No description provided for @deviceDetailSignalTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Signal Time'**
  String get deviceDetailSignalTimeLabel;

  /// No description provided for @deviceDetailBound.
  ///
  /// In en, this message translates to:
  /// **'Bound'**
  String get deviceDetailBound;

  /// No description provided for @deviceDetailUnbound.
  ///
  /// In en, this message translates to:
  /// **'Unbound'**
  String get deviceDetailUnbound;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @lease.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get lease;

  /// No description provided for @deviceDetailPortFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get deviceDetailPortFilterAll;

  /// No description provided for @deviceDetailPortFilterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Vacant'**
  String get deviceDetailPortFilterAvailable;

  /// No description provided for @deviceDetailPortFilterDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get deviceDetailPortFilterDisabled;

  /// No description provided for @deviceDetailPortFilterInUse.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get deviceDetailPortFilterInUse;

  /// No description provided for @deviceDetailPortReplaceable.
  ///
  /// In en, this message translates to:
  /// **'Replaceable'**
  String get deviceDetailPortReplaceable;

  /// No description provided for @deviceDetailPortDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get deviceDetailPortDisabled;

  /// No description provided for @deviceDetailPortAvailable.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get deviceDetailPortAvailable;

  /// No description provided for @deviceDetailPortSetup.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get deviceDetailPortSetup;

  /// No description provided for @deviceDetailPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get deviceDetailPortLabel;

  /// No description provided for @deviceDetailPortOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Door'**
  String get deviceDetailPortOpen;

  /// No description provided for @deviceDetailPortOpened.
  ///
  /// In en, this message translates to:
  /// **'Door Opened'**
  String get deviceDetailPortOpened;

  /// No description provided for @deviceDetailPortEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get deviceDetailPortEnable;

  /// No description provided for @deviceDetailPortDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get deviceDetailPortDisable;

  /// No description provided for @deviceDetailPortOpenConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm to open port {portNo} door?'**
  String deviceDetailPortOpenConfirm(Object portNo);

  /// No description provided for @deviceDetailPortEnableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable this port?'**
  String get deviceDetailPortEnableConfirm;

  /// No description provided for @deviceDetailPortDisableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm to disable this port?'**
  String get deviceDetailPortDisableConfirm;

  /// No description provided for @deviceDetailPortOpenSuccess.
  ///
  /// In en, this message translates to:
  /// **'Door opened successfully'**
  String get deviceDetailPortOpenSuccess;

  /// No description provided for @deviceDetailPortOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open door'**
  String get deviceDetailPortOpenFailed;

  /// No description provided for @deviceDetailPortEnableSuccess.
  ///
  /// In en, this message translates to:
  /// **'Port enabled successfully'**
  String get deviceDetailPortEnableSuccess;

  /// No description provided for @deviceDetailPortDisableSuccess.
  ///
  /// In en, this message translates to:
  /// **'Port disabled successfully'**
  String get deviceDetailPortDisableSuccess;

  /// No description provided for @deviceDetailNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get deviceDetailNavigation;

  /// No description provided for @deviceDetailRepairCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get deviceDetailRepairCompleted;

  /// No description provided for @deviceDetailRepairMissingParts.
  ///
  /// In en, this message translates to:
  /// **'Missing Parts'**
  String get deviceDetailRepairMissingParts;

  /// No description provided for @vehicleDetailBindingId.
  ///
  /// In en, this message translates to:
  /// **'Bind user'**
  String get vehicleDetailBindingId;

  /// No description provided for @vehicleDetailUserPhone.
  ///
  /// In en, this message translates to:
  /// **'User phone number'**
  String get vehicleDetailUserPhone;

  /// No description provided for @vehicleDetailPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Number plate'**
  String get vehicleDetailPlateNumber;

  /// No description provided for @vehicleDetailMileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get vehicleDetailMileage;

  /// No description provided for @vehicleDetailVin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get vehicleDetailVin;

  /// No description provided for @vehicleDetailOwner.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get vehicleDetailOwner;

  /// No description provided for @vehicleDetailViewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get vehicleDetailViewMore;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
