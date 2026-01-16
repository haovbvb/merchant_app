package com.okla.ops.beans

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

@Parcelize
data class ScanDeviceBean(
    val sn: String?="",
    val vin: String?="",
    val vcu: String?=""
):Parcelable
