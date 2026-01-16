package com.okla.ops.beans

data class DeviceInventoryResp(
    val list: List<DeviceInventory>,
    val total: Int
)

data class DeviceInventory(
    val deviceType: Int?,
    val inventory: Long?,
    val inventoryNo: String?,
    val status: Int?,
    val stock: Long?,
    val warehouseName: String?,
)

data class DeviceInventoryDetail(
    val createTime: String?,
    val detailPage: DeviceInventoryDataResp?,
    val deviceType: Int,//1电池 2电摩 3电柜
    val diff: Int,
    val inventory: Int,
    val inventoryNo: String?,
    val status: Int,
    val stock: Int,
    val warehouseAddress: String?,
    val warehouseName: String?,
    val warehouseNo: String,
    val warehouseType: Int
)

data class DeviceInventoryDataResp(
    val list: MutableList<DeviceInventoryData>,
    val total: Int
)

data class DeviceInventoryData(
    val accountName: String,
    val deviceSn: String,
    val inventoryTime: String,
    val remark: String,
    var status: Int,
)

data class DeviceInventoryScanResult(
    val result: Int
)
