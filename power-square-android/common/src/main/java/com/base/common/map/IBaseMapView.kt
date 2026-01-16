package com.base.common.map

import android.os.Bundle
import com.base.common.beans.LocationData

interface IBaseMapView {
    fun onStart()
    fun onResume()
    fun onPause()
    fun onStop()
    fun onDestroy()
    fun onSaveInstanceState(outState: Bundle)
    fun onLowMemory()
    fun setCenter(locationData: LocationData, anim: Boolean)
    fun setCenter()
    fun setCenter(locationData: LocationData)
    fun refreshCenterPoi(locationData: LocationData)
    fun drawMarker(latitude:Double,longitude:Double,deviceType:Int)

}