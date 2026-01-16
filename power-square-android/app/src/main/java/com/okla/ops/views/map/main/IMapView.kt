package com.okla.ops.views.map.main

import android.os.Bundle
import android.widget.FrameLayout
import com.base.common.map.IBaseMapView
import com.google.android.gms.maps.model.LatLng
import com.okla.ops.beans.BatteryDevice
import com.okla.ops.beans.NearByVehicle
import com.okla.ops.beans.PolylinePoints

interface IMapView : IBaseMapView {
    fun createMapView(bundle: Bundle?, callback: IMapCallback): FrameLayout //创建地图控件

    fun updateVehiclelist(
        newBatteryList: List<BatteryDevice>
    )
    fun updateNearByVehiclelist(
        newBatteryList: List<NearByVehicle>
    )

    fun drawRoute(mPolylinePoints: PolylinePoints)

    fun performSearchStationClicked(pid: String)
    fun onSwitchMarker(position: Int)
    fun getSwitchType(): Int

    fun drawDangerRegion(map: MutableMap<String, MutableList<LatLng>>)

    fun drawOperationRegion(map: MutableMap<String, MutableList<LatLng>>)

    fun clearMarker()

    fun clearPolyline()
    fun drawPolyLine(polyList: List<LatLng>)
}