package com.okla.ops.views.workbench.user

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVFragment
import com.google.android.material.tabs.TabLayout
import com.google.android.material.tabs.TabLayoutMediator
import com.okla.ops.R
import com.okla.ops.adapter.ViewPager2FragmentAdapter
import com.okla.ops.databinding.FragmentUserOrderRecordBinding
import com.okla.ops.utils.TextUtil

class UserOrderRecordFragment :
    BaseNormalVFragment<UserViewModel, FragmentUserOrderRecordBinding>(),
    TextUtil {

    companion object {
        fun getInstance(cardNum: String): UserOrderRecordFragment {
            val fragment = UserOrderRecordFragment()
            val bundle = Bundle()
            bundle.putString("cardNum", cardNum)
            fragment.arguments = bundle
            return fragment
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_user_order_record
    }

    override fun onCreateViewModel(): UserViewModel {
        return ViewModelProvider(this)[UserViewModel::class.java]
    }

    private var mCardNum: String = ""
    private var mStatus = -1
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mCardNum = arguments?.getString("cardNum") ?: ""
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        initTitles()
        initViewPager()
        initIndicator()
        onRefresh()
    }

    private val mTitleDataList = mutableListOf<String>()
    private fun initTitles() {
        mTitleDataList.clear()
        mTitleDataList.add(getString(R.string.str_sales_order))
        mTitleDataList.add(getString(R.string.str_rental_order))
        mTitleDataList.add(getString(R.string.str_swap_order))
    }

    private fun initIndicator() {
        mBinding.tabLayout.setSelectedTabIndicator(null)
        mBinding.tabLayout.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = true
                val position = tab?.position ?: 0
                mStatus = when (position) {
                    0 -> 1
                    1 -> 2
                    2 -> 3
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
        TabLayoutMediator(mBinding.tabLayout, mBinding.viewPager) { tab, position ->
            val custom = LayoutInflater.from(context)
                .inflate(R.layout.layout_custom_tab, mBinding.tabLayout, false)
            custom.findViewById<TextView>(R.id.tabText).apply {
                text = mTitleDataList[position]
                isSelected = (position == 0)
            }
            tab.customView = custom
        }.attach()

    }

    private fun initViewPager() {
        mBinding.viewPager.isNestedScrollingEnabled = false
        mBinding.viewPager.isUserInputEnabled = false
        mBinding.viewPager.adapter =
            ViewPager2FragmentAdapter(
                requireActivity(),
                mTitleDataList.size
            ) { position ->
                when (position) {
                    // 销售订单
                    0 -> UserSaleOrderRecordListFragment.getInstance(mCardNum)
                    // 租赁订单
                    1 -> UserRentOrderRecordListFragment.getInstance(mCardNum)
                    // 换电订单
                    2 -> UserSwapOrderRecordListFragment.getInstance(mCardNum)
                    else -> {
                        UserSaleOrderRecordListFragment.getInstance(mCardNum)
                    }
                }
            }
    }

}