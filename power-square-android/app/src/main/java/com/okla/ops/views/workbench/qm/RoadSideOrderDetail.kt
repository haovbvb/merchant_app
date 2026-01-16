package com.okla.ops.views.workbench.qm

data class RoadSideOrderDetail(
    val createTime: Long? = 0,
    val creator: String? = "-",
    val description: String? = "-",
    val deviceSn: String? = "-",
    val deviceType: Int? = 0,
    val img: String? = "-",
    val imgList: String? = "-",
    val latitude: Double? = 0.0,
    val longitude: Double? = 0.0,
    val opResponse: String? = "-",
    val recordNo: String? = "-",
    val reportTime: String? = "-",
    val result: Int? = 0,
    val rider: String? = "-",
    val cardNum: String? = "-",
    val riderPhone: String? = "-",
    val source: Int? = 0,
    val status: Int? = 0,
    val payWay: Int? = 0,
    val attachment: String? = "",
    val processTime: Long? = 0,
    val fee: Double? = 0.00,
    val firstName: String? = "",
    val lastName: String? = ""
)

data class WorkOrderProcess(
    val imgList: String,
    val latitude: Double,
    val longitude: Double,
    val processAccountAvatar: String,
    val processAccountName: String,
    val processDesc: String,
    val processResult: String,
    val processTime: String
)
