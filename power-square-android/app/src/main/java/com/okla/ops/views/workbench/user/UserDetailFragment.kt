package com.okla.ops.views.workbench.user

import android.Manifest
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.lifecycle.ViewModelProvider
import androidx.viewpager2.widget.ViewPager2
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.okla.ops.R
import com.okla.ops.adapter.ViewPager2FragmentAdapter
import com.okla.ops.beans.UserDetail
import com.okla.ops.databinding.FragmentUserDetailBinding
import com.okla.ops.utils.ViewClickUtils
import net.lucode.hackware.magicindicator.FragmentContainerHelper
import net.lucode.hackware.magicindicator.buildins.UIUtil
import net.lucode.hackware.magicindicator.buildins.commonnavigator.CommonNavigator
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.CommonNavigatorAdapter
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerIndicator
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerTitleView
import net.lucode.hackware.magicindicator.buildins.commonnavigator.indicators.LinePagerIndicator
import net.lucode.hackware.magicindicator.buildins.commonnavigator.titles.ColorTransitionPagerTitleView
import net.lucode.hackware.magicindicator.buildins.commonnavigator.titles.SimplePagerTitleView

class UserDetailFragment :
    BaseNormalVFragment<UserViewModel, FragmentUserDetailBinding>() {

    companion object {
        fun getInstance(userDetail: UserDetail): UserDetailFragment {
            val fragment = UserDetailFragment()
            val bundle = Bundle()
            bundle.putParcelable("userDetail", userDetail)
            fragment.arguments = bundle
            return fragment
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_user_detail
    }

    override fun onCreateViewModel(): UserViewModel {
        return ViewModelProvider(this)[UserViewModel::class.java]
    }

    private lateinit var permissionManager: PermissionManager
    private var mUserDetail: UserDetail? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            requireActivity().activityResultRegistry,
            this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        mUserDetail = arguments?.getParcelable("userDetail")
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        initIndicator()
        initViewPager()
        initClick()
        initData()
    }

    private fun initViewPager() {
        mBinding.viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)
                mFragmentContainerHelper.handlePageSelected(position)
                mBinding.magicIndicator.onPageSelected(position)
            }
        })
        mBinding.viewPager.isNestedScrollingEnabled = false
        mBinding.viewPager.isUserInputEnabled = false
        mBinding.viewPager.adapter =
            ViewPager2FragmentAdapter(
                requireActivity(),
                mTitleDataList.size
            ) { position ->
                when (position) {
                    //基本信息
                    0 -> PersonalInfoFragment.getInstance(mUserDetail!!)
                    //订单记录
                    1 -> UserOrderRecordFragment.getInstance(mUserDetail?.cardNum ?: "")
                    //支付记录
                    2 -> PaymentRecordFragment.getInstance(mUserDetail?.cardNum ?: "")
                    //换电记录
                    3 -> BatterySwapRecordFragment.getIntents(mUserDetail?.cardNum ?: "")

                    else -> PersonalInfoFragment.getInstance(mUserDetail!!)
                }
            }
    }

    private val mFragmentContainerHelper: FragmentContainerHelper = FragmentContainerHelper()
    private val mTitleDataList = ArrayList<String>()
    private lateinit var commonNavigator: CommonNavigator
    private fun initIndicator() {
        context?.let { context ->
            mTitleDataList.add(context.getString(R.string.text_personal_info))
            mTitleDataList.add(context.getString(R.string.str_order_records))
            mTitleDataList.add(context.getString(R.string.text_payment_record))
            mTitleDataList.add(context.getString(R.string.text_battery_swap_record))
            commonNavigator = CommonNavigator(context)
            commonNavigator.isAdjustMode = false //可滚动
            commonNavigator.adapter = object : CommonNavigatorAdapter() {
                override fun getCount(): Int {
                    return mTitleDataList.size
                }

                override fun getTitleView(context: Context?, index: Int): IPagerTitleView {
                    val titleView: SimplePagerTitleView = ColorTransitionPagerTitleView(context)
                    titleView.text = mTitleDataList[index]
                    titleView.normalColor = Color.parseColor("#66000000")
                    titleView.selectedColor = Color.parseColor("#e6000000")
                    titleView.textSize = 15f
                    titleView.setOnClickListener {
                        mFragmentContainerHelper.handlePageSelected(index)
                        mBinding.viewPager.currentItem = index
                    }
                    return titleView
                }

                override fun getIndicator(context: Context?): IPagerIndicator {
                    val indicator = LinePagerIndicator(context)
                    indicator.mode = LinePagerIndicator.MODE_EXACTLY
                    indicator.lineWidth = UIUtil.dip2px(context, 68.0).toFloat()
                    indicator.setColors(Color.parseColor("#FF56B327"))
                    return indicator
                }
            }
            mBinding.magicIndicator.navigator = commonNavigator
            mFragmentContainerHelper.attachMagicIndicator(mBinding.magicIndicator)
        }
    }

    private fun initClick() {
        mBinding.userInfo.setOnPhoneListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnPhoneListener
            }
            if (TextUtils.isEmpty(mUserDetail?.phone)) {
                return@setOnPhoneListener
            }
            askPhonePermission()
        }
    }

    private fun initData() {
        mBinding.userInfo.setAvatar(mUserDetail?.avatar ?: "")
        mBinding.userInfo.setName(String.format("${mUserDetail?.firstName} ${mUserDetail?.lastName}"))
        mBinding.userInfo.setId(mUserDetail?.username ?: "")
    }

    private fun askPhonePermission() {
        val permissions = mutableListOf(
            Manifest.permission.CALL_PHONE,
        )
        permissionManager.checkPermissions(object : PermissionListenerImpl() {
            override fun passPermission() {
                super.passPermission()
                callPhone()
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(requireActivity(), "")
            }
        }, *permissions.toTypedArray())
    }

    private fun callPhone() {
        context?.let {
            val intent = Intent()
            intent.setAction(Intent.ACTION_CALL)
            intent.setData(Uri.parse("tel:${mUserDetail?.phone}"))
            it.startActivity(intent)
        }
    }

}