package com.okla.ops.views.workbench.vcu

data class VcuData(
    val name: String,
    val data: String,
    var select: Boolean,
    var net: Boolean,
)

data class VcuVersion(
    val name: String,
    val url: String,
)

data class VcuDataHistoryListResp(
    val list: List<VcuDataHistory>?,
    val total: Int
)

data class VcuDataHistory(
    val msgType: Int,
    val communicationType: Int,
    val command: String,
    val data: String,
    val createTime: String
)
