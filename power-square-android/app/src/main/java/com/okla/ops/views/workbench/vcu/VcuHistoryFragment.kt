package com.okla.ops.views.workbench.vcu

import android.os.Bundle
import android.view.View
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVFragment
import com.base.common.custom.BottomSpacingItemDecoration
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.databinding.FragmentVcuHistoryBinding

class VcuHistoryFragment :
    BaseNormalListVFragment<VcuViewModel, FragmentVcuHistoryBinding>() {

    companion object {
        fun newInstance(sn: String): VcuHistoryFragment {
            val fragment = VcuHistoryFragment()
            val bundle = Bundle()
            bundle.putString("sn", sn)
            fragment.arguments = bundle
            return fragment
        }
    }

    private var deviceSn: String = ""
    override fun getArgumentsBundle(arguments: Bundle?) {
        super.getArgumentsBundle(arguments)
        arguments?.let {
            deviceSn = it.getString("sn", "")
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_vcu_history
    }

    override fun onCreateViewModel(): VcuViewModel {
        return ViewModelProvider(requireActivity())[VcuViewModel::class.java]
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        addObserver()
    }

    override fun onResume() {
        super.onResume()
        onRefresh()
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        getStatusView().enableRefresh = true
//        getStatusView().enableLoadMore = true
        initListener()
        initData()
    }

    private fun addObserver() {
        getViewModel().mVcuDataHistoryListLiveData.observe(this) {
            updateListItems(it.list)
            if (it.list?.isEmpty() == true && pageIndex == defaultStartPageIndex) {
                mBinding.emptyView.visibility = View.VISIBLE
            } else {
                mBinding.emptyView.visibility = View.GONE
            }
        }
    }

    private fun initData() {
        mBinding.btnAll.isSelected = true
    }

    private fun initListener() {
        mBinding.btnAll.setOnClickListener(this)
        mBinding.btnRequest.setOnClickListener(this)
        mBinding.btnResponse.setOnClickListener(this)
    }

    private var mMsgType: Int? = null
    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.btnAll -> {
                resetBtnState()
                mBinding.btnAll.isSelected = true
                mMsgType = null
                onRefresh()
            }

            R.id.btnRequest -> {
                resetBtnState()
                mBinding.btnRequest.isSelected = true
                mMsgType = 1
                onRefresh()
            }

            R.id.btnResponse -> {
                resetBtnState()
                mBinding.btnResponse.isSelected = true
                mMsgType = 2
                onRefresh()
            }
        }
    }

    private fun resetBtnState() {
        mBinding.btnAll.isSelected = false
        mBinding.btnRequest.isSelected = false
        mBinding.btnResponse.isSelected = false
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<VcuDataHistory>
    override fun createAdapter(): RecyclerView.Adapter<*>? {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<VcuDataHistory>(R.layout.item_vcu_history) {
            override fun convert(
                helper: BaseViewHolder,
                item: VcuDataHistory
            ) {
                super.convert(helper, item)
                val tvDirection = helper.getView<AppCompatTextView>(R.id.tvDirection)
                val ivDirection = helper.getView<AppCompatImageView>(R.id.ivDirection)
                val tvDate = helper.getView<AppCompatTextView>(R.id.tvDate)
                val ivConnection = helper.getView<AppCompatImageView>(R.id.ivConnection)
                val tvCommand = helper.getView<AppCompatTextView>(R.id.tvCommand)
                val tvData = helper.getView<AppCompatTextView>(R.id.tvData)
                context?.run {
                    tvDirection.text =
                        if (item.msgType == 1) getString(R.string.str_request) else getString(
                            R.string.str_response
                        )
                    ivDirection.setImageDrawable(
                        if (item.msgType == 1) ContextCompat.getDrawable(
                            this,
                            R.mipmap.icon_request
                        ) else ContextCompat.getDrawable(
                            this,
                            R.mipmap.icon_response
                        )
                    )
                    ivConnection.setImageDrawable(
                        if (item.communicationType == 1) ContextCompat.getDrawable(
                            this,
                            R.mipmap.icon_wifi
                        ) else ContextCompat.getDrawable(
                            this,
                            R.mipmap.icon_ble
                        )
                    )
                }
                tvDate.text = DateTimeUtils.getTimeString(
                    DateTimeUtils.defaultFormat,
                    item.createTime
                )
                tvCommand.text = item.command
                tvData.text = item.data
            }
        }
        return mAdapter
    }

    override fun getRecyclerView(): RecyclerView? {
        return mBinding.recyclerView
    }

    override fun buildItemDecorations(): List<RecyclerView.ItemDecoration?>? {
        return listOf(BottomSpacingItemDecoration(DensityUtil.dp2px(12f)))
    }

    override fun initPageData() {
        getViewModel().queryVcuDataList(deviceSn, mMsgType, pageIndex, pageSize)
    }

}