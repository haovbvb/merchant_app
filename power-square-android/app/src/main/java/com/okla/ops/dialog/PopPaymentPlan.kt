package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import android.view.View
import android.widget.LinearLayout
import com.lxj.xpopup.core.AttachPopupView
import com.okla.ops.R
import com.okla.ops.beans.PaymentPlan
import com.okla.ops.weight.SimpleTextView

@SuppressLint("ViewConstructor")
class PopPaymentPlan(
    context: Context,
    private val paymentPlanList: MutableList<PaymentPlan>,
    private val callBack: (plan: PaymentPlan) -> Unit
) : AttachPopupView(context) {
    override fun getImplLayoutId(): Int {
        return R.layout.pop_payment_plan
    }

    override fun onCreate() {
        super.onCreate()
        val linearLayout = findViewById<LinearLayout>(R.id.llContent)

        paymentPlanList.forEach {
            val textView = SimpleTextView(context)
            textView.setContent(
                context.getString(
                    R.string.text_payment_plan_periods,
                    "${it.planName}",
                    "${it.period}"
                )
            )
            textView.tag = it
            textView.setOnClickListener { v ->
                v?.tag?.let { tag ->
                    if (tag is PaymentPlan) {
                        callBack.invoke(tag)
                    }
                }
                dismiss()
            }
            linearLayout.addView(textView)
        }
    }
}