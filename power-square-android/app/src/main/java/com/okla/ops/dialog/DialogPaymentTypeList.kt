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
import com.okla.ops.beans.PaymentType
import com.okla.ops.databinding.DialogPaymentPlanListBinding
import com.okla.ops.databinding.DialogPaymentTypeListBinding

@SuppressLint("ViewConstructor")
class DialogPaymentTypeList(
    context: Context,
    private val paymentTypeList: MutableList<PaymentType>,
    private val callBack: (paymentType: PaymentType) -> Unit
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_payment_type_list
    }

    private var mBinding: DialogPaymentTypeListBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.btnCancel?.setOnClickListener {
            dismiss()
        }
        createAdapter()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<PaymentType>
    private fun createAdapter() {
        mBinding?.rvPaymentType?.layoutManager =
            LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<PaymentType>(R.layout.layout_text_simple) {
            override fun convert(helper: BaseViewHolder, item: PaymentType) {
                super.convert(helper, item)
                item.run {
                    val tvContent = helper.getView<AppCompatTextView>(R.id.tvContent)
                    tvContent.text = name
                    tvContent.setTextColor(
                        if (selected) ContextCompat.getColor(
                            context,
                            R.color.main_color
                        ) else ContextCompat.getColor(context, R.color.color_e60c0c0d)
                    )
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                val paymentType = adapter.data[position] as PaymentType
                adapter.data.forEachIndexed { index, item ->
                    if (item is PaymentType) {
                        if (item.selected) {
                            item.selected = false
                            mAdapter.notifyItemChanged(index)
                        }
                    }
                }
                paymentType.selected = true
                mAdapter.notifyItemChanged(position)
                callBack.invoke(paymentType)
                dismiss()
            }
        var isItemSelected = false
        paymentTypeList.forEach {
            if (it.selected) {
                isItemSelected = true
            }
        }
        if (!isItemSelected) {
            paymentTypeList.firstOrNull()?.selected = true
        }
        mBinding?.rvPaymentType?.adapter = mAdapter
        mAdapter.setNewData(paymentTypeList)
    }

}