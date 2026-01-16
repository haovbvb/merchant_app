package com.okla.ops.utils

data class CabinetFormat(
    val msgType: Int,
    val devId: String,
    val paramList: List<CabinetParam>,
    val txnNo: String,
)

data class CabinetParam(
    var id: String?,
    var value: String?,
    val doorId: String?,
)

data class CabinetData(
    val msgType: Int,
    val devId: String,
    val result: Int?,
    val txnNo: String,
    val isFull: Int?,
    val cabList: List<CabinetInfo>?,
    val boxList: List<BoxInfo>?,
    val batList: List<BatteryInfo>?,
    val resultList: List<ResultInfo>?,
    val attrList: List<Attr>?,
    val alarmList: List<AlarmInfo>?,
)

data class CabinetDataResult(
    val msgType: Int,
    val devId: String,
    val result: Int?,
    val txnNo: String,
)

data class ResultInfo(
    val id: String,
    val value: String,
)

data class CabinetInfo(
    val dBM: String,
    val locationSta: String,
    val cabVol: String,
    val cabCur: String,
    val emKwh: String,
    val cabT: String,
    val cabEnable: String,
    val cabSta: String,
    val batNum: String,
    val batFullA: String,
    val batFullB: String,
    val batFullC: String,
    val elecSta: String,
    val cabAlarm: List<String>,
    val cabFault: List<String>,
    val alarmList: List<AlarmInfo>,
    val checkdoorSta: String
)

data class BoxInfo(
    val doorId: String,
    val doorSta: String,
    val boxSta: String,
    val boxEnable: String,
    val boxT: String,
    val boxChgSta: String,
    val boxHeatSta: String,
    val boxAlarm: List<String>,
    val boxFault: List<String>,
    val batteryId: String,
    val dischgCode: String,
    val chgVol: String,
    val batchgTime: String,
    val batFulTime: String
)

data class BatteryInfo(
    val doorId: String,
    val batteryId: String,
    val soc: String,
    val soh: String,
    val bmsT: String,
    val batT: String,
    val envT: String,
    val totalAH: String,
    val batSta: String,
    val batCtrl: String,
    val cellNum: String,
    val batVol: String,
    val batCycle: String,
    val chgCur: String,
    val cellVol: String,
    val bmsFault: List<String>,
    val bmsAlarm: List<String>
)

data class AlarmInfo(
    val id: String,
    val doorId: Int,
    val batteryId: String,
    val alarmFlag: Int,
    val alarmDesc: String,
    val alarmTime: Long
)

/**
 * 盾创协议
 * id       : 值说明
 * 02105001 : GSM 信号强度
 * 02106001 : 柜内电池 SN
 * 02107001 : 电柜总电压
 * 02108001 : 电柜总电流
 * 02113001 : 电柜体温度
 * 02109001 : 柜内电池电量
 * 02118001 : 柜门是否禁用
 * 02120001 : 电表
 * 02019001 : 备用电源状态
 * 02017001 : 烟雾
 * 02018001 : 浸水
 * 02020001 : 主控与柜控通信状态
 * 02020002 : 电柜维护门状态
 * 02020003 : 机柜风扇状态
 * 柜门
 * 02103001 : 柜门锁状态
 */
data class Attr(
    val doorId: String,
    val id: String,
    val value: String,
)
//02103001 仓位锁状态：0：关，1：开
//02118001 仓位是否禁用：0：禁用，1：启动
//02106001 仓位内电池SN
//02104001 仓位状态：1：电池正在充电，2：电池充满，5：异常，0：无电池
//18102001 仓位温度 单位℃
//18002010 仓位是否可换电池： >0：可换电， <0：不可换电
//18801001 远程设备换电阈值（遥信）

//02020001 主控与柜控通信状态：0：断开，1：正常
//02020002 电柜维护门状态：0：关闭，1：开启
//02020003 机柜风扇状态：0：关闭，1：运行，2：异常
//02101001 ？
//02102001 换电柜状态 0：上电初始化，1：无换电、放电、取电，2：在换电，3：在归还，4：在取电，5：换电异常
object CabinetSignal {
    const val GSM = "02105001"
    const val CABINET_VOLTAGE = "02107001"
    const val CABINET_CURRENT = "02108001"
    const val CABINET_TEMPERATURE = "02113001"
    const val BATTERY_SOC = "02109001"
    const val ELECTRIC_METER = "02120001"
    const val BACKUP_BATTERY_STATUS = "02019001"
    const val ALARM_SMOKE = "02017001"
    const val ALARM_WATER = "02018001"
    const val ALL_DATA = "02309009"
    const val CTRL_CHARGER = "020030"//020030XX -> XX 为柜门，柜门充电模块故障
    const val CTRL_SYSTEM = "02020001"
    const val CABINET_MAINTENANCE_DOOR = "02020002"
    const val CABINET_FAN_STATUS = "02020003"
    const val CABINET_DOOR_STATUS = "02118001"
    const val CABINET_DOOR_LOCK = "02103001"
    const val BATTERY_SN = "02106001"
    const val CABINET_SWAP_STATUS = "18002010"
    const val CABINET_BATTERY_SWAP_STATUS = "02104001"
}

object CabinetDataType {
    const val QUERY_REQUEST = 210
    const val QUERY_RESPONSE = 211
    const val ATTRIBUTE_REQUEST = 310
    const val ATTRIBUTE_RESPONSE = 311
    const val ALARM_REQUEST = 410
    const val ALARM_RESPONSE = 411
    const val CONTROL_REQUEST = 500
    const val CONTROL_RESPONSE = 501
}

object CabinetParamName {
    const val RESET = "swCabReset"
    const val SWITCH_CONTROL = "switchControl"
    const val CAB_VOLUME = "swCabVolControl"
    const val CAB_SOC = "swCabSocControl"
    const val SOFT_VERSION = "softVersion"
    const val CAB_TCP_PORT = "swCabTcpPort"
    const val APN = "APN"
    const val CONTROL = "02301001"
}
