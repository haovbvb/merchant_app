import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

/// 设备类型选择 BottomSheet
/// 用于设备发出、盘点等模块选择设备类型
class DeviceTypeSheet extends StatelessWidget {
  const DeviceTypeSheet({super.key, required this.l10n});

  final AppLocalizations l10n;

  /// 显示设备类型选择 Sheet
  /// 返回选中的设备类型: 1=电池, 2=车辆, 3=换电柜
  static Future<int?> show(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DeviceTypeSheet(l10n: l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.selectDeviceType,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DeviceTypeItem(
                  icon: 'assets/android/mipmap-xxhdpi/icon_transport_battery.webp',
                  label: l10n.warehouseDeviceTypeBattery,
                  color: AppColors.primaryColor,
                  onTap: () => Navigator.of(context).pop(1),
                ),
                _DeviceTypeItem(
                  icon: 'assets/android/mipmap-xxhdpi/icon_transport_vehicel.png',
                  label: l10n.warehouseDeviceTypeVehicle,
                  color: const Color(0xFF2196F3),
                  onTap: () => Navigator.of(context).pop(2),
                ),
                _DeviceTypeItem(
                  icon: 'assets/android/mipmap-xxhdpi/icon_transport_station.png',
                  label: l10n.warehouseDeviceTypeStation,
                  color: const Color(0xFFFF9800),
                  onTap: () => Navigator.of(context).pop(3),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DeviceTypeItem extends StatelessWidget {
  const _DeviceTypeItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Image.asset(icon, width: 40, height: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
