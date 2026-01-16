package com.okla.ops.views.workbench.sales.depositrefund

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.http.HttpMethods

class DepositRefundViewModel : BaseViewModel() {
    var refundInfoLiveData = MutableLiveData<DepositRefundInfoBean?>()
    var refundOrderListLiveData = MutableLiveData<List<Deposit>?>()
    fun getRefundInfoByUserId(cardNum: String) {
        addDisposable(
            HttpMethods.getDepositRefundInfo(cardNum)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<DepositRefundInfoBean?>() {
                    override fun onSuccess(refundInfo: DepositRefundInfoBean?) {
                        refundInfoLiveData.value = refundInfo
                        if (!refundInfo?.depositList.isNullOrEmpty()) {
                            refundOrderListLiveData.value = refundInfo?.depositList
                        } else {
                            refundOrderListLiveData.value = null
                        }
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        refundInfoLiveData.value = null
                        refundOrderListLiveData.value = null
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    var refundResultLiveData = MutableLiveData<Any?>()
    fun refundDeposit(cardNum: String, orderNo: String, remark: String,recoveryFlag:Int) {
        val map = HashMap<String, Any>()
        map["cardNum"] = cardNum
        map["orderNo"] = orderNo
        if (!remark.isNullOrBlank()) {
            map["remark"] = remark
        }
        map["recoveryFlag"]=recoveryFlag
        addDisposable(
            HttpMethods.refundDeposit(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(result: Any?) {
                        refundResultLiveData.value = "success"
                        loadState.postValue(State.getInstance(State.SUCCESS))
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        refundResultLiveData.value = null
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }
}