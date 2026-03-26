import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import '../models/message_list_response.dart';
import '../profile_route_paths.dart';
import '../providers/message_controller.dart';

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 80;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(messageListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(messageListProvider);
    final notifier = ref.read(messageListProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.messageCenterTitle)),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: state.items.isEmpty && !state.loading
            ? _MessageEmptyState(text: l10n.messageEmpty)
            : ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemBuilder: (context, index) {
                  if (index == state.items.length) {
                    return _LoadMoreFooter(
                      loading: state.loadingMore,
                      hasMore: state.hasMore,
                    );
                  }
                  final item = state.items[index];
                  return _MessageTile(
                    item: item,
                    time: DateFormatUtils.formatTimestamp(
                      item.createTime,
                      pattern: 'yyyy-MM-dd HH:mm',
                    ),
                    theme: theme,
                    onTap: () => _openMessageDetail(context, notifier, item),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: state.items.length + 1,
              ),
      ),
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
    if (parsed == null || !parsed.hasScheme) return;
    if (!context.mounted) return;

    final title = item.title?.trim().isNotEmpty == true
        ? item.title!.trim()
        : context.l10n.messageDetail;
    final target =
        '${ProfileRoutePaths.messageDetail}?url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title)}';
    await context.push(target);
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
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.content ?? '-', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (item.isRead != 1) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
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

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.loading, required this.hasMore});

  final bool loading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            context.l10n.messageNoMore,
            style: const TextStyle(color: AppColors.iconMuted),
          ),
        ),
      );
    }
    return const SizedBox(height: 1);
  }
}

class _MessageEmptyState extends StatelessWidget {
  const _MessageEmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 72,
                color: AppColors.profileChevron,
              ),
              const SizedBox(height: 16),
              Text(text, style: const TextStyle(color: AppColors.iconMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
