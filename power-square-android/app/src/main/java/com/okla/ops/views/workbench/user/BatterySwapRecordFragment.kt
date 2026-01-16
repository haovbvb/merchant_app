package com.okla.ops.views.workbench.user

import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.databinding.ViewDataBinding
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVFragment
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.PowerChangeBeanNew
import com.okla.ops.beans.PowerChangeItem
import com.okla.ops.databinding.FragmentUserSwapRecordBinding

class BatterySwapRecordFragment :
    BaseNormalListVFragment<UserViewModel, FragmentUserSwapRecordBinding?>() {
    private  var mAdapter: SingleDataBindingNoPUseAdapter<PowerChangeItem>? = null

    private lateinit var powerChangeListObserver: Observer<PowerChangeBeanNew?>
    private var mCarNum: String? = ""

    override fun getLayoutId(): Int {
        return R.layout.fragment_user_swap_record
    }

    override fun onCreateViewModel(): UserViewModel {
        return ViewModelProvider(this)[UserViewModel::class.java]
    }

    override fun createAdapter(): RecyclerView.Adapter<*> {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<PowerChangeItem>(R.layout.item_battery_swap_record) {
            override fun convert(helper: BaseViewHolder, item: PowerChangeItem?) {
                super.convert(helper, item)
                if (item?.type === 5) {
                    (helper.getView<View>(R.id.imIcon) as ImageView).setImageDrawable(
                        ContextCompat.getDrawable(
                            mContext,
                            R.mipmap.icon_manual_change
                        )
                    )
                    (helper.getView<View>(R.id.tvSwapName) as TextView).setText(mContext.getString(R.string.user_manual_battery_exchange))
                } else if (item?.type === 6) {
                    (helper.getView<View>(R.id.imIcon) as ImageView).setImageDrawable(
                        ContextCompat.getDrawable(
                            mContext,
                            R.mipmap.icon_remote_change
                        )
                    )
                    (helper.getView<View>(R.id.tvSwapName) as TextView).setText(mContext.getString(R.string.user_remote_battery_exchange))
                } else if (item?.type === 7) {
                    (helper.getView<View>(R.id.imIcon) as ImageView).setImageDrawable(
                        ContextCompat.getDrawable(
                            mContext,
                            R.mipmap.icon_bluetooth_change
                        )
                    )
                    (helper.getView<View>(R.id.tvSwapName) as TextView).setText(mContext.getString(R.string.user_bluetooth_battery_exchange))
                } else {
                    (helper.getView<View>(R.id.imIcon) as ImageView).setImageDrawable(
                        ContextCompat.getDrawable(
                            mContext,
                            R.mipmap.icon_scan_change
                        )
                    )
                    (helper.getView<View>(R.id.tvSwapName) as TextView).setText(mContext.getString(R.string.user_scan_code_replace_battery))
                }
                val tvSwapStatus = helper.getView<TextView>(R.id.tvSwapStatus)
                tvSwapStatus.visibility = View.VISIBLE
                when (item?.status) {
                    0 -> {
                        tvSwapStatus.visibility = View.GONE
                        tvSwapStatus.text = getString(R.string.str_exchange_success)
                        tvSwapStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.color_0abf83
                            )
                        )
                    }

                    1 -> {
                        tvSwapStatus.text = getString(R.string.str_exchange_success)
                        tvSwapStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.color_0abf83
                            )
                        )
                    }

                    2 -> {
                        tvSwapStatus.text = getString(R.string.str_exchange_fail)
                        tvSwapStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.color_fa4b51
                            )
                        )
                    }

                    3 -> {
                        tvSwapStatus.text = getString(R.string.str_exchange_part_success)
                        tvSwapStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.color_ed942f
                            )
                        )
                    }

                    4 -> {
                        tvSwapStatus.text = getString(R.string.str_exchange_system_reject)
                        tvSwapStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.color_fa4b51
                            )
                        )
                    }
                }
            }
        }
        mAdapter?.setOnItemClickListener(BaseQuickAdapter.OnItemClickListener { adapter, view, position ->

        })
        return mAdapter as SingleDataBindingNoPUseAdapter<PowerChangeItem>
    }

    override fun getRecyclerView(): RecyclerView? {
        return mBinding?.rvContact
    }

    override fun initPageData() {
        getViewModel().getPowerChangeList(mCarNum?:"",pageSize,pageIndex)
//        getLoading().onStart()
//        bdListData
    }

    private val bdListData: Unit
        get() {
            if (!TextUtils.isEmpty(mCarNum)) {
                getViewModel().getPowerChangeList(mCarNum, pageSize, pageIndex)
                    .observe(this,powerChangeListObserver)
            } else {
                mBinding?.clNoData?.setVisibility(View.VISIBLE)
                mBinding?.rvContact?.setVisibility(View.GONE)
            }
        }

    override fun initViews(view: View, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        getStatusView().setEnableLoadMore(true)
        getStatusView().setEnableRefresh(true)
        mCarNum = arguments?.getString("cardNum")?:""

        initObserver()
        initClicks()
        onRefresh();
    }


    private fun initObserver() {
//        getViewModel().bdContactListMutableLiveData.observe(this) { workUserSearchBeanNew ->
//            if (workUserSearchBeanNew != null) {
//                mCarNum = workUserSearchBeanNew.getCardNum()
//                pageIndex = getDefaultStartPageIndex()
//                bdListData
//            }
//        }
        getViewModel().powerChangeListMutableLiveData.observe(this,{
            updateListItems(it?.list)
            if(it==null){
                if (it?.list.isNullOrEmpty()) {
                    if(pageIndex==1){
                        mBinding?.clNoData?.setVisibility(View.VISIBLE)
                        mBinding?.rvContact?.setVisibility(View.GONE)
                    }
                } else {
                    mBinding?.clNoData?.setVisibility(View.GONE)
                    mBinding?.rvContact?.setVisibility(View.VISIBLE)
                }
            }else{
                if(pageIndex==1){
                    mBinding?.clNoData?.setVisibility(View.VISIBLE)
                    mBinding?.rvContact?.setVisibility(View.GONE)
                }
            }

        })

//        powerChangeListObserver = Observer<PowerChangeBeanNew?> { bean: PowerChangeBeanNew? ->
//            if (bean != null) {
//                updateListItems(bean?.list)
//            }
//
//            getLoading().onFinish()
//            getStatusView().onFinishRefresh()
//        }
//        mBinding?.rvContact?.setAdapter(mAdapter)
    }


    private fun initClicks() {
    }

    companion object {
        fun getIntents(cardNum: String?): BatterySwapRecordFragment {
            val fragment = BatterySwapRecordFragment()
            val bundle = Bundle()
            bundle.putString("cardNum", cardNum)
            fragment.arguments = bundle
            return fragment
        }
    }
}