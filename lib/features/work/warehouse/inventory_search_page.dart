import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/warehouse/inventory_controller.dart';
import 'package:merchant_app/features/work/warehouse/inventory_detail_page_new.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventorySearchPage extends ConsumerStatefulWidget {
  const InventorySearchPage({super.key});

  @override
  ConsumerState<InventorySearchPage> createState() =>
      _InventorySearchPageState();
}

class _InventorySearchPageState extends ConsumerState<InventorySearchPage> {
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
    final notifier = ref.read(inventoryListProvider.notifier);
    final state = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.warehouseInventorySearchTitle)),
      body: _loadingHistory
          ? const Center(child: SizedBox.shrink())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: l10n.warehouseInventorySearchHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _search(notifier),
            ),
            const SizedBox(height: 12),
            if (_controller.text.trim().isEmpty && _history.isNotEmpty)
              _HistoryView(
                items: _history,
                onTapItem: (item) {
                  _controller.text = item;
                  _search(notifier);
                },
                onClear: _clearHistory,
              ),
            if (_controller.text.trim().isEmpty && _history.isNotEmpty)
              const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _search(notifier),
              child: Text(l10n.warehouseSearchAction),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: state.items.isEmpty
                  ? Center(child: Text(l10n.warehouseInventorySearchEmpty))
                  : ListView.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.inventoryNo ?? '-'),
                            subtitle: Text(item.warehouseName ?? '-'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => InventoryDetailPageNew(
                                  inventoryNo: item.inventoryNo ?? '',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(StorageKeys.inventorySearchHistory) ?? [];
    if (!mounted) return;
    setState(() {
      _history
        ..clear()
        ..addAll(list);
      _loadingHistory = false;
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
    await notifier.refresh(keyword: keyword);
    final items = ref.read(inventoryListProvider).items;
    if (items.isNotEmpty) {
      await _addHistory(keyword);
    }
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({
    required this.items,
    required this.onTapItem,
    required this.onClear,
  });

  final List<String> items;
  final ValueChanged<String> onTapItem;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.deviceSearchHistoryTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(onPressed: onClear, child: const Text('清空')),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (e) => InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onTapItem(e),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(e),
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
