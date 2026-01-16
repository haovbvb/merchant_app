package com.okla.ops.beans

data class WorkOrderStat(
    val finishNum: Int,
    val processNum: Int,
    val timeoutNum: Int
)

data class RoadSideListResp(
    val list: MutableList<RoadSideInfo>,
    val total: Int
)

data class RoadSideInfo(
    val createTime: String? = "-",
    val description: String? = "-",
    val deviceSn: String? = "-",
    val deviceType: Int? = 0,
    val img: String? = "-",
    val recordNo: String? = "-",
    val result: Int? = 0,
    val status: Int? = 0,
    val completetime: String? = "-",
    val processTime:String?=""
)

data class WorkOrderDetail(
    val accountName: String,
    val createTime: String,
    val deadlineTime: String,
    val deviceImg: String,
    val deviceSn: String,
    val exam: WorkOrderExam?,
    val latitude: Double,
    val longitude: Double,
    val process: WorkOrderProcess?,
    val sheetDesc: String,
    val sheetLevel: Int,
    val sheetNo: String,
    val sheetStatus: Int,
    val sheetType: String,
    val timeout: Boolean
)

data class WorkOrderExam(
    val processAccountName: String,
    val processTime: String,
    val processDesc: String,
    val processResult: String,
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

data class WorkOrderReport(
    var imgList: String? = "",
    var latitude: Double? = 0.0,
    var longitude: Double? = 0.0,
    var processDesc: String? = "",
    var result: Int? = 0,
    var sheetNo: String? = ""
)