package com.okla.ops.views.workbench.warehouse

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.DeviceInventoryResp
import com.okla.ops.beans.DeviceTransportResp
import com.okla.ops.http.HttpMethods

class SearchViewModel : BaseViewModel() {

    var mDeviceInventoryRespLiveData = MutableLiveData<DeviceInventoryResp?>()

    fun queryDeviceInventoryPage(page: Int, size: Int, keyWord: String) {
        addDisposable(
            HttpMethods.queryDeviceInventoryPage(page, size, keyWord, null)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<DeviceInventoryResp>() {
                    override fun onSuccess(t: DeviceInventoryResp?) {
                        mDeviceInventoryRespLiveData.value = t
                        loadState.value = State.getInstance(State.SUCCESS)
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mDeviceIssueRespLiveData = MutableLiveData<DeviceTransportResp?>()

    fun queryDeviceIssuePage(keyWord: String?, status: Int?, page: Int, size: Int) {
        addDisposable(
            HttpMethods.queryDeviceIssuePage(keyWord, status, page, size)
                .subscribeWith(object : NullAbleObserver<DeviceTransportResp>() {
                    override fun onSuccess(t: DeviceTransportResp?) {
                        mDeviceIssueRespLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mDeviceReceiveRespLiveData = MutableLiveData<DeviceTransportResp>()

    fun queryDeviceReceivePage(keyWord: String, status: Int?, page: Int, size: Int) {
        addDisposable(
            HttpMethods.queryDeviceReceivePage(keyWord, status, page, size)
                .subscribeWith(object : NullAbleObserver<DeviceTransportResp>() {
                    override fun onSuccess(t: DeviceTransportResp?) {
                        mDeviceReceiveRespLiveData.value = t ?: DeviceTransportResp(
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
}