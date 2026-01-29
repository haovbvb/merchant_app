import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/qrcode/qr_code_list_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class QrCodeListPage extends ConsumerStatefulWidget {
  const QrCodeListPage({
    super.key,
    this.selectMode = false,
    this.initialItems = const [],
    this.fixedDeviceType,
    this.title,
  });

  final bool selectMode;
  final List<String> initialItems;
  final int? fixedDeviceType;
  final String? title;

  @override
  ConsumerState<QrCodeListPage> createState() => _QrCodeListPageState();
}

class _QrCodeListPageState extends ConsumerState<QrCodeListPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
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

    return WillPopScope(
      onWillPop: () async {
        if (widget.selectMode) {
          Navigator.of(context).pop(state.items);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? l10n.qrcodeListTitle),
          actions: [
            IconButton(
              icon: AppIcons.scanIcon(),
              onPressed: () => _scanAndAdd(notifier),
            ),
            if (widget.selectMode)
              TextButton(
                onPressed: () => Navigator.of(context).pop(state.items),
                child: Text(l10n.qrcodeListConfirm),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          if (widget.fixedDeviceType == null) ...[
            Text(
              l10n.qrcodeDeviceTypeTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _deviceTypeOptions(l10n)
                  .map(
                    (item) => ChoiceChip(
                      label: Text(item.label),
                      selected: state.deviceType == item.value,
                      onSelected: (_) => notifier.setDeviceType(item.value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: l10n.qrcodeInputHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: state.loading
                    ? null
                    : () => _resolveManual(notifier),
                child: Text(l10n.qrcodeResolveAction),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.items.isEmpty)
            _QrEmptyState(text: l10n.qrcodeListEmpty)
          else
            ...List.generate(
              state.items.length,
              (index) => Card(
                child: ListTile(
                  title: Text(state.items[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => notifier.removeAt(index),
                  ),
                ),
              ),
            ),
        ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _scanAndAdd(notifier),
          child: AppIcons.scanIcon(),
        ),
      ),
    );
  }

  Future<void> _scanAndAdd(QrCodeListNotifier notifier) async {
    final deviceType = ref.read(qrCodeListProvider).deviceType;
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          parseDeviceSn: true,
          deviceType: deviceType,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    final resolved = await _resolveAndAdd(notifier, result);
    if (!mounted) return;
    _showResolveSnack(resolved);
  }

  Future<void> _resolveManual(QrCodeListNotifier notifier) async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    final resolved = await _resolveAndAdd(notifier, value);
    if (!mounted) return;
    if (resolved != null) {
      _controller.clear();
    }
    _showResolveSnack(resolved);
  }

  Future<String?> _resolveAndAdd(
    QrCodeListNotifier notifier,
    String value,
  ) async {
    if (value.trim().isEmpty) return null;
    final resolved = await notifier.resolveDeviceSn(value);
    if (resolved != null) {
      notifier.addItem(resolved);
    }
    return resolved;
  }

  void _showResolveSnack(String? value) {
    final l10n = context.l10n;
    final message = value == null
        ? l10n.qrcodeResolveFailed
        : l10n.qrcodeResolveSuccess;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<_DeviceTypeOption> _deviceTypeOptions(AppLocalizations l10n) {
    return [
      _DeviceTypeOption(label: l10n.qrcodeDeviceTypeBattery, value: 1),
      _DeviceTypeOption(label: l10n.qrcodeDeviceTypeVehicle, value: 2),
      _DeviceTypeOption(label: l10n.qrcodeDeviceTypeCabinet, value: 3),
      _DeviceTypeOption(label: l10n.qrcodeDeviceTypeAll, value: null),
    ];
  }
}

class _DeviceTypeOption {
  const _DeviceTypeOption({required this.label, required this.value});

  final String label;
  final int? value;
}

class _QrEmptyState extends StatelessWidget {
  const _QrEmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/icon_empty_record.png',
              width: 160,
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
