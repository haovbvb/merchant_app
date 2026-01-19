import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _RoadSideListPageState extends ConsumerState<RoadSideListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roadSideListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(roadSideListProvider);
    final notifier = ref.read(roadSideListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.roadsideTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) => notifier.refresh(status: _statusForTab(index)),
          tabs: [
            Tab(text: l10n.roadsideTabAll),
            Tab(text: l10n.roadsideTabWaiting),
            Tab(text: l10n.roadsideTabProcessing),
            Tab(text: l10n.roadsideTabCompleted),
          ],
        ),
      ),
      body: SmartRefresher(
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
        child: state.items.isEmpty
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
                          builder: (_) =>
                              RoadSideDetailPage(recordNo: recordNo),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  int? _statusForTab(int index) {
    switch (index) {
      case 1:
        return 0;
      case 2:
        return 1;
      case 3:
        return 2;
      default:
        return null;
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

    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _ImageBox(url: item.img),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'No.${item.recordNo ?? '-'}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        _StatusChip(
                          label: _statusLabel(l10n, item.status),
                          textColor: statusColors.text,
                          backgroundColor: statusColors.background,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('SN: ${item.deviceSn ?? '-'}'),
                    const SizedBox(height: 4),
                    Text(item.description ?? '-'),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.roadsideTimeLabel}: ${item.createTime ?? '-'}',
                    ),
                    if (item.result != null && item.status != 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.roadsideResultLabel}: '
                        '${_resultLabel(l10n, item.result)}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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
        width: 56,
        height: 56,
        color: Colors.black12,
        child: const Icon(Icons.broken_image_outlined),
      );
    }
    return Image.network(
      url!,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 56,
        height: 56,
        color: Colors.black12,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: textColor),
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
    case 0:
      return const _StatusColors(
        text: Color(0xFFE25C5C),
        background: Color(0xFFFFF1F1),
      );
    case 1:
      return const _StatusColors(
        text: Color(0xFFF09A2B),
        background: Color(0xFFFFF4E6),
      );
    case 2:
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
        child: Text(
          text,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
