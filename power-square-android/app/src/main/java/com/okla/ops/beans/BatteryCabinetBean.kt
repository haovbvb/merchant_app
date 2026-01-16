package com.okla.ops.beans

import com.okla.ops.beans.BatModelBean

data class BatteryCabinetBean(
    var status: Int,
    var stationPid: String,
    var stationSn: String,
    var stationName: String,
    var stationAddress: String,
    var latitude: Double,
    var longitude: Double,
    var onlineStatus: Int,
    var batteryNum: Int,//柜子存放电池数
    var forbidNum: Int,//禁仓数量
    var fullFlag: Int,//满仓标志1 满仓
    var availableBatteryNum: Int,//柜子可用电池数
    var emptyNum: Int,//空仓数
    var batteryInfo: String,
    var img: String,
    var imgList: String,
    var batModelList: List<BatModelBean>
)
