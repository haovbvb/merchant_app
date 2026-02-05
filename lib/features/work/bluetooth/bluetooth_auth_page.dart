import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/bluetooth_permission.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

/// 蓝牙授权入口页面 - Find Bluetooth key
class BluetoothAuthPage extends ConsumerStatefulWidget {
  const BluetoothAuthPage({super.key});

  @override
  ConsumerState<BluetoothAuthPage> createState() => _BluetoothAuthPageState();
}

class _BluetoothAuthPageState extends ConsumerState<BluetoothAuthPage> {
  final List<ScanResult> _devices = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  BluetoothDevice? _connectingDevice;
  bool _bluetoothOn = false;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _checkBluetoothState() async {
    final permission = await ensureBluetoothPermission();
    if (!permission.granted) {
      if (mounted) {
        showToast('请授予蓝牙权限');
      }
      return;
    }

    _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;
      setState(() {
        _bluetoothOn = state == BluetoothAdapterState.on;
      });
      if (_bluetoothOn && _devices.isEmpty) {
        _startScan();
      }
    });

    final state = await FlutterBluePlus.adapterState.first;
    setState(() {
      _bluetoothOn = state == BluetoothAdapterState.on;
    });
    if (_bluetoothOn) {
      _startScan();
    }
  }

  Future<void> _toggleBluetooth(bool value) async {
    if (value) {
      await FlutterBluePlus.turnOn();
    } else {
      await FlutterBluePlus.stopScan();
      setState(() {
        _devices.clear();
        _scanning = false;
      });
    }
  }

  Future<void> _startScan() async {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _devices.clear();
    });

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      // 只显示名称以 HNTT 开头的设备（蓝牙钥匙）
      final filtered = results
          .where((r) =>
              r.device.platformName.isNotEmpty &&
              r.device.platformName.startsWith('HNTT'))
          .toList();
      setState(() {
        _devices
          ..clear()
          ..addAll(filtered);
      });
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      androidUsesFineLocation: true,
    );

    if (mounted) {
      setState(() => _scanning = false);
    }
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    setState(() => _connectingDevice = device);

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      if (!mounted) return;

      // 连接成功，进入授权页面
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _BluetoothAuthorizationPage(device: device),
        ),
      );

      // 返回后断开连接
      await device.disconnect();
    } catch (e) {
      if (mounted) {
        showToast('连接失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _connectingDevice = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bluetoothAuthFindTitle)),
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          // Bluetooth 开关
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.bluetoothAuthBluetoothLabel,
                  style: const TextStyle(fontSize: 16),
                ),
                CupertinoSwitch(
                  value: _bluetoothOn,
                  activeTrackColor: AppColors.primaryColor,
                  onChanged: _toggleBluetooth,
                ),
              ],
            ),
          ),

          // 设备列表
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.bluetoothAuthAvailableDevices,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        if (_scanning)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _devices.isEmpty
                        ? Center(
                            child: Text(
                              _scanning
                                  ? l10n.bluetoothAuthScanning
                                  : l10n.bluetoothAuthNoDevices,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _devices.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              indent: 56,
                            ),
                            itemBuilder: (context, index) {
                              final device = _devices[index].device;
                              final isConnecting =
                                  _connectingDevice?.remoteId == device.remoteId;

                              return ListTile(
                                leading: Image.asset(
                                  'assets/android/mipmap-xxhdpi/icon_blue_key_autho.png',
                                  width: 32,
                                  height: 32,
                                ),
                                title: Text(device.platformName),
                                trailing: isConnecting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: const SizedBox.shrink(),
                                      )
                                    : null,
                                onTap: isConnecting
                                    ? null
                                    : () => _connectDevice(device),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 蓝牙授权操作页面 - Authorization
class _BluetoothAuthorizationPage extends StatefulWidget {
  const _BluetoothAuthorizationPage({required this.device});

  final BluetoothDevice device;

  @override
  State<_BluetoothAuthorizationPage> createState() =>
      _BluetoothAuthorizationPageState();
}

class _BluetoothAuthorizationPageState
    extends State<_BluetoothAuthorizationPage> {
  final _snController = TextEditingController();
  bool _authorizing = false;
  bool _clearing = false;

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (result != null && result.isNotEmpty) {
      _snController.text = result;
    }
  }

  Future<void> _openAuthorization() async {
    final l10n = context.l10n;
    final sn = _snController.text.trim();
    if (sn.isEmpty) {
      showToast(l10n.bluetoothAuthSnRequired);
      return;
    }

    // 确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(
        message: l10n.bluetoothAuthConfirmOpen,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true) return;

    setState(() => _authorizing = true);

    try {
      // TODO: 发送蓝牙授权命令
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) {
        showToast(l10n.bluetoothAuthSuccess);
      }
    } catch (e) {
      if (mounted) {
        showToast(l10n.bluetoothAuthFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _authorizing = false);
      }
    }
  }

  Future<void> _clearAuthorization() async {
    final l10n = context.l10n;

    // 确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(
        message: l10n.bluetoothAuthConfirmClear,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true) return;

    setState(() => _clearing = true);

    try {
      // TODO: 发送清除授权命令
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) {
        showToast(l10n.bluetoothAuthClearSuccess);
      }
    } catch (e) {
      if (mounted) {
        showToast(l10n.bluetoothAuthClearFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _clearing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bluetoothAuthTitle)),
      backgroundColor: AppColors.bgColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 已连接设备卡片
          _ConnectedDeviceCard(device: widget.device),
          const SizedBox(height: 16),

          // 授权柜机输入区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bluetoothAuthAuthorizedStation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _snController,
                  decoration: InputDecoration(
                    hintText: l10n.bluetoothAuthSnHint,
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _scanQRCode,
                      icon: AppIcons.scanIcon(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Opening Authorization 按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _authorizing ? null : _openAuthorization,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _authorizing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: const SizedBox.shrink(),
                          )
                        : Text(
                            l10n.bluetoothAuthOpenButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Clear Authorization 按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _clearing ? null : _clearAuthorization,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.black26),
                    ),
                    child: _clearing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: const SizedBox.shrink(),
                          )
                        : Text(
                            l10n.bluetoothAuthClearButton,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tips 区域
          _TipsSection(),
        ],
      ),
    );
  }
}

/// 已连接设备卡片
class _ConnectedDeviceCard extends StatelessWidget {
  const _ConnectedDeviceCard({required this.device});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B9FE8), Color(0xFF5BB8F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_blue_key_autho.png',
            width: 32,
            height: 32,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.platformName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.bluetoothAuthConnected,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.bluetooth,
            color: Colors.white.withOpacity(0.3),
            size: 48,
          ),
        ],
      ),
    );
  }
}

/// Tips 区域
class _TipsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tips = [
      l10n.bluetoothAuthTip1,
      l10n.bluetoothAuthTip2,
      l10n.bluetoothAuthTip3,
      l10n.bluetoothAuthTip4,
      l10n.bluetoothAuthTip5,
      l10n.bluetoothAuthTip6,
    ];

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.bluetoothAuthTipsTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),
        ...tips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('· ', style: TextStyle(color: Colors.black54)),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 确认对话框
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.message,
    required this.onCancel,
    required this.onConfirm,
  });

  final String message;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.black26),
                      ),
                      child: Text(
                        l10n.bluetoothAuthCancel,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: onConfirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(l10n.bluetoothAuthConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
