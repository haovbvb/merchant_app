package com.okla.ops.views

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.City
import com.okla.ops.http.HttpMethods
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.File

open class MainViewModel : BaseViewModel() {

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

}