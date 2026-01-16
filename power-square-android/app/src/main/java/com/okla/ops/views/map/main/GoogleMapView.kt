package com.okla.ops.views.map.main

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.location.Location
import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.base.common.beans.LocationData
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.Dash
import com.google.android.gms.maps.model.Gap
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.android.gms.maps.model.MapStyleOptions
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.gms.maps.model.PatternItem
import com.google.android.gms.maps.model.Polygon
import com.google.android.gms.maps.model.PolygonOptions
import com.google.android.gms.maps.model.Polyline
import com.google.android.gms.maps.model.PolylineOptions
import com.okla.ops.R
import com.okla.ops.beans.BatteryDevice
import com.okla.ops.beans.NearByVehicle
import com.okla.ops.beans.PolylinePoints
import com.okla.ops.utils.GooglePolyUtils

class GoogleMapView(applicationContext: Context) : IMapView, OnMapReadyCallback,
    GoogleMap.OnCameraMoveStartedListener,
    GoogleMap.OnCameraMoveListener,
    GoogleMap.OnCameraMoveCanceledListener,
    GoogleMap.OnCameraIdleListener,
    GoogleMap.OnPolylineClickListener,
    GoogleMap.OnMapClickListener, GoogleMap.OnMarkerClickListener {

    var zoomLever: Float = 15F //地图等级范围2.0f---22.0f
    var mContext: Context = applicationContext
    lateinit var mGoogleMap: GoogleMap
    lateinit var mMapView: MapView
    lateinit var mCallback: IMapCallback
    private val MAPVIEW_BUNDLE_KEY = "MapViewBundleKey"
    override fun createMapView(savedInstanceState: Bundle?, callback: IMapCallback): FrameLayout {
        mCallback = callback
        mMapView = MapView(mContext)
        var mapViewBundle: Bundle? = null
        if (savedInstanceState != null) {
            mapViewBundle = savedInstanceState.getBundle(MAPVIEW_BUNDLE_KEY)
        }
        mMapView.onCreate(mapViewBundle)
        mMapView.getMapAsync(this)
        return mMapView
    }

    override fun updateVehiclelist(newBatteryList: List<BatteryDevice>) {
    }

    /**
     * 绘制电池
     */
    var mVehicleList = mutableListOf<NearByVehicle>() //新数据pid集合
    override fun updateNearByVehiclelist(
        newBatteryList: List<NearByVehicle>
    ) {
        if (mVehicleList.isEmpty()) {
            newBatteryList.forEach {
                drawMarkerMethods(it)
                mVehicleList.add(it)
                if (isFirst) {
                    showMethodWithCurLoc()
                }
            }
        } else {
            newBatteryList.filter {
                !mVehicleList.contains(it)
            }.forEach {
                drawMarkerMethods(it)
                mVehicleList.add(it)
            }
            mVehicleList.filter {
                !newBatteryList.contains(it)
            }.forEach {
                mVehicleList.remove(it)
            }
        }
        mMakerList.filter {
            !newBatteryList.contains(it.tag)
        }.forEach {
            it.remove()
            mMakerList.remove(it)
        }
    }

    var isFirst = true

    //全屏绘制:是否以手机位置为中心的
    private fun showMethodWithCurLoc() {
        isFirst = false
        if (mVehicleList.size > 0) {
            mBuilder = LatLngBounds.builder()
            mVehicleList.forEach {
                val mTempLatLng = LatLng(it.latitude ?: 0.0, it.longitude ?: 0.0)
                mBuilder.include(mTempLatLng)
                currentLocation.run {
                    mBuilder.include(
                        LatLng(
                            latitude * 2 - mTempLatLng.latitude,
                            longitude * 2 - mTempLatLng.longitude
                        )
                    )
                }
            }
            currentLocation.run {
                mBuilder.include(LatLng(latitude, longitude))
            }
            mGoogleMap.setOnMapLoadedCallback {
                mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngBounds(mBuilder.build(), 200))
            }
        } else {
            setCenter()
        }
    }

    var mPolyline: Polyline? = null
    lateinit var polylineOptions: PolylineOptions
    var isDrawPolyLine: Boolean = false
    override fun drawRoute(mPolylinePointsBean: PolylinePoints) {
        GooglePolyUtils.decodePoly(mPolylinePointsBean)
        mPolyline?.remove()
        polylineOptions = PolylineOptions()
            .color(ContextCompat.getColor(mContext, R.color.color_202b57))
            .width(7.0f)
            .clickable(true)
            .addAll(GooglePolyUtils.decodePoly(mPolylinePointsBean))
        mPolyline = mGoogleMap.addPolyline(polylineOptions)
        isDrawPolyLine = true

        addPolylineBoundShowMethod(polylineOptions.points)
    }

    override fun performSearchStationClicked(sn: String) {
        mVehicleList.forEach {
            if (it.sn == sn) {
                mPolyline?.remove()
                mCallback.onMapMarkerVehicleClick(it)
            }
        }
    }

    var markerType = 0
    override fun onSwitchMarker(type: Int) {
        markerType = type
//        clearMarker()
//        when (markerType) {
//            0 -> {
//                mVehicleList.forEach {
//                    if (it.needMaintenance == false) {
//                        drawMarkerMethods(it)
//                    }
//                }
//            }
//
//            1 -> {
//                mVehicleList.forEach {
//                    if (it.needMaintenance == true) {
//                        drawMarkerMethods(it)
//                    }
//                }
//            }
//            else->{
//                mVehicleList.forEach {
//                    drawMarkerMethods(it)
//                }
//            }
//        }

//        mMakerList.forEach { marker ->
//            if (markerType == 0) {
//                marker.isVisible = true
//            } else {
//                marker.isVisible = false
//            }
//        }
    }

    override fun getSwitchType(): Int {
        return markerType
    }

    private val DASH: PatternItem = Dash(8f)
    private val GAP: PatternItem = Gap(8f)
    private val PATTERN_POLYGON_ALPHA = listOf(GAP, DASH)
    var dangerPolygonMap: MutableMap<String, Polygon> = mutableMapOf()
    override fun drawDangerRegion(map: MutableMap<String, MutableList<LatLng>>) {
        dangerPolygonMap.forEach {
            it.value.remove()
        }
        dangerPolygonMap.clear()
        map.forEach {
            if (it.value.isNotEmpty()) {
                val addPolygon = mGoogleMap.addPolygon(
                    PolygonOptions()
                        .addAll(it.value)
                        .fillColor(Color.parseColor("#14FA4B51"))
                        .strokePattern(PATTERN_POLYGON_ALPHA)
                        .strokeColor(Color.parseColor("#FFFA4B51"))
                        .strokeWidth(4f)
                )
                dangerPolygonMap += it.key to addPolygon
            }
        }
    }

    var operationPolygonMap: MutableMap<String, Polygon> = mutableMapOf()
    override fun drawOperationRegion(map: MutableMap<String, MutableList<LatLng>>) {
        operationPolygonMap.forEach {
            it.value.remove()
        }
        operationPolygonMap.clear()
        map.forEach {
            if (it.value.isNotEmpty()) {
                val addPolygon = mGoogleMap.addPolygon(
                    PolygonOptions()
                        .addAll(it.value)
                        .fillColor(Color.parseColor("#0A1184F7"))
                        .strokeColor(Color.parseColor("#FF1184F7"))
                        .strokeWidth(4f)
                )
                operationPolygonMap += it.key to addPolygon
            }
        }
    }

    override fun clearMarker() {
        mGoogleMap.clear()
        mVehicleList.clear()
    }

    var mMakerList = mutableListOf<Marker>()
    private fun drawMarkerMethods(info: NearByVehicle) {
        info.needMaintenance?.let {
            drawMarkerVehicle(
                info.latitude ?: 0.0,
                info.longitude ?: 0.0,
                it
            )?.run {
                tag = info
                mMakerList.add(this)
            }
        }
    }

    var mMarkerOptions: MarkerOptions? = null
    private fun drawMarkerVehicle(
        latitude: Double,
        longitude: Double,
        needMaintenance: Boolean,
    ): Marker? {
        mMarkerOptions = MarkerOptions()
            .position(LatLng(latitude, longitude))
            .anchor(0.5f, 1.0f)
            .icon(
                BitmapDescriptorFactory.fromBitmap(getMarkerFromView(needMaintenance))
            )
        return mGoogleMap.addMarker(mMarkerOptions!!)
    }

    lateinit var view: View
    lateinit var tvValue: TextView
    lateinit var ivIcon: ImageView
    lateinit var mTempBitmap: Bitmap
    lateinit var mCanvas: Canvas
    private fun getMarkerFromView(type: Int): Bitmap {
        view = View.inflate(
            mContext,
            R.layout.layout_marker,
            null
        )
        ivIcon = view.findViewById(R.id.ivMarker)
        when (type) {
            1 -> {
                ivIcon.setImageResource(R.mipmap.icon_battery_loc)
            }
            2->{
                ivIcon.setImageResource(R.mipmap.icon_marker_vehicle)
            }
            3->{
                ivIcon.setImageResource(R.mipmap.icon_station_loc)
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

    private fun getMarkerFromView(needMaintenance: Boolean): Bitmap {
        view = View.inflate(
            mContext,
            R.layout.layout_marker,
            null
        )
        ivIcon = view.findViewById(R.id.ivMarker)
        when (needMaintenance) {
            false -> {
                ivIcon.setImageResource(R.mipmap.icon_marker_vehicle)
            }

            true -> {
                ivIcon.setImageResource(R.mipmap.icon_marker_need_maintenance)
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

    lateinit var mBuilder: LatLngBounds.Builder

    //轨迹线全屏绘制
    fun addPolylineBoundShowMethod(list: List<LatLng>) {
        if (list.isNotEmpty()) {
            mBuilder = LatLngBounds.builder()
            list.forEach {
                mBuilder.include(it)
            }
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngBounds(mBuilder.build(), 200))
        }
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
        var mapViewBundle = outState.getBundle(MAPVIEW_BUNDLE_KEY)
        if (mapViewBundle == null) {
            mapViewBundle = Bundle()
            outState.putBundle(MAPVIEW_BUNDLE_KEY, mapViewBundle)
        }
        mMapView.onSaveInstanceState(mapViewBundle)
    }

    override fun onLowMemory() {
        mMapView.onLowMemory()
    }

    override fun setCenter(locationData: LocationData, anim: Boolean) {
        if (anim) setCenter(locationData) else setCenterNoAnimate(locationData)
    }

    override fun setCenter() {
        currentLocation.run {
            try {
                mGoogleMap.animateCamera(
                    CameraUpdateFactory.newLatLngZoom(
                        LatLng(latitude, longitude),
                        zoomLever
                    )
                )
            } catch (e: Exception) {
                e.printStackTrace()
            }
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

    fun setCenterNoAnimate(locationData: LocationData) {
        mGoogleMap.moveCamera(
            CameraUpdateFactory.newLatLngZoom(
                LatLng(
                    locationData.latitude,
                    locationData.longitude
                ), zoomLever
            )
        )
    }

    var currentLocation: LocationData = LocationData(
        DataStoreUtils.readDoubleData(DataStoreKeyUtils.LATLNG_LATITUDE),
        DataStoreUtils.readDoubleData(DataStoreKeyUtils.LATLNG_LONTITUDE)
    )
    var currentLocMarker: Marker? = null
    override fun refreshCenterPoi(locationData: LocationData) {
        currentLocation = locationData
        if (currentLocMarker == null) {
            mMarkerOptions = MarkerOptions()
                .position(LatLng(locationData.latitude, locationData.longitude))
                .anchor(0.5f, 0.5f)
                .icon(BitmapDescriptorFactory.fromResource(R.mipmap.icon_location))
            currentLocMarker = mGoogleMap.addMarker(mMarkerOptions!!)
        } else {
            currentLocMarker?.position = LatLng(locationData.latitude, locationData.longitude)
        }
    }

    override fun drawMarker(latitude: Double, longitude: Double,deviceType:Int) {
        mMarkerOptions = MarkerOptions()
            .position(LatLng(latitude, longitude))
            .anchor(0.5f, 1.0f)
            .icon(
                BitmapDescriptorFactory.fromBitmap(getMarkerFromView(deviceType))
            )
        mGoogleMap.addMarker(mMarkerOptions!!)
    }

    override fun onMapReady(map: GoogleMap) {
        //隐藏商业等建筑物marker
        map.setMapStyle(MapStyleOptions(mContext.getString(R.string.style_json)))
        mGoogleMap = map
        with(mGoogleMap) {
            mCallback.onMapReady()
            uiSettings.isMapToolbarEnabled = false
            uiSettings.isTiltGesturesEnabled = false
            uiSettings.isRotateGesturesEnabled = false

            setOnMapClickListener(this@GoogleMapView)
            setOnMarkerClickListener(this@GoogleMapView)
            setOnCameraIdleListener(this@GoogleMapView)
            setOnCameraMoveStartedListener(this@GoogleMapView)
            setOnCameraMoveListener(this@GoogleMapView)
            setOnCameraMoveCanceledListener(this@GoogleMapView)
            setOnPolylineClickListener(this@GoogleMapView)
            setMapZoomLevel()
        }
    }

    private fun setMapZoomLevel() {
        mGoogleMap.animateCamera(CameraUpdateFactory.zoomTo(zoomLever))
    }

    override fun onCameraMoveStarted(p0: Int) = Unit

    override fun onCameraMove() = Unit

    override fun onCameraMoveCanceled() = Unit

    lateinit var mCameraIdleLatLngNew: LatLng
    var mCameraIdleLatLngOld: LatLng? = null
    var distance = FloatArray(1)
    var dismeter = 1000f //多少距离直径内不请求数据
    override fun onCameraIdle() {
        mCameraIdleLatLngNew = mGoogleMap.cameraPosition.target

        mCameraIdleLatLngOld?.run {
            if (isDrawPolyLine) return
            Location.distanceBetween(
                latitude,
                longitude,
                mCameraIdleLatLngNew.latitude,
                mCameraIdleLatLngNew.longitude,
                distance
            )
            if (distance[0] > dismeter) {
                mCallback.cameraIdle(
                    LocationData(
                        mCameraIdleLatLngNew.latitude,
                        mCameraIdleLatLngNew.longitude
                    ), true
                )
            }
        }
        mCameraIdleLatLngOld = mCameraIdleLatLngNew
    }

    override fun onMapClick(p0: LatLng) {
        mCallback.onMapClick()
        mPolyline?.remove()
        isDrawPolyLine = false
        if (isMarkerClick) {
            showMethodWithCurLoc()
            isMarkerClick = false
        }
    }

    var isMarkerClick = false
    override fun onMarkerClick(mMarker: Marker): Boolean {
        if (mMarker.tag == null) return true
        val batteryBean = mMarker.tag as? BatteryDevice
        if (batteryBean != null) {
            mCallback.onMapMarkerClick(batteryBean)
        } else {
            val vehicleBean = mMarker.tag as? NearByVehicle
            vehicleBean?.let { mCallback.onMapMarkerVehicleClick(it) }
        }

        mPolyline?.remove()
        isMarkerClick = true
        return true
    }

    override fun onPolylineClick(mPolyline: Polyline) {
        addPolylineBoundShowMethod(mPolyline.points)
    }

    override fun drawPolyLine(polyList: List<LatLng>) {
        if (mPolyline != null) {
            mPolyline!!.remove()
        }
        polylineOptions = PolylineOptions()
            .color(R.color.black)
            .width(7f)
            .clickable(false)
            .add(*polyList.toTypedArray<LatLng>())
        mPolyline = mGoogleMap.addPolyline(polylineOptions)
        isDrawPolyLine = true
//        initPhoneAndMidMarkers();
//        if(middleMarker != null) {
//            middleMarker.setVisible(true);
//            middleMarker.setPosition(mCameraIdleLatLngOld);
//        }
    }


    override fun clearPolyline() {
        mPolyline?.remove()
        isDrawPolyLine = false
        if (isMarkerClick) {
            showMethodWithCurLoc()
            isMarkerClick = false
        }
    }
}