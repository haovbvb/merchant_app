import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/vcu/vcu_control_page.dart';
import 'package:merchant_app/features/work/vcu/vcu_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VcuSearchPage extends ConsumerStatefulWidget {
  const VcuSearchPage({super.key});

  @override
  ConsumerState<VcuSearchPage> createState() => _VcuSearchPageState();
}

class _VcuSearchPageState extends ConsumerState<VcuSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _history = [];
  bool _loadingHistory = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(vcuProvider);
    final notifier = ref.read(vcuProvider.notifier);
    final hasHistory = _history.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vcuSearchTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _submit(value, notifier),
              decoration: InputDecoration(
                hintText: l10n.deviceSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: AppIcons.scanIcon(),
                      onPressed: state.searching ? null : _scan,
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: state.searching
                          ? null
                          : () => _submit(_controller.text, notifier),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _loadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : hasHistory
                  ? _VcuSearchHistory(
                      title: l10n.deviceSearchHistoryTitle,
                      clearLabel: l10n.deviceSearchHistoryClear,
                      items: _history,
                      onClear: _clearHistory,
                      onSelected: (value) {
                        _controller.text = value;
                        _submit(value, notifier);
                      },
                    )
                  : _VcuSearchEmpty(text: l10n.deviceSearchEmpty),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(StorageKeys.vcuSearchHistory) ?? [];
    setState(() {
      _history
        ..clear()
        ..addAll(items);
      _loadingHistory = false;
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(StorageKeys.vcuSearchHistory, _history);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.vcuSearchHistory);
    setState(() => _history.clear());
  }

  Future<void> _addHistory(String value) async {
    final input = value.trim();
    if (input.isEmpty) return;
    setState(() {
      _history.remove(input);
      _history.insert(0, input);
      if (_history.length > 5) {
        _history.removeLast();
      }
    });
    await _saveHistory();
  }

  Future<void> _submit(String value, VcuNotifier notifier) async {
    final l10n = context.l10n;
    final input = value.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deviceSearchHint)));
      return;
    }
    final sn = ScanUtils.getDeviceSn(input).trim();
    if (sn.isEmpty) return;
    await _addHistory(input);
    final result = await notifier.searchDeviceBySn(sn);
    if (!mounted) return;
    final deviceInfo = result?.deviceInfo;
    if (deviceInfo == null ||
        deviceInfo.ctrlId == null ||
        deviceInfo.ctrlId!.isEmpty) {
      showToast(l10n.deviceSearchEmpty);
      return;
    }
    final vin = deviceInfo.vin ?? deviceInfo.deviceId ?? sn;
    final ctrlId = deviceInfo.ctrlId ?? '';
    final deviceSn = deviceInfo.sn ?? deviceInfo.deviceId ?? sn;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VcuControlPage(
          initialVin: vin,
          initialCtrlId: ctrlId,
          initialSn: deviceSn,
        ),
      ),
    );
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _controller.text = result;
    await _submit(result, ref.read(vcuProvider.notifier));
  }
}

class _VcuSearchEmpty extends StatelessWidget {
  const _VcuSearchEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_empty_search.png',
            width: 160,
          ),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _VcuSearchHistory extends StatelessWidget {
  const _VcuSearchHistory({
    required this.title,
    required this.clearLabel,
    required this.items,
    required this.onClear,
    required this.onSelected,
  });

  final String title;
  final String clearLabel;
  final List<String> items;
  final VoidCallback onClear;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(onPressed: onClear, child: Text(clearLabel)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => ActionChip(
                  label: Text(item),
                  onPressed: () => onSelected(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
