package com.okla.ops.beans

data class BatterOrVehicleInfo(
    val batteryVo: BatteryVo,
    val carVo: CarVo,
    val deviceType: Int     //1 电摩 2 电池
)

data class BatteryVo(
    val cycle: Int?,
    val img: String? = "",
    val lastSignalTime: String? = "-",
    val onlineFlag: Int,
    val sn: String? = "-",
    val soc: Int?,
    val soh: Int?,
    var isSelected: Boolean,
    val model: String? = "-",
    val rentDay: Int?,
    val spec: String? = "",
    val cardNum: String? = "-",
    val createTime: String? = "-",
    var batteryType: String? = "-",
    var bindSource: Int = 0,
    var batModel:String?=null,
    var batSpec:String?=null
)

data class CarVo(
    val carModel: String? = "-",
    val carNumber: String? = "-",
    val carSpec: String? = "-",
    val img: String? = "-",
    val sn: String? = "-",
    val vin: String? = "-",
    var isSelected: Boolean,
    val model: String = "-",
    val rentDay: Int?,
    val spec: String = "-",
    val cardNum: String = "-",
    val createTime: String? = "-",
    val carType: String? = "-",
    val bindSource: Int = 0

)


data class StationVo(
    val address: String? = null,
    val createTime: String? = null,
    val img: String? = null,
    val name: String? = null,
    val onlineFlag: Int? = null,
    val sn: String? = null,
    val storeNum: String? = null
)
