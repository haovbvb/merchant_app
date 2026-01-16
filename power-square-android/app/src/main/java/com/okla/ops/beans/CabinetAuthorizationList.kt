package com.okla.ops.beans

data class CabinetAuthorizationList(
    var list: List<CabinetAuthorization>,
    var total: Int
)

data class CabinetAuthorization(
    var avg7DaySwapTime: String? = "",
    var damageNum: Int? = 0,
    var offlineNum: Int? = 0,
    var onlineStatus: Int? = 0,
    var showOnlineStatus: String? = "",
    var standardImg: String? = "",
    var standardSwapTime: String? = "",
    var stationAddress: String? = "",
    var stationSn: String? = "",
    var storeNum: Int? = 0
)
