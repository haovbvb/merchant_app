import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/features/work/device/device_detail_page_new.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceSearchPage extends StatefulWidget {
  const DeviceSearchPage({
    super.key,
    this.returnResult = false,
    this.latitude,
    this.longitude,
    this.deviceType,
    this.readOnly = false,
    this.initialKeyword,
  });

  final bool returnResult;
  final double? latitude;
  final double? longitude;
  final int? deviceType;
  final bool readOnly;
  final String? initialKeyword;

  @override
  State<DeviceSearchPage> createState() => _DeviceSearchPageState();
}

class _DeviceSearchPageState extends State<DeviceSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _history = [];
  bool _loadingHistory = true;
  bool _showHistory = true;

  String get _historyKey => widget.deviceType == 3
      ? StorageKeys.stationSearchHistory
      : StorageKeys.deviceSearchHistory;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    final initial = widget.initialKeyword?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      _showHistory = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _submit(initial);
      });
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasHistory = _history.isNotEmpty;
    final hintText = widget.deviceType == 3
        ? l10n.deviceSearchStationHint
        : l10n.deviceSearchHint;

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
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 15),
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    setState(() {
                      _showHistory = value.trim().isEmpty;
                    });
                  },
                  onSubmitted: _submit,
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() {
                      _showHistory = true;
                    });
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
                onTap: _scan,
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
          : (_showHistory && hasHistory)
          ? _buildHistoryView(l10n)
          : _DeviceSearchEmpty(text: l10n.deviceSearchEmpty),
    );
  }

  Widget _buildHistoryView(dynamic l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.deviceSearchHistoryTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black06Text,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _clearHistory,
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF999999),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _history.map((item) {
              return GestureDetector(
                onTap: () {
                  _controller.text = item;
                  _submit(item);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black06Text,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_historyKey) ?? [];
    setState(() {
      _history
        ..clear()
        ..addAll(items);
      _loadingHistory = false;
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _history);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() {
      _history.clear();
      _showHistory = true;
    });
  }

  Future<void> _addHistory(String value) async {
    final input = value.trim();
    if (input.isEmpty) return;
    setState(() {
      _history.remove(input);
      _history.insert(0, input);
      if (_history.length > 5) {
        _history.removeRange(5, _history.length);
      }
    });
    await _saveHistory();
  }

  Future<void> _submit(String value) async {
    final l10n = context.l10n;
    final input = value.trim();
    final isStationMode = widget.deviceType == 3;
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isStationMode
                ? l10n.deviceSearchStationHint
                : l10n.deviceSearchHint,
          ),
        ),
      );
      return;
    }
    String sn;
    if (isStationMode) {
      sn = ScanUtils.parseSnByDeviceType(input, 3).trim();
      if (!_isValidStationSnInput(input, sn)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deviceSearchInvalidStationSn)),
        );
        return;
      }
    } else {
      sn = widget.deviceType == null
          ? ScanUtils.getDeviceSn(input).trim()
          : ScanUtils.parseSnByDeviceType(input, widget.deviceType).trim();
    }

    if (sn.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deviceSearchEmpty)));
      return;
    }
    _controller.text = sn;
    setState(() => _showHistory = false);
    if (!mounted) return;
    if (widget.returnResult) {
      await _addHistory(sn);
      if (!mounted) return;
      Navigator.of(context).pop(sn);
      return;
    }
    final hasData = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DeviceDetailPageNew(
          initialSn: sn,
          readOnly: widget.readOnly,
          popToSearchOnClear: true,
        ),
      ),
    );
    if (!mounted) return;
    if (hasData == true) {
      await _addHistory(sn);
      return;
    }
    setState(() => _showHistory = true);
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          allowManualInput: true,
          parseDeviceSn: true,
          deviceType: widget.deviceType,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _controller.text = result;
    await _submit(result);
  }

  bool _isValidStationSnInput(String rawInput, String parsedSn) {
    if (parsedSn.isEmpty) return false;
    final input = rawInput.trim();
    final lower = input.toLowerCase();
    if (lower.isEmpty) return false;

    final containsNonStationKey =
        lower.contains('vin=') ||
        lower.contains('vin:') ||
        lower.contains('imei=') ||
        lower.contains('imei:') ||
        lower.contains('iccid=') ||
        lower.contains('iccid:') ||
        lower.contains('vcu=') ||
        lower.contains('vcu:');
    if (containsNonStationKey) return false;

    if (lower.startsWith('b:')) return false;

    return true;
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
          Text(text, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
