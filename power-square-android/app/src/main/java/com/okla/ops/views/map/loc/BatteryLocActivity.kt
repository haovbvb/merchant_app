package com.okla.ops.views.map.loc

import android.Manifest
import android.content.Context
import android.content.Intent
import android.location.Location
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.view.ViewGroup
import android.view.animation.Animation
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.beans.LocationData
import com.base.common.map.GeoLocationCallback
import com.base.common.map.IBaseGeoLocation
import com.base.common.map.navigation.GoogleMapNavigation
import com.base.common.map.popup.MapPopup
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.LocationAddressUtils
import com.base.common.utils.StatusBarUtil
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.utils.StringUtil
import com.chad.library.adapter.base.BaseViewHolder
import com.google.android.gms.maps.model.Marker
import com.luck.picture.lib.thread.PictureThreadUtils
import com.lxj.xpopup.XPopup
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.BatteryDetail
import com.okla.ops.databinding.ActivityLocBatteryBinding
import com.okla.ops.utils.TextUtil
import com.okla.ops.views.map.MapFactory
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class BatteryLocActivity :
    BaseNormalListVActivity<BaseViewModel, ActivityLocBatteryBinding>(),
    ITrajectoryMapCallback,
    GeoLocationCallback, TextUtil {

    companion object {
        fun startBatteryLocActivity(context: Context, batArray: Array<BatteryDetail>) {
            val intent = Intent(context, BatteryLocActivity::class.java)
            val bundle = Bundle()
            bundle.putParcelableArray("batArray", batArray)
            intent.putExtras(bundle)
            context.startActivity(intent)
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_loc_battery;
    }

    lateinit var mMapView: ITrajectoryMapView
    lateinit var mGeoLocation: IBaseGeoLocation
    var centerLocationData: LocationData = LocationData()
    lateinit var permissionManager: PermissionManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            activityResultRegistry,
            this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        mGeoLocation = MapFactory.getMapLocation(this)
        mGeoLocation.initLocationClient()
        askPermissionLoc()
        centerLocationData.latitude =
            DataStoreUtils.readDoubleData(DataStoreKeyUtils.LATLNG_LATITUDE)
        centerLocationData.longitude =
            DataStoreUtils.readDoubleData(DataStoreKeyUtils.LATLNG_LONTITUDE)
    }

    override fun buildLayoutManager(): RecyclerView.LayoutManager {
        val manager = LinearLayoutManager(this)
        manager.orientation = LinearLayoutManager.HORIZONTAL
        return manager
    }

    override fun onCreateViewModel(): BaseViewModel {
        return ViewModelProvider(this)[BaseViewModel::class.java];
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
        mMapView = MapFactory.getBatteryLocMapInstance(this)
        val mapView = mMapView.createMapView(savedInstanceState, this)
        val params = ConstraintLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        mBinding.map.addView(mapView, params)
        initClicks()
    }

    private fun initClicks() {
        mBinding.ivLocation.setOnClickListener(this)
        mBinding.btnBack.setOnClickListener(this)
    }

    var refreshAnimation: Animation? = null
    override fun onClick(v: View?) {
        super.onClick(v)
        when (v?.id) {
            R.id.btnBack -> {
                finish()
            }

            R.id.ivLocation -> {
                mMapView.setCenter()
            }
        }
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<BatteryDetail>

    override fun createAdapter(): RecyclerView.Adapter<*> {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<BatteryDetail>(R.layout.item_battery_loc) {
            override fun convert(helper: BaseViewHolder, item: BatteryDetail) {
                super.convert(helper, item)
                helper.addOnClickListener(R.id.btnNav)
                helper.setText(R.id.tvSN, "SN: ${item.deviceSn}")
                val distance = FloatArray(1)
                Location.distanceBetween(
                    centerLocationData.latitude,
                    centerLocationData.longitude,
                    item.latitude ?: 0.0,
                    item.longitude ?: 0.0,
                    distance
                )
                helper.setText(R.id.tvDistance, StringUtil.m2km(distance[0].toDouble()))
                val tvDetailAddress = helper.getView<TextView>(R.id.tvDetailAddress)
                LocationAddressUtils.getAddressByLocal(
                    item.latitude ?: 0.0,
                    item.longitude ?: 0.0,
                    item.deviceSn ?: ""
                ).apply {
                    if (TextUtils.isEmpty(this)) {
                        singleThreadedExecutor.execute {
                            getAddressCoroutine(item, tvDetailAddress)
                        }
                    } else {
                        tvDetailAddress.text = this
                    }
                }
            }
        }
        mAdapter.setOnItemChildClickListener { _, _, position ->
            val item = mAdapter.data[position]
            if (item.latitude != null && item.longitude != null)
                XPopup.Builder(this)
                    .asCustom(MapPopup(this) {
                        GoogleMapNavigation.startNavigation(
                            this,
                            item?.latitude ?: 0.0,
                            item?.longitude ?: 0.0
                        )
                    })
                    .show()
        }
        return mAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        return mBinding.recyclerView
    }

    override fun initPageData() {

    }

    override fun onMapReady() {
        toMutableList.forEachIndexed { _, battery ->
            if (battery.latitude != null && battery.longitude != null) {
                mMapView.drawMarkerLastPark(
                    battery.latitude, battery.longitude, battery.status ?: 0
                )
            }
        }
        mAdapter.setNewData(toMutableList)
    }

    override fun onMakerClick(mMarker: Marker) {
        //点击
        (mBinding.recyclerView.layoutManager as LinearLayoutManager).scrollToPositionWithOffset(
            mMarker.tag as Int,
            0
        )
    }

    private val toMutableList: MutableList<BatteryDetail> = mutableListOf()
    override fun getIntentExtras(intent: Intent?) {
        super.getIntentExtras(intent)
        val parcelableArray = intent?.getParcelableArrayExtra("batArray")
        parcelableArray?.let {
            val myDataArray = parcelableArray.filterIsInstance<BatteryDetail>().toTypedArray()
            myDataArray.forEach {
                toMutableList.add(it)
            }
        }
    }

    override fun onStart() {
        super.onStart()
        mMapView.onStart()
        mGeoLocation.onStartLocate(this, 10 * 1000L, 10f)
    }

    override fun onResume() {
        super.onResume()
        mMapView.onResume()
    }

    override fun onPause() {
        super.onPause()
        mMapView.onPause()
        mGeoLocation.onPauseLocate()
    }

    override fun onStop() {
        super.onStop()
        mMapView.onStop()
        mGeoLocation.onStopLocate()
    }

    override fun onDestroy() {
        super.onDestroy()
        mMapView.onDestroy()
    }

    override fun onLowMemory() {
        super.onLowMemory()
        mMapView.onLowMemory()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        mMapView.onSaveInstanceState(outState)
    }

    fun askPermissionLoc() {
        val permissions = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        )
        permissionManager.checkPermissions(object : PermissionListenerImpl() {
            override fun passPermission() {
                super.passPermission()
                mGeoLocation.onStartLocate(this@BatteryLocActivity, 10 * 1000L, 10f)
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(this@BatteryLocActivity, "")
            }
        }, *permissions)
    }

    var isFirstLoad = true
    override fun onLocationChanged(data: LocationData) {
        centerLocationData = data
        mMapView.refreshCenterPoi(data)
        DataStoreUtils.saveSyncDoubleData(DataStoreKeyUtils.LATLNG_LATITUDE, data.latitude)
        DataStoreUtils.saveSyncDoubleData(DataStoreKeyUtils.LATLNG_LONTITUDE, data.longitude)
        mAdapter?.notifyDataSetChanged()
        if (isFirstLoad) {
            mMapView.setCenter()
            isFirstLoad = false
        }
    }

    val singleThreadedExecutor: ExecutorService = Executors.newSingleThreadExecutor()

    fun getAddressCoroutine(info: BatteryDetail, tvAddress: TextView) = runBlocking {
        launch {
            if (info.deviceSn != null && info.latitude != null && info.longitude != null) {
                val result =
                    LocationAddressUtils.getAddressByCoroutine(
                        info.latitude,
                        info.longitude,
                        this@BatteryLocActivity
                    )
                LocationAddressUtils.saveAddressToLocal(
                    info.latitude,
                    info.longitude, info.deviceSn, result
                )
                runOnUiThread {
                    tvAddress.text = result
                }
            }
        }
    }

}
