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
      l10n.userFilterOverdue,
      l10n.userFilterDishonest,
      l10n.userFilterEnded,
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
            width: double.infinity,
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: isSelected
                              ? Border.all(color: AppColors.primaryColor, width: 1)
                              : null,
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? AppColors.primaryColor
                                : const Color(0x99000000),
                            fontWeight: FontWeight.normal,
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
        return 1; // Normal
      case 2:
        return 2; // Overdue
      case 3:
        return 3; // Dishonest
      case 4:
        return 4; // Ended
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
    final statusColors = _getStatusColors(item.type);
    final statusLabel = _getStatusLabel(l10n, item.type);
    final tipInfo = _getTipInfo(l10n, item.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Column(
            children: [
              // Header: Avatar, Name, Status, ID
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 27,
                      backgroundColor: const Color(0xFFF5F5F5),
                      backgroundImage: item.avatar.isNotEmpty
                          ? NetworkImage(item.avatar)
                          : null,
                      child: item.avatar.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Color(0xFF999999),
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isNotEmpty ? displayName : item.username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xE6000000),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatusChip(
                              text: statusLabel,
                              textColor: statusColors.text,
                              backgroundColor: statusColors.background,
                              borderColor: statusColors.border,
                            ),
                            const SizedBox(width: 5),
                            _StatusChip(
                              text: 'ID:${item.cardNum}',
                              textColor: const Color(0x99000000),
                              backgroundColor: Colors.transparent,
                              borderColor: const Color(0x26000000),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    _StatItem(
                      label: l10n.userStatOrder,
                      value: (item.order ?? 0).toString(),
                    ),
                    Container(
                      width: 0.5,
                      height: 24,
                      color: const Color(0x12000000),
                    ),
                    _StatItem(
                      label: l10n.userStatConsumption,
                      value: _formatCurrency(item.orderAmount ?? 0),
                    ),
                    Container(
                      width: 0.5,
                      height: 24,
                      color: const Color(0x12000000),
                    ),
                    _StatItem(
                      label: l10n.userStatAssets,
                      value: (item.asset ?? 0).toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              // Tip info
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_order_notify.png',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tipInfo ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0x99000000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
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
              color: Color(0x66000000),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xE6000000),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
        ),
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
    case 1: // Normal
      return const _StatusColors(
        text: Color(0xFFF49300),
        background: Colors.transparent,
        border: Color(0xFFF49300),
      );
    case 2: // Overdue
      return const _StatusColors(
        text: Color(0xFFFA4332),
        background: Color(0xFFFFF3F2),
        border: Color(0xFFFFF3F2),
      );
    case 3: // Dishonest
      return const _StatusColors(
        text: Color(0xFFFA4332),
        background: Color(0xFFFFF3F2),
        border: Color(0xFFFFF3F2),
      );
    case 4: // Ended
      return const _StatusColors(
        text: AppColors.primaryColor,
        background: Colors.transparent,
        border: AppColors.primaryColor,
      );
    default:
      return const _StatusColors(
        text: Color(0x99000000),
        background: Colors.transparent,
        border: Color(0x26000000),
      );
  }
}

String _getStatusLabel(AppLocalizations l10n, int status) {
  switch (status) {
    case 1:
      return l10n.userFilterNormal;
    case 2:
      return l10n.userFilterOverdue;
    case 3:
      return l10n.userFilterDishonest;
    case 4:
      return l10n.userFilterEnded;
    default:
      return '-';
  }
}

String? _getTipInfo(AppLocalizations l10n, int status) {
  switch (status) {
    case 1:
      return l10n.userTipNormal;
    case 2:
      return l10n.userTipOverdue;
    case 3:
      return l10n.userTipDishonest;
    case 4:
      return l10n.userTipEnded;
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
