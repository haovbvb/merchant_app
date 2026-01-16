package com.okla.ops.views.workbench.qm.maintenance

import android.text.TextUtils
import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.BookMaintenanceBean
import com.okla.ops.beans.VehicleRepairListResp
import com.okla.ops.http.HttpMethods

class MaintenanceBookViewModel : BaseViewModel() {

    var mGetDeviceSn = MutableLiveData<String>()

    fun getDeviceSn(content: String) {
        addDisposable(
            HttpMethods.getDeviceSn(2, content)
                .subscribeWith(object : NullAbleObserver<String>() {

                    override fun onSuccess(data: String) {
                        if (TextUtils.isEmpty(data)) {
                            mGetDeviceSn.value = content
                        } else {
                            mGetDeviceSn.value = data
                        }
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
    }

    var mBookMaintenance = MutableLiveData<BookMaintenanceBean?>()

    fun queryAppointment(sn: String) {
        addDisposable(
            HttpMethods.queryAppointment(sn)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<BookMaintenanceBean>() {

                    override fun onSuccess(data: BookMaintenanceBean) {
                        mBookMaintenance.value = data;
                        loadState.value = State.getInstance(State.SUCCESS)
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        mBookMaintenance.value = null
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    var mVehicleRepairList = MutableLiveData<VehicleRepairListResp>()

    fun queryRepairRecordList(sn: String, page: Int, pageSize: Int) {
        addDisposable(
            HttpMethods.queryRepairRecordList(sn, page, pageSize)
                .subscribeWith(object : NullAbleObserver<VehicleRepairListResp>() {

                    override fun onSuccess(data: VehicleRepairListResp) {
                        mVehicleRepairList.value = data;
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
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
                .subscribeWith(object : NullAbleObserver<Any?>() {

                    override fun onSuccess(data: Any?) {
                        genMaintenanceResultLiveData.value = data
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
    }

}