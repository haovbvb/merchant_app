package com.okla.ops.beans

import java.io.Serializable

data class EquipmentDeviceSearchBeanNew(
    var deviceInfo: DeviceInfo,
    var type: Int// 1电池 2车辆 3电柜
) : Serializable
