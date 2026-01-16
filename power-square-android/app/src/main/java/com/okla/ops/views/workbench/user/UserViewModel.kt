package com.okla.ops.views.workbench.user

import androidx.lifecycle.MutableLiveData
import com.base.common.net.BaseListResponse
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.esquare.ops.beans.WorkUserSearchBeanNew
import com.okla.ops.beans.PowerChangeBeanNew
import com.okla.ops.beans.UserDetail
import com.okla.ops.beans.UserInfo
import com.okla.ops.beans.UserPaymentRecord
import com.okla.ops.http.HttpMethods


class UserViewModel : BaseViewModel() {

    /**
     * 分页查询门店用户
     */
    var userListLiveData = MutableLiveData<BaseListResponse<UserInfo>>()
    fun getUserList(
        type: Int?,
        keyword: String?,
        pageNum: Int,
        pageSize: Int,
    ) {
        val map = java.util.HashMap<String, Any>()
        type?.let {
            map["type"] = it
        }
        keyword?.let {
            map["keyword"] = it
        }
        map["pageNum"] = pageNum
        map["pageSize"] = pageSize
        addDisposable(
            HttpMethods.getUserList(map)
                .subscribeWith(object : NullAbleObserver<BaseListResponse<UserInfo>>() {
                    override fun onSuccess(resp: BaseListResponse<UserInfo>?) {
                        userListLiveData.value = resp ?: BaseListResponse()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

    var userSearchListLiveData = MutableLiveData<BaseListResponse<UserInfo>>()
    fun getUserSearchList(
        keyword: String?,
        pageNum: Int,
        pageSize: Int,
    ) {
        val map = java.util.HashMap<String, Any>()
        if(keyword.isNullOrBlank()){
            return
        }
        map["keyword"] = keyword ?: ""
        map["pageNum"] = pageNum
        map["pageSize"] = pageSize
        addDisposable(
            HttpMethods.getUserListByKeyword(map)
                .subscribeWith(object : NullAbleObserver<BaseListResponse<UserInfo>>() {
                    override fun onSuccess(resp: BaseListResponse<UserInfo>?) {
                        userSearchListLiveData.value = resp ?: BaseListResponse()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    var userDetailLiveData = MutableLiveData<UserDetail>()
    fun getUserDetail(cardNum: String) {
        val map = HashMap<String, Any>()
        map["cardNum"] = cardNum
        addDisposable(
            HttpMethods.getUserDetail(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<UserDetail>() {
                    override fun onSuccess(userDetail: UserDetail?) {
                        userDetailLiveData.value = userDetail ?: UserDetail()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    /**
     * 分页查询用户订单信息
     */
    var userSaleOrderListLiveData = MutableLiveData<List<SaleOrder>?>()
    var userRentOrderListLiveData = MutableLiveData<List<RentOrder>?>()
    var userSwapOrderListLiveData = MutableLiveData<List<OtherOrder>?>()
    var saleOrderList = ArrayList<SaleOrder>()
    var rentOrderList = ArrayList<RentOrder>()
    var swapOrderList = ArrayList<OtherOrder>()

    fun getUserOrderList(
        orderType: Int,
        cardNum: String,
        pageNum: Int,
        pageSize: Int,
    ) {
        val map = java.util.HashMap<String, Any>()
        map["cardNum"] = cardNum
        map["pageNum"] = pageNum
        map["pageSize"] = pageSize
        addDisposable(
            HttpMethods.getUserOrderList(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<UserOrderResponse?>() {
                    override fun onSuccess(resp: UserOrderResponse?) {
                        if (resp == null) {
                            userSaleOrderListLiveData.value = null
                            userRentOrderListLiveData.value = null
                            userSwapOrderListLiveData.value = null
                        } else {
                            if (resp.list.isNullOrEmpty()) {
                                userSaleOrderListLiveData.value = null
                                userRentOrderListLiveData.value = null
                                userSwapOrderListLiveData.value = null
                            } else {
                                when (orderType) {
                                    //销售
                                    0 -> {
                                        saleOrderList.clear()
                                        resp.list.forEach {
                                            if (it.orderType == 1) {
                                                val saleOrder = it.saleOrder
                                                saleOrder?.attachment = it.attachment
                                                saleOrder?.orderNo = it.orderNo
                                                saleOrder?.payWay = it.payWay
                                                saleOrder?.orderAmount = it.orderAmount
                                                saleOrder?.createTime = it.createTime
                                                saleOrder?.let { it1 -> saleOrderList.add(it1) }
                                            }
                                        }
                                        userSaleOrderListLiveData.value = saleOrderList
                                    }
                                    //租赁
                                    1 -> {
                                        rentOrderList.clear()
                                        resp.list.forEach {
                                            if (it.orderType == 2) {
                                                val rentOrder = it.rentOrder
                                                rentOrder?.attachment = it.attachment
                                                rentOrder?.orderNo = it.orderNo
                                                rentOrder?.payWay = it.payWay
                                                rentOrder?.orderAmount = it.orderAmount
                                                rentOrder?.createTime = it.createTime
                                                rentOrder?.let { it1 -> rentOrderList.add(it1) }
                                            }
                                        }
                                        userRentOrderListLiveData.value = rentOrderList
                                    }
                                    //绑定
                                    2 -> {
                                        swapOrderList.clear()
                                        resp.list.forEach {
                                            if (it.orderType == 3) {
                                                val swapOrder = it.otherOrder
                                                swapOrder?.attachment = it.attachment
                                                swapOrder?.orderNo = it.orderNo
                                                swapOrder?.payWay = it.payWay
                                                swapOrder?.orderAmount = it.orderAmount
                                                swapOrder?.createTime = it.createTime
                                                swapOrder?.let { it1 ->
                                                    swapOrderList.add(
                                                        it1
                                                    )
                                                }
                                            }
                                        }
                                        userSwapOrderListLiveData.value = swapOrderList
                                    }
                                }
                            }
                        }

                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

    /**
     * 分页查询用户付款信息
     */
    var userPayListLiveData = MutableLiveData<MutableList<UserPaymentRecord>>()
    fun getUserPayList(
        cardNum: String,
        pageNum: Int,
        pageSize: Int,
    ) {
        val map = java.util.HashMap<String, Any>()
        map["cardNum"] = cardNum
        map["pageNum"] = pageNum
        map["pageSize"] = pageSize
        addDisposable(
            HttpMethods.getUserPayList(map)
                .subscribeWith(object : NullAbleObserver<BaseListResponse<UserPaymentRecord>>() {
                    override fun onSuccess(resp: BaseListResponse<UserPaymentRecord>?) {
                        userPayListLiveData.value = resp?.list ?: mutableListOf()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

//    /**
//     * 分页查询用户换电记录
//     */
//    var userSwapReocrLiveData = MutableLiveData<BatterySwapRecord?>()
//    fun getUserSwapRecord(
//        cardNum: String,
//        pageNum: Int,
//        pageSize: Int,
//    ) {
//        val map = java.util.HashMap<String, Any>()
//        map["cardNum"] = cardNum
//        map["pageNum"] = pageNum
//        map["pageSize"] = pageSize
//        addDisposable(
//            HttpMethods.getUserBatterySwapRecord(map)
//                .subscribeWith(object : NullAbleObserver<BatterySwapRecord>() {
//                    override fun onSuccess(resp: BatterySwapRecord?) {
//                        userSwapReocrLiveData.value = resp
//                    }
//
//                    override fun onFail(e: ErrorMsgBean?) {
//                        loadState.value =
//                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
//                    }
//                })
//        )
//    }


    var powerChangeListMutableLiveData: MutableLiveData<PowerChangeBeanNew?> = MutableLiveData()

    //获取换电记录列表
    fun getPowerChangeList(userId: String?, size: Int, page: Int): MutableLiveData<PowerChangeBeanNew?> {
        val map = java.util.HashMap<String, Any>()
        map["cardNum"] = userId?:""
        map["pageNum"] = page
        map["pageSize"] = size
        addDisposable(
            HttpMethods.getUserBatterySwapRecord(map)
                .subscribeWith(object : NullAbleObserver<PowerChangeBeanNew?>() {
                    override fun onSuccess(list: PowerChangeBeanNew?) {
                        powerChangeListMutableLiveData.setValue(list)
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        loadState.postValue(
                            State.getInstance(State.ERROR)
                                .setErrorMsgBean(e)
                                .setShowToast(true)
                        )
                    }
                })
        )
        return powerChangeListMutableLiveData
    }

}