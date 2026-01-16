package com.base.common.map.location

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import com.base.common.beans.LocationData
import com.base.common.map.GeoLocationCallback
import com.base.common.map.IBaseGeoLocation
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority

/**
 * 必须手机内置有GoogleService才有效
 */
class GoogleGeolocationGMS(context: Context) : IBaseGeoLocation {
    val mContext = context
    lateinit var mListener: GeoLocationCallback
    private lateinit var mLocationListener: LocationCallback
    private lateinit var locationRequest: LocationRequest
    private lateinit var fusedLocationClient: FusedLocationProviderClient

    override fun initLocationClient() {
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(mContext);

        mLocationListener = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult ?: return
                for (location in locationResult.locations) {
                    mListener.onLocationChanged(LocationData(location.latitude, location.longitude))
                }
            }
        }
    }

    override fun onStartLocate(
        listener: GeoLocationCallback,
        minTimeMs: Long,
        minDistanceM: Float
    ) {
        mListener = listener

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
        locationRequest = LocationRequest.create().apply {
            interval = minTimeMs
            fastestInterval = minTimeMs
            priority = Priority.PRIORITY_HIGH_ACCURACY
            smallestDisplacement = minDistanceM
        }
        fusedLocationClient.requestLocationUpdates(locationRequest, mLocationListener, null)
    }

    override fun onPauseLocate() {
        fusedLocationClient.removeLocationUpdates(mLocationListener)
    }

    override fun onStopLocate() {
        fusedLocationClient.removeLocationUpdates(mLocationListener)
    }
}