package com.okla.ops.beans

/**
 * @Auther Administrator
 * @Date 2022/7/8 16:52
 * @Describe:
 */
data class NewCabinetBean(
    val stationModel: String,
    val stationName: String,
    val stationModelName: String,//电柜 规格仓数(用于storeNum字段)
    val standardImg: String,
    val address: String,
    val pid: String,
    val sn: String
)
