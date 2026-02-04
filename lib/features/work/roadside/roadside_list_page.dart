import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/roadside_list.dart';
import 'package:merchant_app/features/work/roadside/roadside_controller.dart';
import 'package:merchant_app/features/work/roadside/roadside_detail_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RoadSideListPage extends ConsumerStatefulWidget {
  const RoadSideListPage({super.key});

  @override
  ConsumerState<RoadSideListPage> createState() => _RoadSideListPageState();
}

class _RoadSideListPageState extends ConsumerState<RoadSideListPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roadSideListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(roadSideListProvider);
    final notifier = ref.read(roadSideListProvider.notifier);

    final tabs = [
      l10n.roadsideTabAll,
      l10n.roadsideTabWaiting,
      l10n.roadsideTabProcessing,
      l10n.roadsideTabCompleted,
    ];

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.roadsideTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(tabs.length, (index) {
                  final isSelected = _selectedTabIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: index < tabs.length - 1 ? 12 : 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedTabIndex = index);
                        notifier.refresh(status: _statusForTab(index));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.white,
                          ),
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? AppColors.primaryColor
                                : const Color(0xFF666666),
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // List content
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: state.hasMore,
              onRefresh: () async {
                await notifier.refresh(status: state.status);
                _refreshController.refreshCompleted();
                if (!ref.read(roadSideListProvider).hasMore) {
                  _refreshController.loadNoData();
                }
              },
              onLoading: () async {
                await notifier.loadMore();
                if (ref.read(roadSideListProvider).hasMore) {
                  _refreshController.loadComplete();
                } else {
                  _refreshController.loadNoData();
                }
              },
              child: state.loading && state.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.items.isEmpty
                      ? _EmptyView(text: l10n.roadsideEmpty)
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return _RoadSideCard(
                              l10n: l10n,
                              item: item,
                              onTap: () {
                                final recordNo = item.recordNo;
                                if (recordNo == null || recordNo.isEmpty) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RoadSideDetailPage(recordNo: recordNo),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  int? _statusForTab(int index) {
    switch (index) {
      case 1:
        return 0; // Waiting for rescue
      case 2:
        return 1; // In progress
      case 3:
        return 2; // Completed
      default:
        return null; // All
    }
  }
}

class _RoadSideCard extends StatelessWidget {
  const _RoadSideCard({
    required this.l10n,
    required this.item,
    this.onTap,
  });

  final AppLocalizations l10n;
  final RoadSideInfo item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors(item.status ?? -1);
    final statusLabel = _statusLabel(l10n, item.status);
    final showResult = item.status == 2 && item.result != null;

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
            // Header with NO. and date
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'NO.${item.recordNo ?? '-'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.createTime ?? '-',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            // Device SN card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Vehicle image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _ImageBox(url: item.img),
                  ),
                  const SizedBox(width: 12),
                  // SN info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SN: ${item.deviceSn ?? '-'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.black06Text,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Rescue result row (if completed)
            if (showResult) ...[
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.roadsideRescueResult,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _resultLabel(l10n, item.result),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black06Text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  const _ImageBox({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.electric_bike_outlined,
          color: Color(0xFFBBBBBB),
          size: 32,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.electric_bike_outlined,
            color: Color(0xFFBBBBBB),
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _StatusColors {
  const _StatusColors({required this.text, required this.background});

  final Color text;
  final Color background;
}

_StatusColors _statusColors(int status) {
  switch (status) {
    case 0: // Waiting for rescue
      return const _StatusColors(
        text: Color(0xFFE25C5C),
        background: Color(0xFFFFF1F1),
      );
    case 1: // In progress
      return const _StatusColors(
        text: Color(0xFFF09A2B),
        background: Color(0xFFFFF4E6),
      );
    case 2: // Completed
      return const _StatusColors(
        text: Color(0xFF00B88A),
        background: Color(0xFFE9F7F2),
      );
    default:
      return const _StatusColors(
        text: Color(0xFF7A7A7A),
        background: Color(0xFFF2F2F2),
      );
  }
}

String _statusLabel(AppLocalizations l10n, int? status) {
  switch (status) {
    case 0:
      return l10n.roadsideStatusWaiting;
    case 1:
      return l10n.roadsideStatusProcessing;
    case 2:
      return l10n.roadsideStatusCompleted;
    default:
      return '-';
  }
}

String _resultLabel(AppLocalizations l10n, int? result) {
  switch (result) {
    case 1:
      return l10n.roadsideResultReturnFactory;
    case 2:
      return l10n.roadsideResultCompleted;
    default:
      return '-';
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
