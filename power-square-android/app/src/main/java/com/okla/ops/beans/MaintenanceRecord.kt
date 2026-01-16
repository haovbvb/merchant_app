package com.okla.ops.beans

data class DeviceMaintenanceResponse(
    val list: List<MaintenanceRecord>,
    val total: Int
)

data class MaintenanceRecord(
    val username: String? = "",
    val img: String? = "",
    val itemName: String? = "",
    val log: String? = "",
    val chargeTime: String? = "",
    val date: String? = null,
    val createTime: Long? = null
)
