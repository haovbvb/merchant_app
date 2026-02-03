import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/bluetooth/bluetooth_auth_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_authorization_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_detail_page.dart';
import 'package:merchant_app/features/work/device/device_detail_page_new.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class CabinetOperatePage extends StatelessWidget {
  const CabinetOperatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetOperateTitle)),
      backgroundColor: AppColors.bgColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OperateItem(
            iconPath: 'assets/android/mipmap-xxhdpi/icon_station_operation.png',
            title: l10n.cabinetOperateStationOperation,
            onTap: () => _scanAndOpenDeviceDetail(context),
          ),
          _OperateItem(
            iconPath: 'assets/android/mipmap-xxhdpi/icon_blue_key_autho.png',
            title: l10n.cabinetOperateBluetoothAuth,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BluetoothAuthPage()),
            ),
          ),
          _OperateItem(
            iconPath: 'assets/android/mipmap-xxhdpi/icon_release_station.png',
            title: l10n.cabinetOperateAuthorization,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CabinetAuthorizationPage()),
            ),
          ),
          _OperateItem(
            iconPath: 'assets/android/mipmap-xxhdpi/icon_station_open_door.webp',
            title: l10n.cabinetOperateOpenDoor,
            onTap: () => _scanAndOpenDoor(context),
          ),
          _OperateItem(
            iconPath: 'assets/android/mipmap-xxhdpi/icon_signal_offline.webp',
            title: l10n.cabinetOperateOfflineOM,
            onTap: () => _scanAndOpenOfflineDetail(context),
          ),
        ],
      ),
    );
  }

  /// Scan QR code and open device detail page for station operation.
  Future<void> _scanAndOpenDeviceDetail(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (!context.mounted || result == null || result.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeviceDetailPageNew(initialSn: result)),
    );
  }

  /// Scan QR code and open cabinet back door.
  Future<void> _scanAndOpenDoor(BuildContext context) async {
    final l10n = context.l10n;
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (!context.mounted || result == null || result.isEmpty) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cabinetOperateOpenDoorConfirmTitle),
        content: Text(l10n.cabinetOperateOpenDoorConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Call open door API
    final api = ApiService();
    final response = await api.post<Object>(
      ApiPath.cabinetOpenBackDoor,
      data: {'sn': result},
      parser: (json) => json ?? Object(),
    );

    if (!context.mounted) return;
    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cabinetOperateOpenDoorSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cabinetOperateOpenDoorFailed)),
      );
    }
  }

  /// Scan QR code and open offline operation detail page.
  Future<void> _scanAndOpenOfflineDetail(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (!context.mounted || result == null || result.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CabinetOfflineDetailPage(initialSn: result),
      ),
    );
  }
}

class _OperateItem extends StatelessWidget {
  const _OperateItem({
    required this.iconPath,
    required this.title,
    required this.onTap,
  });

  final String iconPath;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Image.asset(iconPath, width: 32, height: 32),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
