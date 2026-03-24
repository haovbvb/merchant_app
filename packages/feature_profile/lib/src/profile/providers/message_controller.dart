import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking/networking.dart';

import '../models/message_list_response.dart';
import '../profile_api_path.dart';

const _pageSize = 10;

class MessageListState {
  const MessageListState({
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.items = const [],
    this.total = 0,
  });

  final bool loading;
  final bool loadingMore;
  final int page;
  final List<MessageItem> items;
  final int total;

  bool get hasMore => items.length < total;

  MessageListState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    List<MessageItem>? items,
    int? total,
  }) {
    return MessageListState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

final messageListProvider =
    NotifierProvider<MessageListNotifier, MessageListState>(
  MessageListNotifier.new,
);

class MessageListNotifier extends Notifier<MessageListState> {
  final ApiService _api = ApiService();

  @override
  MessageListState build() => const MessageListState();

  Future<void> refresh() async {
    state = state.copyWith(loading: true, page: 1);
    final response = await _api.get<MessageListResponse>(
      ProfileApiPath.urlOf(ProfileApiPath.messageGetSysList),
      queryParameters: {'pageIndex': 1, 'pageSize': _pageSize},
      parser: (json) =>
          MessageListResponse.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    final result = response.result;
    state = state.copyWith(
      loading: false,
      items: result?.list ?? const [],
      total: result?.total ?? 0,
      page: 1,
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(loadingMore: true);

    final response = await _api.get<MessageListResponse>(
      ProfileApiPath.urlOf(ProfileApiPath.messageGetSysList),
      queryParameters: {'pageIndex': nextPage, 'pageSize': _pageSize},
      parser: (json) =>
          MessageListResponse.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    final result = response.result;
    state = state.copyWith(
      loadingMore: false,
      page: nextPage,
      items: [...state.items, ...?result?.list],
      total: result?.total ?? state.total,
    );
  }

  Future<void> markRead(MessageItem item) async {
    final msgId = item.msgId;
    if (msgId == null) return;

    await _api.post<Object>(
      ProfileApiPath.urlOf(ProfileApiPath.messageUpdateFlag),
      data: {'flag': 1, 'msgId': msgId},
      parser: (json) => json ?? Object(),
    );

    final updated = state.items
        .map((value) => value.msgId == msgId ? value.copyWith(isRead: 1) : value)
        .toList();
    state = state.copyWith(items: updated);
  }
}
