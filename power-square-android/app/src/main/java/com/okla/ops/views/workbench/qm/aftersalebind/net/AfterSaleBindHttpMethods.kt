package com.okla.ops.views.workbench.qm.aftersalebind.net

import com.base.common.GlobalConfigure
import com.base.common.net.ServiceGenerator
import com.okla.ops.beans.BatterOrVehicleInfo
import com.okla.ops.beans.AfterSaleCanBindOrderBean
import io.reactivex.Observable

object AfterSaleBindHttpMethods {
    private var opsService: AfterSaleBindOpsService = ServiceGenerator.createService(
        AfterSaleBindOpsService::class.java,
        GlobalConfigure.getBaseUrl()
    )

    fun queryCanBindOrderByUserId(userId: String): Observable<MutableList<AfterSaleCanBindOrderBean>> {
        return opsService.queryCanBindOrderByUserId(userId)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getAfterSaleBindDeviceInfo(deviceSn: String, model: String,deviceType:Int): Observable<BatterOrVehicleInfo> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["sn"] = deviceSn
        map["model"] = model
        map["deviceType"]= deviceType
        return opsService.getAfterSaleBindDeviceInfo(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun afterSellBind(
        cardNum: String,
        deviceSn: String,
        deviceType: Int,
        orderNo: String
    ): Observable<String?> {
        val map = HashMap<String, Any>()
        map["cardNum"] = cardNum
        map["deviceSn"] = deviceSn
        map["deviceType"] = deviceType
        map["orderNo"] = orderNo
        return opsService.afterSellBind(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
}