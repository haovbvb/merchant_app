package com.okla.ops.views.workbench.device

import androidx.lifecycle.MutableLiveData
import com.base.common.net.BaseListResponse
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.BatteryDetail
import com.okla.ops.beans.ChargeHistory
import com.okla.ops.beans.UserInfo
import com.okla.ops.http.HttpMethods
import com.okla.ops.views.MainViewModel

class DeviceViewModel : MainViewModel() {

    val batteryDetailLiveData = MutableLiveData<BatteryDetail?>()
    fun searchBatteryBySn(sn: String) {
        val map = java.util.HashMap<String, Any>()
        map["sn"] = sn
        addDisposable(
            HttpMethods.searchBatteryBySn(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<BatteryDetail>() {
                    override fun onSuccess(batteryDetail: BatteryDetail?) {
                        batteryDetailLiveData.value = batteryDetail
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        batteryDetailLiveData.value = null
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

    val turnDischargesStatusLiveData = MutableLiveData<Boolean>()
    fun turnDischargesStatus(sn: String, status: Int) {
        val map = java.util.HashMap<String, Any>()
        map["sn"] = sn
        map["status"] = status
        addDisposable(
            HttpMethods.turnDischargesStatus(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(any: Any?) {
                        turnDischargesStatusLiveData.value = true
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        turnDischargesStatusLiveData.value = false
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

    /**
     * 分页查询设备充电记录
     */
    var deviceChargeListLiveData = MutableLiveData<MutableList<ChargeHistory>>()
    fun getDeviceChargeList(
        sn: String?,
        pageNum: Int,
        pageSize: Int,
    ) {
        val map = java.util.HashMap<String, Any>()
        sn?.let {
            map["sn"] = sn
        }
        map["pageNum"] = pageNum
        map["pageSize"] = pageSize
        addDisposable(
            HttpMethods.queryDeviceChargeRecord(map)
                .subscribeWith(object : NullAbleObserver<BaseListResponse<ChargeHistory>>() {
                    override fun onSuccess(resp: BaseListResponse<ChargeHistory>?) {
                        deviceChargeListLiveData.value = resp?.list ?: mutableListOf()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

}