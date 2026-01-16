package com.okla.ops.beans

/**
 * Author: Joe
 * Date: 2024/1/25 16:40
 * Description:
 */
data class WarehouseBean(
    val cityName: String?=null,
    val outWarehouseName: String?,
    val outWarehouseNo: String?,
    val inWarehouseName: String?,
    val inWarehouseNo: String,
    val warehouseType: Int?,
    val img: String,
    val warehouseName: String?,
    val warehouseNo: String?,
)

object WarehouseBeanType {
    const val TYPE_MAIN: Int = 0
    const val TYPE_CITY: Int = 1
    const val TYPE_SERVICE: Int = 2
}