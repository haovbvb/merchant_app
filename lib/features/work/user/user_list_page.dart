import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/user/user_controller.dart';
import 'package:merchant_app/features/work/user/user_detail_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController _keywordController = TextEditingController();
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(userListProvider);
    final notifier = ref.read(userListProvider.notifier);
    final hasHistory = _history.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userListTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _keywordController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.userSearchHint,
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
                      onPressed: () => _submitSearch(_keywordController.text),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: _submitSearch,
            ),
          ),
          if (hasHistory)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _UserSearchHistory(
                title: l10n.userSearchHistoryTitle,
                clearLabel: l10n.userSearchHistoryClear,
                items: _history,
                onClear: _clearHistory,
                onSelected: (value) {
                  _keywordController.text = value;
                  _submitSearch(value);
                },
              ),
            ),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: state.hasMore,
              onRefresh: () async {
                await notifier.refresh(keyword: _keywordController.text);
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
              child: state.items.isEmpty
                  ? _UserEmptyState(text: l10n.userListEmpty)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        final displayName =
                            '${item.firstName} ${item.lastName}'.trim();
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person_outline),
                            ),
                            title: Text(displayName.isEmpty
                                ? item.username
                                : displayName),
                            subtitle: Text('${item.cardNum}  |  ${item.idNumber}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => UserDetailPage(
                                  cardNum: item.cardNum,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(StorageKeys.userSearchHistory) ?? [];
    setState(() {
      _history
        ..clear()
        ..addAll(items);
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(StorageKeys.userSearchHistory, _history);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.userSearchHistory);
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

  Future<void> _submitSearch(String value) async {
    final keyword = ScanUtils.getUserCarNum(value).trim();
    if (keyword.isEmpty) return;
    _keywordController.text = keyword;
    await ref.read(userListProvider.notifier).refresh(keyword: keyword);
    if (!mounted) return;
    final hasResult = ref.read(userListProvider).items.isNotEmpty;
    if (hasResult) {
      await _addHistory(keyword);
    }
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    final keyword = ScanUtils.getUserCarNum(result).trim();
    if (keyword.isEmpty) return;
    _keywordController.text = keyword;
    await _submitSearch(keyword);
  }
}

class _UserEmptyState extends StatelessWidget {
  const _UserEmptyState({required this.text});

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

class _UserSearchHistory extends StatelessWidget {
  const _UserSearchHistory({
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
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 12),
      ],
    );
  }
}
