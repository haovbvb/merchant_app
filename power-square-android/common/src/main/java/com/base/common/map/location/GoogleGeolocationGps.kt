package com.base.common.map.location

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import com.base.common.beans.LocationData
import com.base.common.map.IBaseGeoLocation
import com.base.common.map.GeoLocationCallback
import com.base.common.utils.NetworkUtils

/**
1.使用gps，收不到任何回调。
2.使用network,一直回调onProviderDisabled
原因：那就是当你在室内开发时，你的手机根本就没法获取位置信息，你叫系统如何将位置信息通知给你的程序。
所以要从根本上解决这个问题，就要解决位置信息获取问题。
 * @Version:
 */
class GoogleGeolocationGps(context: Context) : IBaseGeoLocation {
    val mContext = context
    lateinit var mListener: GeoLocationCallback
    lateinit var mLocationListener: LocationListener
    lateinit var mLocationManager: LocationManager
    override fun initLocationClient() {
        mLocationManager = mContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        mLocationListener = object : LocationListener {

            override fun onLocationChanged(location: Location) {
                mListener.onLocationChanged(LocationData(location.latitude, location.longitude))
            }

            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {

            }

            override fun onProviderEnabled(provider: String) {

            }

            override fun onProviderDisabled(provider: String) {

            }

        }
    }

    override fun onStartLocate(
        listener: GeoLocationCallback,
        minTimeMs: Long,
        minDistanceM: Float
    ) {

        if (mLocationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) && NetworkUtils.isMobileData()) {
            if (ActivityCompat.checkSelfPermission(
                    mContext,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(
                    mContext,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return
            }
            mLocationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
            mLocationManager.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                minTimeMs,
                minDistanceM,
                mLocationListener
            )
        }
        if (mLocationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER) && NetworkUtils.isWifiConnected()) {
            if (ActivityCompat.checkSelfPermission(
                    mContext,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(
                    mContext,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return
            }
            mLocationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
            mLocationManager.requestLocationUpdates(
                LocationManager.NETWORK_PROVIDER,
                minTimeMs,
                minDistanceM,
                mLocationListener
            )
        }
    }

    override fun onPauseLocate() {
        mLocationManager.removeUpdates(mLocationListener)
    }

    override fun onStopLocate() {
        mLocationManager.removeUpdates(mLocationListener)
    }
}