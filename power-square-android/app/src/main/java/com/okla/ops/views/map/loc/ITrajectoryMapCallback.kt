package com.okla.ops.views.map.loc

import com.google.android.gms.maps.model.Marker

interface ITrajectoryMapCallback {
    fun onMapReady()
    fun onMakerClick(mMarker: Marker)
}