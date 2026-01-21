import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/widgets/common_webview_page.dart';
import 'package:merchant_app/data/models/message_list_response.dart';
import 'package:merchant_app/features/me/message_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage> {
  final DateFormat _timeFormatter = DateFormat('yyyy-MM-dd HH:mm');
  late final RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageListProvider.notifier).refresh();
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
    final state = ref.watch(messageListProvider);
    final notifier = ref.read(messageListProvider.notifier);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileMessage)),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: state.hasMore,
        header: const WaterDropHeader(),
        onRefresh: () async {
          await notifier.refresh();
          _refreshController.refreshCompleted();
          if (!ref.read(messageListProvider).hasMore) {
            _refreshController.loadNoData();
          }
        },
        onLoading: () async {
          await notifier.loadMore();
          if (ref.read(messageListProvider).hasMore) {
            _refreshController.loadComplete();
          } else {
            _refreshController.loadNoData();
          }
        },
        child: state.items.isEmpty
            ? _MessageEmptyState(text: l10n.messageEmpty)
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _MessageTile(
                    item: item,
                    time: _formatTime(item.createTime),
                    theme: theme,
                    onTap: () => _openMessageDetail(context, notifier, item),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: state.items.length,
              ),
      ),
    );
  }

  String _formatTime(int? value) {
    if (value == null || value == 0) return '-';
    final timestamp = value > 1000000000000 ? value : value * 1000;
    return _timeFormatter.format(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }

  Future<void> _openMessageDetail(
    BuildContext context,
    MessageListNotifier notifier,
    MessageItem item,
  ) async {
    await notifier.markRead(item);
    final url = item.url ?? '';
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme) {
      return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommonWebViewPage(
          initialUrl: url,
          title: item.title?.trim().isNotEmpty == true
              ? item.title!.trim()
              : context.l10n.profileMessage,
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.item,
    required this.time,
    required this.theme,
    required this.onTap,
  });

  final MessageItem item;
  final String time;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MessageIcon(url: item.iconUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? '-',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.content ?? '-',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (item.isRead != 1) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageIcon extends StatelessWidget {
  const _MessageIcon({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.notifications_active_outlined,
          color: theme.colorScheme.primary,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        url!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.notifications_active_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _MessageEmptyState extends StatelessWidget {
  const _MessageEmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_empty_record.png',
            width: 80,
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
