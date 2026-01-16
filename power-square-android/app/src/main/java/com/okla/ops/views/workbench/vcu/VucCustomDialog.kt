package com.okla.ops.views.workbench.vcu

import android.annotation.SuppressLint
import android.content.Context
import android.text.TextUtils
import androidx.databinding.DataBindingUtil
import com.base.common.utils.ToastUtils
import com.okla.ops.R
import com.okla.ops.databinding.DialogVcuCustomBinding
import com.lxj.xpopup.core.BottomPopupView

@SuppressLint("ViewConstructor")
class VucCustomDialog(
    context: Context,
    private val textRes: Int,
    private val vcuCustomView: VcuCustomView,
    private val confirm: (data: VcuData) -> Unit
) : BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_vcu_custom
    }

    override fun onCreate() {
        super.onCreate()
        DataBindingUtil.bind<DialogVcuCustomBinding>(
            bottomPopupContainer.getChildAt(
                0
            )
        )?.run {
            tvTitle.text = context.getString(textRes)
            contentView.addView(vcuCustomView)
            btnCancel.setOnClickListener {
                dismiss()
            }
            btnSend.setOnClickListener {
                val data = vcuCustomView.getData()
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