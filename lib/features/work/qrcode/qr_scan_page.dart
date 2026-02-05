import 'dart:async';

import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/core/utils/camera_permission.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({
    super.key,
    this.allowManualInput = true,
    this.parseDeviceSn = false,
    this.deviceType,
  });

  final bool allowManualInput;
  final bool parseDeviceSn;
  final int? deviceType;

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> with TickerProviderStateMixin {
  MobileScannerController? _controller;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _handled = false;
  bool _checkingPermission = true;
  CameraPermissionResult? _permission;
  bool _torchOn = false;
  bool _isInputMode = false;
  String? _successMessage;

  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _inputFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isInputMode = _inputFocusNode.hasFocus;
    });
  }

  void _initController() {
    _controller ??= MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _inputController.dispose();
    _inputFocusNode.removeListener(_onFocusChange);
    _inputFocusNode.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPermission = _permission?.granted ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
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
    );
  }

  Widget _buildScannerView(BuildContext context) {
    // 确保控制器已初始化
    _initController();

    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.65;

    return Stack(
      children: [
        // 相机预览
        Positioned.fill(
          child: MobileScanner(controller: _controller!, onDetect: _onDetect),
        ),

        // 扫描框遮罩层
        Positioned.fill(
          child: CustomPaint(
            painter: _ScanOverlayPainter(
              scanAreaSize: scanAreaSize,
              borderRadius: 24,
            ),
          ),
        ),

        // 扫描框边角装饰
        Center(
          child: SizedBox(
            width: scanAreaSize,
            height: scanAreaSize,
            child: CustomPaint(painter: _ScanCornerPainter(borderRadius: 24)),
          ),
        ),

        // 扫描线动画
        Center(
          child: SizedBox(
            width: scanAreaSize - 32,
            height: scanAreaSize,
            child: AnimatedBuilder(
              animation: _scanLineController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScanLinePainter(
                    progress: _scanLineController.value,
                  ),
                );
              },
            ),
          ),
        ),

        // 顶部返回按钮
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),

        // 成功提示
        if (_successMessage != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC3C3C3C),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 手电筒按钮
        Positioned(
          bottom: 180,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _toggleTorch,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _torchOn
                      ? AppColors.primaryColor
                      : const Color(0x80808080),
                  borderRadius: BorderRadius.circular(16),
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

        // 底部输入区域
        if (widget.allowManualInput)
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: _buildInputArea(l10n),
          ),
      ],
    );
  }

  Widget _buildInputArea(dynamic l10n) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xCC3C3C3C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(
                  Icons.edit_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: l10n.scanManualInput,
                      hintStyle: const TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _confirmManualInput(),
                  ),
                ),
                if (_inputController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _inputController.clear();
                      setState(() {});
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.cancel,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        if (_isInputMode || _inputController.text.isNotEmpty) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _confirmManualInput,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                l10n.scanConfirm,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPermissionView(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Column(
        children: [
          // 顶部返回按钮
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.no_photography_outlined,
                      size: 64,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.scanCameraPermissionTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.scanCameraPermissionDesc,
                      style: const TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _checkPermission,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: Text(l10n.scanPermissionRetry),
                    ),
                    if (_showOpenSettings) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: openAppSettings,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        child: Text(l10n.scanOpenSettings),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // 底部手动输入
          if (widget.allowManualInput)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _buildInputArea(l10n),
            ),
        ],
      ),
    );
  }

  bool get _showOpenSettings {
    final status = _permission?.status;
    return status == CameraPermissionStatus.deniedForever ||
        status == CameraPermissionStatus.restricted;
  }

  Future<void> _checkPermission() async {
    if (mounted) {
      setState(() {
        _checkingPermission = true;
      });
    }
    final result = await ensureCameraPermission();
    if (!mounted) return;
    setState(() {
      _permission = result;
      _checkingPermission = false;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    final parsed = _parseResult(value);
    if (parsed.isEmpty) return;
    _handled = true;
    Navigator.of(context).pop(parsed);
  }

  void _toggleTorch() {
    _controller?.toggleTorch();
    setState(() {
      _torchOn = !_torchOn;
    });
  }

  void _confirmManualInput() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final parsed = _parseResult(text);
    if (parsed.isEmpty) return;

    // 显示成功提示
    setState(() {
      _successMessage = context.l10n.scanSuccessEntry;
    });

    // 延迟后返回结果
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop(parsed);
      }
    });
  }

  String _parseResult(String value) {
    if (!widget.parseDeviceSn && widget.deviceType == null) {
      return value.trim();
    }
    if (widget.deviceType != null) {
      return ScanUtils.parseSnByDeviceType(value, widget.deviceType).trim();
    }
    return ScanUtils.getDeviceSn(value).trim();
  }
}

/// 扫描区域遮罩
class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({required this.scanAreaSize, required this.borderRadius});

  final double scanAreaSize;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.5);

    final scanRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: scanAreaSize,
        height: scanAreaSize,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 扫描框边角
class _ScanCornerPainter extends CustomPainter {
  _ScanCornerPainter({required this.borderRadius});

  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 32.0;

    // 左上角
    final topLeftPath = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, borderRadius)
      ..arcToPoint(
        Offset(borderRadius, 0),
        radius: Radius.circular(borderRadius),
      )
      ..lineTo(cornerLength, 0);
    canvas.drawPath(topLeftPath, paint);

    // 右上角
    final topRightPath = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - borderRadius, 0)
      ..arcToPoint(
        Offset(size.width, borderRadius),
        radius: Radius.circular(borderRadius),
      )
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(topRightPath, paint);

    // 左下角
    final bottomLeftPath = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - borderRadius)
      ..arcToPoint(
        Offset(borderRadius, size.height),
        radius: Radius.circular(borderRadius),
        clockwise: false,
      )
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(bottomLeftPath, paint);

    // 右下角
    final bottomRightPath = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - borderRadius, size.height)
      ..arcToPoint(
        Offset(size.width, size.height - borderRadius),
        radius: Radius.circular(borderRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(bottomRightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 扫描线
class _ScanLinePainter extends CustomPainter {
  _ScanLinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        AppColors.primaryColor.withValues(alpha: 0.8),
        AppColors.primaryColor,
        AppColors.primaryColor.withValues(alpha: 0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, y - 2, size.width, 4))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
