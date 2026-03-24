import 'package:flutter/foundation.dart';

@immutable
class MessageListResponse {
  const MessageListResponse({
    required this.list,
    required this.total,
  });

  final List<MessageItem> list;
  final int total;

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    return MessageListResponse(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => MessageItem.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const <MessageItem>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

@immutable
class MessageItem {
  const MessageItem({
    required this.castType,
    required this.content,
    required this.createTime,
    required this.iconUrl,
    required this.isRead,
    required this.msgId,
    required this.source,
    required this.title,
    required this.type,
    required this.url,
  });

  final String? castType;
  final String? content;
  final int? createTime;
  final String? iconUrl;
  final int? isRead;
  final int? msgId;
  final String? source;
  final String? title;
  final int type;
  final String? url;

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      castType: json['castType']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createTime: (json['createTime'] as num?)?.toInt(),
      iconUrl: json['iconUrl']?.toString() ?? '',
      isRead: (json['isRead'] as num?)?.toInt(),
      msgId: (json['msgId'] as num?)?.toInt(),
      source: json['source']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: (json['type'] as num?)?.toInt() ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }

  MessageItem copyWith({int? isRead}) {
    return MessageItem(
      castType: castType,
      content: content,
      createTime: createTime,
      iconUrl: iconUrl,
      isRead: isRead ?? this.isRead,
      msgId: msgId,
      source: source,
      title: title,
      type: type,
      url: url,
    );
  }
}
