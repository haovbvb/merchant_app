package com.okla.ops.beans

data class VehicleDetailBean(
    val name: String,              // 车辆
    val specification: String,        // 规格
    val model: String,                // 型号
    val licensePlateNumber: String,  // 车牌号
    val vin:String,
    val img:String
) {

}