import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/data/models/vehicle_repair_list_resp.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_controller.dart';
import 'package:merchant_app/features/work/maintenance/repair_record_create_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
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
      appBar: AppBar(
        title: Text(l10n.repairRecordTitle),
        actions: [
          IconButton(
            tooltip: l10n.repairRecordAddTitle,
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const RepairRecordCreatePage(),
                ),
              );
              if (result == true && mounted) {
                notifier.refresh(_snController.text.trim());
              }
            },
          ),
        ],
      ),
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
                        return _RepairRecordItem(
                          item: item,
                          l10n: l10n,
                          onViewDetail: () =>
                              _showDetailDialog(context, item, l10n),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
  void _showDetailDialog(
    BuildContext context,
    VehicleRepair item,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RepairRecordDetailSheet(item: item, l10n: l10n),
    );
  }}

class _RepairRecordItem extends StatelessWidget {
  const _RepairRecordItem({
    required this.item,
    required this.l10n,
    required this.onViewDetail,
  });

  final VehicleRepair item;
  final AppLocalizations l10n;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Status
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: item.fixManAvatar.isNotEmpty
                    ? NetworkImage(item.fixManAvatar)
                    : null,
                child: item.fixManAvatar.isEmpty
                    ? const Icon(Icons.person, size: 18, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.fixMan.isNotEmpty ? item.fixMan : '-',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              _buildStatusTag(),
            ],
          ),
          const SizedBox(height: 12),
          // Item name
          Text(
            item.itemName.isNotEmpty ? item.itemName : '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (item.remark.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.remark,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          // Date + View Detail
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(item.createTime),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              GestureDetector(
                onTap: onViewDetail,
                child: Text(
                  l10n.maintenanceViewDetail,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag() {
    String text;
    Color textColor;
    Color bgColor;

    switch (item.result) {
      case 1: // Finish
        text = l10n.repairRecordStatusFinish;
        textColor = const Color(0xFF00B88A);
        bgColor = const Color(0xFFE9F7F2);
      case 2: // Lack
        text = l10n.repairRecordStatusLack;
        textColor = const Color(0xFFED942F);
        bgColor = const Color(0xFFFDF5EB);
      case 3: // Discard
        text = l10n.repairRecordStatusDiscard;
        textColor = const Color(0xFFFA4B51);
        bgColor = const Color(0xFFFFF0F0);
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: textColor),
      ),
    );
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '-';
    return DateFormatUtils.formatString(raw, fallback: raw);
  }
}

class _RepairRecordDetailSheet extends StatelessWidget {
  const _RepairRecordDetailSheet({
    required this.item,
    required this.l10n,
  });

  final VehicleRepair item;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final images = item.imgList
        .split(',')
        .where((url) => url.trim().isNotEmpty)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text(
                    l10n.repairRecordDetailTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name
                  Text(
                    item.itemName.isNotEmpty ? item.itemName : '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (item.remark.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.remark,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                  // Images
                  if (images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              images[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  // Operator
                  const SizedBox(height: 16),
                  Text(
                    l10n.repairRecordOperator,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: item.fixManAvatar.isNotEmpty
                            ? NetworkImage(item.fixManAvatar)
                            : null,
                        child: item.fixManAvatar.isEmpty
                            ? const Icon(Icons.person,
                                size: 16, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.fixMan.isNotEmpty ? item.fixMan : '-',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
