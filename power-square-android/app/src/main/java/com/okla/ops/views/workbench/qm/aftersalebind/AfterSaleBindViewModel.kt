package com.okla.ops.views.workbench.qm.aftersalebind

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.AfterSaleCanBindOrderBean
import com.okla.ops.beans.BatterOrVehicleInfo
import com.okla.ops.beans.PurchasingUser
import com.okla.ops.beans.UserDetail
import com.okla.ops.http.HttpMethods
import com.okla.ops.views.workbench.qm.aftersalebind.net.AfterSaleBindHttpMethods

class AfterSaleBindViewModel : BaseViewModel() {
    var deviceDetailLiveData = MutableLiveData<BatterOrVehicleInfo?>()
    fun getAfterSaleBindDeviceInfo(deviceSn: String, model: String,deviceType: Int) {
        addDisposable(
            AfterSaleBindHttpMethods.getAfterSaleBindDeviceInfo(deviceSn, model,deviceType)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<BatterOrVehicleInfo?>() {
                    override fun onSuccess(data: BatterOrVehicleInfo?) {
                        deviceDetailLiveData.value = data
                        loadState.value = State.getInstance(State.SUCCESS)
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        deviceDetailLiveData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    var userDetailLiveData = MutableLiveData<UserDetail?>()
    fun getUserDetail(cardNum: String) {
        val map = HashMap<String, Any>()
        map["cardNum"] = cardNum
        addDisposable(
            HttpMethods.queryUserForAfterSaleBind(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<UserDetail>() {
                    override fun onSuccess(userDetail: UserDetail?) {
                        userDetailLiveData.value = userDetail
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        userDetailLiveData.value = null
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val ordersLiveData = MutableLiveData<List<AfterSaleCanBindOrderBean?>?>()
    fun queryOderCanBind(userId: String) {
        addDisposable(
            AfterSaleBindHttpMethods.queryCanBindOrderByUserId(userId)
                .subscribeWith(object : NullAbleObserver<List<AfterSaleCanBindOrderBean?>?>() {
                    override fun onSuccess(t: List<AfterSaleCanBindOrderBean?>?) {
                        ordersLiveData.value = t

                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ordersLiveData.value = null
                        ToastUtils.showShort(e?.msg)
                    }
                })
        )
    }

    val afterSellBindLiveData = MutableLiveData<String?>()
    fun afterSellBind(cardNum: String, deviceSn: String, deviceType: Int, orderNo: String) {
        addDisposable(
            AfterSaleBindHttpMethods.afterSellBind(cardNum, deviceSn, deviceType, orderNo)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<String?>() {
                    override fun onSuccess(t: String?) {
                        afterSellBindLiveData.value = "success"

                    }

                    override fun onFail(e: ErrorMsgBean) {
                        afterSellBindLiveData.value = null
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }
}