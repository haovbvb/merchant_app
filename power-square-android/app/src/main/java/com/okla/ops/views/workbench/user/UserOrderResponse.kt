package com.okla.ops.views.workbench.user


data class UserOrderResponse(
    val list: List<OrderItem> ?=null,
    val total: Int = 0
)

data class OrderItem(
    val attachment: String = "",
    val createTime: Long? = 0,
    var orderAmount: Double = 0.00,
    val orderNo: String = "",
    val payWay: Int = 0,
    val orderType: Int = 0,
    val otherOrder: OtherOrder? = null,
    val rentOrder: RentOrder? = null,
    val saleOrder: SaleOrder? = null
)

data class OtherOrder(
    val batteryNum: Int? = 0,
    val batteryType: String? = "",
    val carType: String? = "",
    val duration: Int? = 0,
    val expireDate: Long? = 0,
    val remainDuration: Int? = 0,
    val remainTime: Int? = 0,
    val serviceAmount: Double? = 0.00,
    var status: Int? = 0,
    val times: Int? = 0,
    var attachment: String? = "",
    var createTime: Long? = 0,
    var orderAmount: Double? = 0.00,
    var orderNo: String? = "",
    var payWay: Int? = 0,
    var payType: Int? = 0,
    var infoName: String? = ""

)

data class RentOrder(
    val depositAmount: Double? = 0.00,
    val deviceImg: String? = "",
    val deviceModel: String? = null,
    val deviceSn: String? = null,
    val deviceType: Int? = 0,
    val duration: Int? = 0,
    val expireDate: Long? = 0,
    val remainDuration: Int? = 0,
    val serviceAmount: Double? = 0.00,
    var status: Int? = 0,
    var attachment: String? = "",
    var createTime: Long? = 0,
    var orderAmount: Double? = 0.00,
    var orderNo: String? =null,
    var payWay: Int? = 0,
    var payType: Int? = 0,
    val infoName:String?=null
)

data class SaleOrder(
    val deviceImg: String = "",
    val deviceModel: String = "",
    val deviceSn: String? = "",
    val deviceType: Int = 0,
    val payType: Int = 0,
    val perAmount: Double? = 0.00,
    val period: Int? = 0,
    val rate: Double? = 0.00,
    var status: Int? = 0,
    var attachment: String? = "",
    var createTime: Long? = 0,
    var orderAmount: Double? = 0.00,
    var orderNo: String? = "",
    var payWay: Int? = 0,
)

