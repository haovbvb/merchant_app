package com.okla.ops.views.map

import android.content.Context
import com.base.common.map.IBaseGeoLocation
import com.base.common.map.location.GoogleGeolocationGMS
import com.okla.ops.views.map.loc.ITrajectoryMapView
import com.okla.ops.views.map.loc.TrajectoryMapView
import com.okla.ops.views.map.main.GoogleMapView
import com.okla.ops.views.map.main.IMapView
import com.okla.ops.views.map.places.GooglePlacesMethod
import com.okla.ops.views.map.places.IPlacesMethod
import com.okla.ops.views.map.select.GoogleMapViewSelectAddr
import com.okla.ops.views.map.select.IMapViewSelectAddr


/**
 * @Date: 2021/1/11 9:53
 * @Author: Craz
 * @Description:
 * @Version:
 */
object MapFactory {
    fun getMapInstance(context: Context): IMapView {
        return GoogleMapView(context.applicationContext)
    }

    fun getMapSelectAddrInstance(context: Context): IMapViewSelectAddr {
        return GoogleMapViewSelectAddr(context.applicationContext)
    }

    fun getMapLocInstance(context: Context): IGeolocation {
        return GoogleGeolocation(context.applicationContext)
    }

    fun getBatteryLocMapInstance(context: Context): ITrajectoryMapView {
        return TrajectoryMapView(context.applicationContext)
    }
    fun getMapLocation(context: Context): IBaseGeoLocation {
        return GoogleGeolocationGMS(context.applicationContext)
    }
    fun getPlacesMethod(context: Context?): IPlacesMethod {
        return GooglePlacesMethod(context)
    }
}