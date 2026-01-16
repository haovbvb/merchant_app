package com.okla.ops.views.workbench.sales.swapbind

import com.okla.ops.beans.BatteryVo
import com.okla.ops.beans.CarVo

data class SwapBindInfo(
    val address: String? = "",
    val avatar: String? = "",
    val batteryList: List<BatteryVo> ?=null,
    val birthday: String? = "",
    val cardImg: String? = "",
    val cardNum: String? = "",
    val email: String? = "",
    val firstName: String? = "",
    val idNumber: String? = "",
    val lastName: String? = "",
    val personImg: String? = "",
    val phone: String? = "",
    val username: String? = "",
    val vehicleList: List<CarVo> ?=null
)


