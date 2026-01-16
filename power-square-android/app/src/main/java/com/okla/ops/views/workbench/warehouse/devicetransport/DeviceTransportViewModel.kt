package com.okla.ops.views.workbench.warehouse.devicetransport

import androidx.compose.runtime.key
import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.City
import com.okla.ops.beans.DeviceTransportDetail
import com.okla.ops.beans.DeviceTransportResp
import com.okla.ops.beans.WarehouseBean
import com.okla.ops.http.HttpMethods

class DeviceTransportViewModel : BaseViewModel() {

    var mDeviceTransportRespLiveData = MutableLiveData<DeviceTransportResp?>()

    fun queryDeviceIssuePage(keyword: String?, status: Int?, page: Int, size: Int) {
        addDisposable(
            HttpMethods.queryDeviceIssuePage(keyword, status, page, size)
                .subscribeWith(object : NullAbleObserver<DeviceTransportResp>() {
                    override fun onSuccess(t: DeviceTransportResp?) {
                        mDeviceTransportRespLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var myWarehouseBeanLiveData = MutableLiveData<WarehouseBean?>()

    fun queryMyWarehouseInfo() {
        addDisposable(
            HttpMethods.queryMyWarehouseInfo()
                .subscribeWith(object : NullAbleObserver<WarehouseBean>() {
                    override fun onSuccess(t: WarehouseBean?) {
                        myWarehouseBeanLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mInWarehouseBeanListLiveData = MutableLiveData<List<WarehouseBean>?>()

    fun queryInWarehouseList(keyword: String, cityCode: String) {
        val map = HashMap<String, Any>()
        map["cityCode"] = cityCode
        map["name"] = keyword
        addDisposable(
            HttpMethods.queryInWarehouseList(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<List<WarehouseBean>>() {
                    override fun onSuccess(t: List<WarehouseBean>?) {
                        mInWarehouseBeanListLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mCreateIssueLiveData = MutableLiveData<Any>()

    fun createIssue(
        inWarehouseNo: String,
        outWarehouseNo: String?,
        deviceType: Int,
        sns: MutableList<String>,
        trackingNumber: String
    ) {
        addDisposable(
            HttpMethods
                .createIssue(inWarehouseNo, outWarehouseNo, deviceType, sns, trackingNumber)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(t: Any?) {
                        mCreateIssueLiveData.value = t ?: Any()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mOutTransportDetailLiveData = MutableLiveData<DeviceTransportDetail?>()

    fun queryOutTransportDetail(transferNo: String, page: Int, size: Int) {
        addDisposable(
            HttpMethods.queryOutTransportDetail(transferNo, page, size)
                .subscribeWith(object : NullAbleObserver<DeviceTransportDetail>() {
                    override fun onSuccess(t: DeviceTransportDetail?) {
                        mOutTransportDetailLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mEditTrackingNumberLiveData = MutableLiveData<Any>()

    fun editTrackingNumber(
        trackingNo: String,
        trackingNumber: String
    ) {
        addDisposable(
            HttpMethods
                .editTrackingNumber(trackingNo, trackingNumber)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(t: Any?) {
                        loadState.postValue(State.getInstance(State.SUCCESS))
                        mEditTrackingNumberLiveData.value = t ?: Any()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mDeviceTransportReceiveRespLiveData = MutableLiveData<DeviceTransportResp>()

    fun queryDeviceReceivePage(keyword: String,status: Int?, page: Int, size: Int) {
        addDisposable(
            HttpMethods.queryDeviceReceivePage(keyword,status, page, size)
                .subscribeWith(object : NullAbleObserver<DeviceTransportResp>() {
                    override fun onSuccess(t: DeviceTransportResp?) {
                        mDeviceTransportReceiveRespLiveData.value = t ?: DeviceTransportResp(
                            mutableListOf(), 0
                        )
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
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

    var mDeviceWithdrawLiveData = MutableLiveData<Any?>()

    fun withdrawDevice(deviceSn: String, transferNo: String) {
        addDisposable(
            HttpMethods.withdrawDevice(deviceSn, transferNo)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(t: Any?) {
                        loadState.postValue(State.getInstance(State.SUCCESS))
                        mDeviceWithdrawLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mCheckDeviceSn = MutableLiveData<String>()

    fun checkDeviceSn(type: Int, sn: String, warehouseNo: String?) {
        addDisposable(
            HttpMethods.checkDeviceSn(type, sn, warehouseNo ?: "")
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

    val cityListLiveData = MutableLiveData<MutableList<City>>()
    fun getCityList() {
        addDisposable(
            HttpMethods.getCityList()
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<MutableList<City>>() {
                    override fun onSuccess(list: MutableList<City>?) {
                        cityListLiveData.value = list ?: mutableListOf()
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
    }

}