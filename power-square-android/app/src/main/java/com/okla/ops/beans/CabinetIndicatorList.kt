package com.okla.ops.beans

data class CabinetIndicatorList(
    var list: List<CabinetIndicator>,
    var total: Int
)

data class CabinetIndicator(
    var avg7DaySwapTime: String? = "",
    var damageNum: Int? = 0,
    var offlineNum: Int? = 0,
    var onlineStatus: Int? = 0,
    var showOnlineStatus: String? = "",
    var standardImg: String? = "",
    var standardSwapTime: String? = "",
    var stationAddress: String? = "",
    var stationSn: String? = "",
    var storeNum: Int? = 0,
    var latitude: Double,
    var longitude: Double,
)
