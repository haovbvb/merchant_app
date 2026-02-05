import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/camera_permission.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/features/work/warehouse/receive_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiveScanPage extends ConsumerStatefulWidget {
  const ReceiveScanPage({
    super.key,
    required this.transferNo,
  });

  final String transferNo;

  @override
  ConsumerState<ReceiveScanPage> createState() => _ReceiveScanPageState();
}

class _ReceiveScanPageState extends ConsumerState<ReceiveScanPage>
    with TickerProviderStateMixin {
  MobileScannerController? _controller;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _handled = false;
  bool _checkingPermission = true;
  CameraPermissionResult? _permission;
  bool _torchOn = false;
  bool _hasReceived = false;

  // 结果提示
  bool _showResult = false;
  bool _resultSuccess = false;
  String _resultMessage = '';

  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _initController() {
    _controller ??= MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final result = await ensureCameraPermission();
    if (!mounted) return;
    setState(() {
      _permission = result;
      _checkingPermission = false;
    });
    if (result.granted) {
      _initController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPermission = _permission?.granted ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop && _hasReceived) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: true,
          body: _checkingPermission
              ? const Center(
                  child: const SizedBox.shrink(),
                )
              : hasPermission
                  ? _buildScannerView(context)
                  : _buildPermissionView(context),
        ),
      ),
    );
  }

  Widget _buildScannerView(BuildContext context) {
    _initController();

    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.65;

    return Stack(
      children: [
        // 相机预览
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),

        // 扫描框遮罩
        _buildScanOverlay(scanAreaSize),

        // 扫描线动画
        Positioned(
          left: (size.width - scanAreaSize) / 2,
          top: (size.height - scanAreaSize) / 2 - 40,
          width: scanAreaSize,
          height: scanAreaSize,
          child: AnimatedBuilder(
            animation: _scanLineController,
            builder: (context, child) {
              return Align(
                alignment: Alignment(
                  0,
                  -1 + 2 * _scanLineController.value,
                ),
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primaryColor.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 结果提示
        if (_showResult)
          Positioned(
            left: 24,
            right: 24,
            top: (size.height - scanAreaSize) / 2 + scanAreaSize / 2 - 60,
            child: _buildResultBadge(),
          ),

        // 返回按钮
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(_hasReceived),
          ),
        ),

        // 手电筒按钮
        Positioned(
          left: 0,
          right: 0,
          top: (size.height + scanAreaSize) / 2 - 40 + 40,
          child: Center(
            child: GestureDetector(
              onTap: _toggleTorch,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),

        // 底部输入框
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () => _showManualInputDialog(context),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.deviceReceiveManualInput,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBadge() {
    return AnimatedOpacity(
      opacity: _showResult ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _resultSuccess
                  ? Icons.check_circle
                  : Icons.cancel,
              color: _resultSuccess ? AppColors.primaryColor : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _resultMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOverlay(double scanAreaSize) {
    final size = MediaQuery.of(context).size;
    final top = (size.height - scanAreaSize) / 2 - 40;
    final left = (size.width - scanAreaSize) / 2;

    return Stack(
      children: [
        // 四周半透明遮罩
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Positioned(
                left: left,
                top: top,
                child: Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 扫描框边角
        Positioned(
          left: left,
          top: top,
          child: _buildCorner(true, true),
        ),
        Positioned(
          right: left,
          top: top,
          child: _buildCorner(false, true),
        ),
        Positioned(
          left: left,
          bottom: size.height - top - scanAreaSize,
          child: _buildCorner(true, false),
        ),
        Positioned(
          right: left,
          bottom: size.height - top - scanAreaSize,
          child: _buildCorner(false, false),
        ),
      ],
    );
  }

  Widget _buildCorner(bool isLeft, bool isTop) {
    const size = 24.0;
    const strokeWidth = 3.0;
    const color = Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          isLeft: isLeft,
          isTop: isTop,
          strokeWidth: strokeWidth,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPermissionView(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.scanCameraPermissionTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await openAppSettings();
                if (mounted) {
                  _checkPermission();
                }
              },
              child: Text(l10n.scanOpenSettings),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _handled = true;
    _processScannedCode(code);
  }

  Future<void> _processScannedCode(String code) async {
    // 解析设备SN
    final deviceSn = ScanUtils.getDeviceSn(code);

    // 调用接收接口
    final result = await ref.read(receiveDetailProvider.notifier).receiveDevice(deviceSn);

    if (!mounted) return;

    setState(() {
      _showResult = true;
      _resultSuccess = result.success;
      _resultMessage = result.success
          ? context.l10n.deviceReceiveSuccess
          : context.l10n.deviceReceiveNotBelong;
    });

    if (result.success) {
      _hasReceived = true;
    }

    // 3秒后隐藏结果并允许继续扫描
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showResult = false;
          _handled = false;
        });
      }
    });
  }

  void _toggleTorch() async {
    await _controller?.toggleTorch();
    setState(() {
      _torchOn = !_torchOn;
    });
  }

  Future<void> _showManualInputDialog(BuildContext context) async {
    final l10n = context.l10n;
    _inputController.clear();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deviceReceiveManualInput),
        content: TextField(
          controller: _inputController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.deviceIssueEnterDeviceSn,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = _inputController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      _handled = true;
      _processScannedCode(result);
    }
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({
    required this.isLeft,
    required this.isTop,
    required this.strokeWidth,
    required this.color,
  });

  final bool isLeft;
  final bool isTop;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isLeft && isTop) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (!isLeft && isTop) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else if (isLeft && !isTop) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
