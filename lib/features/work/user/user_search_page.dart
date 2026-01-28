import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/data/models/user_info.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/user/user_controller.dart';
import 'package:merchant_app/features/work/user/user_detail_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSearchPage extends ConsumerStatefulWidget {
  const UserSearchPage({super.key});

  @override
  ConsumerState<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends ConsumerState<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _history = [];
  List<UserInfo> _results = [];
  bool _isSearching = false;
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
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(StorageKeys.userSearchHistory) ?? [];
    setState(() => _history = items);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(StorageKeys.userSearchHistory, _history);
  }

  Future<void> _addHistory(String value) async {
    final input = value.trim();
    if (input.isEmpty) return;
    setState(() {
      _history.remove(input);
      _history.insert(0, input);
      if (_history.length > 10) {
        _history.removeLast();
      }
    });
    await _saveHistory();
  }

  Future<void> _removeHistory(String value) async {
    setState(() => _history.remove(value));
    await _saveHistory();
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.userSearchHistory);
    setState(() => _history.clear());
  }

  Future<void> _search(String value) async {
    final keyword = ScanUtils.getUserCarNum(value).trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    _searchController.text = keyword;
    await ref.read(userListProvider.notifier).refresh(keyword: keyword);
    final results = ref.read(userListProvider).items;

    setState(() {
      _results = results;
      _isSearching = false;
    });

    if (results.isNotEmpty) {
      await _addHistory(keyword);
    }
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    await _search(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildSearchField(l10n),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/android/mipmap-xxhdpi/icon_scan.webp',
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.qr_code_scanner,
                color: Colors.black,
              ),
            ),
            onPressed: _scan,
          ),
        ],
      ),
      body: _hasSearched ? _buildResults(l10n) : _buildHistoryView(l10n),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.userSearchHint,
          hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF999999), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF999999), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _hasSearched = false;
                      _results.clear();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onChanged: (value) => setState(() {}),
        onSubmitted: _search,
      ),
    );
  }

  Widget _buildHistoryView(AppLocalizations l10n) {
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.userSearchHistoryTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: _clearHistory,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 16, color: Color(0xFF999999)),
                    const SizedBox(width: 4),
                    Text(
                      l10n.userSearchHistoryClear,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _history.map((item) => _HistoryChip(
              text: item,
              onTap: () => _search(item),
              onDelete: () => _removeHistory(item),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(AppLocalizations l10n) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/icon_empty_search.png',
              width: 120,
              height: 120,
              errorBuilder: (_, __, ___) => Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.userListEmpty,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _results[index];
        return _UserCard(
          l10n: l10n,
          item: item,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserDetailPage(cardNum: item.cardNum),
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({
    required this.text,
    required this.onTap,
    required this.onDelete,
  });

  final String text;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.close, size: 14, color: Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.l10n,
    required this.item,
    this.onTap,
  });

  final AppLocalizations l10n;
  final UserInfo item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = '${item.firstName} ${item.lastName}'.trim();
    final statusColors = _getStatusColors(item.status);
    final statusLabel = _getStatusLabel(l10n, item.status);
    final tipInfo = _getTipInfo(l10n, item.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFF5F5F5),
                    backgroundImage: item.avatar.isNotEmpty
                        ? NetworkImage(item.avatar)
                        : null,
                    child: item.avatar.isEmpty
                        ? const Icon(Icons.person, color: Color(0xFF999999), size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName.isNotEmpty ? displayName : item.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: statusColors.border, width: 1),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(fontSize: 11, color: statusColors.text),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID:${item.cardNum}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Stats row
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _StatItem(label: l10n.userStatOrder, value: (item.order ?? 0).toString()),
                  Container(width: 1, height: 24, color: const Color(0xFFEEEEEE)),
                  _StatItem(label: l10n.userStatConsumption, value: _formatCurrency(item.orderAmount ?? 0)),
                  Container(width: 1, height: 24, color: const Color(0xFFEEEEEE)),
                  _StatItem(label: l10n.userStatAssets, value: (item.asset ?? 0).toString()),
                ],
              ),
            ),
            // Tip info
            if (tipInfo != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.campaign_outlined, size: 18, color: Color(0xFF999999)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tipInfo,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$ ', decimalDigits: 2).format(amount);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
        ],
      ),
    );
  }
}

class _StatusColors {
  const _StatusColors({required this.text, required this.background, required this.border});

  final Color text;
  final Color background;
  final Color border;
}

_StatusColors _getStatusColors(int status) {
  switch (status) {
    case 0:
      return const _StatusColors(text: Color(0xFF00B88A), background: Color(0xFFE9F7F2), border: Color(0xFF00B88A));
    case 1:
      return const _StatusColors(text: Color(0xFF00B88A), background: Colors.white, border: Color(0xFF00B88A));
    case 2:
      return const _StatusColors(text: Color(0xFFF09A2B), background: Color(0xFFFFF4E6), border: Color(0xFFF09A2B));
    case 3:
      return const _StatusColors(text: Color(0xFFE25C5C), background: Color(0xFFFFF1F1), border: Color(0xFFE25C5C));
    default:
      return const _StatusColors(text: Color(0xFF7A7A7A), background: Color(0xFFF2F2F2), border: Color(0xFFBDBDBD));
  }
}

String _getStatusLabel(AppLocalizations l10n, int status) {
  switch (status) {
    case 0:
      return l10n.userFilterNormal;
    case 1:
      return l10n.userFilterEnded;
    case 2:
      return l10n.userFilterOverdue;
    case 3:
      return l10n.userFilterDishonest;
    default:
      return '-';
  }
}

String? _getTipInfo(AppLocalizations l10n, int status) {
  switch (status) {
    case 0:
      return l10n.userTipNormal;
    case 1:
      return l10n.userTipEnded;
    case 2:
      return l10n.userTipOverdue;
    case 3:
      return l10n.userTipDishonest;
    default:
      return null;
  }
}
