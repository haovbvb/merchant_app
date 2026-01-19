import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';
import 'package:merchant_app/features/work/warehouse/transport_detail_page.dart';

class TransportSearchPage extends ConsumerStatefulWidget {
  const TransportSearchPage({super.key, required this.mode});

  final TransportMode mode;

  @override
  ConsumerState<TransportSearchPage> createState() =>
      _TransportSearchPageState();
}

class _TransportSearchPageState extends ConsumerState<TransportSearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notifier = ref.read(transportListProvider.notifier);
    final state = ref.watch(transportListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.warehouseTransportSearchTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: l10n.warehouseTransportSearchHint,
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
                  ? Center(child: Text(l10n.warehouseTransportSearchEmpty))
                  : ListView.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.transferNo),
                            subtitle: Text(item.inWarehouseName),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TransportDetailPage(
                                  transferNo: item.transferNo,
                                  mode: widget.mode,
                                  status: item.status,
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

  Future<void> _search(TransportListNotifier notifier) async {
    await notifier.refresh(
      keyword: _controller.text.trim(),
      mode: widget.mode,
    );
  }
}
