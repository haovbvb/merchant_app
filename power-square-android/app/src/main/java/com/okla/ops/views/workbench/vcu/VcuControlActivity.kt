package com.okla.ops.views.workbench.vcu

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.google.android.material.tabs.TabLayoutMediator
import com.okla.ops.R
import com.okla.ops.adapter.ViewPager2FragmentAdapter
import com.okla.ops.beans.DeviceInfo
import com.okla.ops.databinding.ActivityVcuControlBinding
import com.okla.ops.ble.BluetoothBleUtil

class VcuControlActivity : BaseNormalVActivity<VcuViewModel, ActivityVcuControlBinding>() {

    companion object {
        fun startVcuControlActivity(context: Context, devInfo: DeviceInfo) {
            val intent = Intent(context, VcuControlActivity::class.java)
            intent.putExtra("devInfo", devInfo)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): VcuViewModel? {
        return ViewModelProvider(this)[VcuViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_vcu_control
    }

    override fun title(): Int {
        return R.string.str_vcu_testing
    }

    override fun getIntentExtras(intent: Intent?) {
        super.getIntentExtras(intent)
        val devInfo: DeviceInfo? = intent?.getSerializableExtra("devInfo") as DeviceInfo
        deviceSn = devInfo?.deviceId ?: ""
        deviceCtrlId = devInfo?.ctrlId ?: ""
        isOnline = devInfo?.onlineStatus == 1
    }

    private var deviceSn: String = ""
    private var deviceCtrlId: String = ""
    private var isOnline: Boolean = false
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initObserver()
    }

    override fun onDestroy() {
        super.onDestroy()
        BluetoothBleUtil.getInstance().destroy()
    }

    override fun onResume() {
        super.onResume()
        BluetoothBleUtil.getInstance().addStateCallback(callback)
    }

    override fun onStop() {
        super.onStop()
        BluetoothBleUtil.getInstance().removeStateCallback(callback)
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        initTitles()
        initViewPagerAndTabs()
        if (TextUtils.isEmpty(deviceSn)) {
            finish()
        }
        initData()
    }

    private fun initData() {
        mBinding.tvDeviceInfo.text = "SN:$deviceCtrlId"
        mBinding.tv4GStatus.isSelected = isOnline
    }

    private fun initObserver() {

    }

    private val mTitleDataList = mutableListOf<String>()

    private fun initTitles() {
        mTitleDataList.add(getResources().getString(R.string.str_test_operation))
        mTitleDataList.add(getResources().getString(R.string.str_req_history))
    }

    private fun initViewPagerAndTabs() {
        mBinding.viewPager.adapter = ViewPager2FragmentAdapter(
            this,
            mTitleDataList.size
        ) { position ->
            when (position) {
                0 -> VcuControlFragment.newInstance(deviceSn, deviceCtrlId)
                1 -> VcuHistoryFragment.newInstance(deviceCtrlId)
                else -> throw IllegalStateException("Invalid position $position")
            }
        }
        mBinding.viewPager.isUserInputEnabled = false
        TabLayoutMediator(mBinding.tablayout, mBinding.viewPager) { tab, position ->
            tab.text = mTitleDataList[position]
        }.attach()
    }

    private val callback = object : BluetoothBleUtil.BluetoothBleStateCallback {

        override fun onConnected() {
            mBinding.tvBleStatus.isSelected = true
        }

        override fun onDisconnect() {
            mBinding.tvBleStatus.isSelected = false
        }
    }

}