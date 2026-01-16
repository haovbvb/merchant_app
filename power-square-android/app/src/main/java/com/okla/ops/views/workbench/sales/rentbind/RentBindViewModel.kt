package com.okla.ops.views.workbench.sales.rentbind

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.CarVo
import com.okla.ops.beans.ShopPaymentMethod
import com.okla.ops.http.HttpMethods

class RentBindViewModel : BaseViewModel() {
    var deviceInfoLiveData = MutableLiveData<RentDeviceInfoBean?>()
    var packListLiveData = MutableLiveData<List<Pack>?>()
    fun getRentInfo(deviceSn: String) {
        addDisposable(
            HttpMethods.getRentInfo(deviceSn)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<RentDeviceInfoBean?>() {
                    override fun onSuccess(rentDevice: RentDeviceInfoBean?) {
                        deviceInfoLiveData.value = rentDevice
                        packListLiveData.value = rentDevice?.packList
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        deviceInfoLiveData.value = null
                        packListLiveData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
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