package com.okla.ops.views.workbench.sales.depositrefund

data class DepositRefundInfoBean(
    val address: String = "",
    val avatar: String = "",
    val birthday: String = "",
    val cardImg: String = "",
    val cardNum: String = "",
    val depositList: List<Deposit>? = null,
    val email: String = "",
    val firstName: String = "",
    val idNumber: String = "",
    val lastName: String = "",
    val personImg: String = "",
    val phone: String = "",
    val username: String = ""
)

data class Deposit(
    val depositAmount: Double = 0.00,
    val depositImgList: String = "",
    val orderNo: String? = null,
    val unbindTime: Long? = 0,
    var isSelected: Boolean,
)

