// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get tabHome => '首页';

  @override
  String get tabWork => '工作台';

  @override
  String get tabMe => '我的';

  @override
  String get homeTitle => '首页';

  @override
  String get homePlaceholder => '该页面为展示占位，后续业务能力请在 feature_home 内演进。';

  @override
  String get workTitle => '工作台';

  @override
  String get workPlaceholder => '该页面为展示占位，后续业务能力请在 feature_work 内演进。';

  @override
  String get authLoginTitle => '登录';

  @override
  String get authModuleTitle => '原登录功能模块';

  @override
  String get accountLabel => '账号';

  @override
  String get accountHint => '请输入账号';

  @override
  String get accountRequired => '请输入账号';

  @override
  String get passwordLabel => '密码';

  @override
  String get passwordHint => '请输入密码';

  @override
  String get passwordRequired => '请输入密码';

  @override
  String get passwordTooShort => '密码长度至少 6 位';

  @override
  String get agreeTerms => '我已阅读并同意服务协议与隐私政策';

  @override
  String get login => '登录';

  @override
  String get agreeTermsFirst => '请先勾选协议';

  @override
  String get exampleFeatureTitle => '示例功能';

  @override
  String get backTemplateHome => '返回模板首页';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonRetry => '重试';

  @override
  String get profileDefaultName => '我的';

  @override
  String get profileMessages => '消息';

  @override
  String get profileChangePassword => '修改密码';

  @override
  String get profileLanguageSetting => '语言设置';

  @override
  String get profileServiceAgreement => '服务协议';

  @override
  String get profileAboutApp => '关于应用';

  @override
  String get profileEditNicknameTitle => '修改昵称';

  @override
  String get profileNicknameHint => '请输入昵称';

  @override
  String get profileNicknameEmpty => '昵称不能为空';

  @override
  String get profileLogout => '退出登录';

  @override
  String get profileLogoutConfirm => '确定退出登录吗？';

  @override
  String profileUserId(Object id) {
    return 'ID: $id';
  }

  @override
  String get languageSettingsTitle => '语言设置';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get serviceAgreementAndPrivacyTitle => '服务协议与隐私政策';

  @override
  String get userAgreement => '用户协议';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get changePasswordTitle => '修改密码';

  @override
  String changePasswordCurrentAccount(Object account) {
    return '当前账号: $account';
  }

  @override
  String get changePasswordTips => '请输入 6 位及以上新密码，并与确认密码保持一致。';

  @override
  String get changePasswordOldPassword => '旧密码';

  @override
  String get changePasswordOldPasswordHint => '请输入旧密码';

  @override
  String get changePasswordNewPassword => '新密码';

  @override
  String get changePasswordNewPasswordHint => '请输入新密码';

  @override
  String get changePasswordConfirmPassword => '确认密码';

  @override
  String get changePasswordConfirmPasswordHint => '请再次输入新密码';

  @override
  String get changePasswordSubmit => '确认修改';

  @override
  String get changePasswordMismatch => '两次输入的新密码不一致';

  @override
  String get changePasswordSuccess => '密码修改成功';

  @override
  String get changePasswordFieldRequired => '该项不能为空';

  @override
  String get scanManualInput => '手动输入';

  @override
  String get scanVehicleVin => '车辆 VIN';

  @override
  String get scanConfirm => '确认';

  @override
  String get scanRecorded => '已记录';

  @override
  String get scanCameraPermissionRequired => '需要相机权限';

  @override
  String get scanCameraPermissionDesc => '请在系统设置中允许相机访问后重试。';

  @override
  String get scanTakePhoto => '拍照';

  @override
  String get scanChooseFromGallery => '从相册选择';

  @override
  String get aboutDebugEntryEnabled => '调试入口已打开';

  @override
  String get aboutAppName => 'DEMO';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get messageCenterTitle => '消息中心';

  @override
  String get messageEmpty => '暂无消息';

  @override
  String get messageDetail => '消息详情';

  @override
  String get messageNoMore => '没有更多了';

  @override
  String get showcaseStyleTokens => '样式令牌';

  @override
  String get showcaseToolkit => '工具能力';

  @override
  String showcaseCurrentTime(Object value) {
    return '当前时间: $value';
  }

  @override
  String showcaseScanParsed(Object value) {
    return '扫码解析结果: $value';
  }

  @override
  String get showcaseInteractions => '通用交互组件';

  @override
  String get showcaseToastDemo => '这是来自 foundation 的 Toast';

  @override
  String get showcaseConfirmDemoMessage => '这是 design_system 的确认弹窗示例。';

  @override
  String get showcaseMedia => '媒体组件';
}
