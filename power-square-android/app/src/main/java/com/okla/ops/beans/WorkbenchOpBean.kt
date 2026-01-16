package com.okla.ops.beans

data class WorkbenchOpBean(
    var faultStationNum: Int,
    var healthyFlag: Int,
    val healthyPercent: Float,
    var healthyPortPercent: String,
    var notGoodPerformStationNum: Int,
    var today: String
)
