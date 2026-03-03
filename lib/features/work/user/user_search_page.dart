import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/data/models/user_info.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/user/user_controller.dart';
import 'package:merchant_app/features/work/user/user_detail_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSearchPage extends ConsumerStatefulWidget {
  const UserSearchPage({super.key});

  @override
  ConsumerState<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends ConsumerState<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> _history = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _loadingHistory = true;
  String _historyKey = StorageKeys.userSearchHistory;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _search(_searchController.text);
    }
  }

  void _onInputChanged(String value) {
    if (value.isEmpty && _hasSearched) {
      _showHistory();
    }
    setState(() {});
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final account = prefs.getString(StorageKeys.loginAccount) ?? '';
    _historyKey = account.isNotEmpty
        ? '${StorageKeys.userSearchHistory}_$account'
        : StorageKeys.userSearchHistory;
    final items = prefs.getStringList(_historyKey) ?? [];
    setState(() {
      _history = items;
      _loadingHistory = false;
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _history);
  }

  Future<void> _addHistory(String value) async {
    final input = value.trim();
    if (input.isEmpty) return;
    setState(() {
      _history.remove(input);
      _history.insert(0, input);
      if (_history.length > 5) {
        _history = _history.sublist(0, 5);
      }
    });
    await _saveHistory();
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() => _history.clear());
  }

  Future<void> _search(String value) async {
    final keyword = ScanUtils.getUserCarNum(value).trim();
    if (keyword.isEmpty) {
      _showHistory();
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _keyword = keyword;
    });

    _searchController.text = keyword;
    _refreshController.resetNoData();
    await ref.read(userListProvider.notifier).refresh(keyword: keyword);
    if (!mounted) return;

    setState(() {
      _isSearching = false;
    });

    final items = ref.read(userListProvider).items;
    if (items.isNotEmpty) {
      await _addHistory(keyword);
    }

    if (!ref.read(userListProvider).hasMore) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  void _showHistory() {
    setState(() {
      _hasSearched = false;
      _isSearching = false;
      _keyword = '';
    });
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(allowManualInput: true)),
    );
    if (!mounted || result == null || result.isEmpty) return;
    await _search(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(userListProvider);
    final notifier = ref.read(userListProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SearchHeader(
              l10n: l10n,
              controller: _searchController,
              focusNode: _focusNode,
              onBack: () {
                ref.read(userListProvider.notifier).refresh(keyword: '');
                Navigator.of(context).pop();
              },
              onScan: _scan,
              onSubmitted: _search,
              onChanged: _onInputChanged,
              onClear: () {
                _searchController.clear();
                _showHistory();
              },
            ),
            Expanded(
              child: _loadingHistory
                  ? const SizedBox.shrink()
                  : _hasSearched
                      ? _buildResults(l10n, state, notifier)
                      : _buildHistoryView(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryView(AppLocalizations l10n) {
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.userSearchHistoryTitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xE60C0C0D),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _clearHistory,
                child: Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_search_delete.webp',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _history
                .map(
                  (item) => _HistoryChip(
                    text: item,
                    onTap: () => _search(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    AppLocalizations l10n,
    UserListState state,
    UserListNotifier notifier,
  ) {
    if (state.items.isEmpty && !_isSearching) {
      return _SearchEmptyView(text: l10n.userSearchEmpty);
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: state.hasMore,
          onRefresh: () async {
            await notifier.refresh(keyword: _keyword);
            _refreshController.refreshCompleted();
            if (!ref.read(userListProvider).hasMore) {
              _refreshController.loadNoData();
            }
          },
          onLoading: () async {
            await notifier.loadMore();
            if (ref.read(userListProvider).hasMore) {
              _refreshController.loadComplete();
            } else {
              _refreshController.loadNoData();
            }
          },
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Color(0xFFE6E6E6),
            ),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _UserSearchItem(
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
          ),
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.l10n,
    required this.controller,
    required this.focusNode,
    required this.onBack,
    required this.onScan,
    required this.onSubmitted,
    required this.onChanged,
    required this.onClear,
  });

  final AppLocalizations l10n;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onBack;
  final VoidCallback onScan;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 5, 15, 5),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 30,
              height: 38,
              child: Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: AppColors.black06Text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.userSearchHint,
                        hintStyle: const TextStyle(
                          color: Color(0x66000000),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(left: 16, right: 8),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: onClear,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Image.asset(
                          'assets/android/mipmap-xxhdpi/icon_clear.webp',
                          width: 18,
                          height: 18,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFE0E0E0),
                  ),
                  GestureDetector(
                    onTap: onScan,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      child: Image.asset(
                        'assets/android/mipmap-xxhdpi/icon_scan3.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.qr_code_scanner,
                          size: 20,
                          color: AppColors.black06Text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xB30C0C0D),
          ),
        ),
      ),
    );
  }
}

class _UserSearchItem extends StatelessWidget {
  const _UserSearchItem({required this.item, this.onTap});

  final UserInfo item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = '${item.firstName} ${item.lastName}'.trim();
    final idText = item.username.isNotEmpty ? item.username : item.cardNum;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFF5F5F5),
              backgroundImage:
                  item.avatar.isNotEmpty ? NetworkImage(item.avatar) : null,
              child: item.avatar.isEmpty
                  ? const Icon(
                      Icons.person,
                      color: Color(0xFF999999),
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isNotEmpty ? displayName : item.username,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xE6000000),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ID: $idText',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0x99000000),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyView extends StatelessWidget {
  const _SearchEmptyView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0x80000000),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
