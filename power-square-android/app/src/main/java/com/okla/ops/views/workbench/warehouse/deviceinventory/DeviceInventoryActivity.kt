package com.okla.ops.views.workbench.warehouse.deviceinventory

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.custom.SpaceItemDecoration
import com.base.library.utils.DensityUtils
import com.base.library.utils.StringUtil
import com.chad.library.adapter.base.BaseViewHolder
import com.google.android.material.tabs.TabLayout
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.DeviceInventory
import com.okla.ops.beans.DeviceType
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.databinding.ActivityDeviceInventoryBinding
import com.okla.ops.dialog.SelectDeviceTypeDialog
import com.okla.ops.views.workbench.warehouse.DeviceTransorInVentorySearchActivity

class DeviceInventoryActivity :
    BaseNormalListVActivity<DeviceInventoryViewModel, ActivityDeviceInventoryBinding>() {

    companion object {
        fun getIntents(context: Context) {
            context.startActivity(Intent(context, DeviceInventoryActivity::class.java))
        }
    }

    override fun onCreateViewModel(): DeviceInventoryViewModel {
        return ViewModelProvider(this).get(DeviceInventoryViewModel::class.java)
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_device_inventory
    }

    override fun title(): Int {
        return R.string.inventory_inventory
    }

    override fun onRestart() {
        super.onRestart()
        onRefresh()
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        getStatusView().enableRefresh = true
        getStatusView().enableLoadMore = true
        initIndicator()
        mBinding.includeTitle.topRightImage.setImageDrawable(
            ContextCompat.getDrawable(
                this,
                R.mipmap.icon_add_device_send
            )
        )
        mBinding.includeTitle.topRightImage.visibility = View.VISIBLE
        mBinding.clEmpty.setIcon(ContextCompat.getDrawable(this, R.mipmap.icon_empty_inventory))
        mBinding.clEmpty.setTextInfo(getString(R.string.inventory_list_empty))
        mBinding.clEmpty.setBtnCreateGone()
        initObserver()
        initClick()
        onRefresh()
    }

    private var mStatus: Int? = null
    private val mTitleDataList = mutableListOf<String>()
    private fun initIndicator() {
        //初始化标题列表（可根据需要清空再填充）
        mTitleDataList.clear()
        mTitleDataList.add(getString(R.string.transport_all))
        mTitleDataList.add(getString(R.string.str_completed))
        mTitleDataList.add(getString(R.string.str_unfinished))
        mTitleDataList.add(getString(R.string.str_revoked))
        mTitleDataList.forEach { title ->
            val tab = mBinding.tabLayout.newTab()
            val customView = LayoutInflater.from(this).inflate(R.layout.layout_custom_tab, null)
            customView.findViewById<TextView>(R.id.tabText).text = title
            tab.customView = customView
            mBinding.tabLayout.addTab(tab)
        }
        mBinding.tabLayout.setSelectedTabIndicator(null)
        mBinding.tabLayout.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = true
                val position = tab?.position ?: 0
                mStatus = when (position) {
                    0 -> null
                    1 -> 1
                    2 -> 0
                    3 -> 2
                    else -> mStatus
                }
                onRefresh()
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = false

            }

            override fun onTabReselected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = true

            }
        })

    }

    private fun initClick() {
//        mBinding.clEmpty.setOnCreateListener {
//            showCreateInventoryDialog()
//        }
        mBinding.tvSearch.setOnClickListener(this)
    }

    private fun initObserver() {
        getViewModel().mDeviceInventoryRespLiveData.observe(this) {
            updateListItems(it?.list)
            if (data.isEmpty()) {
                mBinding.clEmpty.visibility = View.VISIBLE
                mBinding.swipRefresh.visibility = View.GONE
            } else {
                mBinding.clEmpty.visibility = View.GONE
                mBinding.swipRefresh.visibility = View.VISIBLE
            }
        }
//        getViewModel().mInventoryWarehouseListLiveData.observe(this) {
//            it?.let { it1 -> showSelectInventoryWarehouseDialog(it1) }
//        }
    }

    private var keyword: String = ""
    private var mSelectDeviceTypeDialog: SelectDeviceTypeDialog? = null
    private val mDeviceTypeList = mutableListOf<DeviceType>()
    override fun onRightImage() {
//        showCreateInventoryDialog()
        showSelectDeviceTypeDialog()

    }

    private fun showSelectDeviceTypeDialog() {
        if (mDeviceTypeList.isEmpty()) {
            mDeviceTypeList.add(
                DeviceType(
                    resources.getString(R.string.transport_battery),
                    DeviceTypeObject.TYPE_BATTERY
                )
            )
            mDeviceTypeList.add(
                DeviceType(
                    resources.getString(R.string.transport_vehicle),
                    DeviceTypeObject.TYPE_VEHICLE
                )
            )
            mDeviceTypeList.add(
                DeviceType(resources.getString(R.string.transport_station),
                        DeviceTypeObject.TYPE_STATION))

        }
        if (mSelectDeviceTypeDialog == null) {
            mSelectDeviceTypeDialog = SelectDeviceTypeDialog(this, mDeviceTypeList)
            mSelectDeviceTypeDialog?.setOnClickListener {
                DeviceInventoryDetailActivity.getIntents(
                    this@DeviceInventoryActivity,
                    it,
                    DeviceInventoryDetailActivity.OPT_CREATE
                )
            }
        }
        mSelectDeviceTypeDialog?.show()
    }

