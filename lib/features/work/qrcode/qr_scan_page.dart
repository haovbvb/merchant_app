import 'package:flutter/material.dart';
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

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  bool _checkingPermission = true;
  CameraPermissionResult? _permission;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasPermission = _permission?.granted ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanPageTitle),
        actions: [
          if (hasPermission)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _controller.toggleTorch(),
              tooltip: l10n.scanFlashOn,
            ),
        ],
      ),
      body: _checkingPermission
          ? const Center(child: CircularProgressIndicator())
          : hasPermission
              ? Stack(
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        if (_handled) return;
                        final barcodes = capture.barcodes;
                        if (barcodes.isEmpty) return;
                        final value = barcodes.first.rawValue;
                        if (value == null || value.isEmpty) return;
                        final parsed = _parseResult(value);
                        if (parsed.isEmpty) return;
                        _handled = true;
                        Navigator.of(context).pop(parsed);
                      },
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.scanHint,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.allowManualInput) ...[
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => _showManualInput(context),
                              child: Text(l10n.scanManualInput),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              : _PermissionView(
                  title: l10n.scanCameraPermissionTitle,
                  description: l10n.scanCameraPermissionDesc,
                  retryLabel: l10n.scanPermissionRetry,
                  settingsLabel: l10n.scanOpenSettings,
                  showSettings: _showOpenSettings,
                  onRetry: _checkPermission,
                  onOpenSettings: openAppSettings,
                  onManualInput: widget.allowManualInput
                      ? () => _showManualInput(context)
                      : null,
                  manualInputLabel: l10n.scanManualInput,
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

  Future<void> _showManualInput(BuildContext context) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.scanManualInput),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.scanInputHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.scanConfirm),
            ),
          ],
        );
      },
    );
    if (!mounted || result == null || result.isEmpty) return;
    final parsed = _parseResult(result);
    if (parsed.isEmpty) return;
    Navigator.of(context).pop(parsed);
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

class _PermissionView extends StatelessWidget {
  const _PermissionView({
    required this.title,
    required this.description,
    required this.retryLabel,
    required this.settingsLabel,
    required this.showSettings,
    required this.onRetry,
    required this.onOpenSettings,
    required this.manualInputLabel,
    this.onManualInput,
  });

  final String title;
  final String description;
  final String retryLabel;
  final String settingsLabel;
  final bool showSettings;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final VoidCallback? onManualInput;
  final String manualInputLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
            if (showSettings) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onOpenSettings,
                child: Text(settingsLabel),
              ),
            ],
            if (onManualInput != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onManualInput,
                child: Text(manualInputLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
