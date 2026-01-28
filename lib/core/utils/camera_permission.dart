import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionStatus {
  granted,
  denied,
  deniedForever,
  restricted,
}

class CameraPermissionResult {
  const CameraPermissionResult(this.status);

  final CameraPermissionStatus status;

  bool get granted => status == CameraPermissionStatus.granted;
}

Future<CameraPermissionResult> ensureCameraPermission() async {
  var status = await Permission.camera.status;

  // 如果权限已授予，直接返回
  if (status.isGranted) {
    return const CameraPermissionResult(CameraPermissionStatus.granted);
  }

  // 如果权限已被永久拒绝，不再请求
  if (status.isPermanentlyDenied) {
    return const CameraPermissionResult(CameraPermissionStatus.deniedForever);
  }

  // 如果权限受限（如家长控制），无法请求
  if (status.isRestricted) {
    return const CameraPermissionResult(CameraPermissionStatus.restricted);
  }

  // 权限未确定或被拒绝（非永久），请求权限
  // 注意：在 iOS 上，如果是 notDetermined 状态，这里会弹出系统权限请求对话框
  final requested = await Permission.camera.request();

  if (requested.isGranted) {
    return const CameraPermissionResult(CameraPermissionStatus.granted);
  }
  if (requested.isPermanentlyDenied) {
    return const CameraPermissionResult(CameraPermissionStatus.deniedForever);
  }
  if (requested.isRestricted) {
    return const CameraPermissionResult(CameraPermissionStatus.restricted);
  }
  return const CameraPermissionResult(CameraPermissionStatus.denied);
}