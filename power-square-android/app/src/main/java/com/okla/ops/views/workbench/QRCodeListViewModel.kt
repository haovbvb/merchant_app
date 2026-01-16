package com.okla.ops.views.workbench

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.Battery
import com.okla.ops.beans.DeviceInventoryScanResult
import com.okla.ops.http.HttpMethods

/**
 * Author: Joe
 * Date: 2024/2/21 10:04
 * Description:
 */
class QRCodeListViewModel : BaseViewModel() {

    var mCheckDeviceSn = MutableLiveData<String>()

    fun checkDeviceSn(type: Int, sn: String, warehouseNo: String?) {
        addDisposable(
            HttpMethods.checkDeviceSn(type, sn, warehouseNo?:"")
                .subscribeWith(object : NullAbleObserver<Any?>() {

                    override fun onSuccess(str: Any?) {
                        mCheckDeviceSn.value = sn
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
    }

    var mDeviceReceiveLiveData = MutableLiveData<Any?>()

    fun receiveDevice(deviceSn: String, transferNo: String) {
        addDisposable(
            HttpMethods.receiveDevice(deviceSn, transferNo)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(t: Any?) {
                        loadState.postValue(State.getInstance(State.SUCCESS))
                        mDeviceReceiveLiveData.value = deviceSn
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mScanInventoryLiveData = MutableLiveData<String>()

    fun scanInventory(sn: String, inventoryNo: String?) {
        addDisposable(
            HttpMethods.scanInventory(sn, inventoryNo?:"")
                .subscribeWith(object : NullAbleObserver<DeviceInventoryScanResult?>() {

                    override fun onSuccess(result: DeviceInventoryScanResult?) {
                        mScanInventoryLiveData.value = "$sn,${result?.result}"
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
    }

//    val queryBatteryLiveData = MutableLiveData<Battery?>()
//    fun queryShipBatteryBySn(sn: String) {
//        val map = HashMap<String, Any>()
//        map["sn"] = sn
//        addDisposable(
//            HttpMethods.queryShipBatteryBySn(map)
//                .subscribeWith(object : NullAbleObserver<Battery>() {
//                    override fun onSuccess(battery: Battery?) {
//                        queryBatteryLiveData.value = battery
//                    }
//
//                    override fun onFail(e: ErrorMsgBean) {
//                        ToastUtils.showShort(e.msg)
//                    }
//                })
//        )
//    }
}