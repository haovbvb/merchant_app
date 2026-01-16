package com.base.common.map

import com.base.common.beans.LocationData

interface GeoLocationCallback {
    fun onLocationChanged(data: LocationData)
}