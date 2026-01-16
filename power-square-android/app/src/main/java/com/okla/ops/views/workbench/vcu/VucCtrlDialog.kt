package com.okla.ops.views.workbench.vcu

import android.annotation.SuppressLint
import android.content.Context
import android.text.TextUtils
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import com.base.common.utils.ToastUtils
import com.okla.ops.R
import com.okla.ops.databinding.DialogVcuCtrlBinding
import com.lxj.xpopup.core.BottomPopupView

@SuppressLint("ViewConstructor")
class VucCtrlDialog(
    context: Context,
    private val drawableRes: Int,
    private val textRes: Int,
    private val data: String,
    private val confirm: (data: VcuData) -> Unit
) : BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_vcu_ctrl
    }

    override fun onCreate() {
        super.onCreate()
        DataBindingUtil.bind<DialogVcuCtrlBinding>(
            bottomPopupContainer.getChildAt(
                0
            )
        )?.run {
            ivTitle.setImageDrawable(ContextCompat.getDrawable(context, drawableRes))
            tvTitle.text = context.getString(textRes)
            btn4G.isSelected = false
            btn4G.setOnClickListener {
                btnBle.isSelected = false
                btn4G.isSelected = true
            }
            btnBle.isSelected = true
            btnBle.setOnClickListener {
                btn4G.isSelected = false
                btnBle.isSelected = true
            }
            btnCancel.setOnClickListener {
                dismiss()
            }
            btnSend.setOnClickListener {
                val data = VcuData("", data, select = false, net = btn4G.isSelected)
                if (TextUtils.isEmpty(data.data)) {
                    ToastUtils.showShort(context.getString(R.string.str_invalid_data))
                    return@setOnClickListener
                }
                dismiss()
                confirm.invoke(data)
            }
        }
    }

}