import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/features/work/bluetooth/bluetooth_auth_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_authorization_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_detail_page.dart';
import 'package:merchant_app/features/work/device/device_search_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class CabinetOperatePage extends StatelessWidget {
  const CabinetOperatePage({super.key});

  static final ApiService _api = ApiService();

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
            iconPath: 'assets/android/mipmap-xxhdpi/icon_station_op.png',
            title: l10n.cabinetOperateStationOperation,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DeviceSearchPage(deviceType: 3),
              ),
            ),
          ),
          _OperateItem(
            iconPath: 'assets/android/mipmap-xxhdpi/icon_blue_key_autho.png',
            title: l10n.cabinetOperateBluetoothAuth,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BluetoothAuthPage()),
            ),
          ),
          _OperateItem(
            iconPath: 'assets/android/mipmap-xxhdpi/icon_m_op.png',
            title: l10n.cabinetOperateAuthorization,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CabinetAuthorizationPage()),
            ),
          ),
          _OperateItem(
            iconPath: 'assets/android/mipmap-xxhdpi/icon_offline_op.png',
            title: l10n.cabinetOperateOfflineOM,
            onTap: () => _scanAndOpenOfflineDetail(context),
          ),
        ],
      ),
    );
  }

  /// Scan QR code and open offline operation detail page.
  Future<void> _scanAndOpenOfflineDetail(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(parseDeviceSn: true, deviceType: 3),
      ),
    );
    if (!context.mounted || result == null || result.isEmpty) return;
    final baseInfo = await _fetchCabinetBaseInfo(result);
    if (!context.mounted) return;
    if (baseInfo != null && (baseInfo.hasPermission ?? 0) != 1) {
      showToast(_noPermissionTip(context));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CabinetOfflineDetailPage(
          initialSn: result,
          initialBaseInfo: baseInfo,
        ),
      ),
    );
  }

  /// 获取设备基础信息，同时用于权限校验。返回 null 表示请求失败（放行导航）。
  Future<CabinetDetailBaseInfoBean?> _fetchCabinetBaseInfo(String sn) async {
    try {
      final response = await _api.get<CabinetDetailBaseInfoBean>(
        ApiPath.cabinetBaseInfo,
        queryParameters: {'sn': sn.trim()},
        showHud: false,
        parser: (json) => CabinetDetailBaseInfoBean.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );
      return response.result;
    } catch (_) {
      // 请求失败时放行，交由详情页自行处理。
      return null;
    }
  }

  String _noPermissionTip(BuildContext context) {
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase() == 'zh';
    return isZh
        ? '没有权限,请联系管理员'
        : 'No permission, please contact administrator';
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
