package com.okla.ops.views.monitor

import android.Manifest
import android.content.Context
import android.content.Intent
import android.location.Location
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.TextView
import androidx.appcompat.widget.AppCompatTextView
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.custom.BottomSpacingItemDecoration
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.WindowInsetsHelper
import com.base.library.utils.GsonUtils
import com.base.library.utils.StringUtil
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseViewHolder
import com.google.gson.reflect.TypeToken
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.NearByVehicle
import com.okla.ops.beans.SearchHistory
import com.okla.ops.databinding.ActivityBatterySearchListBinding
import com.okla.ops.utils.ScanUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.devicedetail.DeviceDetailActivity
import com.okla.ops.weight.SearchHistoryView
import com.okla.ops.weight.SearchScanTitleView.OnSearchScanTitleListener
import com.luck.picture.lib.utils.SdkVersionUtils

class VehicleSearchListActivity :
    BaseNormalListVActivity<MonitorViewModel, ActivityBatterySearchListBinding>() {

    companion object {
        fun startVehicleSearchListActivity(context: Context, latitude: Double, longitude: Double) {
            val intent = Intent(context, VehicleSearchListActivity::class.java)
            intent.putExtra("latitude", latitude)
            intent.putExtra("longitude", longitude)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): MonitorViewModel {
        return ViewModelProvider(this)[MonitorViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_battery_search_list
    }

    private var deviceSn: String = ""
    private var mMyLatitude: Double = 0.0
    private var mMyLongitude: Double = 0.0
    override fun getIntentExtras(intent: Intent?) {
        super.getIntentExtras(intent)
        mMyLatitude = intent?.getDoubleExtra("latitude", 0.0) ?: 0.0
        mMyLongitude = intent?.getDoubleExtra("longitude", 0.0) ?: 0.0
    }

    private val mBatteryCount = 1000
    private val mBatteryRadius = 30 * 1000
    private lateinit var permissionManager: PermissionManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            activityResultRegistry, this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        initObserver()
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        initListener()
        mBinding.searchScanTitleView.setSearchHint(getString(R.string.hint_enter_device_or_scan_qr_code))
        WindowInsetsHelper.applyForToolbar(this,mBinding.searchScanTitleView.id)
        switchViewDefault()
        initData()
    }

    private fun initData() {
        val historyJson = readHistoryData()
        if (historyJson.isNotEmpty()) {
            val type = object : TypeToken<MutableList<SearchHistory>>() {}.type
            mBinding.searchHistoryView.setHistoryData(GsonUtils.fromGson(historyJson, type))
        }
    }

    private fun readHistoryData(): String {
        val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")
        return DataStoreUtils.readStringData(
            DataStoreKeyUtils.HISTORY_SEARCH_MONITOR_VEHICLES.plus(
                account
            )
        )
    }

    private fun clearHistory() {
        val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")
        DataStoreUtils.saveSyncStringData(
            DataStoreKeyUtils.HISTORY_SEARCH_MONITOR_VEHICLES.plus(account),
            ""
        )
    }

    private fun addHistory(content: String) {
        if (TextUtils.isEmpty(content)) return
        if (!mBinding.searchHistoryView.isExistHistoryData(content)) {
            var historyJson = readHistoryData()
            if (historyJson.isNotEmpty()) {
                val type = object : TypeToken<MutableList<SearchHistory>>() {}.type
                val historyList = GsonUtils.fromGson<MutableList<SearchHistory>>(historyJson, type)
                if (historyList.size > 4) {
                    historyList.removeAt(0)
                }
                historyList.add(0, SearchHistory(content, content))
                mBinding.searchHistoryView.setHistoryData(historyList)
                historyJson = GsonUtils.toGson(historyList)
            } else {
                val list: MutableList<SearchHistory> = mutableListOf()
                list.add(SearchHistory(content, content))
                mBinding.searchHistoryView.setHistoryData(list)
                historyJson = GsonUtils.toGson(list)
            }
            val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")
            DataStoreUtils.saveSyncStringData(
                DataStoreKeyUtils.HISTORY_SEARCH_MONITOR_VEHICLES.plus(account),
                historyJson
            )
        }
    }

    private fun initObserver() {
//        getViewModel().mEquipmentDeviceSearchBeanData.observe(this,{
//
//        })
        getViewModel().vehicleListLiveData.observe(this) {
            mAdapter.setNewData(it)
            if (it != null && it.isNotEmpty()) {
                addHistory(deviceSn)
            }
            it?.let { it1 -> switchViewBySearchResult(it1) }
        }
    }

    private fun initListener() {
        mBinding.searchScanTitleView.setOnSearchScanTitleListener(object :
            OnSearchScanTitleListener {
            override fun onScanClick() {
                askPermission()
            }

            override fun onSearch(content: String?) {
                if (!TextUtils.isEmpty(content)) {
                    deviceSn = content!!
                    onRefresh()
                } else {
                    switchViewDefault()
                }
            }

            override fun onBack() {
                finish()
            }

        })
    }

    private fun switchViewBySearchResult(list: MutableList<NearByVehicle>) {
        if (list.isNullOrEmpty()) {
            mBinding.searchHistoryView.visibility = View.GONE
            mBinding.swipRefresh.visibility = View.GONE
            mBinding.emptyView.visibility = View.VISIBLE

        } else {
            mBinding.searchHistoryView.visibility = View.GONE
            mBinding.swipRefresh.visibility = View.VISIBLE
            mBinding.emptyView.visibility = View.GONE
        }
    }

    private fun switchViewDefault() {
        mBinding.emptyView.visibility = View.GONE
        mBinding.swipRefresh.visibility = View.GONE
        mBinding.searchHistoryView.visibility = View.VISIBLE
        mBinding.emptyView.findViewById<TextView>(R.id.tvNoData).text =
            mContext.getString(R.string.str_empty_search_tip)
        mBinding.searchHistoryView.setListener(object : SearchHistoryView.OnClickListener {
            override fun onSelectedName(id: String) {
                deviceSn = id
                onRefresh()
            }

            override fun onClearSearchName() {
                clearHistory()
            }
        })
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<NearByVehicle>
    override fun createAdapter(): RecyclerView.Adapter<*> {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<NearByVehicle>(R.layout.item_battery) {
            override fun convert(
                helper: BaseViewHolder,
                item: NearByVehicle
            ) {
                super.convert(helper, item)
                Glide.with(this@VehicleSearchListActivity).load(item.img)
                    .into(helper.getView(R.id.ivBattery))
                val sn = item.sn ?: "-"
                helper.getView<AppCompatTextView>(R.id.tvSn).text =
                    getString(R.string.text_sn_str, sn)
                val tvCoordinates: AppCompatTextView = helper.getView(R.id.tvCoordinates)
                val tvDistance: AppCompatTextView = helper.getView(R.id.tvDistance)
                if (item.latitude != null && item.latitude != 0.0 && item.longitude != null && item.longitude != 0.0) {
                    tvCoordinates.text = getString(
                        R.string.text_coordinates_str,
                        "${item.latitude}  ${item.longitude}"
                    )
                    val distance = FloatArray(1)
                    Location.distanceBetween(
                        mMyLatitude,
                        mMyLongitude,
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
                if (item.needMaintenance == true) {
                    tvStatus.visibility = View.VISIBLE
                } else {
                    tvStatus.visibility = View.GONE
                }
                helper.setText(
                    R.id.tvBindid,
                    mContext.getString(R.string.str_binding_id, item.cardNum)
                )
            }
        }
        mAdapter.setOnItemClickListener { adapter, _, position ->
            val battery = adapter.data[position] as NearByVehicle
            DeviceDetailActivity.startDeviceDetailActivity(
                this@VehicleSearchListActivity,
                battery.sn ?: "", 0
            )
        }
        return mAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        mBinding.rvBattery.addItemDecoration(BottomSpacingItemDecoration(6))
        return mBinding.rvBattery
    }

    override fun initPageData() {
        getViewModel().getNearByVehicleList(
            mMyLatitude,
            mMyLongitude,
            mBatteryCount,
            mBatteryRadius,
            deviceSn,
            null
        )
    }

    private fun askPermission() {
        val permissions = mutableListOf(
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.CAMERA,
        )
        if (SdkVersionUtils.isTIRAMISU()) {
            permissions.remove(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
        permissionManager.checkPermissions(object : PermissionListenerImpl() {
            override fun passPermission() {
                super.passPermission()
//                startActivityForResult(Intent(this@BatterySearchListActivity,QRCodeActivity::class.java),QrCodeUtils.REQUEST_CODE_DEFINE)
//                QrCodeUtils.startScanQrCode(this@BatterySearchListActivity)
                IntentIntegrator(this@VehicleSearchListActivity)
                    .setOrientationLocked(false)
                    .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                    .setCaptureActivity(QRCodeActivity::class.java)
                    .initiateScan() //  初始化扫描
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(this@VehicleSearchListActivity, "")
            }
        }, *permissions.toTypedArray())
    }

    /**
     * Event for receiving the activity result.
     *
     * @param requestCode Request code.
     * @param resultCode Result code.
     * @param data        Result.
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode != RESULT_OK || data == null) {
            return
        }
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            val mScanResult = intentResult?.contents ?: ""
            deviceSn = ScanUtils.Companion.getDeviceSn(mContext, mScanResult)
            if (!TextUtils.isEmpty(deviceSn)) {
                onRefresh()
            }
        }
    }

}