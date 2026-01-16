package com.okla.ops.views.monitor

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew
import com.okla.ops.beans.NearByVehicle
import com.okla.ops.beans.PolylinePoints
import com.okla.ops.http.HttpMethods
import com.okla.ops.views.workbench.equipmentsearch.net.DeviceSearchHttpMethods.getDeviceListSearchDataNew

class MonitorViewModel : BaseViewModel() {
    val sampleVehicles = mutableListOf(
        NearByVehicle(
            carNumber = "粤A·12345",
            cardNum = "10000000037",
            img = "https://example.com/images/car1.png",
            latitude = 22.573292,
            longitude = 113.900745,
            mile = 15230.00,
            needMaintenance = true,
            sn = "AG12025060500011"
        ),
        NearByVehicle(
            carNumber = "粤A·54321",
            cardNum = "10000000038",
            img = "https://example.com/images/car2.png",
            latitude = 22.573800,
            longitude = 113.901200,
            mile = 8320.00,
            needMaintenance = true,
            sn = "AG12025060500011"
        ),
        NearByVehicle(
            carNumber = "粤A·67890",
            cardNum = "10000000040",
            img = "https://example.com/images/car3.png",
            latitude = 22.572900,
            longitude = 113.900300,
            mile = 42000.00,
            needMaintenance = false,
            sn = "SN1003"
        ),
        NearByVehicle(
            carNumber = null,
            cardNum = "C1004",
            img = null,
            latitude = 22.573500,
            longitude = 113.900500,
            mile = null,
            needMaintenance = false,
            sn = null
        )
    )

    val vehicleListLiveData = MutableLiveData<MutableList<NearByVehicle>?>()

    fun getNearByVehicleList(
        latitude: Double,
        longitude: Double,
        count: Int,
        radius: Int,
        sn: String?,
        status: Int?
    ) {
        val map = HashMap<String, Any>()
        map["latitude"] = latitude
        map["longitude"] = longitude
        map["count"] = count
        map["radius"] = radius
        sn?.let {
            map["vehicleSn"] = it
        }
        //1 待保养 0无需保养
        status?.let {
            map["maintainFlag"] = it
        }
        addDisposable(
            HttpMethods.getNearByVehicleList(map)
                .subscribeWith(object : NullAbleObserver<MutableList<NearByVehicle>>() {
                    override fun onSuccess(list: MutableList<NearByVehicle>?) {
                        vehicleListLiveData.value = list ?: mutableListOf()
//                        vehicleListLiveData.value= sampleVehicles
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        vehicleListLiveData.value = null
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
    }

    /**
     * 获取路线
     */
    var mRoutesData = MutableLiveData<PolylinePoints?>()
    fun getRoutes(origin: String, destination: String, avoid: String, mode: String, key: String) {
        val hashMap = hashMapOf<String, Any>(
            "origin" to origin,
            "destination" to destination,
            "avoid" to avoid,
            "mode" to mode,
            "key" to key
        )
        addDisposable(
            HttpMethods.getRoutes(hashMap)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<PolylinePoints>() {
                    override fun onSuccess(t: PolylinePoints?) {
                        mRoutesData.value = t
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        mRoutesData.value = null
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }


    var mPhoneLiveData = MutableLiveData<Any?>()
    fun getPhoneByCardNum(cardNum: String) {
        addDisposable(
            HttpMethods.getPhoneByCardNum(cardNum)
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(t: Any?) {
                        mPhoneLiveData.value = t ?: "-"
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        mPhoneLiveData.value = "-"
                    }
                })
        )
    }


    // 搜索设备
    var mEquipmentDeviceSearchBeanData: MutableLiveData<EquipmentDeviceSearchBeanNew?> =
        MutableLiveData()

    fun getDeviceListSearchData(inputData: String?): LiveData<EquipmentDeviceSearchBeanNew?> {
        addDisposable(
            getDeviceListSearchDataNew(inputData!!)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<EquipmentDeviceSearchBeanNew?>() {
                    override fun onSuccess(t: EquipmentDeviceSearchBeanNew?) {
                        mEquipmentDeviceSearchBeanData.setValue(t)
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        mEquipmentDeviceSearchBeanData.setValue(null)
                        loadState.value =
                            State.getInstance(State.ERROR)
                        ToastUtils.showShort(e.msg)
                    }
                })
        )
        return mEquipmentDeviceSearchBeanData
    }
}