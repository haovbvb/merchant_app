package com.okla.ops.views.workbench.warehouse.devicetransport

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
import com.base.common.utils.DensityUtil
import com.base.library.utils.StringUtil
import com.chad.library.adapter.base.BaseViewHolder
import com.google.android.material.tabs.TabLayout
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.DeviceTransport
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.databinding.ActivityDeviceTransportReceiveBinding
import com.okla.ops.views.workbench.warehouse.DeviceTransorInVentorySearchActivity
import net.lucode.hackware.magicindicator.FragmentContainerHelper

/**
 * Author: Joe
 * Date: 2024/1/30 14:54
 * Description:
 */
class DeviceTransportReceiveActivity :
    BaseNormalListVActivity<DeviceTransportViewModel, ActivityDeviceTransportReceiveBinding>() {

    companion object {
        fun getIntents(context: Context) {
            context.startActivity(Intent(context, DeviceTransportReceiveActivity::class.java))
        }
    }

    override fun onCreateViewModel(): DeviceTransportViewModel {
        return ViewModelProvider(this).get(DeviceTransportViewModel::class.java)
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_device_transport_receive
    }

    override fun title(): Int {
        return R.string.workbench_device_receive
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
        initObserver()
        initClick()
        onRefresh()
    }

    private fun initObserver() {
        getViewModel().mDeviceTransportReceiveRespLiveData.observe(this) {
            updateListItems(it.list)
            if (data.isEmpty()) {
                mBinding.clEmpty.visibility = View.VISIBLE
                mBinding.swipRefresh.visibility = View.GONE
            } else {
                mBinding.clEmpty.visibility = View.GONE
                mBinding.swipRefresh.visibility = View.VISIBLE
            }
        }
    }

    private var mStatus: Int? = null
    private val mTitleDataList = mutableListOf<String>()
    private val mFragmentContainerHelper = FragmentContainerHelper()
    private fun initIndicator() {
        mTitleDataList.apply {
            add(getString(R.string.transport_all))
            add(getString(R.string.transport_in_transit))
            add(getString(R.string.transport_receive))
            add(getString(R.string.transport_receive_part))
            add(getString(R.string.str_withdraw_all))
        }
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
                    1 -> 0
                    2 -> 1
                    3 -> 2
                    4 -> 3
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


    private lateinit var mSingleDataBindingNoPUseAdapter: SingleDataBindingNoPUseAdapter<DeviceTransport>

    override fun createAdapter(): RecyclerView.Adapter<*> {
        mSingleDataBindingNoPUseAdapter = object :
            SingleDataBindingNoPUseAdapter<DeviceTransport>(R.layout.item_device_transport) {

            override fun convert(helper: BaseViewHolder, item: DeviceTransport) {
                super.convert(helper, item)
                item.run {
                    helper.setText(R.id.tvTransferNum, transferNo)
                    val tvDesName = helper.getView<AppCompatTextView>(R.id.tvDesName)
                    if (item.outWarehouseName.contains("platform")) {
                        tvDesName.text = mContext.getString(R.string.text_platform)
                    }else{
                        tvDesName.text = item.outWarehouseName
                    }
                    helper.setText(R.id.tvNumValue, StringUtil.isDataNumberEmpty(deviceNum))
                    helper.setText(R.id.tvReceiveValue, StringUtil.isDataNumberEmpty(receivedNum))
                    val recallNum = deviceNum - inTransitNum - receivedNum
                    helper.setText(
                        R.id.tvRecallValue,
                        StringUtil.isDataNumberEmpty(if (recallNum >= 0) recallNum else 0)
                    )
                    val tvStatus = helper.getView<AppCompatTextView>(R.id.tvStatus)
                    when (status) {
                        0 -> {//在途
                            tvStatus.text = getString(R.string.transport_status_on)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransportReceiveActivity,
                                R.drawable.bg_fef7ea_r4
                            )

                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransportReceiveActivity,
                                    R.color.color_ed942f
                                )
                            )
                        }

                        1 -> {//已接收
                            tvStatus.text = getString(R.string.transport_status_receive)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransportReceiveActivity,
                                R.drawable.bg_ffeef7e9_r4
                            )

                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransportReceiveActivity,
                                    R.color.main_color
                                )
                            )
                        }

                        2 -> {//部分接收
                            tvStatus.text = getString(R.string.transport_receive_part)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransportReceiveActivity,
                                R.drawable.bg_f0f7ff_r4
                            )

                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransportReceiveActivity,
                                    R.color.color_1184f7
                                )
                            )
                        }

                        3 -> {//已撤回
                            tvStatus.text = getString(R.string.str_withdraw_all)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransportReceiveActivity,
                                R.drawable.bg_fff3f2_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransportReceiveActivity,
                                    R.color.color_ffa4332
                                )
                            )
                        }
                    }
                    val tvDeviceType = helper.getView<AppCompatTextView>(R.id.tvDeviceType)
                    when (deviceType) {
                        DeviceTypeObject.TYPE_BATTERY -> {//电池
                            tvDeviceType.text = getString(R.string.transport_battery)
                        }

                        DeviceTypeObject.TYPE_VEHICLE -> {//车辆
                            tvDeviceType.text = getString(R.string.transport_vehicle)
                        }
                        DeviceTypeObject.TYPE_STATION -> {//电柜
                            tvDeviceType.text = getString(R.string.transport_station)
                        }
                    }
                }
            }
        }
        mSingleDataBindingNoPUseAdapter.setOnItemClickListener { adapter, _, position ->
            val itemData = adapter.data[position] as DeviceTransport
            DeviceTransportDetailActivity.getIntents(
                this,
                itemData.transferNo,
                DeviceTransportDetailActivity.TRANSPORT_TYPE_RECEPTION,
                itemData.status
            )
        }
        return mSingleDataBindingNoPUseAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        mBinding.recyclerView.addItemDecoration(SpaceItemDecoration(0, DensityUtil.dp2px(3.0f)))
        return mBinding.recyclerView
    }

    override fun initPageData() {
        getViewModel().queryDeviceReceivePage("", mStatus, pageIndex, pageSize)
    }

    private fun initClick() {
        mBinding.tvSearch.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.tvSearch -> {
                DeviceTransorInVentorySearchActivity.Companion.getIntents(
                    this,
                    DeviceTransorInVentorySearchActivity.TYPE_DEVICE_RECEIVE
                )
            }
        }
    }
}