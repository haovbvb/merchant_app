package com.okla.ops.views

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.beans.RxEvent
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.base.common.utils.WindowInsetsHelper
import com.base.library.base.BaseAppCompatFragment
import com.okla.ops.R
import com.okla.ops.adapter.CustomFragmentPagerAdapter
import com.okla.ops.databinding.ActivityMainBinding
import com.okla.ops.views.login.LoginActivity
import com.okla.ops.views.mine.MineFragment
import com.okla.ops.views.monitor.MonitorFragment
import com.okla.ops.views.workbench.WorkbenchFragmentNew
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class MainActivity : BaseNormalVActivity<MainViewModel, ActivityMainBinding>() {

    companion object {
        fun startMainActivity(context: Context) {
            val intent = Intent(context, MainActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): MainViewModel {
        return ViewModelProvider(this)[MainViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_main
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        initViewPager()
        initClick()
        WindowInsetsHelper.applyForBottom(mBinding.main)
    }

    private fun initClick() {
        mBinding.homeIndicatorMonitor.setOnClickListener(this)
        mBinding.homeIndicatorWorkbench.setOnClickListener(this)
        mBinding.homeIndicatorMine.setOnClickListener(this)
    }

    private fun initViewPager() {
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
        supportFragmentManager
        val pageAdapter =
            CustomFragmentPagerAdapter(supportFragmentManager, mOnFragmentChangeListener)
        pageAdapter.count = mViewPagerCount
        mBinding.mViewpager.offscreenPageLimit = mViewPagerCount
        mBinding.mViewpager.adapter = pageAdapter
        mBinding.mViewpager.setNoScroll(true)
        mBinding.mViewpager.isScrollContainer = false
        mBinding.ivHomeIndicatorMonitor.isSelected = true
        mBinding.homeIndicatorMonitor.isSelected = true
    }

    private val mOnFragmentChangeListener =
        CustomFragmentPagerAdapter.OnFragmentChangeListener {
            when (it) {
                1 -> getWorkbenchFragment()

                2 -> getMineFragment()

                else -> {
                    getMonitorFragment()
                }
            }
        }

    private fun getMonitorFragment(): BaseAppCompatFragment {
        return MonitorFragment.newInstance()
    }

    private fun getWorkbenchFragment(): BaseAppCompatFragment {
        return WorkbenchFragmentNew.newInstance()
    }

    private fun getMineFragment(): BaseAppCompatFragment {
        return MineFragment.newInstance()
    }

    private var mViewPagerCount = 3

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.home_indicator_monitor -> {
                controlBottomNav(0)
                StatusBarUtil.StatusBarLightMode(this)
                mBinding.ivHomeIndicatorMonitor.isSelected = true
                mBinding.homeIndicatorMonitor.isSelected = true
                mBinding.ivHomeIndicatorWorkbench.isSelected = false
                mBinding.homeIndicatorWorkbench.isSelected = false
                mBinding.ivHomeIndicatorMine.isSelected = false
                mBinding.homeIndicatorMine.isSelected = false
            }

            R.id.home_indicator_workbench -> {
                controlBottomNav(1)
                StatusBarUtil.StatusBarDarkMode(this)
                mBinding.ivHomeIndicatorMonitor.isSelected = false
                mBinding.homeIndicatorMonitor.isSelected = false
                mBinding.ivHomeIndicatorWorkbench.isSelected = true
                mBinding.homeIndicatorWorkbench.isSelected = true
                mBinding.ivHomeIndicatorMine.isSelected = false
                mBinding.homeIndicatorMine.isSelected = false
            }

            R.id.home_indicator_mine -> {
                controlBottomNav(2)
                StatusBarUtil.StatusBarLightMode(this)
                mBinding.ivHomeIndicatorMonitor.isSelected = false
                mBinding.homeIndicatorMonitor.isSelected = false
                mBinding.ivHomeIndicatorWorkbench.isSelected = false
                mBinding.homeIndicatorWorkbench.isSelected = false
                mBinding.ivHomeIndicatorMine.isSelected = true
                mBinding.homeIndicatorMine.isSelected = true
            }
        }
    }

    private fun controlBottomNav(position: Int) {
        mBinding.mViewpager.setCurrentItem(position, false)
    }

    override fun isBindEventBusHere(): Boolean {
        return true
    }

    //登出账号
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun logout(logout: RxEvent.LoginOut) {
        LoginActivity.startLoginActivity(this)
        finish()
    }
    private var backPressedOnce = false
    override fun onBackPressed() {
        if (backPressedOnce) {
            // 第二次按，直接退出
            super.onBackPressed()
        } else {
            // 第一次按，只弹吐司，设置标志
            backPressedOnce = true
            ToastUtils.showShort(getString(R.string.press_back_again))
        }
    }

    override fun onResume() {
        super.onResume()
        backPressedOnce = false

    }

}