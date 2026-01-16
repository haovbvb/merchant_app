package com.okla.ops.views.workbench.sales.offlineregister

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.DataStoreUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.AreaCountry
import com.okla.ops.beans.AreaCountryResp
import com.okla.ops.http.HttpMethods
import okhttp3.MultipartBody

class OfflineUserRegisterViewModel : BaseViewModel() {

    var mSelectedPhoneCountryAreaLiveData = MutableLiveData<AreaCountry>()

    /**
     * 设置当前国家地区
     */
    fun setCurrentCountryArea(country: AreaCountry) {
//        mTenantIdLiveData.value = country.tenantId ?: BuildConfig.TENANT_ID
        mSelectedPhoneCountryAreaLiveData.value = country
    }

    var mCountryAreaListLiveData = MutableLiveData<List<AreaCountry>>()

    /**
     * 获取手机区号配置
     */
    fun getCountryAreaList() {
        if (mCountryAreaListLiveData.value.isNullOrEmpty()) {
            addDisposable(
                HttpMethods.getAreaCodeConfig().compose(
                    LoadingTransHelper.loadingState(loadState)
                ).subscribeWith(object : NullAbleObserver<AreaCountryResp>() {
                    override fun onSuccess(areaCountryResp: AreaCountryResp) {
                        mCountryAreaListLiveData.value = areaCountryResp.list ?: mutableListOf()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
            )
        }
    }

    var mPhoneLiveData = MutableLiveData<String>()

    /**
     * 设置手机号码
     */
    fun setPhone(phone: String) {
        mPhoneLiveData.value = phone
    }

    var mTenantIdLiveData = MutableLiveData<String>()


    var mSendSmsLiveData = MutableLiveData<Boolean>()

    /**
     * 发送短信验证码
     * @param type 业务类型：1注册，2重置密码，3登录
     */
    fun sendSms(phone: String, type: Int) {
        val hashMap = HashMap<String, Any>()
        hashMap["phone"] = phone
        hashMap["type"] = type
        addDisposable(
            HttpMethods.sendSms(hashMap).compose(
                LoadingTransHelper.loadingState(loadState)
            ).subscribeWith(object : NullAbleObserver<Any>() {
                override fun onSuccess(sendSms: Any?) {
                    mSendSmsLiveData.value = true
                    loadState.value = State.getInstance(State.SUCCESS).setShowToast(true)
                }

                override fun onFail(e: ErrorMsgBean?) {
                    mSendSmsLiveData.value = false
                    loadState.value =
                        State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                }
            })
        )
    }

    var mRegisterLiveData = MutableLiveData<Any>()

    /**
     * 注册
     */
    fun register(data: List<MultipartBody.Part>) {
        addDisposable(
            HttpMethods.offlineRegister(data)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(register: Any?) {
                        loadState.value = State.getInstance(State.SUCCESS).setShowToast(true)
                        mRegisterLiveData.value = register ?: Any()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }
}