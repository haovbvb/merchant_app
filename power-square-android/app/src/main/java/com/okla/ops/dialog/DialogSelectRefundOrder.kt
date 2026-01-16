package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.base.common.utils.NumToStrUtil
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.databinding.DialogSelectRefundOrderBinding
import com.okla.ops.views.workbench.sales.depositrefund.Deposit
import com.lxj.xpopup.core.BottomPopupView

@SuppressLint("ViewConstructor")
class DialogSelectRefundOrder(
    context: Context,
    private val orderList: MutableList<Deposit>,
    private val callBack: SelectCallBack
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_select_refund_order
    }

    private var selectedOrderList = ArrayList<Deposit>()
    private var mBinding: DialogSelectRefundOrderBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.btnCancel?.setOnClickListener {
            dismiss()
        }
        createAdapter()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<Deposit>
    private fun createAdapter() {
        mBinding?.rvBatterys?.layoutManager =
            LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<Deposit>(R.layout.item_dialog_select_refundorder) {
            override fun convert(helper: BaseViewHolder, item: Deposit) {
                super.convert(helper, item)
                item.run {
                    if (item.unbindTime != null) {
                        helper.setText(
                            R.id.tv_unbind_time,
                            DateTimeUtils.getTimeString(
                                DateTimeUtils.dateFormatNormal,
                                item.unbindTime,
                                LanguageUtils.LanguageUtil.getLocalByLanguage()
                            )
                        )
                    } else {
                        helper.setText(R.id.tv_unbind_time, item.unbindTime ?: "-")
                    }
                    helper.setText(
                        R.id.tv_order_no,
                        mContext.getString(R.string.str_order_no).plus(item.orderNo)
                    )
                    val depositAmount = NumToStrUtil.DoubleToStrWith2(depositAmount)
                    helper.setText(R.id.tv_price, "$".plus(depositAmount))
                    if (item.isSelected) {
                        helper.setImageResource(R.id.img_check, R.mipmap.icon_green_checked)
                    } else {
                        helper.setImageResource(R.id.img_check, R.mipmap.icon_grey_unchecked)
                    }
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                orderList.forEachIndexed { index, deposit ->
                    deposit.isSelected = index == position
                }
                mAdapter.notifyDataSetChanged()
                callBack.onSelectedRefundOrder(orderList.get(position))
                dismiss()
            }
        mAdapter.setNewData(orderList)
        mBinding?.rvBatterys?.adapter = mAdapter
    }

    interface SelectCallBack {
        fun onSelectedRefundOrder(order: Deposit)
    }
}