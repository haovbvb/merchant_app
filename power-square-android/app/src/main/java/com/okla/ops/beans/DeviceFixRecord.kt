package com.okla.ops.beans

data class DeviceFixRecordResponse(
    val list: List<DeviceFixRecord>,
    val total: Int
)

data class DeviceFixRecord(
    val fixMan: String? = "",
    val fixManAvatar: String? = null,
    val itemName: String? = null,
    val remark: String? = null,
    val result: String?=null,
    val createTime: Long?
)
