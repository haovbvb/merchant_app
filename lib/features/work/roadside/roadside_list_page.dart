import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : const Color(0xFFF2F2F2),
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
                  ? const Center(child: SizedBox.shrink())
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
    final showResult = item.status == 1 || item.status == 2;
    final showCompleteTime = item.status == 2;
    final resultText = _resultLabel(l10n, item.result);
    final resultDotColor = _resultDotColor(item.result);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NO.${item.recordNo ?? '-'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(item.createTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColors.background,
                    borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE6E6E6)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FC),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.fromLTRB(8, 10, 10, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImageBox(url: item.img),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SN: ${item.deviceSn ?? '-'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (item.description == null ||
                                  item.description!.trim().isEmpty)
                              ? '-'
                              : item.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Rescue result row (if completed)
            if (showResult) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.roadsideRescueResult,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: resultDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          resultText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.black06Text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (showCompleteTime) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _completionTimeLabel(context),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF999999),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTime(item.processTime ?? item.completetime),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.black06Text,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    return DateFormatUtils.formatString(raw, fallback: raw);
  }
}

class _ImageBox extends StatelessWidget {
  const _ImageBox({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Image.asset(
        'assets/android/mipmap-xxhdpi/icon_empty_record.png',
        fit: BoxFit.contain,
      ),
    );

    if (url == null || url!.isEmpty) {
      return fallback;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
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

Color _resultDotColor(int? result) {
  switch (result) {
    case 1:
      return const Color(0xFFED942F);
    case 2:
      return const Color(0xFF56B337);
    default:
      return const Color(0xFFCCCCCC);
  }
}

String _completionTimeLabel(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '完成时间' : 'Completion time';
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
