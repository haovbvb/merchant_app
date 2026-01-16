package com.okla.ops.beans

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

//弹窗列表
data class Shop(
    val shopName: String,
    val shopNo: String,
    var select: Boolean = false,
)

data class Shop1Num(
    val all: Int? = 0,
    val direct: Int? = 0,
    val franchise: Int? = 0,
)

//列表
data class Shop1(
    val batStock: Int,
    val cityName: String,
    val img: String,
    val name: String,
    val shopManager: String,
    val shopNo: String,
    val type: Int,
    val users: Int
)

//详情
@Parcelize
data class ShopDetail(
    val address: String? = "",
    val batStock: Int? = 0,
    val cityCode: String? = "",
    val cityName: String? = "",
    val imgList: String? = "",
    val latitude: Double? = 0.0,
    val longitude: Double? = 0.0,
    val managerPhone: String? = "",
    val name: String? = "",
    val remark: String? = "",
    val shopManager: String? = "",
    val shopNo: String? = "",
    val status: Int? = 0,
    val type: Int? = 0,
    val users: Int? = 0
) : Parcelable
