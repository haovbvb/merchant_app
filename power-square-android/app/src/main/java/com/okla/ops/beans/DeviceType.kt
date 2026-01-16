package com.okla.ops.beans

data class DeviceType(
    val deviceName: String,
    val deviceType: Int
)

object DeviceTypeObject {
    const val TYPE_BATTERY: Int = 1
    const val TYPE_VEHICLE: Int = 2
    const val TYPE_STATION: Int= 3
}

object PayTypeObject {
    const val TYPE_CASH: Int = 1
    const val TYPE_ONLINE: Int = 2
}

object PayFullTypeObject {
    const val TYPE_FULL: Int = 1
    const val TYPE_INSTALLMENT: Int = 2
}