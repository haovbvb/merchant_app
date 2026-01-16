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
import com.okla.ops.databinding.DialogSelectSaleDataBinding

@SuppressLint("ViewConstructor")
class DialogSlectStatisticsData(
    context: Context,
    private val callBack: (pos: Int) -> Unit
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_select_sale_data
    }

    private var mBinding: DialogSelectSaleDataBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.btnCancel?.setOnClickListener {
            dismiss()
        }
        mBinding?.tvSalesData?.setOnClickListener {
            mBinding?.tvSalesData?.setTextColor(ContextCompat.getColor(context,R.color.main_color))
            mBinding?.tvAfterSaleData?.setTextColor(ContextCompat.getColor(context,R.color.color_e60c0c0d))
            callBack(0)
            mBinding?.tvSalesData?.postDelayed(Runnable {
                dismiss()
            },600)
        }
        mBinding?.tvAfterSaleData?.setOnClickListener {
            mBinding?.tvAfterSaleData?.setTextColor(ContextCompat.getColor(context,R.color.main_color))
            mBinding?.tvSalesData?.setTextColor(ContextCompat.getColor(context,R.color.color_e60c0c0d))
            callBack(1)
            mBinding?.tvAfterSaleData?.postDelayed(Runnable {
                dismiss()
            },600)
        }
    }
}