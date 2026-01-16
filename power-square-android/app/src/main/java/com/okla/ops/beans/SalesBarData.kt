package com.okla.ops.beans

data class SalesBarData(
    val amountList: MutableList<Double> = mutableListOf(),
    val numList: MutableList<Int> = mutableListOf(),
    var timeList: MutableList<String> = mutableListOf(),
)

data class OrderListResp(
    val time: String? = "",
    val order: Int? = 0
)

data class AmountListResp(
    val time: String? = "",
    val amount: Double? = 0.0
)

data class SalesListBean(
    val payType: Int,
    val status: Int,
    val orderNo: String? = "-",
    val price: Double,
    val attachment:String?=""
)

data class  SaleSumPageData(
    val avgOrderAmount: Double? = null,
    val incomeRank: Int? = null,
    val numRank: Int? = null,
    val orderIncome: Double? = null,
    val orderNum: Int? = null,
    val signRate: Double? = null
)

// 最外层响应
data class SellDataListResponse(
    val list: List<OrderItem>? = null,
    val total: Int? = null
)

// 内层订单项
data class OrderItem(
    val amount: Double? = null,
    val orderNo: String? = null,
    val orderType: Int? = null,
    val payType: Int? = null,
    val payWay: Int? = null,
    val attachment: String?=null
)
