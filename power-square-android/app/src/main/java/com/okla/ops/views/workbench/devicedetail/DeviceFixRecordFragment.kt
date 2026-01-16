package com.okla.ops.views.workbench.devicedetail

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.custom.SpaceItemDecoration
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.DeviceFixRecord
import com.okla.ops.databinding.FragmentDeviceFixRecordBinding
import com.okla.ops.weight.CircleImageView

class DeviceFixRecordFragment :
    BaseNormalVFragment<DeviceDetailViewModel, FragmentDeviceFixRecordBinding>() {

    companion object {
        private const val DEVICE_TYPE = "type"
        private const val DEVICE_SN = "sn"

        fun getInstance(type: Int, sn: String): DeviceFixRecordFragment {
            val fragment = DeviceFixRecordFragment()
            val bundle = Bundle()
            bundle.putInt(DEVICE_TYPE, type)
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

    var mType = 0
    var mSn = ""
    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        initEmptyPage()
        mBinding.swipRefresh.setEnableRefresh(true)
        mBinding.swipRefresh.setEnableLoadMore(true)
        val arguments = arguments
        if (arguments != null) {
            mType = arguments.getInt(DEVICE_TYPE)
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
        getViewModel().mDeviceFixRecordList.observe(this) {
            updateList(it)
        }
    }

    @SuppressLint("NotifyDataSetChanged")
    private fun updateList(items: List<DeviceFixRecord>?) {
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

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<DeviceFixRecord>
    private fun initAdapter() {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<DeviceFixRecord>(R.layout.item_device_fix_record) {

            override fun convert(helper: BaseViewHolder, item: DeviceFixRecord) {
                super.convert(helper, item)
                val tvStatus = helper.getView<AppCompatTextView>(R.id.tvStatus)
                item.run {
                    context?.let {
                        Glide.with(it).load(fixManAvatar).error(R.mipmap.icon_def_avatar)
                            .placeholder(R.mipmap.icon_def_avatar)
                            .into(helper.getView<CircleImageView>(R.id.imArrow))
                    }
                    tvStatus.text = result ?: "-"

                    helper.setText(R.id.tvName, fixMan ?: "-")
                    helper.setText(R.id.tvFixName, itemName ?: "-")
                    helper.setText(R.id.tvFixDetail, remark ?: "-")
                    helper.setText(
                        R.id.tvDate,
                        DateTimeUtils.getTimeString(DateTimeUtils.defaultFormat, createTime ?: 0)
                    )
                }
            }
        }
        mBinding.recyclerView.addItemDecoration(SpaceItemDecoration(0, DensityUtil.dp2px(3.0f)))
        mBinding.recyclerView.adapter = mAdapter
    }

    private var pageIndex = 1
    private var pageSize = 10;
    private fun refreshData() {
        when (mType) {
            DeviceDetailFragment.DEVICE_TYPE_BATTERY -> {
                getViewModel().getBatteryFixRecordList(pageIndex, pageSize, mSn)
            }

            DeviceDetailFragment.DEVICE_TYPE_CABIN -> {
                getViewModel().getCabinFixRecordList(pageIndex, pageSize, mSn)
            }

            DeviceDetailFragment.DEVICE_TYPE_CAR -> {
                getViewModel().getCarFixRecordList(pageIndex, pageSize, mSn)
            }
        }
    }


    private fun initEmptyPage() {
        mBinding.emptyLayout.dataErrorInfoIv.setImageResource(R.mipmap.icon_empty_record)
        mBinding.emptyLayout.dataErrorInfoTv.text = context?.getString(R.string.str_empty_record)
        mBinding.emptyLayout.dataErrorView.visibility = View.GONE
    }
}