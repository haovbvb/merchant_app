package com.okla.ops.beans

data class PowerChangeBeanNew(
    val list: List<PowerChangeItem>? = null,
    val total: Int? = null
)

data class PowerChangeItem(
    val cardNum: String? = null,
    val createTime: String? = null,
    val details: List<PowerChangeDetail>? = null,
    val error: String? = null,
    val handlerName: String? = null,
    val handlerPhone: String? = null,
    val inBattery: String? = null,
    val outBattery: String? = null,
    val reason: String? = null,
    val remark: String? = null,
    val rentId: Int? = null,
    val showStatusName: String? = null,
    val stationSn: String? = null,
    val status: Int? = 0,
    val swapTypeName: String? = null,
    val type: Int? = null
)

data class PowerChangeDetail(
    val error: String? = null,
    val inBattery: String? = null,
    val inPort: Int? = null,
    val inSoc: Int? = null,
    val outBattery: String? = null,
    val outPort: Int? = null,
    val outSoc: Int? = null,
    val status: Int? = null
)
