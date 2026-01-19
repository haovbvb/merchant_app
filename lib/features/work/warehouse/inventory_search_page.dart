import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/warehouse/inventory_controller.dart';
import 'package:merchant_app/features/work/warehouse/inventory_detail_page.dart';

class InventorySearchPage extends ConsumerStatefulWidget {
  const InventorySearchPage({super.key});

  @override
  ConsumerState<InventorySearchPage> createState() =>
      _InventorySearchPageState();
}

class _InventorySearchPageState extends ConsumerState<InventorySearchPage> {
  final TextEditingController _controller = TextEditingController();

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
      body: Padding(
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
              onSubmitted: (_) => _search(notifier),
            ),
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
                                builder: (_) => InventoryDetailPage(
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

  Future<void> _search(InventoryListNotifier notifier) async {
    await notifier.refresh(keyword: _controller.text.trim());
  }
}
