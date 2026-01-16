package com.okla.ops.beans

data class DeviceFix(
    val batteryVo: BatteryVo?,
    val carVo: CarVo?,
    val stationVo: StationVo?,
    val deviceType: Int? = 0,
    var itemList: List<DeviceFixProject>?,
    val resultList: List<DeviceFixResult>?
)

data class DeviceFixProject(
    val itemNo: String,
    val itemName: String="-",
    var isSelect: Boolean
)

data class DeviceFixResult(
    val result: String="-",
    val code: String="-",
    var isSelect: Boolean
)
