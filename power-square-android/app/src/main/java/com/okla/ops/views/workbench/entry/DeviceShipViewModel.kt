package com.okla.ops.views.workbench.entry

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.Battery
import com.okla.ops.beans.BatteryNew
import com.okla.ops.beans.Car
import com.okla.ops.beans.CarNew
import com.okla.ops.beans.Station
import com.okla.ops.beans.StationNew
import com.okla.ops.beans.WarehouseBean
import com.okla.ops.http.HttpMethods
import com.okla.ops.views.MainViewModel

open class DeviceShipViewModel : MainViewModel() {
    /**
     *  电柜
     */
    val newStationListLiveData = MutableLiveData<MutableList<StationNew>>()

    //确保创建全新的对象
    fun addNewStation(stationNew: StationNew): Boolean {
        val currentList = newStationListLiveData.value ?: mutableListOf()
        // 防重检查
        if (currentList.any { it.sn == stationNew.sn }) {
            return false
        }
        // 创建全新的列表和全新的对象
        val newList = currentList.map {
            StationNew(it.sn, it.imei, it.iccid, it.lockDevId)
        }.toMutableList()
        // 添加全新的对象
        newList.add(
            StationNew(
                stationNew.sn,
                stationNew.imei,
                stationNew.iccid,
                stationNew.lockDevId
            )
        )
        newStationListLiveData.value = newList
        return true
    }

    // 安全删除
    fun removeNewStation(stationSn: String) {
        val currentList = newStationListLiveData.value ?: return
        val newList = currentList
            .filter { it.sn != stationSn }
            .map { StationNew(it.sn, it.imei, it.iccid, it.lockDevId) }
            .toMutableList()
        newStationListLiveData.value = newList
    }

    fun updateNewStationInfo(
        index: Int,
        stationSn: String,
        imei: String,
        iccid: String,
        lockDevId: String
    ): Boolean {
        val currentList = newStationListLiveData.value ?: mutableListOf()
        // 检查新的SN是否与其他item重复（排除当前index）
        if (currentList.any { it.sn == stationSn && currentList.indexOf(it) != index }) {
            return false // 有重复，更新失败
        }

        if (index in currentList.indices) {
            val newList = currentList.mapIndexed { i, existingStation ->
                if (i == index) {
                    // 创建新对象
                    StationNew(stationSn, imei, iccid, lockDevId)
                } else {
                    // 其他对象也创建新实例
                    StationNew(
                        existingStation.sn,
                        existingStation.imei,
                        existingStation.iccid,
                        existingStation.lockDevId
                    )
                }
            }.toMutableList()

            newStationListLiveData.value = newList
            return true // 更新成功
        }
        return false
    }


    fun getNewStationCount(): Int {
        return newStationListLiveData.value?.size ?: 0
    }

    fun getNewStationList(): MutableList<StationNew> {
        return newStationListLiveData.value ?: mutableListOf()
    }

