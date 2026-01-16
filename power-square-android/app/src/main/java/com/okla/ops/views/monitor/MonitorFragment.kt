package com.okla.ops.views.monitor

//import com.okla.ops.views.workbench.device.DeviceDetailActivity
import android.Manifest
import android.animation.Animator
import android.animation.Animator.AnimatorListener
import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.location.Location
import android.os.Bundle
import android.provider.Settings
import android.text.TextUtils
import android.view.View
import android.view.ViewGroup
import android.view.animation.LinearInterpolator
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.delegate.NetworkChangeDelegate
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.beans.LocationData
import com.base.common.custom.BottomSpacingItemDecoration
import com.base.common.map.GeoLocationCallback
import com.base.common.map.IBaseGeoLocation
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.DensityUtil
import com.base.common.utils.LocationAddressUtils.getAddressByCoroutine
import com.base.common.utils.LocationAddressUtils.getAddressByLocal
import com.base.common.utils.LocationAddressUtils.saveAddressToLocal
import com.base.library.utils.StringUtil
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.BatteryDevice
import com.okla.ops.beans.NearByVehicle
import com.okla.ops.databinding.FragmentMonitorBinding
import com.okla.ops.utils.LocationUtil
import com.okla.ops.views.map.MapFactory
import com.okla.ops.views.map.main.IMapCallback
import com.okla.ops.views.map.main.IMapView
import com.okla.ops.views.workbench.devicedetail.DeviceDetailActivity
import com.luck.picture.lib.thread.PictureThreadUtils.runOnUiThread
import com.lxj.xpopup.XPopup
import com.lxj.xpopup.enums.PopupPosition
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MonitorFragment : BaseNormalVFragment<MonitorViewModel, FragmentMonitorBinding>(),
    IMapCallback,
    GeoLocationCallback {

    companion object {
        fun newInstance(): MonitorFragment {
            return MonitorFragment()
        }
    }

    private val mBatteryCount = 1000
    private val mBatteryRadius = 30 * 1000
    private var mStatus: Int? = null
    private lateinit var mMapView: IMapView
    lateinit var mGeoLocation: IBaseGeoLocation
    private var centerLocationData: LocationData = LocationData()

    private lateinit var networkChangeDelegate: NetworkChangeDelegate
    private lateinit var permissionManager: PermissionManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            requireActivity().activityResultRegistry,
            this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        networkChangeDelegate = NetworkChangeDelegate()
        networkChangeDelegate.register(context)
        networkChangeDelegate.setOnNetworkChangeListener {
            askPermission()
        }
        initObserver()
    }

    override fun onStart() {
        super.onStart()
        mMapView.onStart()
    }

    private val permissions = mutableListOf(
        Manifest.permission.ACCESS_FINE_LOCATION,
        Manifest.permission.ACCESS_COARSE_LOCATION,
//            Manifest.permission.READ_EXTERNAL_STORAGE,
        Manifest.permission.ACCESS_NETWORK_STATE,
        Manifest.permission.ACCESS_WIFI_STATE,
//            Manifest.permission.CAMERA,
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        if (!LocationUtil.isLocationServiceEnabled(requireContext())) {
            var haveShow = DataStoreUtils.readBooleanData(
                DataStoreKeyUtils.HAVE_SHOW_LOCATION_SERVICE_TIP,
                false
            )
            if (!haveShow) {
                // 定位服务未开启，提示用户去设置页面打开
                AlertDialog.Builder(requireContext())
                    .setTitle(requireContext().getString(R.string.str_open_location_service))
                    .setMessage(requireContext().getString(R.string.tip_open_location_service))
                    .setPositiveButton(requireContext().getString(R.string.str_go_to_settings)) { _, _ ->
                        startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS))
                    }
                    .setNegativeButton(
                        requireContext().getString(com.base.common.R.string.cc_str_cancel),
                        null
                    )
                    .show()
                DataStoreUtils.saveSyncBooleanData(
                    DataStoreKeyUtils.HAVE_SHOW_LOCATION_SERVICE_TIP,
                    true
                )
            }

        }
    }

    override fun onResume() {
        super.onResume()
        mMapView.onResume()
        if (!PermissionManager.hasPermissions(context, permissions)) {
            if (isNeedAskPermission) {
                askPermission()
            }
        } else {
            mGeoLocation.onStartLocate(this@MonitorFragment, 10 * 1000L, 10f)
        }
        getNearVehicleList()
    }

    override fun onPause() {
        super.onPause()
        onMapClick()//离开界面
        mMapView.onPause()
        mGeoLocation.onPauseLocate()
    }

    override fun onStop() {
        super.onStop()
        stopRotateAnimationRefresh()
        stopRotateAnimationLoc()
        mMapView.onStop()
        mGeoLocation.onStopLocate()
    }

    override fun onDestroy() {
        super.onDestroy()
        networkChangeDelegate.unregister()
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

    private var isNeedAskPermission = true
    private fun askPermission() {
        val permissions = mutableListOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
//            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.ACCESS_WIFI_STATE,
//            Manifest.permission.CAMERA,
        )
//        if (SdkVersionUtils.isTIRAMISU()) {
//            permissions.remove(Manifest.permission.READ_EXTERNAL_STORAGE)
//        }
        permissionManager.checkPermissions(object : PermissionListenerImpl() {
            override fun passPermission() {
                super.passPermission()
                mGeoLocation.onStartLocate(this@MonitorFragment, 10 * 1000L, 10f)
            }

            override fun deniedPermission() {
                super.deniedPermission()
                isNeedAskPermission = false
                PermissionManager.askForPermission(requireActivity(), "")
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(requireActivity(), "")
            }
        }, *permissions.toTypedArray())
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_monitor
    }

    override fun onCreateViewModel(): MonitorViewModel {
        return ViewModelProvider(this)[MonitorViewModel::class.java]
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        mMapView = MapFactory.getMapInstance(requireContext())
        val mapView = mMapView.createMapView(savedInstanceState, this)
        val params = ConstraintLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        mBinding.map.addView(mapView, params)
        mGeoLocation = MapFactory.getMapLocation(requireContext())
        mGeoLocation.initLocationClient()
        initTopAndBottom()
        createAdapter()
        initListener()
        initClick()
    }

    private fun initListener() {
        mBinding.batteryMapInfoView.setOnMoreClickListener {
            context?.let { context ->
                mBinding.batteryMapInfoView.visibility = View.GONE
                setCollapsedSlideView()
//                DeviceDetailActivity.startDeviceDetailActivity(
//                    context,
//                    it, 0
//                )
            }
        }
    }

    private fun initClick() {
        mBinding.ivFilter.setOnClickListener(this)
        mBinding.ivLocation.setOnClickListener(this)
        mBinding.ivRefresh.setOnClickListener(this)
        mBinding.etSearch.setOnClickListener(this)
    }

    private fun initObserver() {
        getViewModel().vehicleListLiveData.observe(this) {
            if (isMapReady) {
                it?.let { it1 ->
                    mBinding.batteryMapInfoView.visibility = View.GONE
                    mMapView.updateNearByVehiclelist(it1)
//                    if(isFirstLoad){
//                    }
//                    if (mStatus == null) {
//                        mMapView.onSwitchMarker(-1)
//                    } else {
//                        mMapView.onSwitchMarker(mStatus!!)
//                    }
                }
            }
            mMapView.setCenter()
            if (it.isNullOrEmpty()) {
                hideCollapsedSlideView()
            } else {
                setCollapsedSlideView()
            }
            mAdapter.setNewData(it)
        }
        //路线规划
        getViewModel().mRoutesData.observe(this) {
            it?.routes?.run {
                if (size > 0) {
                    if (this[0].overview_polyline != null && isMapReady) {
                        mMapView.drawRoute(it)
                    }
                    if (this[0].legs != null) {
                        val distance = this[0].legs[0].distance
                        StringUtil.m2km(distance.value.toDouble())
                    }
                }
            }
        }
        getViewModel().mPhoneLiveData.observe(this, {
            it?.let {
                mBinding.batteryMapInfoView.updatePhone((it ?: "-").toString())

            }
        })
    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.etSearch -> {
                context?.let {
                    VehicleSearchListActivity.startVehicleSearchListActivity(
                        it,
                        centerLocationData.latitude,
                        centerLocationData.longitude
                    )
                }
            }

            R.id.iv_filter -> {
                XPopup.Builder(context)
                    .atView(v)
                    .popupPosition(PopupPosition.Bottom)
                    .asCustom(
                        MapSwitchPopup(
                            requireContext(),
                            mMapView.getSwitchType()
                        ) { position ->
                            mMapView.clearPolyline()//删除路径线
                            mMapView.onSwitchMarker(position)
                            mBinding.ivFilter.isSelected = position != 0
                            mStatus = position - 1
                            if (mStatus == -1) {
                                mStatus = null
                            }
                            getNearVehicleList()
                        })
                    .show()
            }

            R.id.ivLocation -> {
                startRotateAnimationLoc()
                rotateAnimatorLoc?.addListener(object : AnimatorListener {
                    override fun onAnimationStart(animation: Animator) {
                        mMapView.setCenter()
                    }

                    override fun onAnimationEnd(animation: Animator) {
                    }

                    override fun onAnimationCancel(animation: Animator) {

                    }

                    override fun onAnimationRepeat(animation: Animator) {
                        stopRotateAnimationLoc()
                    }
                })
            }

            R.id.ivRefresh -> {
                startRotateAnimationReresh()
                rotateAnimatorReresh?.addListener(object : AnimatorListener {
                    override fun onAnimationStart(animation: Animator) {
                        mMapView.refreshCenterPoi(centerLocationData)
                    }

                    override fun onAnimationEnd(animation: Animator) {
                    }

                    override fun onAnimationCancel(animation: Animator) {

                    }

                    override fun onAnimationRepeat(animation: Animator) {
                        stopRotateAnimationRefresh()
                    }
                })
            }
        }
    }

    private var rotateAnimatorReresh: ObjectAnimator? = null
    private var rotateAnimatorLoc: ObjectAnimator? = null
    private fun startRotateAnimationReresh() {
        // 围绕自身中心旋转
        rotateAnimatorReresh =
            ObjectAnimator.ofFloat(mBinding.ivRefresh, View.ROTATION, 0f, 360f).apply {
                duration = 1000L  // 一圈用时 1 秒
                repeatCount = ValueAnimator.INFINITE
                interpolator = LinearInterpolator() // 匀速转动
                start()
            }
    }

    private fun stopRotateAnimationRefresh() {
        rotateAnimatorReresh?.run {
            cancel()
            // 可选：复位角度
            mBinding.ivRefresh.rotation = 0f
        }
    }

    private fun startRotateAnimationLoc() {
        // 围绕自身中心旋转
        rotateAnimatorLoc =
            ObjectAnimator.ofFloat(mBinding.ivLocation, View.ROTATION, 0f, 360f).apply {
                duration = 1000L  // 一圈用时 1 秒
                repeatCount = ValueAnimator.INFINITE
                interpolator = LinearInterpolator() // 匀速转动
                start()
            }
    }

    private fun stopRotateAnimationLoc() {
        rotateAnimatorLoc?.run {
            cancel()
            // 可选：复位角度
            mBinding.ivLocation.rotation = 0f
        }
    }

    private var bottomSheetBatteryBehavior: BottomSheetBehavior<ConstraintLayout>? = null
    private fun initTopAndBottom() {
        bottomSheetBatteryBehavior = BottomSheetBehavior.from(mBinding.includeSlide.clBottomSheet)
    }

    private fun setCollapsedSlideView() {
        mBinding.includeSlide.clBottomSheet.visibility = View.VISIBLE
        mBinding.includeSlide.rvBattery.scrollTo(0, 0)
        bottomSheetBatteryBehavior?.peekHeight = DensityUtil.dp2px(152f)
        bottomSheetBatteryBehavior?.setState(BottomSheetBehavior.STATE_COLLAPSED)
    }

    private fun hideCollapsedSlideView() {
        mBinding.includeSlide.clBottomSheet.visibility = View.GONE
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<NearByVehicle>
    private fun createAdapter() {
        mBinding.includeSlide.rvBattery.layoutManager =
            LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<NearByVehicle>(R.layout.item_battery) {
            override fun convert(helper: BaseViewHolder, item: NearByVehicle) {
                super.convert(helper, item)
                context?.let {
                    Glide.with(it).load(item.img).into(helper.getView(R.id.ivBattery))
                    val sn = item.sn ?: "-"
                    helper.getView<AppCompatTextView>(R.id.tvSn).text =
                        it.getString(R.string.text_sn_str, sn)
                    val tvCoordinates: AppCompatTextView = helper.getView(R.id.tvCoordinates)
                    val tvDistance: AppCompatTextView = helper.getView(R.id.tvDistance)
                    if (item.latitude != null && item.latitude != 0.0 && item.longitude != null && item.longitude != 0.0) {
                        tvCoordinates.text = it.getString(
                            R.string.text_coordinates_str,
                            "${item.longitude}  ${item.latitude}"
                        )
                        val distance = FloatArray(1)
                        Location.distanceBetween(
                            centerLocationData.latitude,
                            centerLocationData.longitude,
                            item.latitude,
                            item.longitude,
                            distance
                        )
                        tvDistance.text = StringUtil.m2km(distance[0].toDouble())
                    } else {
                        tvCoordinates.text = "-"
                        tvDistance.text = "-"
                    }
                    val tvStatus: AppCompatTextView = helper.getView(R.id.tvStatus)
                    tvStatus.setCompoundDrawablesRelativeWithIntrinsicBounds(
                        null,
                        null,
                        null,
                        null
                    )
                    if (item.needMaintenance == true) {
                        helper.setGone(R.id.tvStatus, true)
                    } else {
                        helper.setGone(R.id.tvStatus, false)
                    }
                    helper.setText(
                        R.id.tvBindid,
                        mContext.getString(R.string.str_binding_id, item.cardNum ?: "-")
                    )
                    // 先给一个占位
                    helper.setText(R.id.tvCoordinates, mContext.getString(R.string.str_loading))
                    setDetailAddress(helper.getView(R.id.tvCoordinates), item)
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                context?.let {
                    val battery = adapter.data[position] as NearByVehicle
                    DeviceDetailActivity.startDeviceDetailActivity(
                        it,
                        battery.sn, 0
                    )
                }
            }
        mBinding.includeSlide.rvBattery.addItemDecoration(BottomSpacingItemDecoration(6))
        mBinding.includeSlide.rvBattery.adapter = mAdapter
        mAdapter.setNewData(mutableListOf())
    }

    override fun onMapMarkerClick(battery: BatteryDevice) {

    }

    override fun onMapMarkerVehicleClick(battery: NearByVehicle) {
        if (!TextUtils.isEmpty(battery.cardNum)) {
            getViewModel().getPhoneByCardNum(battery.cardNum ?: "")
        }
        if (battery.latitude != null && battery.longitude != null) {
            getRoutes(battery.latitude, battery.longitude)
        }
        mBinding.batteryMapInfoView.updateData(battery, centerLocationData)
        mBinding.batteryMapInfoView.visibility = View.VISIBLE
        hideCollapsedSlideView()
    }


    override fun onMapClick() {
        if (mAdapter.data.isNotEmpty()) {
            setCollapsedSlideView()
        }
        mBinding.batteryMapInfoView.visibility = View.GONE
        mMapView.clearPolyline()
    }

    private var isMapReady = false
    override fun onMapReady() {
        isMapReady = true
    }

    override fun cameraIdle(locationData: LocationData, isRefresh: Boolean) {
        if (isRefresh) {
            getViewModel().getNearByVehicleList(
                locationData.latitude,
                locationData.longitude,
                mBatteryCount,
                mBatteryRadius,
                null,
                mStatus
            )
        }
    }

    private var isFirstLoad = true
    override fun onLocationChanged(locationData: LocationData) {
        centerLocationData = locationData
        mActivity?.runOnUiThread {
            mMapView.refreshCenterPoi(locationData)
        }
        if (isFirstLoad) {
            getNearVehicleList()
            isFirstLoad = false
        }
    }

    private var appInfo: ApplicationInfo? = null
    private var google_key: String? = null
    private fun getRoutes(latitude: Double, longitude: Double) {
        try {
            if (appInfo == null || StringUtil.isEmpty(appInfo)) {
                appInfo = requireContext().packageManager.getApplicationInfo(
                    requireContext().packageName,
                    PackageManager.GET_META_DATA
                )
                google_key = appInfo?.metaData?.getString("direction.api.key", "")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        if (centerLocationData.latitude != 0.0 && centerLocationData.longitude != 0.0 && google_key != null) {
            getViewModel().getRoutes(
                "${centerLocationData.latitude},${centerLocationData.longitude}",
                "$latitude,$longitude",
                "highways",
                "WALKING",
                google_key ?: ""
            )
        }
    }

    private fun getNearVehicleList() {
        if (centerLocationData.latitude != 0.0 && centerLocationData.longitude != 0.0) {
            getViewModel().getNearByVehicleList(
                centerLocationData.latitude,
                centerLocationData.longitude,
                mBatteryCount,
                mBatteryRadius,
                null,
                mStatus
            )
        }

    }

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()

    private fun setDetailAddress(tvDetailAddress: TextView, item: NearByVehicle) {
        val address = getAddressByLocal(
            item.latitude ?: 0.0,
            item.longitude ?: 0.0,
            item.sn ?: ""
        )

        if (TextUtils.isEmpty(address)) {
            executor.execute(Runnable { getAddressAsync(item, tvDetailAddress) })
        } else {
            tvDetailAddress.text = address
        }
    }

    private fun getAddressAsync(info: NearByVehicle, tvAddress: TextView) {
        if (info.latitude != null && info.longitude != null && info?.sn != null) {
            // 调用协程替代方法，这里改为 Java 实现的网络请求或 Geocoder 操作
            val result = context?.let {
                getAddressByCoroutine(
                    info.latitude,
                    info.longitude,
                    it
                )
            }

            result?.let {
                saveAddressToLocal(
                    info.latitude,
                    info.longitude,
                    info.sn,  //救援单号
                    it
                )
            }

            runOnUiThread(Runnable { tvAddress.text = result })
        }
    }
}