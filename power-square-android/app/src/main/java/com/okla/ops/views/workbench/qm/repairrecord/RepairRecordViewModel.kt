package com.okla.ops.views.workbench.qm.repairrecord

import android.net.Uri
import android.text.TextUtils
import androidx.lifecycle.MutableLiveData
import com.base.common.CommonApplication
import com.base.common.image.compress.Compressor
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.base.library.utils.FileUtils
import com.okla.ops.beans.DeviceFix
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew
import com.okla.ops.beans.ImageBean
import com.okla.ops.http.HttpMethods
import com.okla.ops.views.workbench.qm.repairrecord.net.RepairRecordHttpMethods
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody

class RepairRecordViewModel : BaseViewModel() {

    var mGetFixDeviceInfo = MutableLiveData<DeviceFix?>()

    fun getFixDeviceInfo(deviceSn: String) {
        addDisposable(
            RepairRecordHttpMethods.getFixDeviceInfo(deviceSn)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<DeviceFix?>() {

                    override fun onSuccess(data: DeviceFix?) {
                        mGetFixDeviceInfo.value = data
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        mGetFixDeviceInfo.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    var mGetDeviceSn = MutableLiveData<String>()

    fun getDeviceSn(content: String) {
        addDisposable(
            HttpMethods.getDeviceSn(2, content)
                .subscribeWith(object : NullAbleObserver<String>() {

                    override fun onSuccess(data: String?) {
                        if (TextUtils.isEmpty(data)) {
                            mGetDeviceSn.value = content
                        } else {
                            mGetDeviceSn.value = data ?: ""
                        }
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    var mEquipmentDeviceSearchBeanData = MutableLiveData<EquipmentDeviceSearchBeanNew?>()

    //获取搜索设备列表  type '设备类型 0：电池  1：电柜 4 车辆
    fun getDeviceListSearchData(inputData: String) {
        addDisposable(
            RepairRecordHttpMethods.getDeviceListSearchDataNew(inputData)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<EquipmentDeviceSearchBeanNew?>() {
                    override fun onSuccess(list: EquipmentDeviceSearchBeanNew?) {
                        if (list != null) {
                            mEquipmentDeviceSearchBeanData.setValue(list)
                        } else {
                            mEquipmentDeviceSearchBeanData.setValue(null)
                        }
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        mEquipmentDeviceSearchBeanData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    var mAddFixDeviceResult = MutableLiveData<Any>()

    fun addFixDeviceRecord(
        cardNum: String,
        deviceSn: String,
        deviceType: Int,
        fixItem: String,
        remark: String,
        result: String
    ) {
        addDisposable(
            RepairRecordHttpMethods
                .addFixDeviceRecord(cardNum, deviceSn, deviceType, fixItem, remark, result)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {

                    override fun onSuccess(data: Any?) {
                        mAddFixDeviceResult.value = data ?: Any()
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val mUploadImageLiveData = MutableLiveData<String?>()
    val mImageFileLiveData = MutableLiveData<ImageBean>()

    fun uploadImage(image: ImageBean) {
        addDisposable(
            Observable.just(image)
                .subscribeOn(Schedulers.single())
                .observeOn(Schedulers.io())
                .compose(LoadingTransHelper.loadingState(loadState))
                .flatMap {
                    val file = Compressor().compressToFile(
                        it.fileUri, String.format(
                            "compress_%s", FileUtils.getFileRealNameFromUri(
                                CommonApplication.getInstance(),
                                it.fileUri
                            )
                        )
                    )
                    val requestBody =
                        RequestBody.create("multipart/form-data".toMediaTypeOrNull(), file)
                    val name = "${System.currentTimeMillis()}".plus(".jpg")

                    val part = MultipartBody.Part.createFormData("file", name, requestBody)
                    RepairRecordHttpMethods.uploadFixImg(part)
                }
                .subscribeWith(object : NullAbleObserver<String>() {
                    override fun onSuccess(t: String?) {
                        mImageFileLiveData.value = image
                        mUploadImageLiveData.value = t
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