package com.okla.ops.beans

data class Stock(
    val batteryNum: Int,
    val cityName: String,
    val createTime: String,
    val shopName: String,
    val transferNo: String,
    val transferType: Int,
)

data class StockNum(
    val all: Int? = 0,
    val dispatch: Int? = 0,
    val recall: Int? = 0,
)

data class StockDetail(
    val batteryNum: Int? = 0,
    val cityName: String? = "",
    val createTime: String? = "",
    val list: MutableList<BatteryTransfer>? = mutableListOf(),
    val remark: String? = "",
    val shopName: String? = "",
    val transferNo: String? = "",
    val transferType: Int? = 0
)
