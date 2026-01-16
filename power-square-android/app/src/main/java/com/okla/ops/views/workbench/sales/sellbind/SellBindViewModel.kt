package com.okla.ops.views.workbench.sales.sellbind

import android.text.TextUtils
import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.BatterOrVehicleInfo
import com.okla.ops.beans.PaymentPlan
import com.okla.ops.beans.PurchasingUser
import com.okla.ops.beans.ServicePlanBean
import com.okla.ops.beans.ServicePlanInfo
import com.okla.ops.beans.ShopPaymentMethod
import com.okla.ops.http.HttpMethods
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.File

class SellBindViewModel : BaseViewModel() {
    var batterOrVehicleInfo = MutableLiveData<BatterOrVehicleInfo?>()
    fun queryBatteryOrVehicle(sn: String, batteryType: String, carType: String) {
        val map = HashMap<String, Any>()
        map["sn"] = sn
        if (!TextUtils.isEmpty(batteryType.trim())) {
            map["batteryType"] = batteryType
        }
        if (!TextUtils.isEmpty(carType.trim())) {
            map["carType"] = carType
        }
        addDisposable(
            HttpMethods.querySaleDeviceInfo(map)
                .subscribeWith(object : NullAbleObserver<BatterOrVehicleInfo>() {
                    override fun onSuccess(deviceDetail: BatterOrVehicleInfo?) {
                        batterOrVehicleInfo.value = deviceDetail
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        batterOrVehicleInfo.value = null
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    var servicePlanBeanLiveData = MutableLiveData<List<ServicePlanBean>?>()
    fun getServicePlanByName(name: String, pageIndex: Int, pageSize: Int) {
        val map = HashMap<String, Any>()
        map["keyword"] = name
        map["pageNum"] = pageIndex
        map["pageSize"] = pageSize
        addDisposable(
            HttpMethods.queryServicePlanByName(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<ServicePlanInfo>() {
                    override fun onSuccess(info: ServicePlanInfo?) {
                        servicePlanBeanLiveData.value = info?.list
                        loadState.value = State.getInstance(State.SUCCESS)
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

    // 分期方案
    var paymentPlanListLiveData = MutableLiveData<List<PaymentPlan>?>()
    fun getPaymentPlanList(amount: Double) {
        val map = HashMap<String, Any>()
        map["packageAmount"] = amount
        addDisposable(
            HttpMethods.getPaymentPlanList(map)
                .subscribeWith(object : NullAbleObserver<List<PaymentPlan>?>() {
                    override fun onSuccess(servicePlanBean: List<PaymentPlan>?) {
                        paymentPlanListLiveData.value = servicePlanBean
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

    val sellResultLiveData = MutableLiveData<Any?>()
    fun sellBind(
        address: String,
        birthday: String,
        cardImg: String,
        cardNum: String,
        email: String,
        firstName: String,
        lastName: String,
        idNumber: String,
        phone: String,
        payType: Int,
        planNo: String,
        personImg: String,
        servicePlanId: String,
        paySource: Int,
        deviceSn: String,
        deviceType: Int
    ) {
        val map = HashMap<String, Any>()
        map["address"] = address
        map["birthday"] = birthday
        map["cardImg"] = cardImg
        map["cardNum"] = cardNum
        map["email"] = email
        map["firstName"] = firstName
        map["lastName"] = lastName
        map["idNumber"] = idNumber
        map["phone"] = phone
        map["payType"] = payType
        map["planNo"] = planNo
        map["personImg"] = personImg
        map["infoCode"] = servicePlanId;
        map["paySource"] = paySource
        map["deviceSn"] = deviceSn
        map["type"] = deviceType
        addDisposable(
            HttpMethods.sellBind(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(any: Any?) {
                        sellResultLiveData.value = any ?: ""
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        sellResultLiveData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val rentResultLiveData = MutableLiveData<Any?>()
    fun rentBind(
        address: String,
        birthday: String,
        cardImg: String,
        cardNum: String,
        email: String,
        firstName: String,
        lastName: String,
        idNumber: String,
        phone: String,
        payType: Int,
        personImg: String,
        infoCode: String,
        paySource: Int,
        deviceSn: String,
        deviceType: Int
    ) {
        val map = HashMap<String, Any>()
        map["address"] = address
        map["birthday"] = birthday
        map["cardImg"] = cardImg
        map["cardNum"] = cardNum
        map["email"] = email
        map["firstName"] = firstName
        map["lastName"] = lastName
        map["idNumber"] = idNumber
        map["phone"] = phone
        map["payType"] = payType
        map["personImg"] = personImg
        map["infoCode"] = infoCode;
        map["paySource"] = paySource
        map["deviceSn"] = deviceSn
        map["type"] = deviceType
        addDisposable(
            HttpMethods.rentBind(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(any: Any?) {
                        rentResultLiveData.value = any ?: ""
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        rentResultLiveData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val purchasingUserLiveData = MutableLiveData<PurchasingUser?>()
    fun queryUserForSell(cardNum: String) {
        val map = HashMap<String, Any>()
        map["cardNum"] = cardNum
        addDisposable(
            HttpMethods.queryUserForSell(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<PurchasingUser>() {
                    override fun onSuccess(purchasing: PurchasingUser?) {
                        purchasingUserLiveData.value = purchasing
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        purchasingUserLiveData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    fun queryUserForRent(cardNum: String) {
        val map = HashMap<String, Any>()
        map["cardNum"] = cardNum
        addDisposable(
            HttpMethods.queryUserForRent(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<PurchasingUser>() {
                    override fun onSuccess(purchasing: PurchasingUser?) {
                        purchasingUserLiveData.value = purchasing ?: PurchasingUser()
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        purchasingUserLiveData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val uploadCardLiveData = MutableLiveData<String>()
    fun uploadCardImg(filePath: String) {
        addDisposable(
            Observable.just(filePath)
                .subscribeOn(Schedulers.single())
                .observeOn(Schedulers.io())
                .compose(LoadingTransHelper.loadingState(loadState))
                .flatMap {
                    val requestBody =
                        RequestBody.create(
                            "multipart/form-data".toMediaTypeOrNull(),
                            File(filePath)
                        )
                    val name = "${System.currentTimeMillis()}".plus(".jpg")
                    val part = MultipartBody.Part.createFormData("file", name, requestBody)
                    HttpMethods.uploadCardImg(part)
                }
                .subscribeWith(object : NullAbleObserver<String>() {
                    override fun onSuccess(t: String?) {
                        uploadCardLiveData.value = t ?: ""
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        );
    }

    val createSwapBindOrderLiveData = MutableLiveData<Any?>()
    fun createSwapBindOrder(infoCode: String, paySource: Int, cardNum: String) {
        val map = HashMap<String, Any>()
        map["infoCode"] = infoCode
        map["paySource"] = paySource
        map["cardNum"] = cardNum
        addDisposable(
            HttpMethods.createSwapBindOrder(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(any: Any?) {
                        createSwapBindOrderLiveData.value = any ?: ""
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        createSwapBindOrderLiveData.value = null
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