package com.okla.ops.views.workbench.warehouse.deviceinventory

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.DeviceInventoryData
import com.okla.ops.beans.DeviceInventoryDetail
import com.okla.ops.beans.DeviceInventoryResp
import com.okla.ops.beans.ScanDeviceBean
import com.okla.ops.beans.WarehouseBean
import com.okla.ops.http.HttpMethods

class DeviceInventoryViewModel : BaseViewModel() {

    var mDeviceInventoryRespLiveData = MutableLiveData<DeviceInventoryResp?>()

    fun queryDeviceInventoryPage(page: Int, size: Int, keyword: String, status: Int?) {
        addDisposable(
            HttpMethods.queryDeviceInventoryPage(page, size, keyword, status)
                .subscribeWith(object : NullAbleObserver<DeviceInventoryResp>() {
                    override fun onSuccess(t: DeviceInventoryResp?) {
                        mDeviceInventoryRespLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }


    var myWarehouseBeanLiveData = MutableLiveData<WarehouseBean?>()

    fun queryMyWarehouseInfo() {
        addDisposable(
            HttpMethods.queryMyWarehouseInfo()
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<WarehouseBean>() {
                    override fun onSuccess(t: WarehouseBean?) {
                        myWarehouseBeanLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }


    var mStartInventoryLiveData = MutableLiveData<DeviceInventoryDetail?>()
    var mStartInventoryFailureLiveData = MutableLiveData<Any>()

    fun startInventory(deviceTyp: Int, warehouseNo: String) {
        addDisposable(
            HttpMethods.startInventory(deviceTyp, warehouseNo)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<DeviceInventoryDetail>() {
                    override fun onSuccess(t: DeviceInventoryDetail?) {
                        mStartInventoryLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        mStartInventoryFailureLiveData.value = Any()
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mRevokeInventoryLiveData = MutableLiveData<Any>()

    fun revokeInventory(inventoryNo: String) {
        addDisposable(
            HttpMethods.evokeInventory(inventoryNo)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(t: Any?) {
                        mRevokeInventoryLiveData.value = t ?: Any()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mCompleteInventoryLiveData = MutableLiveData<Any>()

    fun completeInventory(inventoryNo: String) {
        addDisposable(
            HttpMethods.completeInventory(inventoryNo)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(t: Any?) {
                        mCompleteInventoryLiveData.value = t ?: Any()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mQueryInventoryLiveData = MutableLiveData<DeviceInventoryDetail?>()

    fun queryInventory(inventoryNo: String, page: Int, size: Int) {
        addDisposable(
            HttpMethods.queryInventory(inventoryNo, page, size)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<DeviceInventoryDetail>() {
                    override fun onSuccess(t: DeviceInventoryDetail?) {
                        mQueryInventoryLiveData.value = t
                        if (page == 1) {
                            clearTempDeviceInventoryList()
                            pendingStatusUpdates.clear()
                            addedCount = 0
                        }
                        t?.detailPage?.list?.let {
                            addTempDeviceInventoryList(it)
                            it.forEach {
                                val scannedStatus = pendingStatusUpdates.remove(it.deviceSn)
                                if (scannedStatus != null) {
                                    // 如果该设备曾被扫码过（但尚未出现在列表中），就补上状态
                                    it.status = scannedStatus
                                }
                            }

                        }
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    private var tempDeviceInventoryList = mutableListOf<DeviceInventoryData>()


    fun addTempDeviceInventoryList(list: List<DeviceInventoryData>) {
        tempDeviceInventoryList.addAll(list)
    }

    fun clearTempDeviceInventoryList() {
        tempDeviceInventoryList.clear()
    }


    /**
     * 处理扫码返回的盘盈数据
     */
    fun handleScanSurplus(snListSurplus: MutableList<DeviceInventoryData>): List<DeviceInventoryData> {
        val resultList = mutableListOf<DeviceInventoryData>()
        for (bean in snListSurplus) {
            val (sn, statusStr) = bean.deviceSn.split(",")
            val status = statusStr.toInt()
            // 盘盈：如不存在才新增
            if (tempDeviceInventoryList.none { it.deviceSn == sn }) {
                val newItem = DeviceInventoryData(
                    "", sn, "", "", 2
                )
                resultList.add(0, newItem)  // 加到最前面
            }
        }
        return resultList
    }


    //盘盈数量
    var addedCount = 0
    private val pendingStatusUpdates = mutableMapOf<String, Int>()

    /**
     * 处理扫码结果：更新 totalList，并返回哪些位置要刷新、哪些新条目要插入
     */
    fun handleScan(snList: List<ScanDeviceBean>): ScanResult {
        var firstPos = -1
        val updated = mutableListOf<Int>()
        val toAdd = mutableListOf<DeviceInventoryData>()

        snList.forEach { bean ->
            val (sn, statusStr) = bean.sn!!.split(",")
            val status = statusStr.toInt()
            // 在 totalList 中查找
            val idx = tempDeviceInventoryList.indexOfFirst { it.deviceSn == sn }

            when (status) {
                1 -> {
                    // 记录补丁 （扫码过来时候数量可能在尚未加载出来的页码里面 例如现在全量数据只有第一页，但是扫码的数据在 第二页或者其他页）
                    pendingStatusUpdates[sn] = status
                    // 已盘点：如果找得到，就更新状态并记录位置
                    if (idx != -1) {
                        tempDeviceInventoryList[idx].status = 1
                        updated += idx
                        if (firstPos == -1) firstPos = idx
                    }
                }

                2 -> {
                    // 盘盈：如果列表中不存在，则新增到最前面
                    if (idx == -1) {
                        val newItem = DeviceInventoryData(
                            "",               // 根据实际填充
                            deviceSn = sn,
                            "",             // 根据实际填充
                            "",            // 根据实际填充
                            2
                        )
                        tempDeviceInventoryList.add(0, newItem)
                        toAdd += newItem
                        addedCount += 1
                        if (firstPos == -1) firstPos = 0
                    }
                }
            }
        }

        return ScanResult(
            firstPos = firstPos,
            updatedPositions = updated,
            newItems = toAdd
        )
    }

    data class ScanResult(
        val firstPos: Int,              // 第一个找到并更新/新增的全局下标
        val updatedPositions: List<Int>,// 需要调用 notifyItemChanged 的全局下标列表
        val newItems: List<DeviceInventoryData> // 需要插入到列表开头的新条目
    )
}