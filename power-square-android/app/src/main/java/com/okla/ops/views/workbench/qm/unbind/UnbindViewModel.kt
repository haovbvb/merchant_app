package com.okla.ops.views.workbench.qm.unbind

import android.text.TextUtils
import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.BatteryUnbindBean
import com.okla.ops.http.HttpMethods
import com.okla.ops.views.workbench.qm.unbind.net.UnbindHttpMethods


/**
 * @Date: 2021/8/17 16:46
 * @Author: Craz
 * @Description:
 * @Version:
 */
class UnbindViewModel : BaseViewModel() {

    val unBindDeviceLiveData= MutableLiveData<Any?>()
    val mGetDeviceSn = MutableLiveData<String>()

    fun unBindDevice(
        sn: String,
        cardNum: String,
        checkRemark: String,
        remark: String,
    ) {
        addDisposable(
            UnbindHttpMethods.unBindDevice(sn, cardNum, checkRemark, remark)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(data: Any?) {
                        unBindDeviceLiveData.value =data
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

//    fun unBindBattery(
//        batterySnList: Array<String>,
//        cardNum: String,
//        reason: String,
//        checkBatRemark: String
//    ) {
//        addDisposable(
//            UnbindHttpMethods.unBindBattery(batterySnList, cardNum, reason, checkBatRemark)
//                .subscribeWith(object : NullAbleObserver<BatteryUnbindBean>() {
//                    override fun onSuccess(data: BatteryUnbindBean?) {
//                        unBindData.value = ""
//                    }
//
//                    override fun onFail(e: ErrorMsgBean) {
//                        ToastUtils.showShort(e.msg)
//                    }
//                })
//        )
//    }
//
//    fun unBindCar(
//        cardNum: String,
//        scooterSn: String,
//        remark: String,
//        checkCarRemark: String,
//        appointmentNo: String?
//    ) {
//        addDisposable(
//            appointmentNo?.let {
//                UnbindHttpMethods
//                    .unBindCar(cardNum, scooterSn, remark, checkCarRemark, it)
//                    .subscribeWith(object : NullAbleObserver<Any>() {
//                        override fun onSuccess(data: Any?) {
//                            unBindData.value = ""
//                        }
//
//                        override fun onFail(e: ErrorMsgBean) {
//                            ToastUtils.showShort(e.msg)
//                        }
//                    })
//            }
//        )
//    }

    fun getDeviceSn(type: Int, content: String) {
        addDisposable(
            HttpMethods.getDeviceSn(type, content)
                .subscribeWith(object : NullAbleObserver<String>() {
                    override fun onSuccess(str: String?) {
                        str?.let {

                            if (TextUtils.isEmpty(it)) {
                                mGetDeviceSn.value = content
//                        ToastUtils.showShort(R.string.qr_code_error);
                            } else {
                                mGetDeviceSn.value = it
                            }

                        }
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        mGetDeviceSn.value = ""
                        ToastUtils.showShort(e?.msg)
                    }
                })
        )
    }

    val unCompletedCarOrderData = MutableLiveData<String>()

    /**
     * 检测是否存在尚未完结预约保养单
     */
    fun checkExistUnCompletedCarOrder(userId: String, sn: String) {
        addDisposable(
            UnbindHttpMethods.checkExistUnCompletedCarOrder(userId, sn)
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(data: Any?) {
                        if (data == null||data=="{}") {
                            unCompletedCarOrderData.value = "";
                        } else {
                            unCompletedCarOrderData.value = data.toString()
                        }
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        unCompletedCarOrderData.value = "";
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
    }

}