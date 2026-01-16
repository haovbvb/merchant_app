package com.okla.ops.beans

data class MessageListResponse(
    val list: List<MessageItem> = emptyList(),
    val total: Int = 0
)

data class MessageItem(
    val castType: String? = "",
    val content: String? = "",
    val createTime: Long? = 0,
    val iconUrl: String? = "",
    val isRead: Int ?= 0,
    val msgId: Int ?= 0,
    val source: String? = "",
    val title: String? = "",
    val type: Int = 0,
    val url: String? = ""
)