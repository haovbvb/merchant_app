package com.okla.ops.views.workbench

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.BatteryType
import com.okla.ops.beans.CarType
import com.okla.ops.beans.StationType
import com.okla.ops.http.HttpMethods

class WorkbenchViewModel : BaseViewModel() {

    val carTypeListLiveData = MutableLiveData<MutableList<CarType>?>()
    val batteryTypeListLiveData = MutableLiveData<MutableList<BatteryType>?>()
    val stationTypeListLiveData = MutableLiveData<MutableList<StationType>?>()
    fun getCarTypeList(): MutableLiveData<MutableList<CarType>?> {
        addDisposable(
            HttpMethods.getCarTypeList()
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<MutableList<CarType>?>() {
                    override fun onSuccess(list: MutableList<CarType>?) {
                        carTypeListLiveData.value = list ?: mutableListOf()
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        carTypeListLiveData.value = null
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
        return carTypeListLiveData
    }

    fun getBatteryTypeList(): MutableLiveData<MutableList<BatteryType>?> {
        addDisposable(
            HttpMethods.getBatteryTypeList()
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<MutableList<BatteryType>>() {
                    override fun onSuccess(list: MutableList<BatteryType>?) {
                        batteryTypeListLiveData.value = list ?: mutableListOf()
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        batteryTypeListLiveData.value = null
                    }
                })
        )
        return batteryTypeListLiveData
    }

    fun getStationTypeList(): MutableLiveData<MutableList<StationType>?> {
        addDisposable(
            HttpMethods.getStationTypeList()
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<MutableList<StationType>>() {
                    override fun onSuccess(list: MutableList<StationType>?) {
                        stationTypeListLiveData.value = list ?: mutableListOf()
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        stationTypeListLiveData.value = null
                    }
                })
        )
        return stationTypeListLiveData
    }

    var mSaleDataLiveData: MutableLiveData<SaleData?> = MutableLiveData()

    fun getSaleData(): MutableLiveData<SaleData?> {
        addDisposable(
            HttpMethods.getSaleData()
                .subscribeWith(object : NullAbleObserver<SaleData?>() {
                    override fun onSuccess(saleData: SaleData?) {
                        mSaleDataLiveData.value = saleData
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        mSaleDataLiveData.value = null
                    }
                })
        )
        return mSaleDataLiveData
    }

//    val uploadProofFileLiveData = MutableLiveData<String>()
//    val progressLiveData = MutableLiveData<Int>()
//    fun uploadProofFile(filePath: String) {
//        addDisposable(
//            Observable.just(filePath)
//                .subscribeOn(Schedulers.single())
//                .observeOn(Schedulers.io())
////                .compose(LoadingTransHelper.loadingState(loadState))
//                .flatMap {
//                    val requestBody =
//                        RequestBody.create(
//                            "multipart/form-data".toMediaTypeOrNull(),
//                            File(filePath)
//                        )
//                    //再包一层 CountingRequestBody
//                    val progressBody = CountingRequestBody(requestBody) { written, total ->
//                        val percent = (written * 100 / total).toInt()
//                        // 把 percent 发给 ViewModel（LiveData/StateFlow）
//                        progressLiveData.value = percent
//                    }
//                    val name = "${System.currentTimeMillis()}android${filePath}"
//                    val part = MultipartBody.Part.createFormData("file", name, progressBody)
//                    HttpMethods.uploadProof(part)
//                }
//                .subscribeWith(object : NullAbleObserver<String>() {
//                    override fun onSuccess(t: String?) {
//                        uploadProofFileLiveData.value = t ?: ""
//                    }
//
//                    override fun onFail(e: ErrorMsgBean?) {
//                        ToastUtils.showShort(e?.msg)
//                    }
//                })
//        );
//    }

//    val uploadProofLiveData = MutableLiveData<String>()
//
//    fun uploadProof(url: String, type: Int): MutableLiveData<String> {
//        addDisposable(
//            HttpMethods.uploadProof(url, type)
//                .compose(LoadingTransHelper.loadingState(loadState))
//                .subscribeWith(object : NullAbleObserver<String>() {
//                    override fun onSuccess(str: String?) {
//                        uploadProofLiveData.value = str ?: ""
//                        loadState.postValue(State.getInstance(State.SUCCESS))
//                    }
//
//                    override fun onFail(e: ErrorMsgBean) {
//                        ToastUtils.showShort(e.msg)
//                        loadState.postValue(State.getInstance(State.ERROR))
//                    }
//                })
//        )
//        return uploadProofLiveData
//    }

}