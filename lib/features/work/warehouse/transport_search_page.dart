import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';
import 'package:merchant_app/features/work/warehouse/transport_detail_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _historyKey = 'device_issue_search_history';

class TransportSearchPage extends ConsumerStatefulWidget {
  const TransportSearchPage({super.key, required this.mode});

  final TransportMode mode;

  @override
  ConsumerState<TransportSearchPage> createState() =>
      _TransportSearchPageState();
}

class _TransportSearchPageState extends ConsumerState<TransportSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _history = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList(_historyKey) ?? [];
    });
  }

  Future<void> _saveHistory(String keyword) async {
    if (keyword.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _history.remove(keyword);
    _history.insert(0, keyword);
    if (_history.length > 10) {
      _history = _history.sublist(0, 10);
    }
    await prefs.setStringList(_historyKey, _history);
    setState(() {});
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() {
      _history = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(transportListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(0, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _doSearch(),
                        decoration: InputDecoration(
                          hintText: l10n.deviceIssueSearchHint,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          suffixIcon: _controller.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _controller.clear();
                                    setState(() {
                                      _hasSearched = false;
                                    });
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.grey.shade400,
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 内容区
            Expanded(
              child: _hasSearched
                  ? _buildSearchResults(l10n, state)
                  : _buildSearchHistory(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistory(AppLocalizations l10n) {
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.searchHistory,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black06Text,
                ),
              ),
              GestureDetector(
                onTap: _clearHistory,
                child: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _history
                .map(
                  (keyword) => GestureDetector(
                    onTap: () {
                      _controller.text = keyword;
                      _doSearch();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        keyword,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
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

  Widget _buildSearchResults(AppLocalizations l10n, TransportListState state) {
    if (state.loading) {
      return const Center(child: SizedBox.shrink());
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/icon_empty_search.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.deviceIssueSearchEmpty,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _SearchResultCard(
          item: item,
          mode: widget.mode,
          l10n: l10n,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TransportDetailPage(
                transferNo: item.transferNo,
                mode: widget.mode,
                status: item.status,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _doSearch() async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _hasSearched = true;
    });

    await ref.read(transportListProvider.notifier).refresh(
          keyword: keyword,
          status: null,
          mode: widget.mode,
        );
    if (!mounted) return;
    final currentState = ref.read(transportListProvider);
    if (currentState.items.isNotEmpty) {
      await _saveHistory(keyword);
    }
  }

}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.item,
    required this.mode,
    required this.l10n,
    required this.onTap,
  });

  final dynamic item;
  final TransportMode mode;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColors = _getStatusColors(item.status);
    final withdrawnNum =
        (item.deviceNum - item.inTransitNum - item.receivedNum)
            .clamp(0, item.deviceNum);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.transferNo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFCCCCCC),
                    size: 20,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatusTag(
                    label: _getStatusLabel(item.status),
                    textColor: statusColors.text,
                    backgroundColor: statusColors.background,
                  ),
                  const SizedBox(width: 8),
                  _StatusTag(
                    label: _getDeviceTypeLabel(item.deviceType),
                    textColor: const Color(0xFF666666),
                    backgroundColor: const Color(0xFFF5F5F5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_device_issuse_state.png',
                    width: 14,
                    height: 14,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.home_outlined,
                      size: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.outWarehouseName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black06Text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  _MetricItem(
                    label: l10n.deviceIssueQuantity,
                    value: item.deviceNum.toString(),
                  ),
                  _MetricItem(
                    label: l10n.deviceIssueReceived,
                    value: item.receivedNum.toString(),
                  ),
                  _MetricItem(
                    label: l10n.deviceIssueWithdrawn,
                    value: withdrawnNum.toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 0:
        return l10n.deviceIssueStatusInTransit;
      case 1:
        return l10n.deviceIssueStatusReceiveAll;
      case 2:
        return l10n.deviceIssueStatusPartial;
      case 3:
        return l10n.deviceIssueStatusWithdrawn;
      default:
        return '-';
    }
  }

  String _getDeviceTypeLabel(int? type) {
    switch (type) {
      case 1:
        return l10n.warehouseDeviceTypeBattery;
      case 2:
        return l10n.warehouseDeviceTypeVehicle;
      case 3:
        return l10n.warehouseDeviceTypeStation;
      default:
        return '-';
    }
  }

  _StatusColors _getStatusColors(int status) {
    switch (status) {
      case 0:
        return const _StatusColors(
          text: Color(0xFFED942F),
          background: Color(0xFFFEF7EA),
        );
      case 1:
        return const _StatusColors(
          text: AppColors.primaryColor,
          background: Color(0xFFEEF7E9),
        );
      case 2:
        return const _StatusColors(
          text: Color(0xFF2196F3),
          background: Color(0xFFE3F2FD),
        );
      case 3:
        return const _StatusColors(
          text: Color(0xFFE25C5C),
          background: Color(0xFFFDECEC),
        );
      default:
        return const _StatusColors(
          text: Color(0xFF999999),
          background: Color(0xFFF5F5F5),
        );
    }
  }
}

class _StatusColors {
  const _StatusColors({required this.text, required this.background});
  final Color text;
  final Color background;
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
