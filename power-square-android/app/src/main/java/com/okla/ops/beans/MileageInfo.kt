package com.okla.ops.beans

data class MileageInfoListResp(
    val time: String,
    val todayMile: Double? = 0.0
)

data class StaticBatteryMile(
    val mile: Double? = 0.0,
    val todayMile: Double? = 0.0,
    val avgSpeed: Double? = 0.0,
    val miles: MutableList<Double>? = mutableListOf(),
    val xvalue: MutableList<String>? = mutableListOf(),
)