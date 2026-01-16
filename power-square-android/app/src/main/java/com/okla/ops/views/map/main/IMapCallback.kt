package com.okla.ops.views.map.main

import com.base.common.beans.LocationData
import com.okla.ops.beans.BatteryDevice
import com.okla.ops.beans.NearByVehicle

interface IMapCallback {
    fun onMapMarkerClick(battery: BatteryDevice)
    fun onMapMarkerVehicleClick(battery: NearByVehicle)
    fun onMapClick()
    fun onMapReady()
    fun cameraIdle(locationData: LocationData, isRefresh: Boolean) //是否刷新数据
}