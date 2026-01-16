package com.okla.ops.views.map.loc

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.core.content.ContextCompat
import com.base.common.beans.LocationData
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.*
import com.okla.ops.R

class TrajectoryMapView(applicatonContext: Context) : ITrajectoryMapView, OnMapReadyCallback,
    GoogleMap.OnCameraMoveStartedListener,
    GoogleMap.OnCameraMoveListener,
    GoogleMap.OnCameraMoveCanceledListener,
    GoogleMap.OnCameraIdleListener,
    GoogleMap.OnMapClickListener, GoogleMap.OnMarkerClickListener {

    var zoomLever: Float = 15F //地图等级范围2.0f---22.0f
    var mContext: Context = applicatonContext
    lateinit var mGoogleMap: GoogleMap
    lateinit var mMapView: MapView
    lateinit var mCallback: ITrajectoryMapCallback
    private val MAPVIEW_BUNDLE_KEY = "MapViewBundleKey"

    override fun createMapView(
        savedInstanceState: Bundle?,
        callback: ITrajectoryMapCallback
    ): FrameLayout {
        mCallback = callback
        mMapView = MapView(mContext)

        val mapViewBundle = savedInstanceState?.getBundle(MAPVIEW_BUNDLE_KEY)
        mMapView.onCreate(mapViewBundle)
        mMapView.getMapAsync(this)
        return mMapView
    }

    var mMarkerOptions: MarkerOptions? = null
    private fun drawMarkerBattery(latitude: Double, longitude: Double, index: Int): Marker? {
        mMarkerOptions = MarkerOptions()
            .position(LatLng(latitude, longitude))
            .anchor(0.5f, 1.0f)
            .icon(BitmapDescriptorFactory.fromBitmap(getMarkerFromView(index)))
        return mMarkerOptions?.let {
            val addMarker = mGoogleMap.addMarker(it)
            addMarker?.tag = index
            addMarker
        }
    }

    lateinit var view: View
    lateinit var ivIcon: ImageView
    lateinit var mTempBitmap: Bitmap
    lateinit var mImageView: ImageView
    lateinit var mCanvas: Canvas
    private fun getMarkerFromView(status: Int): Bitmap {
        view = View.inflate(
            mContext,
            R.layout.layout_marker,
            null
        )
        ivIcon = view.findViewById(R.id.ivMarker)
        when (status) {
            1 -> {
                ivIcon.setImageResource(R.drawable.icon_battery_green)
            }

            2 -> {
                ivIcon.setImageResource(R.drawable.icon_battery_orange)
            }

            3 -> {
                ivIcon.setImageResource(R.drawable.icon_battery_red)
            }
        }
        view.measure(
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        )
        view.layout(0, 0, view.measuredWidth, view.measuredHeight)
        mTempBitmap =
            Bitmap.createBitmap(view.measuredWidth, view.measuredHeight, Bitmap.Config.ARGB_8888)
        mCanvas = Canvas(mTempBitmap)
        view.draw(mCanvas)
        return mTempBitmap
    }

    override fun drawMarkerLastPark(latitude: Double, longitude: Double, index: Int) {
        drawMarkerBattery(latitude, longitude, index)
    }

    override fun onStart() {
        mMapView.onStart()
    }

    override fun onPause() {
        mMapView.onPause()
    }

    override fun onResume() {
        mMapView.onResume()
    }

    override fun onStop() {
        mMapView.onStop()
    }

    override fun onDestroy() {
        mMapView.onDestroy()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        val mapViewBundle = outState.getBundle(MAPVIEW_BUNDLE_KEY) ?: Bundle().also {
            outState.putBundle(MAPVIEW_BUNDLE_KEY, it)
        }
        mMapView.onSaveInstanceState(mapViewBundle)
    }

    override fun onLowMemory() {
        mMapView.onLowMemory()
    }

    override fun setCenter(locationData: LocationData, anim: Boolean) = Unit

    override fun setCenter() {
        currentLocation?.run {
            mGoogleMap.animateCamera(
                CameraUpdateFactory.newLatLngZoom(
                    LatLng(latitude, longitude),
                    zoomLever
                )
            )
        }
    }

    override fun setCenter(locationData: LocationData) {
        mGoogleMap.animateCamera(
            CameraUpdateFactory.newLatLngZoom(
                LatLng(
                    locationData.latitude,
                    locationData.longitude
                ), zoomLever
            )
        )
    }

    var currentLocation: LocationData? = null
    override fun refreshCenterPoi(locationData: LocationData) {
        currentLocation = locationData

    }

    override fun drawMarker(latitude: Double, longitude: Double,deviceType:Int) {

    }

    override fun onMapReady(map: GoogleMap) {
        mGoogleMap = map
        with(mGoogleMap) {
            mCallback.onMapReady()
            uiSettings.isMapToolbarEnabled = false
            uiSettings.isTiltGesturesEnabled = false
            uiSettings.isRotateGesturesEnabled = false

            setOnMapClickListener(this@TrajectoryMapView)
            setOnMarkerClickListener(this@TrajectoryMapView)
            setOnCameraIdleListener(this@TrajectoryMapView)
            setOnCameraMoveStartedListener(this@TrajectoryMapView)
            setOnCameraMoveListener(this@TrajectoryMapView)
            setOnCameraMoveCanceledListener(this@TrajectoryMapView)
            enableMyLocation()
            setMapZoomLevel()
        }
    }

    private fun enableMyLocation() {
        if (ContextCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION)
            == PackageManager.PERMISSION_GRANTED
        ) {
            mGoogleMap.isMyLocationEnabled = true
            mGoogleMap.uiSettings.isMyLocationButtonEnabled = false
        }
    }

    private fun setMapZoomLevel() {
        mGoogleMap.animateCamera(CameraUpdateFactory.zoomTo(zoomLever))
    }

    override fun onCameraMoveStarted(p0: Int) = Unit

    override fun onCameraMove() = Unit

    override fun onCameraMoveCanceled() = Unit

    override fun onCameraIdle() = Unit

    override fun onMapClick(p0: LatLng) = Unit

    override fun onMarkerClick(mMarker: Marker): Boolean {
        mCallback.onMakerClick(mMarker)
        return true
    }
}