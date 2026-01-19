import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RepairRecordPage extends ConsumerStatefulWidget {
  const RepairRecordPage({super.key});

  @override
  ConsumerState<RepairRecordPage> createState() => _RepairRecordPageState();
}

class _RepairRecordPageState extends ConsumerState<RepairRecordPage> {
  final TextEditingController _snController = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _snController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(repairRecordProvider);
    final notifier = ref.read(repairRecordProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.repairRecordTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _snController,
              decoration: InputDecoration(
                hintText: l10n.repairRecordSnHint,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_search.webp',
                    width: 20,
                    height: 20,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => notifier.refresh(_snController.text.trim()),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) => notifier.refresh(value.trim()),
            ),
          ),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: state.hasMore,
              onRefresh: () async {
                await notifier.refresh(_snController.text.trim());
                _refreshController.refreshCompleted();
                if (!ref.read(repairRecordProvider).hasMore) {
                  _refreshController.loadNoData();
                }
              },
              onLoading: () async {
                await notifier.loadMore();
                if (ref.read(repairRecordProvider).hasMore) {
                  _refreshController.loadComplete();
                } else {
                  _refreshController.loadNoData();
                }
              },
              child: state.items.isEmpty
                  ? _RepairEmptyState(text: l10n.repairRecordEmpty)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.itemName),
                            subtitle: Text(
                              '${item.fixMan}  |  ${item.createTime}',
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
}

class _RepairEmptyState extends StatelessWidget {
  const _RepairEmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_empty_record.png',
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
