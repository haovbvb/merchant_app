package com.okla.ops.beans

data class AfterSaleCanBindOrderBean(
    var batteryType: String? = "-",
    var carType: String? = "-",
    var deviceType: Int? = null,
    var orderNo: String? = "-",
    var status: Int? = null,
    var type: Int? = null,
    var isSelected: Boolean
)