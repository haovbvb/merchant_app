package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import android.text.TextUtils
import androidx.databinding.DataBindingUtil
import com.base.common.utils.ToastUtils
import com.lxj.xpopup.core.BottomPopupView
import com.okla.ops.R
import com.okla.ops.databinding.DialogEditNicknameBinding

@SuppressLint("ViewConstructor")
class PopNicknameEdit(
    context: Context,
    private val callBack: (data: String) -> Unit
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_edit_nickname
    }

    override fun onCreate() {
        super.onCreate()
        DataBindingUtil.bind<DialogEditNicknameBinding>(
            bottomPopupContainer.getChildAt(
                0
            )
        )?.run {
            btnConfirm.setOnClickListener {
                val data = etInput.text.toString()
                if (TextUtils.isEmpty(data)) {
                    ToastUtils.showShort(context.getString(R.string.tips_enter_nickname))
                } else {
                    callBack.invoke(data)
                    dismiss()
                }
            }
            btnClose.setOnClickListener {
                dismiss()
            }
        }
    }

}