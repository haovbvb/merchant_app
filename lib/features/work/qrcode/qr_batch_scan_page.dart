import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/camera_permission.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/qrcode/qr_code_list_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrBatchScanPage extends ConsumerStatefulWidget {
  const QrBatchScanPage({
    super.key,
    this.initialItems = const [],
    this.fixedDeviceType,
    this.title,
    this.maxSize,
  });

  final List<String> initialItems;
  final int? fixedDeviceType;
  final String? title;
  final int? maxSize;

  @override
  ConsumerState<QrBatchScanPage> createState() => _QrBatchScanPageState();
}

class _QrBatchScanPageState extends ConsumerState<QrBatchScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  String? _lastText;
  DateTime? _lastTime;
  bool _sameToastShown = false;
  bool _checkingPermission = true;
  CameraPermissionResult? _permission;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(qrCodeListProvider.notifier);
      notifier.reset();
      if (widget.fixedDeviceType != null) {
        notifier.setDeviceType(widget.fixedDeviceType);
      }
      if (widget.initialItems.isNotEmpty) {
        notifier.setInitialItems(widget.initialItems);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(qrCodeListProvider);
    final notifier = ref.read(qrCodeListProvider.notifier);
    final hasPermission = _permission?.granted ?? false;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(state.items);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? l10n.qrcodeListTitle),
          actions: [
            if (hasPermission)
              IconButton(
                icon: const Icon(Icons.flash_on),
                onPressed: () => _controller.toggleTorch(),
                tooltip: l10n.scanFlashOn,
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(state.items),
              child: Text(l10n.qrcodeListConfirm),
            ),
          ],
        ),
        body: _checkingPermission
            ? const Center(child: SizedBox.shrink())
            : hasPermission
                ? Stack(
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: (capture) async {
                          final barcodes = capture.barcodes;
                          if (barcodes.isEmpty) return;
                          final value = barcodes.first.rawValue;
                          if (value == null || value.trim().isEmpty) return;
                          if (_isDuplicate(value, l10n)) return;
                          _lastText = value;
                          _lastTime = DateTime.now();
                          await _resolveAndAdd(notifier, value, l10n);
                        },
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: _ScanPanel(
                          items: state.items,
                          emptyText: l10n.qrcodeListEmpty,
                          onManualInput: () => _showManualInput(context, notifier),
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
                    onManualInput: () => _showManualInput(context, notifier),
                    manualInputLabel: l10n.scanManualInput,
                  ),
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

  bool _isDuplicate(String value, AppLocalizations l10n) {
    final now = DateTime.now();
    if (_lastText != null && _lastText == value) {
      if (_lastTime != null && now.difference(_lastTime!).inSeconds < 3) {
        _scheduleSameToast(l10n);
        return true;
      }
    }
    return false;
  }

  bool _isOverMaxSize(QrCodeListState state, AppLocalizations l10n) {
    final maxSize = widget.maxSize;
    if (maxSize == null) return false;
    if (state.items.length >= maxSize) {
      _showSnack(l10n.qrcodeMaxDevice);
      return true;
    }
    return false;
  }

  void _scheduleSameToast(AppLocalizations l10n) {
    if (_sameToastShown) return;
    _sameToastShown = true;
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      _showSnack(l10n.qrcodeSameAsPrevious);
      _sameToastShown = false;
    });
  }

  Future<void> _resolveAndAdd(
    QrCodeListNotifier notifier,
    String value,
    AppLocalizations l10n,
  ) async {
    final resolved = await notifier.resolveDeviceSn(value);
    if (resolved == null || resolved.trim().isEmpty) return;

    final state = ref.read(qrCodeListProvider);
    final existed = state.items.contains(resolved);
    if (!existed && _isOverMaxSize(state, l10n)) return;

    final added = notifier.addItem(resolved);
    if (!added) {
      _showSnack(l10n.warehouseInventoryScanRepeat);
    }
  }

  Future<void> _showManualInput(
    BuildContext context,
    QrCodeListNotifier notifier,
  ) async {
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
    final state = ref.read(qrCodeListProvider);
    final resolved = await notifier.resolveDeviceSn(result);
    if (resolved == null || resolved.trim().isEmpty) return;
    final existed = state.items.contains(resolved);
    if (!existed && _isOverMaxSize(state, l10n)) return;
    final added = notifier.addItem(resolved);
    if (!added) {
      _showSnack(l10n.warehouseInventoryScanRepeat);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    required this.onManualInput,
    required this.manualInputLabel,
  });

  final String title;
  final String description;
  final String retryLabel;
  final String settingsLabel;
  final bool showSettings;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final VoidCallback onManualInput;
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
            const SizedBox(height: 8),
            TextButton(
              onPressed: onManualInput,
              child: Text(manualInputLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanPanel extends StatelessWidget {
  const _ScanPanel({
    required this.items,
    required this.emptyText,
    required this.onManualInput,
  });

  final List<String> items;
  final String emptyText;
  final VoidCallback onManualInput;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.qrcodeListTitle} (${items.length})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: onManualInput,
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.scanManualInput),
                ),
              ],
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  emptyText,
                  style: const TextStyle(color: Colors.black54),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Text(items[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
