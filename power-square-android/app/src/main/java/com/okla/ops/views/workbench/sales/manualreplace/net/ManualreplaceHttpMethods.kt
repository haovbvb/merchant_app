package com.okla.ops.views.workbench.sales.manualreplace.net

import com.base.common.GlobalConfigure
import com.base.common.net.ServiceGenerator
import io.reactivex.Observable

object ManualreplaceHttpMethods {
    private var opsService: ManualreplaceOpsService = ServiceGenerator.createService(
        ManualreplaceOpsService::class.java,
        GlobalConfigure.getBaseUrl()
    )

    fun manualReplace(ins: String, outs: String, cardNum: String,remark:String): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["inSn"] = ins
        map["outSn"] = outs
        map["cardNum"] = cardNum
        map["reason"]=remark
        return opsService.manualReplace(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
}