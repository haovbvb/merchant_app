import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/camera_permission.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({
    super.key,
    this.allowManualInput = false,
    this.parseDeviceSn = false,
    this.deviceType,
    this.returnRaw = false,
    this.continuousScan = false,
    this.onContinuousScan,
  });

  final bool allowManualInput;
  final bool parseDeviceSn;
  final int? deviceType;
  /// When true, return the raw QR / manual-input value without parsing.
  final bool returnRaw;
  /// When true, keep scanner page open and handle each result via callback.
  final bool continuousScan;
  /// Callback for continuous scan mode. Return a non-empty message to show feedback.
  final FutureOr<String?> Function(String value)? onContinuousScan;

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> with TickerProviderStateMixin {
  MobileScannerController? _controller;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final FocusNode _vinFocusNode = FocusNode();

  bool _handled = false;
  bool _checkingPermission = true;
  CameraPermissionResult? _permission;
  bool _torchOn = false;
  bool _processingContinuousScan = false;
  bool _isInputMode = false;
  String? _successMessage;
  String? _lastContinuousValue;
  DateTime? _lastContinuousAt;

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
    _vinFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isInputMode = _inputFocusNode.hasFocus || _vinFocusNode.hasFocus;
    });
  }

  void _initController() {
    _controller ??= MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _inputController.dispose();
    _vinController.dispose();
    _inputFocusNode.removeListener(_onFocusChange);
    _vinFocusNode.removeListener(_onFocusChange);
    _inputFocusNode.dispose();
    _vinFocusNode.dispose();
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
                child: SizedBox.shrink(),
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

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final torchBottom = widget.allowManualInput
      ? bottomPadding + _manualInputAreaHeight() + 20
      : 180.0;

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
          bottom: torchBottom,
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
                child: Center(
                  child: Image.asset(
                    'assets/android/mipmap-xxhdpi/qr_light.webp',
                    width: 28,
                    height: 28,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
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

  double _manualInputAreaHeight() {
    // 1 row input + confirm; vehicle adds VIN input row.
    const singleInputAndConfirm = 52.0 + 12.0 + 52.0;
    const vehicleExtraInput = 12.0 + 52.0;
    const bottomMargin = 24.0;
    final isVehicle = widget.deviceType == 2;
    return singleInputAndConfirm + (isVehicle ? vehicleExtraInput : 0) + bottomMargin;
  }

  Widget _buildInputArea(dynamic l10n) {
    final isVehicle = widget.deviceType == 2;
    final alwaysShowConfirm = widget.deviceType == 1 || widget.deviceType == 2 || widget.deviceType == 3;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildManualInputBox(
          controller: _inputController,
          focusNode: _inputFocusNode,
          hintText: l10n.deviceReceiveManualInput,
          onSubmitted: (_) => _confirmManualInput(),
        ),
        if (isVehicle) ...[
          const SizedBox(height: 12),
          _buildManualInputBox(
            controller: _vinController,
            focusNode: _vinFocusNode,
            hintText: l10n.scanManualVehicleVin,
            onSubmitted: (_) => _confirmManualInput(),
          ),
        ],
        if (alwaysShowConfirm || _isInputMode || _inputController.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _confirmManualInput,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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

  Widget _buildManualInputBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required ValueChanged<String> onSubmitted,
  }) {
    return Container(
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
              controller: controller,
              focusNode: focusNode,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: onSubmitted,
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
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
    if (!widget.continuousScan && _handled) return;
    if (widget.continuousScan && _processingContinuousScan) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    final resolved = widget.returnRaw ? value.trim() : _parseResult(value);
    if (resolved.isEmpty) return;

    if (widget.continuousScan) {
      final now = DateTime.now();
      if (_lastContinuousValue == resolved &&
          _lastContinuousAt != null &&
          now.difference(_lastContinuousAt!) < const Duration(milliseconds: 1200)) {
        return;
      }
      _lastContinuousValue = resolved;
      _lastContinuousAt = now;
      _handleContinuousScan(resolved);
      return;
    }

    if (widget.returnRaw) {
      _handled = true;
      Navigator.of(context).pop(value.trim());
      return;
    }
    _handled = true;
    Navigator.of(context).pop(resolved);
  }

  Future<void> _handleContinuousScan(String resolved) async {
    _processingContinuousScan = true;
    try {
      final message = await widget.onContinuousScan?.call(resolved);
      if (!mounted) return;
      final text = (message == null || message.trim().isEmpty)
          ? context.l10n.scanSuccessEntry
          : message.trim();
      setState(() {
        _successMessage = text;
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (_successMessage == text) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    } finally {
      _processingContinuousScan = false;
    }
  }

  void _toggleTorch() {
    _controller?.toggleTorch();
    setState(() {
      _torchOn = !_torchOn;
    });
  }

  void _confirmManualInput() {
    final text = _inputController.text.trim();
    final isVehicle = widget.deviceType == 2;
    final isEntryDevice =
        widget.deviceType == 1 || widget.deviceType == 2 || widget.deviceType == 3;

    if (isEntryDevice && text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.entrySnRequired)),
      );
      return;
    }
    if (!isEntryDevice && text.isEmpty) {
      return;
    }

    if (isVehicle) {
      final vin = _vinController.text.trim();
      if (vin.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.entryVinRequired)),
        );
        return;
      }
    }

    if (widget.returnRaw) {
      final raw = isVehicle
          ? _buildVehicleManualRaw(text, _vinController.text.trim())
          : text;
      if (widget.continuousScan) {
        _handleContinuousScan(raw);
        return;
      }
      setState(() {
        _successMessage = context.l10n.scanSuccessEntry;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop(raw);
        }
      });
      return;
    }

    final parsed = _parseResult(
      isVehicle
          ? _buildVehicleManualRaw(text, _vinController.text.trim())
          : text,
    );
    if (parsed.isEmpty) return;

    if (widget.continuousScan) {
      _handleContinuousScan(parsed);
      return;
    }

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

  String _buildVehicleManualRaw(String sn, String vin) {
    final snText = sn.trim();
    final vinText = vin.trim();
    if (snText.isEmpty) {
      return 'VIN:$vinText';
    }
    return 'SN:$snText,VIN:$vinText';
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
