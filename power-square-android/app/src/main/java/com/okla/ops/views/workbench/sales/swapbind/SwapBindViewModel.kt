package com.okla.ops.views.workbench.sales.swapbind

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.BatteryVo
import com.okla.ops.beans.CarVo
import com.okla.ops.beans.ShopPaymentMethod
import com.okla.ops.beans.UserInfo
import com.okla.ops.http.HttpMethods
import com.okla.ops.views.workbench.sales.rentbind.Pack

class SwapBindViewModel : BaseViewModel() {
    var swapBindInfoLiveData = MutableLiveData<SwapBindInfo?>()
    var batteryListLiveData = MutableLiveData<List<BatteryVo>?>()
    var carListLiveData = MutableLiveData<List<CarVo>?>()
    fun getSwapBindInfo(userSn: String) {
        addDisposable(
            HttpMethods.getSwapBindInfo(userSn)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<SwapBindInfo?>() {
                    override fun onSuccess(swapBindInfo: SwapBindInfo?) {
                        swapBindInfoLiveData.value = swapBindInfo
                        carListLiveData.value = swapBindInfo?.vehicleList
                        batteryListLiveData.value = swapBindInfo?.batteryList
                        loadState.value = State.getInstance(State.SUCCESS)
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        swapBindInfoLiveData.value = null
                        carListLiveData.value = null
                        batteryListLiveData.value = null
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }
    var packListLiveData = MutableLiveData<List<Pack>?>()
    fun getSwapPackInfo(batteryType:String,carType:String,minDay:Int?) {
        addDisposable(
            HttpMethods.getSwapPackInfo(batteryType,carType,minDay)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<List<Pack>?>() {
                    override fun onSuccess(list: List<Pack>?) {
                        packListLiveData.value = list
                        loadState.value = State.getInstance(State.SUCCESS)
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        packListLiveData.value = null
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }


    var shopPaymentMethodLiveData = MutableLiveData<ShopPaymentMethod?>()
    fun getShopPaymentMethod(shopNo: String) {
        addDisposable(
            HttpMethods.getShopPaymethod(shopNo)
//                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<ShopPaymentMethod?>() {
                    override fun onSuccess(data: ShopPaymentMethod?) {
                        shopPaymentMethodLiveData.value = data
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        shopPaymentMethodLiveData.value = null

                    }
                })
        )
    }
}