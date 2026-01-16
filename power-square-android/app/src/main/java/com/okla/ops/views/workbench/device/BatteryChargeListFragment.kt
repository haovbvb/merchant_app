package com.okla.ops.views.workbench.device

import android.graphics.Color
import android.os.Bundle
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVFragment
import com.base.common.custom.BottomSpacingColorItemDecoration
import com.base.common.timepicker.DateFormatUtils
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.base.common.utils.LanguageUtils
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.BatteryDetail
import com.okla.ops.beans.ChargeHistory
import com.okla.ops.beans.Shop1
import com.okla.ops.databinding.FragmentBatteryChargeListBinding

class BatteryChargeListFragment :
    BaseNormalListVFragment<DeviceViewModel, FragmentBatteryChargeListBinding>() {

    companion object {
        fun getInstance(sn: String): BatteryChargeListFragment {
            val fragment = BatteryChargeListFragment()
            val bundle = Bundle()
            bundle.putString("sn", sn)
            fragment.arguments = bundle
            return fragment
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_battery_charge_list
    }

    override fun onCreateViewModel(): DeviceViewModel {
        return ViewModelProvider(this)[DeviceViewModel::class.java]
    }

    private var mSn: String? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mSn = arguments?.getString("sn") ?: ""
        addObserver()
    }

    override fun initViews(view: View, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        getStatusView().enableRefresh = true
        getStatusView().enableLoadMore = true
        onRefresh()
    }

    private fun addObserver() {
        getViewModel().deviceChargeListLiveData.observe(this) {
            updateListItems(it)
        }
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<ChargeHistory>
    override fun createAdapter(): RecyclerView.Adapter<*> {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<ChargeHistory>(R.layout.item_charge_history) {
            override fun convert(
                helper: BaseViewHolder,
                item: ChargeHistory
            ) {
                super.convert(helper, item)
                val tvChargeValue = helper.getView<AppCompatTextView>(R.id.tvChargeValue)
                val tvChargeDate =
                    helper.getView<AppCompatTextView>(R.id.tvChargeDate)
                val tvChargeTime = helper.getView<AppCompatTextView>(R.id.tvChargeTime)
                tvChargeValue.text = "${item.chargeValue}%"
                tvChargeDate.text = DateTimeUtils.getTimeString(
                    DateTimeUtils.defaultFormat,
                    item.date,
                    LanguageUtils.LanguageUtil.getLocalByLanguage()
                )
                tvChargeTime.text = item.chargeTime
            }
        }
        return mAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        val backgroundColor = Color.parseColor("#FFE6E6E6")  // 背景颜色
        val itemDecoration =
            BottomSpacingColorItemDecoration(1, backgroundColor, DensityUtil.dp2px(12f))
        mBinding.rvCharge.addItemDecoration(itemDecoration)
        return mBinding.rvCharge
    }

    override fun initPageData() {
        getViewModel().getDeviceChargeList(mSn, pageIndex, pageSize)
    }

}