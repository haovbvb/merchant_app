package com.okla.ops.views.workbench.sales.rentbind

import com.okla.ops.beans.BatteryVo
import com.okla.ops.beans.CarVo

data class RentDeviceInfoBean(
    val carVo: CarVo,
    val batteryVo:BatteryVo,
    val packList: List<Pack>
)

data class Pack(
    val depositAmount: Double?,
    val duration: Int?,
    val haveDeposit: Double?,
    val infoCode: String? = "-",
    val infoName: String? = "-",
    val infoType: Int?,
    val packageAmount: Double?,
    val batteryNum: Int?,
    val batteryType: String? = "-",
    val carType: String? = "-",
    val times: Int?,
    var isSelected: Boolean
)

