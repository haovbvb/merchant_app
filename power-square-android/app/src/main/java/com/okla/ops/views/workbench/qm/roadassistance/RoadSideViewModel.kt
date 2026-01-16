package com.okla.ops.views.workbench.qm.roadassistance

import androidx.lifecycle.MutableLiveData
import com.base.common.image.compress.Compressor
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.RoadSideListResp
import com.okla.ops.beans.WorkOrderReport
import com.okla.ops.http.HttpMethods
import com.okla.ops.views.workbench.qm.RoadSideOrderDetail
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File

class RoadSideViewModel : BaseViewModel() {

    val roadSideListLiveData = MutableLiveData<RoadSideListResp?>()
    fun getRoadSideList(sheetStatus: Int?, page: Int, size: Int) {
        addDisposable(
            HttpMethods.queryRoadSideList(sheetStatus, page, size)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<RoadSideListResp>() {
                    override fun onSuccess(t: RoadSideListResp?) {
                        roadSideListLiveData.value = t
//                        loadState.value = State.getInstance(State.SUCCESS)
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val uploadAttachmentLiveData = MutableLiveData<String>()
    fun uplaodMaintenanceVoucher(filePath: String) {
        addDisposable(
            Observable.just(filePath)
                .subscribeOn(Schedulers.single())
                .observeOn(Schedulers.io())
                .flatMap {
                    val requestBody =
                        RequestBody.create(
                            "multipart/form-data".toMediaTypeOrNull(),
                            File(filePath)
                        )
                    val name = "${System.currentTimeMillis()}".plus(".jpg")
                    val part = MultipartBody.Part.createFormData("file", name, requestBody)
                    HttpMethods.uploadAttachment(part)
                }
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<String>() {
                    override fun onSuccess(t: String?) {
                        uploadAttachmentLiveData.value = t ?: ""
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                        loadState.postValue(State.getInstance(State.FINISH))
                    }
                })
        );
    }

    var genMaintenanceResultLiveData = MutableLiveData<Any?>()

    //产生车辆保养订单
    fun genMaintainRecord(
        attachment: String,
        cardNum: String,
        paySource: Int,
        price: String,
        remark: String,
        vehicleSn: String
    ) {
        addDisposable(
            HttpMethods.genMaintainRecord(attachment, cardNum, paySource, price, remark, vehicleSn)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(data: Any?) {
                        genMaintenanceResultLiveData.value = data
                        loadState.value = State.getInstance(State.SUCCESS)

                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val mRoadSideDetailLiveData = MutableLiveData<RoadSideOrderDetail?>()

    fun queryRoadOrderDetail(sheetNo: String) {
        addDisposable(
            HttpMethods.queryRoadOrderDetail(sheetNo)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<RoadSideOrderDetail>() {
                    override fun onSuccess(t: RoadSideOrderDetail?) {
                        mRoadSideDetailLiveData.value = t
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


    val mRoadSideUploadImageLiveData = MutableLiveData<String?>()
    fun uploadRoadSideImage(imagePath: String) {
        addDisposable(
            Observable.just(imagePath)
                .subscribeOn(Schedulers.single())
                .observeOn(Schedulers.io())
                .compose(LoadingTransHelper.loadingState(loadState))
                .flatMap { path ->
                    // 使用本地文件路径构造 File 对象
                    val originalFile = File(path)
                    // 压缩图片，返回压缩后的 File
                    val compressedFile = Compressor(

                    )
                        .compressToFile(originalFile)

                    // 根据压缩后的文件构建请求体
                    val requestBody =
                        compressedFile.asRequestBody("multipart/form-data".toMediaTypeOrNull())
                    // 使用当前时间戳+原始文件后缀作为文件名
                    val fileName = "${System.currentTimeMillis()}".plus(".jpg")
                    val part = MultipartBody.Part.createFormData(
                        "file",
                        fileName,
                        requestBody
                    )
                    // 调用上传接口
                    HttpMethods.uploadRoadSideImage(part)
                }
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<String>() {
                    override fun onSuccess(t: String?) {
                        mRoadSideUploadImageLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val dealRoadSideResultLiveData = MutableLiveData<String>()

    fun dealRoadSideOrder(workOrderReport: WorkOrderReport) {
        addDisposable(
            HttpMethods.dealRoadSideOrder(
                workOrderReport.imgList ?: "",
                workOrderReport.processDesc ?: "",
                workOrderReport.result ?: 0,
                workOrderReport.sheetNo ?: ""
            )
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(t: Any?) {
                        dealRoadSideResultLiveData.value = t.toString()
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


    var payRoadSideResultLiveData = MutableLiveData<Any?>()

    // 支付道路救援
    fun payRoadSideRecord(
        attachment: String,
        fee: String,
        payType: Int,
        recordNo: String
    ) {
        addDisposable(
            HttpMethods.payRoadSide(attachment, fee, payType, recordNo)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(data: Any?) {
                        payRoadSideResultLiveData.value = "success"
                        loadState.value = State.getInstance(State.SUCCESS)

                    }

                    override fun onFail(e: ErrorMsgBean) {
                        payRoadSideResultLiveData.value = null
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }


    //用户查询模块- 上传凭证
    val UserUploadAttachmentLiveDATA = MutableLiveData<String>()
    fun userUplaodAttachment(filePath: String) {
        addDisposable(
            Observable.just(filePath)
                .subscribeOn(Schedulers.single())
                .observeOn(Schedulers.io())
                .flatMap {
                    // 使用本地文件路径构造 File 对象
                    val originalFile = File(filePath)
                    // 压缩图片，返回压缩后的 File
                    val compressedFile = Compressor(

                    )
                        .compressToFile(originalFile)

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
                    HttpMethods.userUploadAttachment(part)
                }
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<String>() {
                    override fun onSuccess(t: String?) {
                        UserUploadAttachmentLiveDATA.value = t ?: ""
//                        loadState.postValue(State.getInstance(State.SUCCESS))
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                        loadState.postValue(State.getInstance(State.FINISH))
                    }
                })
        );
    }

    //用户查询模块-确认缴费
    var confirmPayResultLiveData = MutableLiveData<Any?>()
    fun userConfirmPayOrder(
        attachment: String,
        cardNum: String,
        orderNo: String,
    ) {
        val map = HashMap<String, Any>()
        map["attachment"] = attachment
        map["cardNum"] = cardNum
        map["orderNo"] = orderNo
        addDisposable(
            HttpMethods.userConfirmPayOrder(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(data: Any?) {
                        confirmPayResultLiveData.value = "success"
                        loadState.value = State.getInstance(State.SUCCESS)

                    }

                    override fun onFail(e: ErrorMsgBean) {
                        confirmPayResultLiveData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }
}
