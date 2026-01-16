package com.okla.ops.beans

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

data class User(
    val token: String,
    val name: String,
    val phone: String,
    val avatar: String,
    val role: Int,
    val agentNo: String,
    val shopNo: String?,
    val managerFlag: Boolean,
    val tenantName: String,
    val emailCode: String,
    val currencyUnit: String,
    val areaCode: String,
    val appRole: String,
    val serviceType: String
)

data class PurchasingUser(
    val address: String? = "",
    val avatar: String? = "",
    val birthday: String? = "",
    val cardImg: String? = "",
    val cardNum: String? = "",
    val email: String? = "",
    val firstName: String? = "",
    val lastName: String? = "",
    val idNumber: String? = "",
    val phone: String? = "",
    val username: String? = "",
    val personImg: String? = ""
)

data class UserInfo(
    val avatar: String,
    val cardNum: String,
    val firstName: String,
    val lastName: String,
    val registerDate: String,
    val remainPay: Double,
    val remainPeriod: Int,
    val totalPay: Double,
    val type: Int,
    var username: String,
    val idNumber: String,
    val status: Int,
    val order: Int?,
    val orderAmount: Double?,
    val asset: Int?
)

@Parcelize
data class UserDetail(
    var avatar: String? = "",
    var cardNum: String? = "",
    val firstName: String? = "",
    val lastName: String? = "",
    val createTime: String? = "",
    val birthday: String? = null,
    val email: String? = "",
    val highPrivacy: Boolean? = false,
    val idNumber: String? = "",
    val imgList: String? = "",
    var phone: String? = "",
    val remark: String? = "",
    val status: Int? = 0,//0 启动 3 禁用
    var type: Int? = 0,//1=正常，4=已逾期，5=失信，8=已退租
    var username: String? = "",
    val batteryList: List<BindDevice>? = null,
    val vehicleList: List<BindDevice>? = null
) : Parcelable

data class UserPaymentRecord(
    val amount: Double? = 0.0,
    val payTime: String? = "",
    val payType: Int? = 0,
    val period: Int? = 0,
    val orderNo: String? = "",
    val attachment: String? = "",
    val payWay: Int? = 0
)

data class BatterySwap(
    val createTime: Long? = 0,
    val inBattery: String?=null,
    val handlerName: String?=null,
    val outBattery: String?=null,
    val reason: String? = "",
    val rentId: Int? = 0,
    val type:Int?=null,
)

data class BatterySwapRecord(
    val list: List<BatterySwap>? = null,
    val total: Int = 0
)
