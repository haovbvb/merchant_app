package com.okla.ops.beans

data class BookMaintenanceBean(
    val address: String? = "-",
    val avatar: String? = "-",
    val carModel: String? = "-",
    val carNumber: String? = "-",
    val carSpec: String? = "-",
    val cardNum: String? = "-",
    val day30Mile: Int? = 0,
    val dayMile: Int? = 0,
    val firstName: String? = "-",
    val img: String? = "-",
    val lastName: String? = "-",
    val latitude: Double? = 0.0,
    val longitude: Double? = 0.0,
    val phone: String? = "-",
    val reservationDate: String? = "-",
    val reservationNo: String? = "-",
    val sn: String? = "-",
    val speedRange: String? = "-",
    val username: String? = "-",
    val vin: String? = "-",
    val day30AvgMilePerDay: Double? = 0.0,
    val day30AvgSpeed: Double? = 0.0,
    val day30AvgSwapCount: Double? = 0.0

)


data class VehicleParamBean(
    val title: String,
    val value: String,
)

data class VehicleRepairListResp(
    val list: List<VehicleRepair>?,
    val total: Int
)

data class VehicleRepair(
    val createTime: String,
    val fixMan: String,
    val fixManAvatar: String,
    val imgList: String,
    val itemName: String,
    val remark: String,
    val result: Int,
)
