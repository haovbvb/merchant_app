package com.okla.ops.views.workbench.sales.installmentPayment

import androidx.lifecycle.MutableLiveData
import com.base.common.image.compress.Compressor
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.InstallmentPaymentResponse
import com.okla.ops.beans.PeriodOrder
import com.okla.ops.http.HttpMethods
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File

class InstallmentViewModel : BaseViewModel() {
    var installMmentInfoLiveData = MutableLiveData<InstallmentPaymentResponse?>()
    var orderListLiveData = MutableLiveData<List<PeriodOrder>?>()
    fun getInstallmentPayInfo(cardNum: String) {
        addDisposable(
            HttpMethods.getInstallmentInfo(cardNum)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<InstallmentPaymentResponse?>() {
                    override fun onSuccess(info: InstallmentPaymentResponse?) {
                        if (info != null) {
                            installMmentInfoLiveData.value = info
                            orderListLiveData.value = info.periodOrderList
                        } else {
                            installMmentInfoLiveData.value = null
                            orderListLiveData.value = null
                        }
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        installMmentInfoLiveData.value = null
                        orderListLiveData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val uploadAttachmentLiveData = MutableLiveData<String>()
    fun uploadAttachment(filePath: String) {
        addDisposable(
            Observable.just(filePath)
                .subscribeOn(Schedulers.single())
                .observeOn(Schedulers.io())
                .flatMap {
                    // 使用本地文件路径构造 File 对象
                    val originalFile = File(filePath)
                    // 压缩图片，返回压缩后的 File
                    val compressedFile = Compressor().compressToFile(originalFile)
                    // 根据压缩后的文件构建请求体
                    val requestBody =
                        compressedFile.asRequestBody("multipart/form-data".toMediaTypeOrNull())
//                    val requestBody =
//                        RequestBody.create(
//                            "multipart/form-data".toMediaTypeOrNull(),
//                            File(filePath)
//                        )
                    val name = "${System.currentTimeMillis()}".plus(".jpg")
                    val part = MultipartBody.Part.createFormData("file", name, requestBody)
                    HttpMethods.uploadAttachment(part)
                }
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<String>() {
                    override fun onSuccess(t: String?) {
                        uploadAttachmentLiveData.value = t ?: ""
//                        loadState.postValue(State.getInstance(State.SUCCESS))
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                        loadState.postValue(State.getInstance(State.FINISH))
                    }
                })
        );
    }

    // 分期缴纳
    var payPeriodResultLiveData = MutableLiveData<Any?>()
    fun payPeriod(cardNum: String, attachment: String, orderNo: String, period: Int) {
        val map = HashMap<String, Any>()
        map["cardNum"] = cardNum
        map["attachment"] = attachment
        map["orderNo"] = orderNo
        map["period"] = period
        addDisposable(
            HttpMethods.payPerido(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(info: Any?) {
                        payPeriodResultLiveData.value = info?:""
                        loadState.postValue(State.getInstance(State.SUCCESS))
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        payPeriodResultLiveData.value = null
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }
}