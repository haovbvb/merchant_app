package com.okla.ops.beans

data class StaticSaleNum(
    val sell: Int,
)

data class StaticSaleShop(
    val batNum: Int? = 0,
    val cityName: String? = "",
    val img: String? = "",
    val manager: String? = "",
    val shopName: String? = "",
    val shopNo: String? = "",
)

data class StaticSaleShopDetail(
    val address: String? = "",
    val batNum: Int? = 0,
    val cityName: String? = "",
    val shopName: String? = "",
    val shopManager: String? = "",
    val shopNo: String? = "",
    val img: String? = "",
    val totalAmount: Double? = 0.0,
)

data class StaticSaleShopDate(
    val amountList: MutableList<Double> = mutableListOf(),
    val batList: MutableList<Int> = mutableListOf(),
    val times: MutableList<String> = mutableListOf(),
)

data class BatListResp(
    val time: Long? = 0,
    val bat: Int? = 0
)

