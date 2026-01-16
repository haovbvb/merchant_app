package com.okla.ops.views.workbench.devicedetail

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.custom.SpaceItemDecoration
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.MaintenanceRecord
import com.okla.ops.databinding.FragmentDeviceFixRecordBinding
import com.okla.ops.weight.CircleImageView

/**
 * 设备保养记录
 */
class MaintenanceRecordFragment :
    BaseNormalVFragment<DeviceDetailViewModel, FragmentDeviceFixRecordBinding>() {

    companion object {
        private const val DEVICE_SN = "sn"
        fun getInstance(sn: String): MaintenanceRecordFragment {
            val fragment = MaintenanceRecordFragment()
            val bundle = Bundle()
            bundle.putString(DEVICE_SN, sn)
            fragment.arguments = bundle
            return fragment
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_device_fix_record
    }

    override fun onCreateViewModel(): DeviceDetailViewModel {
        return ViewModelProvider(this).get(DeviceDetailViewModel::class.java);
    }

    var mSn = ""
    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        initEmptyPage()
        mBinding.swipRefresh.setEnableRefresh(true)
        mBinding.swipRefresh.setEnableLoadMore(true)
        val arguments = arguments
        if (arguments != null) {
            mSn = arguments.getString(DEVICE_SN, "")
        }
        addObserver()
        initAdapter()
        refreshData()
    }

//    override fun onLazyInit() {
//        super.onLazyInit()
//        refreshData()
//    }

    private fun addObserver() {
        mBinding.swipRefresh.setOnRefreshListener {
            pageIndex = 1
            refreshData()
        }
        mBinding.swipRefresh.setOnLoadMoreListener {
            pageIndex++
            refreshData()
        }
        getViewModel().maintenanceRecordList.observe(this) {
            updateList(it)
        }
    }

    @SuppressLint("NotifyDataSetChanged")
    private fun updateList(items: List<MaintenanceRecord>?) {
        if (mAdapter == null) return
        val isDataEmpty = items.isNullOrEmpty()
        if (pageIndex == 1) {
            if (isDataEmpty) {
                mAdapter.setNewData(mutableListOf())
                mBinding.swipRefresh.finishRefreshWithNoMoreData()
            } else {
                mAdapter.setNewData(items?.toMutableList())
                mBinding.swipRefresh.finishRefresh(true)
                mBinding.swipRefresh.resetNoMoreData()
            }
            if (mAdapter.data.isEmpty()) {
                mBinding.emptyLayout.dataErrorView.visibility = View.VISIBLE
                mBinding.swipRefresh.visibility = View.GONE
            } else {
                mBinding.emptyLayout.dataErrorView.visibility = View.GONE
                mBinding.swipRefresh.visibility = View.VISIBLE
            }
        } else {
            if (isDataEmpty) {
                mBinding.swipRefresh.finishLoadMoreWithNoMoreData()
            } else {
                items?.let { mAdapter.addData(it) }
                mBinding.swipRefresh.finishLoadMore(true)
            }
        }
        mAdapter.notifyDataSetChanged()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<MaintenanceRecord>
    private fun initAdapter() {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<MaintenanceRecord>(R.layout.item_device_fix_record) {

            override fun convert(helper: BaseViewHolder, item: MaintenanceRecord) {
                super.convert(helper, item)
                helper.setGone(R.id.tvStatus, false)
                helper.setGone(R.id.img_fix, false)
                item.run {
                    context?.let {
                        Glide.with(it).load(img).error(R.mipmap.icon_def_avatar)
                            .placeholder(R.mipmap.icon_def_avatar)
                            .into(helper.getView<CircleImageView>(R.id.imArrow))
                    }
                    helper.setText(R.id.tvName, item.username)
                    helper.setText(R.id.tvFixName, context?.getString(R.string.str_maintenance_log))
                    helper.setText(R.id.tvFixDetail, item.log)
                    if (item.createTime != null) {
                        helper.setText(
                            R.id.tvDate,DateTimeUtils.getTimeString(DateTimeUtils.dateFormatNormal,item.createTime,)
                        )
                    }
                }
            }
        }
        mBinding.recyclerView.addItemDecoration(SpaceItemDecoration(0, DensityUtil.dp2px(3.0f)))
        mBinding.recyclerView.adapter = mAdapter
    }


    private var pageIndex = 1
    private var pageSize = 10;
    private fun refreshData() {
        getViewModel().getCarMaintenanceRecordList(pageIndex, pageSize, mSn)

    }

    private fun initEmptyPage() {
        mBinding.emptyLayout.dataErrorInfoIv.setImageResource(R.mipmap.icon_empty_record)
        mBinding.emptyLayout.dataErrorInfoTv.text = context?.getString(R.string.str_empty_record)
        mBinding.emptyLayout.dataErrorView.visibility = View.GONE
    }
}