//    private var mCreateInventoryDialog: CreateInventoryDialog? = null
//    private fun showCreateInventoryDialog() {
//        if (mCreateInventoryDialog == null) {
//            mCreateInventoryDialog = CreateInventoryDialog(this)
//            mCreateInventoryDialog?.setOnClickListener(object :
//                CreateInventoryDialog.OnClickListener {
//                override fun onConfirmClick(str: String, type: Int) {
//                    mSelectInventoryWarehouseDialog?.clear()
//                    DeviceInventoryDetailActivity.getIntents(
//                        this@DeviceInventoryActivity,
//                        type,
//                        DeviceInventoryDetailActivity.OPT_CREATE
//                    )
//                }
//
//                override fun onCancel() {
//                    mSelectInventoryWarehouseDialog?.clear()
//                }
//
//                override fun onSelectWarehouse() {
//                    getViewModel().queryInventoryWarehouseList()
//                }
//
//            })
//        }
//        mCreateInventoryDialog?.show()
//    }

//    /**
//     * 选择盘点创库
//     */
//    private var mSelectInventoryWarehouseDialog: SelectWarehouseDialog? = null
//    private fun showSelectInventoryWarehouseDialog(list: List<WarehouseBean>) {
//        if (mSelectInventoryWarehouseDialog == null) {
//            mSelectInventoryWarehouseDialog =
//                SelectWarehouseDialog(
//                    this,
//                    list,
//                    getString(
//                        R.string.transport_choose_warehouse,
//                        getString(R.string.transport_issue_warehouse)
//                    )
//                )
//            mSelectInventoryWarehouseDialog?.setOnClickListener {
//                it?.let {
//                    mCreateInventoryDialog?.updateData(
//                        it.outWarehouseName,
//                        it.outWarehouseNo,
//                        it.warehouseType
//                    )
//                }
//            }
//        } else {
//            mSelectInventoryWarehouseDialog?.updateList(list)
//        }
//        mSelectInventoryWarehouseDialog?.show()
//    }

    private lateinit var mSingleDataBindingNoPUseAdapter: SingleDataBindingNoPUseAdapter<DeviceInventory>

    override fun createAdapter(): RecyclerView.Adapter<*> {
        mSingleDataBindingNoPUseAdapter = object :
            SingleDataBindingNoPUseAdapter<DeviceInventory>(R.layout.item_device_inventory) {

            override fun convert(helper: BaseViewHolder, item: DeviceInventory) {
                super.convert(helper, item)
                item.run {
                    helper.setText(R.id.tvNumber, inventoryNo)
                    if (warehouseName?.contains("platform") == true) {
                        helper.setText(R.id.tvDesName, mContext.getString(R.string.text_platform))
                    } else {
                        helper.setText(R.id.tvDesName, warehouseName)
                    }
                    helper.setText(R.id.tvInventoryValue, StringUtil.isDataNumberEmpty(inventory))
                    helper.setText(R.id.tvStockValue, StringUtil.isDataNumberEmpty(stock))
                    val tvDevice = helper.getView<AppCompatTextView>(R.id.tvDeviceValue)
                    when (deviceType) {
                        DeviceTypeObject.TYPE_BATTERY -> {
                            tvDevice.setText(R.string.inventory_battery)
                        }

                        DeviceTypeObject.TYPE_VEHICLE  -> {
                            tvDevice.setText(R.string.inventory_vehicle)
                        }

                        DeviceTypeObject.TYPE_STATION->{
                            tvDevice.setText(R.string.inventory_station
                            )
                        }

                    }
                    val tvStatus = helper.getView<AppCompatTextView>(R.id.tvStatus)
                    when (status) {
                        0 -> {//进行中
                            tvStatus.setText(R.string.str_unfinished)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceInventoryActivity,
                                R.drawable.bg_fef7ea_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceInventoryActivity,
                                    R.color.color_ed942f
                                )
                            )
                        }

                        1 -> {//已完成
                            tvStatus.setText(R.string.inventory_complete)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceInventoryActivity,
                                R.drawable.bg_ffeef7e9_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceInventoryActivity,
                                    R.color.main_color
                                )
                            )
                        }

                        2 -> {//已撤销
                            tvStatus.setText(R.string.str_revoked)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceInventoryActivity,
                                R.drawable.bg_fff3f2_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceInventoryActivity,
                                    R.color.color_ffa4332
                                )
                            )
                        }
                    }
                }
            }
        }
        mSingleDataBindingNoPUseAdapter.setOnItemClickListener { adapter, _, position ->
            val itemData = adapter.data[position] as DeviceInventory
            DeviceInventoryDetailActivity.getIntents(
                this@DeviceInventoryActivity,
                itemData.deviceType ?: 0,
                DeviceInventoryDetailActivity.OPT_QUERY,
                itemData.inventoryNo ?: ""
            )
        }
        return mSingleDataBindingNoPUseAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        mBinding.recyclerView.addItemDecoration(SpaceItemDecoration(0, DensityUtils.dp2px(3.0f)))
        return mBinding.recyclerView
    }

    override fun initPageData() {
        getViewModel().queryDeviceInventoryPage(pageIndex, pageSize, "", mStatus)
    }


    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.tvSearch -> {
                DeviceTransorInVentorySearchActivity.Companion.getIntents(
                    this,
                    DeviceTransorInVentorySearchActivity.TYPE_DEVICE_INVENTORY
                )
            }
        }
    }
}