package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.custom.SpaceItemDecoration
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.base.common.utils.LanguageUtils
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.PeriodOrder
import com.okla.ops.databinding.DialogSelectInstallpaymentOrderBinding
import com.lxj.xpopup.core.BottomPopupView

@SuppressLint("ViewConstructor")
class DialogSelectPaymentOrder(
    context: Context,
    private val orderList: MutableList<PeriodOrder>,
    private val callBack: SelectCallBack
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_select_installpayment_order
    }

    private var mBinding: DialogSelectInstallpaymentOrderBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.btnCancel?.setOnClickListener {
            dismiss()
        }
        createAdapter()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<PeriodOrder>
    private fun createAdapter() {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<PeriodOrder>(R.layout.item_select_installpayment_order) {
            override fun convert(helper: BaseViewHolder, item: PeriodOrder) {
                super.convert(helper, item)
                item.run {
                    helper.setText(R.id.tv_orderno, item.orderNo)
                    if (item.isSelected) {
                        helper.setImageResource(R.id.img_select, R.mipmap.icon_green_checked)
                    } else {
                        helper.setImageResource(R.id.img_select, R.mipmap.icon_grey_unchecked)
                    }
                    if(item.type==1){
                        helper.setText(R.id.tv_device_sn, mContext.getString(R.string.text_battery).plus(" | ").plus(item.sn))
                    }else if(item.type==2){
                        helper.setText(R.id.tv_device_sn, mContext.getString(R.string.text_vehicle).plus(" | ").plus(item.sn))
                    }
                    if(null!=item.rePaymentDate){
                        helper.setText(R.id.tv_due_date, DateTimeUtils.getTimeString(DateTimeUtils.dateFormatY,item.rePaymentDate,LanguageUtils.LanguageUtil.getLocalByLanguage()))
                    }else{
                        helper.setText(R.id.tv_due_date, "-")
                    }
                    helper.setText(R.id.tv_monthly_amount, "$".plus(item.amount))
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                val periodOrder = adapter.data[position] as PeriodOrder
                adapter.data.forEachIndexed { index, item ->
                    mAdapter.data.get(index).isSelected = index == position
                }
                mAdapter.notifyDataSetChanged()
                callBack.onSelectPaymentOrder(periodOrder)
                mBinding?.rvOrders?.postDelayed(Runnable {
                    dismiss()
                }, 1000)
            }
        mAdapter.setNewData(orderList)
        mBinding?.rvOrders?.adapter = mAdapter
    }

    interface SelectCallBack {
        fun onSelectPaymentOrder(order: PeriodOrder)
    }
}