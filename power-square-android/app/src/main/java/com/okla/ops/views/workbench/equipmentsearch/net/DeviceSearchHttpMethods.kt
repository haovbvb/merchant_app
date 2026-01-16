package com.okla.ops.views.workbench.equipmentsearch.net

import com.base.common.GlobalConfigure
import com.base.common.net.ServiceGenerator
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew
import io.reactivex.Observable

object DeviceSearchHttpMethods {
    private var opsService: DeviceSearchOpsService = ServiceGenerator.createService(
        DeviceSearchOpsService::class.java,
        GlobalConfigure.getBaseUrl()
    )

    fun getDeviceListSearchDataNew(deviceSn: String): Observable<EquipmentDeviceSearchBeanNew> {
        val map: MutableMap<String, String> = java.util.HashMap()
        map["deviceSn"] = deviceSn
        return opsService.getDeviceListSearchDataNew(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
}