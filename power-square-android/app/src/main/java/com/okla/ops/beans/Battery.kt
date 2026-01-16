package com.okla.ops.beans

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

//出货，电池信息
@Parcelize
data class Battery(
    val sn: String?,
    val model: String? = "",
    val modelName: String? = "",
    val img: String? = "",
    val remark: String? = ""
) : Parcelable

//出货，车辆信息
@Parcelize
data class Car(
    val sn: String?,
    val vin: String,
    val model: String? = "",
    val modelName: String? = "",
    val img: String? = "",
    val remark: String? = ""
) : Parcelable

//设备录入 车辆型号列表
@Parcelize
data class CarType(
    val engineDate: String? = "",
    val engineModel: String? = "",
    val img: String? = "",
    val model: String? = "",
    val modelName: String? = "",
    val remark: String? = ""
) : Parcelable

//设备录入 电池型号列表
@Parcelize
data class BatteryType(
    val capacity: Int? = 0,
    val dimension: String? = "",
    var img: String? = "",
    val model: String? = "",
    var modelName: String? = "",
    val remark: String? = "",
    val voltage: Int? = 0,
    val weight: String? = "",
) : Parcelable
//电柜录入 电柜型号列表
@Parcelize
data class StationType(
    //蓝牙类型：1：ble蓝牙 2：经典蓝牙
    val bleType:Int?=0,
    //协议类型：1：弗迪协议 2：比特安协议 3：盾创
    val protocolType:Int?=0,
    val dimension: String? = "",
    var img: String? = "",
    val model: String? = "",
    var modelName: String? = "",
    val remark: String? = "",
    val storeNum: Int? = 0,
    val weight: String? = "",
) : Parcelable
/**
 * 录入电池 入参
 */
@Parcelize
data class BatteryNew(
    var sn: String,
    var imei: String,
    var iccid: String,
) : Parcelable

//出货，电柜信息
@Parcelize
data class Station(
    val sn: String?,
    val model: String? = "",
    val modelName: String? = "",
    val img: String? = "",
    val remark: String? = ""
) : Parcelable
/**
 * 录入电柜 入参
 */
@Parcelize
data class StationNew(
    var sn: String,
    var imei: String,
    var iccid: String,
    var lockDevId:String
) : Parcelable

//录入车辆 入参
@Parcelize
data class CarNew(
    var sn: String,
    var vin: String,
    var ctrlId: String,
) : Parcelable

data class SellBattery(
    val sn: String? = "",
    val cycle: Int? = 0,
    val img: String? = "",
    val lastSignalTime: Long? = 0,
    val onlineFlag: Int? = 0,
    val price: Double? = 0.0,
    val soc: Int? = 0,
    val soh: Int? = 0,
    val paymentPlanList: List<PaymentPlan>? = mutableListOf(),
)

data class PaymentPlan(
    val amount: Double? = 0.0,//单价
    val fee: Double? = 0.0,//总利息
    val perAmount: Double? = 0.0,//每期费用
    val period: Int? = 0,//总期数
    val planName: String? = "",//方案名
    val planNo: String? = "",//方案号
    val rate: Double? = 0.0,//利息率
    val totalAmount: Double? = 0.0,//含息费用总额
    var selected: Boolean = false,
)

@Parcelize
data class BatteryTransfer(
    val sn: String,
    val batModel: String? = "",
    val iccid: String? = "",
    val imei: String? = "",
    val img: String? = "",
    val model: String? = "",
    val modelName: String? = "",
) : Parcelable

@Parcelize
data class NearByVehicle(
    val carNumber: String? = null,
    val cardNum: String? = null,
    val img: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val mile: Double? = null,
    val needMaintenance: Boolean? = null,
    val sn: String? = null
) : Parcelable

@Parcelize
data class BatteryDevice(
    val cycle: Int? = 0,
    val deviceSn: String,
    val dischargeStatus: Int? = 0,
    val img: String? = "",
    val latitude: Double? = 0.0,
    val longitude: Double? = 0.0,
    val mile: Double? = 0.0,
    val model: String? = "",
    val soc: Int? = 0,
    val status: Int? = 0,
    val urgentFlag: Boolean? = false
) : Parcelable

@Parcelize
data class BatteryDetail(
    val avgSpeed: Double? = 0.0,
    val color: Int? = 0,
    val cycle: Int? = 0,
    val deviceSn: String? = "",
    val img: String? = "",
    val latitude: Double? = 0.0,
    val longitude: Double? = 0.0,
    val mile: Double? = 0.0,
    val online: Int? = 0,
    val operationDate: Long? = 0,
    val signalTime: Long? = 0,
    val soc: Int? = 0,
    val status: Int? = 0,
    val todayMile: Double? = 0.0
) : Parcelable

data class ChargeHistory(
    val chargeValue: String? = "",
    val chargeTime: String? = "",
    val date: String? = "",
)

@Parcelize
data class BindDevice(
    val bindDate: Long? = 0,
    val bindSource: Int? = 0,
    val carNumber: String? = "",
    val deviceSn: String? = "",
    val deviceType: Int? = 0,
    val img: String? = "",
    val model: String? = "",
    val modelName: String? = "",
    val payWay: Int? = 0,
    val remainTerm: Int? = 0,
    val rentOrderStatus: Int? = 0,
    val saleOrderStatus: Int? = 0,
    val status: Int? = 0,
    val soc: Int? = 0,
    val onlineFlag: Int? = 0

) : Parcelable
