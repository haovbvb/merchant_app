package com.okla.ops.views.workbench.qm.unbind.net

import com.base.common.GlobalConfigure
import com.base.common.net.ServiceGenerator
import io.reactivex.Observable

object UnbindHttpMethods {
    private var opsService: UnbindOpsService = ServiceGenerator.createService(
        UnbindOpsService::class.java,
        GlobalConfigure.getBaseUrl()
    )

    /**
     * 解綁設備
     */
    fun unBindDevice(
        sn: String,
        cardNum: String,
        checkRemark: String,
        remark: String,
    ): Observable<Any> {
        val map: MutableMap<String, Any> = HashMap()
        map["sn"] = sn
        map["cardNum"] = cardNum
        map["checkRemark"] = checkRemark
        map["remark"] = remark
        return opsService.unBindDevice(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }


//    /**
//     * 解綁电池
//     */
//    fun unBindBattery(
//        batterySnList: Array<String>,
//        cardNum: String,
//        remark: String,
//        checkBatRemark: String
//    ): Observable<BatteryUnbindBean> {
//        val map: MutableMap<String, Any> = java.util.HashMap()
//        map["batterySnList"] = batterySnList
//        map["cardNum"] = cardNum //相当于国内电话号码
//        map["remark"] = remark
//        map["checkBatRemark"] = checkBatRemark
//        return opsService.unBindBattery(map)
//            .compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }
//
//
//    /**
//     * 解綁車輛
//     */
//    fun unBindCar(
//        cardNum: String,
//        scooterSn: String,
//        remark: String,
//        checkCarRemark: String,
//        appointmentNo: String
//    ): Observable<Any> {
//        val map: MutableMap<String, Any> = java.util.HashMap()
//        map["cardNum"] = cardNum //相当于国内电话号码
//        map["carSn"] = scooterSn
//        map["remark"] = remark
//        map["checkCarRemark"] = checkCarRemark
////        if (!appointmentNo.trim { it <= ' ' }.isBlank()) {
////            map["appointmentNo"] = appointmentNo
////        }
//        return opsService.unBindCar(map)
//            .compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }

    /**
     * 检测是否存在尚未完结预约保养单
     *
     * @param userId
     * @param sn
     * @return
     */
    fun checkExistUnCompletedCarOrder(userId: String?, sn: String?): Observable<Any> {
        return opsService.checkExistUnCompleteCarOrder(userId, sn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
}