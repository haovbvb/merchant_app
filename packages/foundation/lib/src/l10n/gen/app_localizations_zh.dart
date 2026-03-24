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
}
