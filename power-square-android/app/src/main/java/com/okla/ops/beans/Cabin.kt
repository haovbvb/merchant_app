package com.okla.ops.beans

data class Cabin(
    var portNo: Int,//仓门号
    var portName: String,//仓门号展示名
    var batterySn: String,//电池SN
    var batterySoc: Int,//电量
    var chargeCurrent: String,//充电电流
    var status: Int,//0 禁 1 启
    var showStatus: String,//仓门展示状态 例如 启动/禁用
    var batteryStatus: Int,//1 占用 0 空闲
    var showBatteryStatus: String,//仓门电池展示状态 例如 占用/空闲
    var doorStatus: Int,//0 关 1 开
    var showDoorStatus: String,//展示仓门状态 开关
    var swapFlag: Int//电量是否高于阈值 1 是，0 否
)
