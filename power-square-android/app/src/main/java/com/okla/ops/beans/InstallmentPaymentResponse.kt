package com.okla.ops.beans

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

data class InstallmentPaymentResponse(
    val address: String? = "",
    val avatar: String? = "",
    val birthday: String? = "",
    val cardImg: String? = "",
    val cardNum: String? = "",
    val createTime: String = "",
    val deviceNum: Int? = 0,
    val email: String? = "",
    val firstName: String? = "",
    val idNumber: String? = "",
    val lastName: String? = "",
    val orderNum: Int? = 0,
    val periodOrderList: List<PeriodOrder> ? = null,
    val personImg: String? = "",
    val phone: String? = "",
    val totalAmount: Double? = 0.00,
    val userOrderStatus: Int? = 0,
    val username: String? = ""
)

@Parcelize
data class PeriodOrder(
    val type:Int?=0,
    val img: String? = "",
    val model: String? = "",
    val orderNo: String? = "",
    val paySource: Int? = 0,
    val rePaymentDate: Long? =0,
    val remainPay: Double? = 0.00,
    val remainPeriod: Int? = 0,
    val sn: String? = "",
    val spec: String? = "",
    val status: Int? = 0,
    val period:Int?=0,
    val amount:Double?=0.00,
    val orderDate:Long?,
    var isSelected: Boolean
) : Parcelable
