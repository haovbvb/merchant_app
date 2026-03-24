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

  if (status.isGranted) {
    return const CameraPermissionResult(CameraPermissionStatus.granted);
  }
  if (status.isPermanentlyDenied) {
    return const CameraPermissionResult(CameraPermissionStatus.deniedForever);
  }
  if (status.isRestricted) {
    return const CameraPermissionResult(CameraPermissionStatus.restricted);
  }

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
