package com.base.common.map.location

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import androidx.core.app.ActivityCompat
import com.base.common.BuildConfig
import com.google.android.gms.location.*
import com.base.common.beans.LocationData
import com.base.common.map.IBaseGeoLocation
import com.base.common.map.GeoLocationCallback

class GoogleGeolocation(context: Context) : IBaseGeoLocation {
    val mContext = context
    lateinit var mListener: GeoLocationCallback
    lateinit var mFusedLocationProviderClient: FusedLocationProviderClient
    lateinit var mLocationCallback: LocationCallback
    lateinit var locationRequest: LocationRequest
    override fun initLocationClient() {
        locationRequest = LocationRequest.create()
            .setInterval(5000)
            .setFastestInterval(4000)
            .setPriority(Priority.PRIORITY_HIGH_ACCURACY)
        mLocationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                super.onLocationResult(result)
                val locationList: List<Location> = result.locations
                if (locationList.isNotEmpty()) {
                    val location: Location = locationList.last()

                    mListener.onLocationChanged(
                        LocationData(
                            location.latitude,
                            location.longitude
                        )
                    )
                }

            }
        }
        mFusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(mContext)
    }

    override fun onStartLocate(listener: GeoLocationCallback, minTimeMs: Long, minDistanceM: Float) {
        mListener = listener
        if (ActivityCompat.checkSelfPermission(
                mContext,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED ||
            ActivityCompat.checkSelfPermission(
                mContext,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            Looper.myLooper()?.let {
                mFusedLocationProviderClient.requestLocationUpdates(
                    locationRequest,
                    mLocationCallback,
                    it
                )
                    .addOnSuccessListener {
                        if (BuildConfig.DEBUG) {
                            mListener.onLocationChanged(
                                LocationData(
                                    22.580991666666666,
                                    113.90715
                                )
                            )
                        }
                    }.addOnFailureListener {
                    }.addOnCanceledListener {
                    }
            }
        }
    }

    override fun onPauseLocate() {
        mFusedLocationProviderClient.removeLocationUpdates(mLocationCallback)
    }

    override fun onStopLocate() {
        mFusedLocationProviderClient.removeLocationUpdates(mLocationCallback)
    }
}