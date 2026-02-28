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
  int _selectedTabIndex = 0;

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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 筛选标签（搜索后显示）
            if (_hasSearched)
              Container(
                color: Colors.white,
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _FilterChip(
                      label: l10n.warehouseTabAll,
                      selected: _selectedTabIndex == 0,
                      onTap: () => _onTabSelected(0),
                    ),
                    _FilterChip(
                      label: l10n.deviceIssueStatusInTransit,
                      selected: _selectedTabIndex == 1,
                      onTap: () => _onTabSelected(1),
                    ),
                    _FilterChip(
                      label: l10n.deviceIssueStatusReceiveAll,
                      selected: _selectedTabIndex == 2,
                      onTap: () => _onTabSelected(2),
                    ),
                    _FilterChip(
                      label: l10n.deviceIssueStatusPartial,
                      selected: _selectedTabIndex == 3,
                      onTap: () => _onTabSelected(3),
                    ),
                    _FilterChip(
                      label: l10n.deviceIssueStatusWithdrawn,
                      selected: _selectedTabIndex == 4,
                      onTap: () => _onTabSelected(4),
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

  void _onTabSelected(int index) {
    setState(() => _selectedTabIndex = index);
    _doSearch(statusIndex: index);
  }

  Future<void> _doSearch({int? statusIndex}) async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _hasSearched = true;
    });

    final status = _mapStatus(statusIndex ?? _selectedTabIndex);
    await ref.read(transportListProvider.notifier).refresh(
          keyword: keyword,
          status: status,
          mode: widget.mode,
        );
    if (!mounted) return;
    final currentState = ref.read(transportListProvider);
    if (currentState.items.isNotEmpty) {
      await _saveHistory(keyword);
    }
  }

  int? _mapStatus(int index) {
    switch (index) {
      case 0:
        return null;
      case 1:
        return 0;
      case 2:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return null;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEEF7E9) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFFE5E5E5),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFF666666),
                fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
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
                    'assets/android/mipmap-xxhdpi/icon_issue_warehouse.webp',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
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
