import 'package:networking/networking.dart';

class ProfileApiPath {
  const ProfileApiPath._();

  static const String accountDetail = '/admin/sys/account/detail';
  static const String accountChangeNickName = '/admin/sys/account/changeNickName';
  static const String accountChangeAvatar = '/admin/sys/account/changeAvatar';

  static const String messageGetSysList = '/admin/sys/msg/getSysMessage';
  static const String messageUpdateFlag = '/admin/sys/msg/updateMsgFlag';
  static const String messageGetUnReadCount = '/admin/sys/msg/getUnReadMsgNum';

  static const String changePassword = '/admin/sys/account/changePassword';

  static String urlOf(String path) => NetworkEnvironmentConfig.urlOf(path);
}
