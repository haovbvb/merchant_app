package com.okla.ops.beans

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

@Parcelize
data class ShopPaymentMethod(
    val address: String? = null,
    val agentName: String? = null,
    val batStock: Int? = null,
    val businessTime: String? = null,
    val cityCode: String? = null,
    val cityName: String? = null,
    val imgList: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val managerPhone: String? = null,
    val name: String? = null,
    val otherPayWay: String? = null,
    val remark: String? = null,
    val saleCashOption: String? = null,
    val saleOnlineOption: String? = null,
    val salePayWay: String? = null,
    val serviceType: String? = null,
    val shopManager: String? = null,
    val shopNo: String? = null,
    val status: Int? = null,
    val type: Int? = null,
    val users: Int? = null,
    val vehicleStock: Int? = null
): Parcelable
