package com.okla.ops.dialog

import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.Window
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.viewModels
import com.okla.ops.R
import com.okla.ops.views.workbench.sales.sellbind.SellBindViewModel

class PaymentListDialogFragment : DialogFragment() {
    private val viewModel: SellBindViewModel by viewModels()
    private var amountStr = ""

    companion object {
        fun getInstance(
            packageAmount: String
        ): PaymentListDialogFragment {
            val planListFragment = PaymentListDialogFragment()
            val bundle = Bundle()
            bundle.putString("amount", packageAmount)
            planListFragment.arguments = bundle
            return planListFragment;
        }
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        amountStr = arguments?.getString("amount") ?: ""
        // 获取布局
        val inflater: LayoutInflater = requireActivity().layoutInflater
        val view: View = inflater.inflate(R.layout.dialog_payment_plan_list, null)
        val dialog = Dialog(requireContext())
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(view) // 使用自定义布局
        dialog.setCancelable(false) // 禁用返回键关闭
        dialog.setCanceledOnTouchOutside(true) // 禁用点击外部关闭
        return dialog
    }
}