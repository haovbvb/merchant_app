import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/user_info.dart';
import 'package:merchant_app/features/work/user/user_controller.dart';
import 'package:merchant_app/features/work/user/user_detail_page.dart';
import 'package:merchant_app/features/work/user/user_search_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userListProvider.notifier).refresh();
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
    final state = ref.watch(userListProvider);
    final notifier = ref.read(userListProvider.notifier);

    final tabs = [
      l10n.userFilterAll,
      l10n.userFilterNormal,
      l10n.userFilterEnded,
      l10n.userFilterOverdue,
      l10n.userFilterDishonest,
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
          l10n.userListTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => _openSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: AppColors.bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryColor : Colors.white,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? AppColors.primaryColor : const Color(0xFF666666),
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
              child: state.items.isEmpty && !state.loading
                      ? _EmptyView(text: l10n.userListEmpty)
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return _UserCard(
                              l10n: l10n,
                              item: item,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => UserDetailPage(
                                      cardNum: item.cardNum,
                                    ),
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
        return 0; // Normal
      case 2:
        return 1; // Ended
      case 3:
        return 2; // Overdue
      case 4:
        return 3; // Dishonest
      default:
        return null; // All
    }
  }

  Future<void> _openSearch(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const UserSearchPage(),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.l10n,
    required this.item,
    this.onTap,
  });

  final AppLocalizations l10n;
  final UserInfo item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = '${item.firstName} ${item.lastName}'.trim();
    final statusColors = _getStatusColors(item.status);
    final statusLabel = _getStatusLabel(l10n, item.status);
    final tipInfo = _getTipInfo(l10n, item.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header: Avatar, Name, Status, ID
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFF5F5F5),
                    backgroundImage: item.avatar.isNotEmpty
                        ? NetworkImage(item.avatar)
                        : null,
                    child: item.avatar.isEmpty
                        ? const Icon(Icons.person, color: Color(0xFF999999), size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName.isNotEmpty ? displayName : item.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: statusColors.border, width: 1),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColors.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID:${item.cardNum}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Stats row
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _StatItem(
                    label: l10n.userStatOrder,
                    value: (item.order ?? 0).toString(),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFEEEEEE),
                  ),
                  _StatItem(
                    label: l10n.userStatConsumption,
                    value: _formatCurrency(item.orderAmount ?? 0),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFEEEEEE),
                  ),
                  _StatItem(
                    label: l10n.userStatAssets,
                    value: (item.asset ?? 0).toString(),
                  ),
                ],
              ),
            ),
            // Tip info
            if (tipInfo != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_order_notify.png',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tipInfo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$ ', decimalDigits: 2).format(amount);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusColors {
  const _StatusColors({required this.text, required this.background, required this.border});

  final Color text;
  final Color background;
  final Color border;
}

_StatusColors _getStatusColors(int status) {
  switch (status) {
    case 0: // Normal
      return const _StatusColors(
        text: Color(0xFF00B88A),
        background: Color(0xFFE9F7F2),
        border: Color(0xFF00B88A),
      );
    case 1: // Ended
      return const _StatusColors(
        text: Color(0xFF00B88A),
        background: Colors.white,
        border: Color(0xFF00B88A),
      );
    case 2: // Overdue
      return const _StatusColors(
        text: Color(0xFFF09A2B),
        background: Color(0xFFFFF4E6),
        border: Color(0xFFF09A2B),
      );
    case 3: // Dishonest
      return const _StatusColors(
        text: Color(0xFFE25C5C),
        background: Color(0xFFFFF1F1),
        border: Color(0xFFE25C5C),
      );
    default:
      return const _StatusColors(
        text: Color(0xFF7A7A7A),
        background: Color(0xFFF2F2F2),
        border: Color(0xFFBDBDBD),
      );
  }
}

String _getStatusLabel(AppLocalizations l10n, int status) {
  switch (status) {
    case 0:
      return l10n.userFilterNormal;
    case 1:
      return l10n.userFilterEnded;
    case 2:
      return l10n.userFilterOverdue;
    case 3:
      return l10n.userFilterDishonest;
    default:
      return '-';
  }
}

String? _getTipInfo(AppLocalizations l10n, int status) {
  switch (status) {
    case 0:
      return l10n.userTipNormal;
    case 1:
      return l10n.userTipEnded;
    case 2:
      return l10n.userTipOverdue;
    case 3:
      return l10n.userTipDishonest;
    default:
      return null;
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});

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
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
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
    );
  }
}
