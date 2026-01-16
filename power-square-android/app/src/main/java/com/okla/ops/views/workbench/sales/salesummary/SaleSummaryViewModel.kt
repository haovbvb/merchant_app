package com.okla.ops.views.workbench.sales.salesummary

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.OrderItem
import com.okla.ops.beans.SaleSumPageData
import com.okla.ops.beans.SalesBarData
import com.okla.ops.beans.SellDataListResponse
import com.okla.ops.http.HttpMethods
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class SaleSummaryViewModel : BaseViewModel() {
    val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")

    // 结束日期：今天
    val endDate = LocalDate.now()

    // 开始日期：30 天前（包括今天一共 30 天）
    val startDate = endDate.minusDays(29)
    private fun getLast30days(): MutableList<String> {
        val times2 = mutableListOf<String>()
        for (i in 0 until 30) {
            val date = endDate.minusDays(i.toLong())
            times2.add(date.format(formatter))
        }
        times2.reverse()
        return times2
    }

    //    val times = mutableListOf(
//        "2024-06", "2024-07", "2024-08", "2024-09",
//        "2024-10", "2024-11", "2024-12", "2025-01",
//        "2025-02", "2025-03", "2025-04", "2025-05"
//    )
    val times = getLast30days()
    val testData = SalesBarData(
        timeList = times,
        numList = mutableListOf(
            110, 0, 0, 130,
            200, 0, 0, 0,
            320, 130, 120, 0,
            200, 0, 0, 0,
            130, 120, 0,
            20, 0, 130,
            200, 0, 0, 0,
            320, 130, 120, 66
        ),
        amountList = mutableListOf(
            0.0, 160.0, 156.0, 130.0,
            200.0, 0.0, 200.0, 0.0,
            320.0, 0.0, 120.0, 0.0,
            0.0, 130.0, 100.0, 90.0,
            200.0, 0.0, 0.0, 0.0,
            320.0, 130.0, 120.0, 66.0,
            0.0, 130.0, 100.0, 90.0,
            200.0, 0.0
        )
    )
    var sellStaticDateLiveData = MutableLiveData<SalesBarData?>()
    fun get12MonthOrderData(

    ) {
//        sellStaticDateLiveData.value = testData
        addDisposable(
            HttpMethods.get12MonthOrderData()
                .subscribeWith(object : NullAbleObserver<SalesBarData>() {
                    override fun onSuccess(staticSaleShopDate: SalesBarData?) {
                        val list =  (DateTimeUtils.getLast12Months(LanguageUtils.LanguageUtil.getLocalByLanguage()))
                        list.reverse()
                        staticSaleShopDate?.timeList=list
                        sellStaticDateLiveData.value =
                            staticSaleShopDate
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

    //销售统计页面排名等数据
    var sellPageRankLiveData = MutableLiveData<SaleSumPageData?>()
    fun getSellPageRankData(startDate: String, endDate: String) {
        val map = HashMap<String, Any>()
        map["startDate"] = startDate
        map["endDate"] = endDate
        addDisposable(
            HttpMethods.getSellPageRankData(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<SaleSumPageData>() {
                    override fun onSuccess(data: SaleSumPageData?) {
                        sellPageRankLiveData.value =
                            data
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

    var shopSellDataLiveData = MutableLiveData<List<OrderItem>?>()
    fun queryShopSellData(
        startDate: String,
        endDate: String,
        payWay: Int?,
        pageNum: Int,
        pageSize: Int,
        getDataType:Int
    ) {
        val map = HashMap<String, Any>()
        map["startDate"] = startDate
        map["endDate"] = endDate
        payWay?.let {
            map["payWay"] = payWay
        }
        map["pageNum"] = pageNum
        map["pageSize"] = pageSize
        addDisposable(
            HttpMethods.getShopSellData(map,getDataType)
                ?.compose(LoadingTransHelper.loadingState(loadState))
                ?.subscribeWith(object : NullAbleObserver<SellDataListResponse>() {
                    override fun onSuccess(data: SellDataListResponse?) {
                        shopSellDataLiveData.value = data?.list
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }


}