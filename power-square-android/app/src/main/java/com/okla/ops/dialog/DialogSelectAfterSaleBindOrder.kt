package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import android.widget.TextView
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.AfterSaleCanBindOrderBean
import com.okla.ops.databinding.DialogSelectRefundOrderBinding
import com.lxj.xpopup.core.BottomPopupView

@SuppressLint("ViewConstructor")
class DialogSelectAfterSaleBindOrder(
    context: Context,
    private val orderList: MutableList<AfterSaleCanBindOrderBean>,
    private val callBack: SelectCallBack
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_select_refund_order
    }

    private var mBinding: DialogSelectRefundOrderBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.tvTitle?.text = context?.getString(R.string.str_select_after_sale_order)
        mBinding?.btnCancel?.setOnClickListener {
            dismiss()
        }
        createAdapter()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<AfterSaleCanBindOrderBean>
    private fun createAdapter() {
        mBinding?.rvBatterys?.layoutManager =
            LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<AfterSaleCanBindOrderBean>(R.layout.item_select_aftersale_order) {
            override fun convert(helper: BaseViewHolder, item: AfterSaleCanBindOrderBean) {
                super.convert(helper, item)
                item.run {
                    helper.setText(
                        R.id.tv_order_no,
                        mContext.getString(R.string.str_order_no).plus(item.orderNo)
                    )
                    if (item.isSelected) {
                        helper.setImageResource(R.id.img_check, R.mipmap.icon_green_checked)
                    } else {
                        helper.setImageResource(R.id.img_check, R.mipmap.icon_grey_unchecked)
                    }
                    val tvDevice = helper.getView<TextView>(R.id.tv_device)
                    if (item.deviceType == 1) {
                        //电池
                        tvDevice.text = context.getString(R.string.text_battery).plus(" | ")
                            .plus(item.batteryType)
                    } else {
                        //车
                        tvDevice.text =
                            context.getString(R.string.text_vehicle).plus(" | ").plus(item.carType)
                    }
                    if (item.type == 1) {
                        //销售
                        helper.setText(R.id.tv_ordertype, mContext.getString(R.string.sale))
                    } else if (item.type == 2) {
                        //租赁
                        helper.setText(R.id.tv_ordertype, mContext.getString(R.string.lease))
                    } else {
                        helper.setText(R.id.tv_ordertype, "-")
                    }
//                    status: 1=已支付 2=分期中 3=租赁中
                    if (item.status == 1) {
                        helper.setText(R.id.tv_orderStatus, mContext.getString(R.string.paid))
                    } else if (item.status == 2) {
                        helper.setText(
                            R.id.tv_orderStatus,
                            mContext.getString(R.string.in_progress)
                        )
                    } else if (item.status == 3) {
                        helper.setText(R.id.tv_orderStatus, mContext.getString(R.string.lease))
                    } else {
                        helper.setText(R.id.tv_orderStatus, "-")
                    }
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                orderList.forEachIndexed { index, afterSaleCanBindOrderBean ->
                    afterSaleCanBindOrderBean.isSelected = index == position
                }
                mAdapter.notifyDataSetChanged()
                callBack.onSelected(orderList.get(position))
                dismiss()
            }
        mAdapter.setNewData(orderList)
        mBinding?.rvBatterys?.adapter = mAdapter
    }

    interface SelectCallBack {
        fun onSelected(order: AfterSaleCanBindOrderBean)
    }
}