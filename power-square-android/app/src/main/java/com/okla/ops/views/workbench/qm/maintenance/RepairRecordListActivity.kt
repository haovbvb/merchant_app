package com.okla.ops.views.workbench.qm.maintenance

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.custom.SpaceItemDecoration
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.base.common.utils.LanguageUtils.LanguageUtil.getLocalByLanguage
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.beans.VehicleRepair
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.databinding.ActivityRepairRecordListBinding
import com.okla.ops.dialog.RepairRecordDetailDialog
import com.okla.ops.weight.CircleImageView

class RepairRecordListActivity :
    BaseNormalListVActivity<MaintenanceBookViewModel, ActivityRepairRecordListBinding>() {

    companion object {
        fun getIntents(context: Context, sn: String) {
            val intent = Intent(context, RepairRecordListActivity::class.java)
            intent.putExtra("sn", sn)
            context.startActivity(intent)
        }
    }

    private var sn: String = ""

    override fun getIntentExtras(intent: Intent?) {
        super.getIntentExtras(intent)
        intent?.run {
            sn = getStringExtra("sn") ?: ""
        }
    }

    override fun onCreateViewModel(): MaintenanceBookViewModel {
        return ViewModelProvider(this)[MaintenanceBookViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_repair_record_list
    }

    override fun title(): Int {
        return R.string.maintenance_repair_record
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        getStatusView().enableRefresh = true
        getStatusView().enableLoadMore = true
        initObserver()
        onRefresh()
    }

    private fun initObserver() {
        getViewModel().mVehicleRepairList.observe(this) {
            updateListItems(it.list)
            if (it.list?.isEmpty() == true && pageIndex == defaultStartPageIndex) {
                mBinding.noDataView.visibility = View.VISIBLE
            } else {
                mBinding.noDataView.visibility = View.GONE
            }
        }
    }

    private lateinit var mSingleDataBindingNoPUseAdapter: SingleDataBindingNoPUseAdapter<VehicleRepair>

    override fun createAdapter(): RecyclerView.Adapter<*> {
        mSingleDataBindingNoPUseAdapter = object :
            SingleDataBindingNoPUseAdapter<VehicleRepair>(R.layout.item_repair_record) {

            override fun convert(helper: BaseViewHolder, item: VehicleRepair) {
                super.convert(helper, item)
                item.run {
                    Glide.with(this@RepairRecordListActivity).load(fixManAvatar)
                        .error(R.mipmap.icon_def_avatar)
                        .placeholder(R.mipmap.icon_def_avatar)
                        .into(helper.getView<CircleImageView>(R.id.ivAvator))
                    helper.setText(R.id.tvName, fixMan)
                    helper.setText(R.id.tvTitle, itemName)
                    helper.setText(R.id.tvContent, remark)
                    helper.setText(
                        R.id.tvDate,
                        DateTimeUtils.getTimeString(DateTimeUtils.defaultFormat, createTime,
                            getLocalByLanguage()
                        )
                    )
                    val tvState = helper.getView<AppCompatTextView>(R.id.tvState)
                    when (result) {
                        1 -> {//完成
                            tvState.setBackgroundDrawable(
                                ContextCompat.getDrawable(
                                    this@RepairRecordListActivity,
                                    R.drawable.bg_e9f7f2_r4
                                )
                            )
                            tvState.text = getString(R.string.maintenance_repair_record_finish)
                            tvState.setTextColor(
                                ContextCompat.getColor(
                                    this@RepairRecordListActivity,
                                    R.color.main_color
                                )
                            )
                        }

                        2 -> {//缺件
                            tvState.setBackgroundDrawable(
                                ContextCompat.getDrawable(
                                    this@RepairRecordListActivity,
                                    R.drawable.bg_fdf5eb_r4
                                )
                            )
                            tvState.text = getString(R.string.maintenance_repair_record_lack)
                            tvState.setTextColor(
                                ContextCompat.getColor(
                                    this@RepairRecordListActivity,
                                    R.color.color_ed942f
                                )
                            )
                        }

                        3 -> {//报废
                            tvState.setBackgroundDrawable(
                                ContextCompat.getDrawable(
                                    this@RepairRecordListActivity,
                                    R.drawable.bg_fff0f0_r4
                                )
                            )
                            tvState.text = getString(R.string.maintenance_repair_record_discard)
                            tvState.setTextColor(
                                ContextCompat.getColor(
                                    this@RepairRecordListActivity,
                                    R.color.color_fa4b51
                                )
                            )
                        }

                        else -> {
                            tvState.visibility = View.GONE
                        }
                    }
                }
                helper.getView<AppCompatTextView>(R.id.btnDetail).setOnClickListener { v: View? ->
                    if (adapter != null)
                        onItemChildClickListener?.onItemChildClick(
                            adapter as BaseQuickAdapter<*, *>?,
                            v,
                            helper.layoutPosition
                        )
                }
            }
        }
        mSingleDataBindingNoPUseAdapter.setOnItemChildClickListener { adapter, _, position ->
            val itemData = adapter.data[position] as VehicleRepair
            if (mDetailDialog == null) {
                mDetailDialog = RepairRecordDetailDialog(this@RepairRecordListActivity)
            }
            mDetailDialog?.updateData(itemData)
            mDetailDialog?.show()
        }
        return mSingleDataBindingNoPUseAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        mBinding.recyclerView.addItemDecoration(SpaceItemDecoration(0, DensityUtil.dp2px(3.0f)))
        return mBinding.recyclerView
    }

    override fun initPageData() {
        getViewModel().queryRepairRecordList(sn, pageIndex, pageSize)
    }

    private var mDetailDialog: RepairRecordDetailDialog? = null

}