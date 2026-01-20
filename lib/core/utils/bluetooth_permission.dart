import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

enum BluetoothPermissionStatus {
  granted,
  denied,
  deniedForever,
  restricted,
}

class BluetoothPermissionResult {
  const BluetoothPermissionResult(this.status);

  final BluetoothPermissionStatus status;

  bool get granted => status == BluetoothPermissionStatus.granted;
}

Future<BluetoothPermissionResult> ensureBluetoothPermission({
  bool requestPermission = true,
}) async {
  if (Platform.isAndroid) {
    final permissions = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    Map<Permission, PermissionStatus> results;
    if (requestPermission) {
      results = await permissions.request();
    } else {
      results = {
        for (final permission in permissions)
          permission: await permission.status,
      };
    }

    if (results.values.any((status) => status.isPermanentlyDenied)) {
      return const BluetoothPermissionResult(
        BluetoothPermissionStatus.deniedForever,
      );
    }

    if (results.values.any((status) => status.isRestricted)) {
      return const BluetoothPermissionResult(
        BluetoothPermissionStatus.restricted,
      );
    }

    if (results.values.any((status) => status.isDenied)) {
      return const BluetoothPermissionResult(BluetoothPermissionStatus.denied);
    }

    return const BluetoothPermissionResult(BluetoothPermissionStatus.granted);
  }

  if (Platform.isIOS) {
    var status = await Permission.bluetooth.status;
    if (status.isDenied && requestPermission) {
      status = await Permission.bluetooth.request();
    }

    if (status.isPermanentlyDenied) {
      return const BluetoothPermissionResult(
        BluetoothPermissionStatus.deniedForever,
      );
    }
    if (status.isRestricted) {
      return const BluetoothPermissionResult(BluetoothPermissionStatus.restricted);
    }
    if (status.isDenied) {
      return const BluetoothPermissionResult(BluetoothPermissionStatus.denied);
    }

    return const BluetoothPermissionResult(BluetoothPermissionStatus.granted);
  }

  return const BluetoothPermissionResult(BluetoothPermissionStatus.granted);
}
