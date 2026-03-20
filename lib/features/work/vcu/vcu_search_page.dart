import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
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
  final FocusNode _focusNode = FocusNode();
  final List<String> _history = [];
  bool _loadingHistory = true;
  bool _showNoData = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(vcuProvider);
    final notifier = ref.read(vcuProvider.notifier);
    final hasHistory = _history.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Container(
          height: 36,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF999999), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _submit(value, notifier),
                  onChanged: (_) {
                    setState(() {
                      if (_showNoData) {
                        _showNoData = false;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: l10n.deviceSearchHint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() => _showNoData = false);
                    _focusNode.requestFocus();
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCCCCCC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: state.searching ? null : _scan,
                child: AppIcons.scanIcon(
                  size: 24,
                  color: AppColors.black06Text,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loadingHistory
          ? const Center(child: SizedBox.shrink())
          : _showNoData
          ? _VcuSearchEmpty(text: l10n.deviceSearchEmpty)
          : Container(
              color: hasHistory ? const Color(0xFFF3F4F6) : Colors.white,
              child: _VcuSearchHistory(
                title: l10n.deviceSearchHistoryTitle,
                items: _history,
                onClear: _clearHistory,
                onSelected: (value) {
                  _controller.text = value;
                  setState(() => _showNoData = false);
                  _submit(value, notifier);
                },
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _focusNode.requestFocus();
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
    setState(() {
      _history.clear();
      _showNoData = false;
    });
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
    _controller.text = sn;
    setState(() => _showNoData = false);
    final result = await notifier.searchDeviceBySn(sn);
    if (!mounted) return;

    final type = result?.type;
    final deviceInfo = result?.deviceInfo;
    final isSupportedType = type == 2 || type == 4;
    if (!isSupportedType || deviceInfo == null) {
      setState(() => _showNoData = true);
      return;
    }

    final ctrlId = deviceInfo.ctrlId?.trim() ?? '';
    if (ctrlId.isEmpty) {
      showToast(l10n.deviceSearchEmpty);
      return;
    }

    await _addHistory(sn);
    if (!mounted) return;
    final vin = deviceInfo.vin ?? deviceInfo.deviceId ?? sn;
    final deviceSn = deviceInfo.deviceId ?? deviceInfo.sn ?? sn;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VcuControlPage(
          initialVin: vin,
          initialCtrlId: ctrlId,
          initialSn: deviceSn,
          initialOnline: (deviceInfo.onlineStatus ?? 0) == 1,
        ),
      ),
    );
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          allowManualInput: true,
          hideManualInputArea: true,
          parseDeviceSn: true,
        ),
      ),
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
    required this.items,
    required this.onClear,
    required this.onSelected,
  });

  final String title;
  final List<String> items;
  final VoidCallback onClear;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
              ),
              if (items.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items
                  .map(
                    (item) => GestureDetector(
                      onTap: () => onSelected(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.black06Text,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
