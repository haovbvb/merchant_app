package com.okla.ops.views.workbench.vcu

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew
import com.okla.ops.ble.OtaUtil
import com.okla.ops.ble.enums.CommandEnum
import com.okla.ops.http.HttpMethods
import com.okla.ops.views.workbench.equipmentsearch.net.DeviceSearchHttpMethods
import java.io.File
import java.util.concurrent.ConcurrentHashMap

class VcuViewModel : BaseViewModel() {

    // 搜索设备
    var mEquipmentDeviceSearchBeanData: MutableLiveData<EquipmentDeviceSearchBeanNew?> =
        MutableLiveData()

    fun searchDeviceBySn(sn: String) {
        /*val devInfo = DeviceInfo()
        devInfo.deviceId = sn
        devInfo.ctrlId = sn
        devInfo.onlineStatus = 0
        mEquipmentDeviceSearchBeanData.value = EquipmentDeviceSearchBeanNew(deviceInfo = devInfo, type = 4)*/
        addDisposable(
            DeviceSearchHttpMethods.getDeviceListSearchDataNew(sn)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<EquipmentDeviceSearchBeanNew?>() {
                    override fun onSuccess(t: EquipmentDeviceSearchBeanNew?) {
                        mEquipmentDeviceSearchBeanData.value = t
                        loadState.value =
                            State.getInstance(State.SUCCESS)
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

    /**
     * 发送车辆指令
     */
    var mSendCommandToCarLiveData = MutableLiveData<Any>()
    fun sendCommandToCar(cmd: Int, devId: String) {
        val hashMap = HashMap<String, Any>()
        hashMap["cmd"] = cmd
        hashMap["devId"] = devId
        addDisposable(
            HttpMethods.sendCommandToCar(hashMap)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(t: Any?) {
                        mSendCommandToCarLiveData.value = cmd
                        loadState.value =
                            State.getInstance(State.SUCCESS)

                        addCommandHistory(
                            VcuDataHistory(
                                2,
                                1,
                                CommandEnum.getCommandByCmd(cmd),
                                "success",
                                System.currentTimeMillis().toString()
                            )
                        )
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)

                        addCommandHistory(
                            VcuDataHistory(
                                2,
                                1,
                                CommandEnum.getCommandByCmd(cmd),
                                e?.msg ?: "",
                                System.currentTimeMillis().toString()
                            )
                        )
                    }
                })
        )
    }

    private var mVcuVersionList: MutableList<VcuVersion> = mutableListOf()
    fun getVcuVersionList(): MutableList<VcuVersion> {
        return mVcuVersionList
    }

    /**
     * 获取中控软件版本列表
     */
    fun queryCtrlVersionList() {
        addDisposable(
            HttpMethods.getVcuVersionList()
                .subscribeWith(object : NullAbleObserver<List<VcuVersion>>() {
                    override fun onSuccess(list: List<VcuVersion>?) {
                        mVcuVersionList.clear()
                        mVcuVersionList.addAll(list ?: mutableListOf())
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        ToastUtils.showShort(e?.msg)
                    }
                })
        )
    }

    /**
     * 下载文件
     */
    var mDownloadLiveData = MutableLiveData<String>()
    fun downloadFile(version: String, downloadUrl: String, savePath: String, filename: String) {
        addDisposable(
            HttpMethods.downloadFile(downloadUrl, savePath, 0L, filename)
                .subscribe({ progress ->
                    Log.d("Download", "進度：${progress.getPercentString()}%")
                }, { error ->
                    val e = ErrorMsgBean()
                    e.msg = error.message
                    loadState.value =
                        State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    mDownloadLiveData.value = ""
                }, {
                    mDownloadLiveData.value = "$version,$savePath/$filename"
                })
        )
    }

    private var map: Map<Int, ByteArray> = hashMapOf()
    suspend fun readOtaData(file: File) {
        val bytes = OtaUtil.readFileToByteArrayAsync(file)
        if (bytes != null) {
            map = OtaUtil.splitBytesToMap(bytes, 58)
        }
    }

    private var otaCheckTxnNo: Long = 0
    fun getOtaCheckTxnNo(): Long {
        return otaCheckTxnNo
    }

    fun setOtaCheckTxnNo(txnNo: Long) {
        this.otaCheckTxnNo = txnNo
    }

    private var otaDataTxnNo: Long = 0
    fun getOtaDataTxnNo(): Long {
        return otaDataTxnNo
    }

    fun setOtaDataTxnNo(txnNo: Long) {
        this.otaDataTxnNo = txnNo
    }

    private var currentIndex = 0

    fun getOtaProcess(): String = "$currentIndex/${map.size}"

    fun startOta() {
        currentIndex = 0
    }

    fun stopOta() {
        currentIndex = 0
    }

    fun isOta() = currentIndex != 0

    fun getOtaDataByIndex(): String {
        if (currentIndex >= map.size) return ""
        val data =
            OtaUtil.buildOtaData(map[currentIndex]?.joinToString("") { "%02X".format(it) } ?: "",
                map.size, currentIndex)
        currentIndex++
        return data
    }

    /**
     * 保存VCU数据
     */
    fun saveVcuData(devId: String, msgType: Int, type: Int, command: String?, data: String) {
        val hashMap = HashMap<String, Any>()
        hashMap["sn"] = devId
        command?.let {
            hashMap["command"] = it
        }
        hashMap["msgType"] = msgType
        hashMap["communicationType"] = 2
        hashMap["data"] = data
        addCommandHistory(
            VcuDataHistory(
                msgType,
                type,
                command ?: "",
                data,
                System.currentTimeMillis().toString()
            )
        )
    }

    private val commandMap = ConcurrentHashMap<Long, String>()
    fun addCommand(txnNo: Long, command: String) {
        commandMap.put(txnNo, command)
    }

    fun getCommand(txtNo: Long): String? = commandMap.remove(txtNo)

    private val commandHistoryList = mutableListOf<VcuDataHistory>()

    private fun addCommandHistory(vcuData: VcuDataHistory) {
        commandHistoryList.add(vcuData)
    }

    var mVcuDataHistoryListLiveData = MutableLiveData<VcuDataHistoryListResp>()

    fun queryVcuDataList(sn: String, type: Int?, page: Int, pageSize: Int) {
        val map = HashMap<String, Any>()
        map["sn"] = sn
        type?.let {
            map["msgType"] = it
        }
        map["pageNum"] = page
        map["pageSize"] = pageSize
        val filteredList = if (type == null) {
            commandHistoryList
        } else {
            commandHistoryList.filter { it.msgType == type }
        }
        val sortedDesc = filteredList.sortedByDescending { it.createTime }
        mVcuDataHistoryListLiveData.value = VcuDataHistoryListResp(sortedDesc,sortedDesc.size)
    }

}