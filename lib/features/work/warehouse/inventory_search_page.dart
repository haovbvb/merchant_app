import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/warehouse/inventory_controller.dart';
import 'package:merchant_app/features/work/warehouse/inventory_detail_page_new.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventorySearchPage extends ConsumerStatefulWidget {
  const InventorySearchPage({super.key});

  @override
  ConsumerState<InventorySearchPage> createState() =>
      _InventorySearchPageState();
}

class _InventorySearchPageState extends ConsumerState<InventorySearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  final List<String> _history = [];

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
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(inventoryListProvider);
    final notifier = ref.read(inventoryListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
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
                        onSubmitted: (_) => _search(notifier),
                        decoration: InputDecoration(
                          hintText: l10n.inventorySearchHint,
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
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _hasSearched
                  ? _buildSearchResults(l10n, state, notifier)
                  : _buildSearchHistory(l10n, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistory(
    AppLocalizations l10n,
    InventoryListNotifier notifier,
  ) {
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
                      _search(notifier);
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

  Widget _buildSearchResults(
    AppLocalizations l10n,
    InventoryListState state,
    InventoryListNotifier notifier,
  ) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: state.hasMore,
      onRefresh: () async {
        await notifier.refresh(
          keyword: _controller.text.trim(),
          resetStatus: true,
        );
        _refreshController.refreshCompleted();
        if (ref.read(inventoryListProvider).hasMore) {
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      },
      onLoading: () async {
        await notifier.loadMore();
        if (ref.read(inventoryListProvider).hasMore) {
          _refreshController.loadComplete();
        } else {
          _refreshController.loadNoData();
        }
      },
      child: state.loading
          ? const Center(child: SizedBox.shrink())
          : state.items.isEmpty
          ? _buildEmptyState(l10n)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _InventorySearchCard(
                  inventoryNo: item.inventoryNo ?? '-',
                  warehouseName: _warehouseNameForDisplay(
                    l10n,
                    item.warehouseName,
                  ),
                  deviceType: _deviceTypeLabel(l10n, item.deviceType),
                  stock: item.stock ?? 0,
                  inventory: item.inventory ?? 0,
                  status: item.status ?? 0,
                  statusLabel: _inventoryStatusLabel(l10n, item.status),
                  deviceLabel: l10n.warehouseInventoryTypeLabel,
                  stockLabel: l10n.inventoryStockLabel,
                  inventoryLabel: l10n.inventoryCountLabel,
                  onTap: () => _goToDetail(item.inventoryNo ?? ''),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
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
            l10n.warehouseInventorySearchEmpty,
            style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _goToDetail(String inventoryNo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InventoryDetailPageNew(inventoryNo: inventoryNo),
      ),
    );
    if (!mounted) return;
    await ref
        .read(inventoryListProvider.notifier)
        .refresh(keyword: _controller.text.trim(), resetStatus: true);
  }

  String _deviceTypeLabel(AppLocalizations l10n, int? type) {
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

  String _inventoryStatusLabel(AppLocalizations l10n, int? status) {
    switch (status) {
      case 0:
        return l10n.warehouseInventoryStatusUnfinished;
      case 1:
        return l10n.warehouseInventoryStatusCompleted;
      case 2:
        return l10n.warehouseInventoryStatusRevoked;
      default:
        return '-';
    }
  }

  String _warehouseNameForDisplay(
    AppLocalizations l10n,
    String? warehouseName,
  ) {
    final name = (warehouseName ?? '').trim();
    if (name.isEmpty) return '-';
    if (name.toLowerCase().contains('platform')) {
      return l10n.commonPlatform;
    }
    return name;
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(StorageKeys.inventorySearchHistory) ?? [];
    if (!mounted) return;
    setState(() {
      _history
        ..clear()
        ..addAll(list);
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.inventorySearchHistory);
    if (!mounted) return;
    setState(() {
      _history.clear();
    });
  }

  Future<void> _addHistory(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;
    _history.remove(value);
    _history.insert(0, value);
    if (_history.length > 5) {
      _history.removeRange(5, _history.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(StorageKeys.inventorySearchHistory, _history);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _search(InventoryListNotifier notifier) async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _hasSearched = true;
    });

    await notifier.refresh(keyword: keyword, resetStatus: true);
    if (!mounted) return;
    final items = ref.read(inventoryListProvider).items;
    if (items.isNotEmpty) {
      await _addHistory(keyword);
    }
  }
}

class _InventorySearchCard extends StatelessWidget {
  const _InventorySearchCard({
    required this.inventoryNo,
    required this.warehouseName,
    required this.deviceType,
    required this.deviceLabel,
    required this.stockLabel,
    required this.inventoryLabel,
    required this.stock,
    required this.inventory,
    required this.status,
    required this.statusLabel,
    required this.onTap,
  });

  final String inventoryNo;
  final String warehouseName;
  final String deviceType;
  final String deviceLabel;
  final String stockLabel;
  final String inventoryLabel;
  final int stock;
  final int inventory;
  final int status;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        inventoryNo,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFF999999),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_issue_warehouse.webp',
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warehouseName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black06Text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricColumn(label: deviceLabel, value: deviceType),
                ),
                Expanded(
                  child: _MetricColumn(label: stockLabel, value: '$stock'),
                ),
                Expanded(
                  child: _MetricColumn(
                    label: inventoryLabel,
                    value: '$inventory',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color textColor;
    Color bgColor;

    switch (status) {
      case 1:
        textColor = AppColors.primaryColor;
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 2:
        textColor = const Color(0xFFE53935);
        bgColor = const Color(0xFFFFEBEE);
        break;
      default:
        textColor = const Color(0xFFF57C00);
        bgColor = const Color(0xFFFFF3E0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.black06Text,
          ),
        ),
      ],
    );
  }
}