    val registerStationLiveData = MutableLiveData<Any>()
    fun registerStation(model: String) {
        val map = HashMap<String, Any>()
        map["model"] = model
        map["list"] = newStationListLiveData.value ?: mutableListOf<StationNew>()
        addDisposable(
            HttpMethods.registerStation(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(any: Any?) {
                        registerStationLiveData.value = any ?: Any()
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }


    /**
     *  電池
     */
    val newBatteryListLiveData = MutableLiveData<MutableList<BatteryNew>>()

    // 安全添加：確保創建全新的對象
    fun addNewBattery(batteryNew: BatteryNew): Boolean {
        val currentList = newBatteryListLiveData.value ?: mutableListOf()
        // 防重檢查
        if (currentList.any { it.sn == batteryNew.sn }) {
            return false
        }
        // 創建全新的列表和全新的對象
        val newList = currentList.map {
            BatteryNew(it.sn, it.imei, it.iccid)
        }.toMutableList()
        // 添加全新的對象
        newList.add(BatteryNew(batteryNew.sn, batteryNew.imei, batteryNew.iccid))
        newBatteryListLiveData.value = newList
        return true
    }

    // 安全刪除
    fun removeNewBattery(batterySn: String) {
        val currentList = newBatteryListLiveData.value ?: return
        val newList = currentList
            .filter { it.sn != batterySn }
            .map { BatteryNew(it.sn, it.imei, it.iccid) }
            .toMutableList()
        newBatteryListLiveData.value = newList
    }

    // 安全更新
    fun updateNewBatteryInfo(index: Int, batterySn: String, imei: String, iccid: String): Boolean {
        val currentList = newBatteryListLiveData.value ?: mutableListOf()
        // 檢查新的SN是否與其他item重複（排除當前index）
        if (currentList.any { it.sn == batterySn && currentList.indexOf(it) != index }) {
            return false // 有重複，更新失敗
        }

        if (index in currentList.indices) {
            val newList = currentList.mapIndexed { i, existingBattery ->
                if (i == index) {
                    // 創建新對象
                    BatteryNew(batterySn, imei, iccid)
                } else {
                    // 其他對象也創建新實例
                    BatteryNew(existingBattery.sn, existingBattery.imei, existingBattery.iccid)
                }
            }.toMutableList()

            newBatteryListLiveData.value = newList
            return true // 更新成功
        }
        return false
    }

    fun getNewBatteryCount(): Int {
        return newBatteryListLiveData.value?.size ?: 0
    }

    fun getNewBatteryList(): MutableList<BatteryNew> {
        return newBatteryListLiveData.value ?: mutableListOf()
    }


    val registerBatteryLiveData = MutableLiveData<Any>()
    fun registerBattery(model: String) {
        val map = HashMap<String, Any>()
        map["model"] = model
        map["list"] = newBatteryListLiveData.value ?: mutableListOf<BatteryNew>()
        addDisposable(
            HttpMethods.registerBattery(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(any: Any?) {
                        registerBatteryLiveData.value = any ?: Any()
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }


    /**
     * 车辆
     */
    val newCarListLiveData = MutableLiveData<MutableList<CarNew>>()
    fun addNewCar(carNew: CarNew): Boolean {
        val currentList = newCarListLiveData.value ?: mutableListOf()
        // 防重檢查
        if (currentList.any { it.sn == carNew.sn }) {
            return false
        }
        // 創建全新的列表和全新的對象
        val newList = currentList.map {
            CarNew(it.sn, it.vin, it.ctrlId)
        }.toMutableList()
        // 添加全新的對象
        newList.add(CarNew(carNew.sn, carNew.vin, carNew.ctrlId))
        newCarListLiveData.value = newList
        return true
    }

    // 安全刪除
    fun removeNewCar(carSn: String) {
        val currentList = newCarListLiveData.value ?: return
        val newList = currentList
            .filter { it.sn != carSn }
            .map { CarNew(it.sn, it.vin, it.ctrlId) }
            .toMutableList()
        newCarListLiveData.value = newList
    }

    // 安全更新
    fun updateNewCarInfo(index: Int, carSn: String, vin: String, ctrlId: String): Boolean {
        val currentList = newCarListLiveData.value ?: mutableListOf()
        // 檢查新的SN是否與其他item重複（排除當前index）
        if (currentList.any { it.sn == carSn && currentList.indexOf(it) != index }) {
            return false // 有重複，更新失敗
        }

        if (index in currentList.indices) {
            val newList = currentList.mapIndexed { i, existingCar ->
                if (i == index) {
                    // 創建新對象
                    CarNew(carSn, vin, ctrlId)
                } else {
                    // 其他對象也創建新實例
                    CarNew(existingCar.sn, existingCar.vin, existingCar.ctrlId)
                }
            }.toMutableList()

            newCarListLiveData.value = newList
            return true // 更新成功
        }
        return false
    }

    fun getNewCarCount(): Int {
        return newCarListLiveData.value?.size ?: 0
    }

    fun getNewCarList(): MutableList<CarNew> {
        return newCarListLiveData.value ?: mutableListOf()
    }

    val registerCarLiveData = MutableLiveData<Any>()
    fun registerCar(model: String) {
        val map = HashMap<String, Any>()
        map["model"] = model
        map["list"] = newCarListLiveData.value ?: mutableListOf<CarNew>()
        addDisposable(
            HttpMethods.registerCar(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(any: Any?) {
                        registerCarLiveData.value = any ?: Any()
                        loadState.value =
                            State.getInstance(State.SUCCESS)
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }


//    val shipCarLiveData = MutableLiveData<String>()
//    fun shipCar(trackingNumber: String, remark: String) {
//        val map = HashMap<String, Any>()
//        map["agentNo"] = agentNo
//        map["list"] = carListLiveData.value ?: mutableListOf<CarNew>()
//        map["trackingNumber"] = trackingNumber
//        map["remark"] = remark
//        addDisposable(
//            HttpMethods.shipCar(map)
//                .compose(LoadingTransHelper.loadingState(loadState))
//                .subscribeWith(object : NullAbleObserver<String>() {
//                    override fun onSuccess(result: String?) {
//                        shipCarLiveData.value = result ?: ""
//                    }
//
//                    override fun onFail(e: ErrorMsgBean) {
//                        ToastUtils.showShort(e.msg)
//                    }
//                })
//        )
//    }

//
//    val agentListLiveData = MutableLiveData<MutableList<Agent>>()
//    var agentNo = ""
//    fun getAgentList(cityCode: String? = "", keyword: String? = "") {
//        val map = HashMap<String, Any>()
//        cityCode?.let {
//            map["cityCode"] = it
//        }
//        keyword?.let {
//            map["keyword"] = it
//        }
//        addDisposable(
//            HttpMethods.getAgentList(map)
//                .compose(LoadingTransHelper.loadingState(loadState))
//                .subscribeWith(object : NullAbleObserver<MutableList<Agent>>() {
//                    override fun onSuccess(list: MutableList<Agent>?) {
//                        agentListLiveData.value = list ?: mutableListOf()
//                    }
//
//                    override fun onFail(e: ErrorMsgBean) {
//                        ToastUtils.showShort(e.msg)
//                    }
//                })
//        )
//    }
//

//    val sellBatteryLiveData = MutableLiveData<SellBattery>()
//    fun querySellBatteryBySn(sn: String) {
//        val map = HashMap<String, Any>()
//        map["sn"] = sn
//        addDisposable(
//            HttpMethods.querySellBatteryBySn(map)
//                .compose(LoadingTransHelper.loadingState(loadState))
//                .subscribeWith(object : NullAbleObserver<SellBattery>() {
//                    override fun onSuccess(sellBattery: SellBattery?) {
//                        sellBatteryLiveData.value = sellBattery ?: SellBattery()
//                    }
//
//                    override fun onFail(e: ErrorMsgBean) {
//                        sellBatteryLiveData.value = SellBattery()
//                        loadState.value =
//                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
//                    }
//                })
//        )
//    }


//    }  val purchasingUserLiveData = MutableLiveData<PurchasingUser>()
//    fun queryUserForSell(cardNum: String) {
//        val map = HashMap<String, Any>()
//        map["cardNum"] = cardNum
//        addDisposable(
//            HttpMethods.queryUserForSell(map)
//                .compose(LoadingTransHelper.loadingState(loadState))
//                .subscribeWith(object : NullAbleObserver<PurchasingUser>() {
//                    override fun onSuccess(purchasing: PurchasingUser?) {
//                        purchasingUserLiveData.value = purchasing ?: PurchasingUser()
//                    }
//
//                    override fun onFail(e: ErrorMsgBean) {
//                        purchasingUserLiveData.value = PurchasingUser()
//                        loadState.value =
//                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
//                    }
//                })
//        )
//    }
//
//    val sellResultLiveData = MutableLiveData<Any>()
//    fun sellBattery(
//        address: String,
//        birthday: String,
//        cardImg: String,
//        cardNum: String,
//        deviceSn: String,
//        email: String,
//        firstName: String,
//        lastName: String,
//        idNumber: String,
//        phone: String,
//        payType: Int,
//        planNo: String,
//        personImg: String,
//    ) {
//        val map = HashMap<String, Any>()
//        map["address"] = address
//        map["birthday"] = birthday
//        map["cardImg"] = cardImg
//        map["cardNum"] = cardNum
//        map["deviceSn"] = deviceSn
//        map["email"] = email
//        map["firstName"] = firstName
//        map["lastName"] = lastName
//        map["idNumber"] = idNumber
//        map["phone"] = phone
//        map["payType"] = payType
//        map["planNo"] = planNo
//        map["personImg"] = personImg
//        addDisposable(
//            HttpMethods.sellBattery(map)
//                .compose(LoadingTransHelper.loadingState(loadState))
//                .subscribeWith(object : NullAbleObserver<Any>() {
//                    override fun onSuccess(any: Any?) {
//                        sellResultLiveData.value = any ?: Any()
//                    }
//
//                    override fun onFail(e: ErrorMsgBean) {
//                        ToastUtils.showShort(e.msg)
//                    }
//                })
//        )

    var myWarehouseBeanLiveData = MutableLiveData<WarehouseBean?>()

    fun queryMyWarehouseInfo() {
        addDisposable(
            HttpMethods.queryMyWarehouseInfo()
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

    var mCreateIssueLiveData = MutableLiveData<Any>()

    fun createIssue(
        inWarehouseNo: String,
        outWarehouseNo: String,
        deviceType: Int,
        sns: MutableList<String>,
        trackingNumber: String
    ) {
        addDisposable(
            HttpMethods
                .createIssue(inWarehouseNo, outWarehouseNo, deviceType, sns, trackingNumber)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any?>() {
                    override fun onSuccess(t: Any?) {
                        mCreateIssueLiveData.value = t ?: Any()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }

    var mCheckDeviceSn = MutableLiveData<String>()

    fun checkDeviceSn(type: Int, sn: String, warehouseNo: String?) {
        addDisposable(
            HttpMethods.checkDeviceSn(type, sn, warehouseNo ?: "")
                .subscribeWith(object : NullAbleObserver<Any?>() {

                    override fun onSuccess(str: Any?) {
                        mCheckDeviceSn.value = sn
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
    }

    var mInWarehouseBeanListLiveData = MutableLiveData<List<WarehouseBean>?>()

    fun queryInWarehouseList(map: HashMap<String, Any>) {
        addDisposable(
            HttpMethods.queryInWarehouseList(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<List<WarehouseBean>>() {
                    override fun onSuccess(t: List<WarehouseBean>?) {
                        mInWarehouseBeanListLiveData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                                .setShowStatusView(true)
                    }
                })
        )
    }
}