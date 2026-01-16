package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.lxj.xpopup.core.BottomPopupView
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.PaymentPlan
import com.okla.ops.databinding.DialogPaymentPlanListBinding

@SuppressLint("ViewConstructor")
class DialogPaymentPlanList(
    context: Context,
    private val paymentPlanList: MutableList<PaymentPlan>,
    private val callBack: (plan: PaymentPlan) -> Unit
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_payment_plan_list
    }

    private var mBinding: DialogPaymentPlanListBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.btnCancel?.setOnClickListener {
            dismiss()
        }
        createAdapter()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<PaymentPlan>
    private fun createAdapter() {
        mBinding?.rvPaymentPlan?.layoutManager =
            LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<PaymentPlan>(R.layout.layout_text_simple) {
            override fun convert(helper: BaseViewHolder, item: PaymentPlan) {
                super.convert(helper, item)
                item.run {
                    val tvContent = helper.getView<AppCompatTextView>(R.id.tvContent)
                    val tvRate = helper.getView<AppCompatTextView>(R.id.tv_rate)
                    tvContent.text = context.getString(
                        R.string.text_payment_plan_periods,
                        "${item.period}"
                    )
                    tvContent.setTextColor(
                        if (selected) ContextCompat.getColor(
                            context,
                            R.color.main_color
                        ) else ContextCompat.getColor(context, R.color.color_e60c0c0d)
                    )
                    tvRate.text =context.getString(R.string.text_rate_plan,(item.rate?.times(100)).toString())
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                val paymentPlan = adapter.data[position] as PaymentPlan
                adapter.data.forEachIndexed { index, item ->
                    if (item is PaymentPlan) {
                        if (item.selected) {
                            item.selected = false
                            mAdapter.notifyItemChanged(index)
                        }
                    }
                }
                paymentPlan.selected = true
                mAdapter.notifyItemChanged(position)
                callBack.invoke(paymentPlan)
                dismiss()
            }
        var isItemSelected = false
        paymentPlanList.forEach {
            if (it.selected) {
                isItemSelected = true
            }
        }
        if (!isItemSelected) {
            paymentPlanList.firstOrNull()?.selected = true
        }
        mBinding?.rvPaymentPlan?.adapter = mAdapter
        mAdapter.setNewData(paymentPlanList)
    }

}