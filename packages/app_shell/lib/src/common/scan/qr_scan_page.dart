import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foundation/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({
    super.key,
    this.allowManualInput = false,
    this.forceScanOnly = false,
    this.hideManualInputArea = false,
    this.parseDeviceSn = false,
    this.deviceType,
    this.returnRaw = false,
    this.continuousScan = false,
    this.onContinuousScan,
  });

  final bool allowManualInput;
  final bool forceScanOnly;
  final bool hideManualInputArea;
  final bool parseDeviceSn;
  final int? deviceType;
  final bool returnRaw;
  final bool continuousScan;
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
  String? _feedbackMessage;

  late AnimationController _scanLineController;

  bool get _showManualInput =>
      widget.allowManualInput && !widget.forceScanOnly && !widget.hideManualInputArea;

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
    if (!mounted) return;
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
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: _checkingPermission
            ? const Center(child: CircularProgressIndicator())
            : hasPermission
            ? _buildScannerView(context)
            : _buildPermissionView(context),
      ),
    );
  }

  Widget _buildScannerView(BuildContext context) {
    _initController();

    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.68;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final torchBottom = _showManualInput
        ? bottomPadding + _manualInputAreaHeight() + 20
        : bottomPadding + 120;

    return Stack(
      children: [
        Positioned.fill(
          child: MobileScanner(controller: _controller!, onDetect: _onDetect),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _ScanOverlayPainter(scanAreaSize: scanAreaSize, borderRadius: 24),
          ),
        ),
        Center(
          child: SizedBox(
            width: scanAreaSize,
            height: scanAreaSize,
            child: CustomPaint(painter: _ScanCornerPainter(borderRadius: 24)),
          ),
        ),
        Center(
          child: SizedBox(
            width: scanAreaSize - 24,
            height: scanAreaSize,
            child: AnimatedBuilder(
              animation: _scanLineController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ScanLinePainter(progress: _scanLineController.value),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),
        if (_feedbackMessage != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xCC3C3C3C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _feedbackMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
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
                  color: _torchOn ? const Color(0xFF0A84FF) : const Color(0x80808080),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _torchOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        if (_showManualInput)
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: _buildInputArea(),
          ),
      ],
    );
  }

  double _manualInputAreaHeight() {
    const singleInputAndConfirm = 52.0 + 12.0 + 52.0;
    const vehicleExtraInput = 12.0 + 52.0;
    final isVehicle = widget.deviceType == 2;
    return singleInputAndConfirm + (isVehicle ? vehicleExtraInput : 0) + 24.0;
  }

  Widget _buildInputArea() {
    final isVehicle = widget.deviceType == 2;
    final alwaysShowConfirm = widget.deviceType == 1 || widget.deviceType == 2 || widget.deviceType == 3;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildManualInputBox(
          controller: _inputController,
          focusNode: _inputFocusNode,
          hintText: 'Manual input',
          onSubmitted: (_) => _confirmManualInput(),
        ),
        if (isVehicle) ...[
          const SizedBox(height: 12),
          _buildManualInputBox(
            controller: _vinController,
            focusNode: _vinFocusNode,
            hintText: 'Vehicle VIN',
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
                backgroundColor: const Color(0xFF0A84FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm'),
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
          const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white60, fontSize: 16),
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
                child: Icon(Icons.cancel, color: Colors.white54, size: 20),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPermissionView(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 72, color: Colors.white70),
              const SizedBox(height: 20),
              const Text(
                'Camera permission required',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Please allow camera access in system settings and try again.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _checkPermission,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkPermission() async {
    setState(() {
      _checkingPermission = true;
    });
    final result = await ensureCameraPermission();
    if (!mounted) return;
    setState(() {
      _permission = result;
      _checkingPermission = false;
    });
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.toggleTorch();
    if (!mounted) return;
    setState(() {
      _torchOn = !_torchOn;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (!mounted) return;
    if (!widget.continuousScan && _handled) return;
    if (widget.continuousScan && _processingContinuousScan) return;

    final raw = capture.barcodes.first.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    final resolved = _resolveValue(raw);
    if (resolved.isEmpty) return;

    if (widget.continuousScan) {
      _handleContinuousScan(resolved);
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
      setState(() {
        _feedbackMessage = (message?.trim().isNotEmpty ?? false) ? message!.trim() : 'Recorded';
      });
      Future<void>.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _feedbackMessage = null;
        });
      });
    } finally {
      _processingContinuousScan = false;
    }
  }

  void _confirmManualInput() {
    final raw = _inputController.text.trim();
    if (raw.isEmpty) return;

    if (widget.deviceType == 2 && _vinController.text.trim().isEmpty) {
      return;
    }

    final resolved = _resolveValue(raw);
    if (resolved.isEmpty) return;

    if (widget.continuousScan) {
      _handleContinuousScan(resolved);
      _inputController.clear();
      _vinController.clear();
      setState(() {});
      return;
    }

    Navigator.of(context).pop(resolved);
  }

  String _resolveValue(String value) {
    if (widget.returnRaw) {
      return value.trim();
    }
    if (!widget.parseDeviceSn) {
      return value.trim();
    }
    if (widget.deviceType != null) {
      return ScanUtils.parseSnByDeviceType(value, widget.deviceType).trim();
    }
    return ScanUtils.getDeviceSn(value).trim();
  }
}

class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({required this.scanAreaSize, required this.borderRadius});

  final double scanAreaSize;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = const Color(0x99000000);
    final center = Offset(size.width / 2, size.height / 2);
    final scanRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: scanAreaSize, height: scanAreaSize),
      Radius.circular(borderRadius),
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) {
    return oldDelegate.scanAreaSize != scanAreaSize || oldDelegate.borderRadius != borderRadius;
  }
}

class _ScanCornerPainter extends CustomPainter {
  _ScanCornerPainter({required this.borderRadius});

  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    const cornerLength = 24.0;
    const strokeWidth = 3.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final r = borderRadius;
    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(r, 0), Offset(r + cornerLength, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, r + cornerLength), paint);

    canvas.drawLine(Offset(w - r, 0), Offset(w - r - cornerLength, 0), paint);
    canvas.drawLine(Offset(w, r), Offset(w, r + cornerLength), paint);

    canvas.drawLine(Offset(r, h), Offset(r + cornerLength, h), paint);
    canvas.drawLine(Offset(0, h - r), Offset(0, h - r - cornerLength), paint);

    canvas.drawLine(Offset(w - r, h), Offset(w - r - cornerLength, h), paint);
    canvas.drawLine(Offset(w, h - r), Offset(w, h - r - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanCornerPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius;
  }
}

class _ScanLinePainter extends CustomPainter {
  _ScanLinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final y = (size.height - 8) * progress;
    final rect = Rect.fromLTWH(0, y, size.width, 4);
    final gradient = const LinearGradient(
      colors: [Color(0x0018E0A1), Color(0xAA18E0A1), Color(0x0018E0A1)],
      stops: [0.0, 0.5, 1.0],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
