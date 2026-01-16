package com.okla.ops.beans

data class PaymentOrder(
    val amount: Double? = 0.0,
    val cardNum: String? = "",
    val firstName: String? = "",
    val lastName: String? = "",
    val orderDate: Long? = 0,
    val orderNo: String? = "",
    val payType: Int? = 0,
    val period: Int? = 0,
    val status: Int? = 0,
    val type: Int? = 0,
    val username: String? = ""
)

data class PaymentType(
    val name: String,
    val type: Int,
    var selected: Boolean
)

data class Insurance(
    val beginDate: String? = "",
    val endDate: String? = "",
    val insuranceAmount: Double? = 0.0,
    val insuranceFee: Double? = 0.0,
    val type: Int? = 0
)
