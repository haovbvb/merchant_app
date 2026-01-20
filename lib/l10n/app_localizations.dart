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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

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

  /// Helper text in the profile tab.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal settings here.'**
  String get profileGreeting;

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

  /// Menu label for viewing the application information.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// Label prefix for app version on About page.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login;

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
  /// **'Enter card number or keyword'**
  String get userSearchHint;

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
  /// **'Maintenance Booking'**
  String get maintenanceBookTitle;

  /// No description provided for @maintenanceSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle SN'**
  String get maintenanceSnLabel;

  /// No description provided for @maintenanceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan vehicle SN'**
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
  /// **'No maintenance info'**
  String get maintenanceEmptyInfo;

  /// No description provided for @maintenanceNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Notes'**
  String get maintenanceNoteLabel;

  /// No description provided for @maintenanceNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter notes'**
  String get maintenanceNoteHint;

  /// No description provided for @maintenanceSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
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

  /// No description provided for @maintenanceSuccessBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get maintenanceSuccessBack;

  /// No description provided for @repairRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Repair Records'**
  String get repairRecordTitle;

  /// No description provided for @repairRecordAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Repair Record'**
  String get repairRecordAddTitle;

  /// No description provided for @repairRecordDeviceSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get repairRecordDeviceSnLabel;

  /// No description provided for @repairRecordDeviceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan device SN'**
  String get repairRecordDeviceSnHint;

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
  /// **'No device info'**
  String get repairRecordDeviceInfoEmpty;

  /// No description provided for @repairRecordProjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Repair item'**
  String get repairRecordProjectLabel;

  /// No description provided for @repairRecordProjectHint.
  ///
  /// In en, this message translates to:
  /// **'Select repair item'**
  String get repairRecordProjectHint;

  /// No description provided for @repairRecordResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Repair result'**
  String get repairRecordResultLabel;

  /// No description provided for @repairRecordResultHint.
  ///
  /// In en, this message translates to:
  /// **'Select repair result'**
  String get repairRecordResultHint;

  /// No description provided for @repairRecordRemarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get repairRecordRemarkLabel;

  /// No description provided for @repairRecordRemarkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter remark'**
  String get repairRecordRemarkHint;

  /// No description provided for @repairRecordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
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
  /// **'Spec'**
  String get repairRecordDeviceSpecLabel;

  /// No description provided for @repairRecordDeviceCardNumLabel.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get repairRecordDeviceCardNumLabel;

  /// No description provided for @repairRecordDeviceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get repairRecordDeviceNameLabel;

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
  /// No description provided for @loginHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username and password to continue.'**
  String get loginHint;

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

  /// No description provided for @afterSaleBindTitle.
  ///
  /// In en, this message translates to:
  /// **'After-sale Binding'**
  String get afterSaleBindTitle;

  /// No description provided for @afterSaleBindUserSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get afterSaleBindUserSectionTitle;

  /// No description provided for @afterSaleBindCardNumLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get afterSaleBindCardNumLabel;

  /// No description provided for @afterSaleBindCardNumHint.
  ///
  /// In en, this message translates to:
  /// **'Enter card number'**
  String get afterSaleBindCardNumHint;

  /// No description provided for @afterSaleBindUserInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get afterSaleBindUserInfoTitle;

  /// No description provided for @afterSaleBindUserInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No user information'**
  String get afterSaleBindUserInfoEmpty;

  /// No description provided for @afterSaleBindSelectableOrders.
  ///
  /// In en, this message translates to:
  /// **'Selectable Orders'**
  String get afterSaleBindSelectableOrders;

  /// No description provided for @afterSaleBindNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders available'**
  String get afterSaleBindNoOrders;

  /// No description provided for @afterSaleBindDeviceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get afterSaleBindDeviceSectionTitle;

  /// No description provided for @afterSaleBindDeviceSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get afterSaleBindDeviceSnLabel;

  /// No description provided for @afterSaleBindDeviceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN or scan'**
  String get afterSaleBindDeviceSnHint;

  /// No description provided for @afterSaleBindDeviceInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Details'**
  String get afterSaleBindDeviceInfoTitle;

  /// No description provided for @afterSaleBindDeviceInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device information'**
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
  /// **'Installment'**
  String get afterSaleBindOrderStatusInstallment;

  /// No description provided for @afterSaleBindOrderStatusLease.
  ///
  /// In en, this message translates to:
  /// **'Leasing'**
  String get afterSaleBindOrderStatusLease;

  /// No description provided for @unbindDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Unbind Device'**
  String get unbindDeviceTitle;

  /// No description provided for @unbindDeviceUserIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get unbindDeviceUserIdLabel;

  /// No description provided for @unbindDeviceUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter card number or scan'**
  String get unbindDeviceUserIdHint;

  /// No description provided for @unbindDeviceDeviceSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Device SN'**
  String get unbindDeviceDeviceSnLabel;

  /// No description provided for @unbindDeviceDeviceSnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN or scan'**
  String get unbindDeviceDeviceSnHint;

  /// No description provided for @unbindDeviceCheckRemarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Check Remark'**
  String get unbindDeviceCheckRemarkLabel;

  /// No description provided for @unbindDeviceCheckRemarkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter check status'**
  String get unbindDeviceCheckRemarkHint;

  /// No description provided for @unbindDeviceReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Unbind Reason'**
  String get unbindDeviceReasonTitle;

  /// No description provided for @unbindDeviceReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Select or enter reason'**
  String get unbindDeviceReasonHint;

  /// No description provided for @unbindDeviceReasonInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter unbind reason'**
  String get unbindDeviceReasonInputHint;

  /// No description provided for @unbindDeviceReason1.
  ///
  /// In en, this message translates to:
  /// **'Device malfunction'**
  String get unbindDeviceReason1;

  /// No description provided for @unbindDeviceReason2.
  ///
  /// In en, this message translates to:
  /// **'User request'**
  String get unbindDeviceReason2;

  /// No description provided for @unbindDeviceReason3.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get unbindDeviceReason3;

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

  /// No description provided for @scanPageTitle.
  ///

  /// No description provided for @warehouseTransportCountLabel.
  ///
  /// **'Quantity'**
  String get warehouseTransportCountLabel;

  /// No description provided for @warehouseTransportReceivedLabel.
  ///
  /// **'Receive'**
  String get warehouseTransportReceivedLabel;

  /// No description provided for @warehouseTransportWithdrawLabel.
  ///
  /// **'Withdraw'**
  String get warehouseTransportWithdrawLabel;
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
  /// **'Cabinet'**
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

  /// No description provided for @deviceSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter device SN or keyword'**
  String get deviceSearchHint;

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
  /// **'Process Order'**
  String get roadsideDealTitle;

  /// No description provided for @roadsideDealResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get roadsideDealResultLabel;

  /// No description provided for @roadsideDealDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Processing Notes'**
  String get roadsideDealDescLabel;

  /// No description provided for @roadsideUploadLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload Images'**
  String get roadsideUploadLabel;

  /// No description provided for @roadsideDealSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get roadsideDealSuccess;

  /// No description provided for @roadsideDealFailed.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get roadsideDealFailed;

  /// No description provided for @bluetoothAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Authorization'**
  String get bluetoothAuthTitle;

  /// No description provided for @bluetoothAuthSn.
  ///
  /// In en, this message translates to:
  /// **'Cabinet SN'**
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
  /// **'This version only includes basic authorization APIs. Bluetooth scan and commands will be added later.'**
  String get bluetoothOperateTip;

  /// No description provided for @bluetoothOperateTodoList.
  ///
  /// In en, this message translates to:
  /// **'• Scan/connect Bluetooth devices (todo)\n• Authorize/clear authorization/set validity (todo)\n• Read device info/logs (todo)'**
  String get bluetoothOperateTodoList;

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

  /// No description provided for @offlineRegisterSmsCode.
  ///
  /// In en, this message translates to:
  /// **'SMS Code'**
  String get offlineRegisterSmsCode;

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

  /// No description provided for @offlineRegisterFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get offlineRegisterFirstName;

  /// No description provided for @offlineRegisterLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get offlineRegisterLastName;

  /// No description provided for @offlineRegisterUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get offlineRegisterUsername;

  /// No description provided for @offlineRegisterBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get offlineRegisterBirthday;

  /// No description provided for @offlineRegisterEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get offlineRegisterEmail;

  /// No description provided for @offlineRegisterReferrer.
  ///
  /// In en, this message translates to:
  /// **'Referrer'**
  String get offlineRegisterReferrer;

  /// No description provided for @offlineRegisterSubmit.
  ///
  /// In en, this message translates to:
  /// **'Register'**
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
  /// **'Full'**
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

  /// No description provided for @rentBindTitle.
  ///
  /// In en, this message translates to:
  /// **'Rent Binding'**
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

  /// No description provided for @rentBindDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Details'**
  String get rentBindDeviceInfo;

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
  /// **'Refund Orders'**
  String get depositRefundOrderSection;

  /// No description provided for @depositRefundVoucher.
  ///
  /// In en, this message translates to:
  /// **'Voucher'**
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
  /// **'Amount'**
  String get depositRefundAmount;

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

  /// No description provided for @merchantReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Merchant Replace'**
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

  /// No description provided for @cabinetPutawayTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Putaway'**
  String get cabinetPutawayTitle;

  /// No description provided for @cabinetPutawaySn.
  ///
  /// In en, this message translates to:
  /// **'Cabinet SN'**
  String get cabinetPutawaySn;

  /// No description provided for @cabinetPutawayInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Info'**
  String get cabinetPutawayInfoTitle;

  /// No description provided for @cabinetPutawayInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cabinet info'**
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

  /// No description provided for @cabinetPutawaySwapTime.
  ///
  /// In en, this message translates to:
  /// **'Swap Times'**
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
  /// **'Cabinet Unshelve'**
  String get cabinetUnshelveTitle;

  /// No description provided for @cabinetUnshelveSn.
  ///
  /// In en, this message translates to:
  /// **'Cabinet SN'**
  String get cabinetUnshelveSn;

  /// No description provided for @cabinetUnshelveInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Info'**
  String get cabinetUnshelveInfoTitle;

  /// No description provided for @cabinetUnshelveInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cabinet info'**
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

  /// No description provided for @cabinetUnshelveSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
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
  /// **'Cabinet Authorization'**
  String get cabinetAuthTitle;

  /// No description provided for @cabinetAuthSn.
  ///
  /// In en, this message translates to:
  /// **'Cabinet SN'**
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
  /// **'Cabinet List'**
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

  /// No description provided for @cabinetAuthCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get cabinetAuthCancelSuccess;

  /// No description provided for @cabinetAuthCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Cancel failed'**
  String get cabinetAuthCancelFailed;

  /// No description provided for @cabinetAuthRecordSection.
  ///
  /// In en, this message translates to:
  /// **'Authorization Records'**
  String get cabinetAuthRecordSection;

  /// No description provided for @cabinetOperateTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Operations'**
  String get cabinetOperateTitle;

  /// No description provided for @cabinetOperateAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Authorization'**
  String get cabinetOperateAuthorization;

  /// No description provided for @cabinetOperateOfflineDetail.
  ///
  /// In en, this message translates to:
  /// **'Offline Detail'**
  String get cabinetOperateOfflineDetail;

  /// No description provided for @cabinetOfflineDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Offline Detail'**
  String get cabinetOfflineDetailTitle;

  /// No description provided for @cabinetOfflineFaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Offline Fault'**
  String get cabinetOfflineFaultTitle;

  /// No description provided for @cabinetOfflinePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get cabinetOfflinePlaceholder;

  /// No description provided for @cabinetOfflineSnLabel.
  ///
  /// In en, this message translates to:
  /// **'Cabinet SN'**
  String get cabinetOfflineSnLabel;

  /// No description provided for @cabinetOfflinePidLabel.
  ///
  /// In en, this message translates to:
  /// **'Cabinet PID'**
  String get cabinetOfflinePidLabel;

  /// No description provided for @cabinetOfflineName.
  ///
  /// In en, this message translates to:
  /// **'Cabinet Name'**
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

  /// No description provided for @cabinetOfflinePortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get cabinetOfflinePortLabel;

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
  /// **'Select Address'**
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
