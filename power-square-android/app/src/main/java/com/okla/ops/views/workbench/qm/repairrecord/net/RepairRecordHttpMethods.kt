package com.okla.ops.views.workbench.qm.repairrecord.net

import com.base.common.GlobalConfigure
import com.base.common.net.ServiceGenerator
import com.okla.ops.beans.DeviceFix
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew
import io.reactivex.Observable
import okhttp3.MultipartBody

object RepairRecordHttpMethods {
    private var opsService: RepairRecordOpsService = ServiceGenerator.createService(
        RepairRecordOpsService::class.java,
        GlobalConfigure.getBaseUrl()
    )

    /**
     * 查询维修设备信息
     */
    fun getFixDeviceInfo(deviceSn: String): Observable<DeviceFix?> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["sn"] = deviceSn
        return opsService.getFixDeviceInfo(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 搜索设备列表(维修登记)
     */
    fun getDeviceListSearchDataNew(deviceSn: String): Observable<EquipmentDeviceSearchBeanNew> {
        val map: MutableMap<String, String> = java.util.HashMap()
        map["deviceSn"] = deviceSn
        return opsService.getDeviceListSearchDataNew(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 查询维修设备信息
     */
    fun addFixDeviceRecord(
        cardNum:String,
        deviceSn: String,
        deviceType: Int,
        fixItem: String,
        remark: String,
        result: String
    ): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["cardNum"]=cardNum
        map["deviceSn"] = deviceSn
        map["deviceType"] = deviceType
        map["fixItem"] = fixItem
        map["remark"] = remark
        map["fixResult"] = result
        return opsService.addFixDeviceRecord(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 上傳設備維修圖片
     */
    fun uploadFixImg(part: MultipartBody.Part?): Observable<String> {
        return opsService.uploadFixImg(part)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

}