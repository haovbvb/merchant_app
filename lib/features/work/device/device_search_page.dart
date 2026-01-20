import 'package:flutter/material.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/features/work/device/device_detail_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceSearchPage extends StatefulWidget {
  const DeviceSearchPage({super.key});

  @override
  State<DeviceSearchPage> createState() => _DeviceSearchPageState();
}

class _DeviceSearchPageState extends State<DeviceSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasHistory = _history.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deviceSearchTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _submit(value),
              decoration: InputDecoration(
                hintText: l10n.deviceSearchHint,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_search.webp',
                    width: 20,
                    height: 20,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scan,
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _submit(_controller.text),
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
                      ? _DeviceSearchHistory(
                          title: l10n.deviceSearchHistoryTitle,
                          clearLabel: l10n.deviceSearchHistoryClear,
                          items: _history,
                          onClear: _clearHistory,
                          onSelected: (value) {
                            _controller.text = value;
                            _submit(value);
                          },
                        )
                      : _DeviceSearchEmpty(text: l10n.deviceSearchEmpty),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(StorageKeys.deviceSearchHistory) ?? [];
    setState(() {
      _history
        ..clear()
        ..addAll(items);
      _loadingHistory = false;
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(StorageKeys.deviceSearchHistory, _history);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.deviceSearchHistory);
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

  Future<void> _submit(String value) async {
    final l10n = context.l10n;
    final input = value.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deviceSearchHint)),
      );
      return;
    }
    final sn = ScanUtils.getDeviceSn(input).trim();
    if (sn.isEmpty) return;
    await _addHistory(input);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailPage(initialSn: sn),
      ),
    );
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          parseDeviceSn: true,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _controller.text = result;
    await _submit(result);
  }
}

class _DeviceSearchEmpty extends StatelessWidget {
  const _DeviceSearchEmpty({required this.text});

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
          Text(
            text,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _DeviceSearchHistory extends StatelessWidget {
  const _DeviceSearchHistory({
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
            TextButton(
              onPressed: onClear,
              child: Text(clearLabel),
            ),
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
