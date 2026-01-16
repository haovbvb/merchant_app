package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.View
import androidx.databinding.DataBindingUtil
import com.base.common.utils.ToastUtils
import com.lxj.xpopup.core.BottomPopupView
import com.okla.ops.R
import com.okla.ops.databinding.DialogEditTextBinding

@SuppressLint("ViewConstructor")
class PopContentEdit(
    context: Context,
    private  val titleStr:String,
    private val callBack: (data: String) -> Unit
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_edit_text
    }

    override fun onCreate() {
        super.onCreate()
        DataBindingUtil.bind<DialogEditTextBinding>(
            bottomPopupContainer.getChildAt(
                0
            )
        )?.run {
            tvTitle.text = titleStr
            btnConfirm.setOnClickListener {
                val data = etInput.text.toString()
                if (TextUtils.isEmpty(data)) {
                    ToastUtils.showShort(context.getString(R.string.hint_enter_tracking_number))
                    return@setOnClickListener
                } else {
                    callBack.invoke(data)
                    dismiss()
                }
            }
            btnClose.setOnClickListener {
                dismiss()
            }
            ivClear.setOnClickListener {
                etInput.setText("")
            }
            etInput.addTextChangedListener(object : TextWatcher {
                override fun beforeTextChanged(
                    s: CharSequence?,
                    start: Int,
                    count: Int,
                    after: Int
                ) {

                }

                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                    if (TextUtils.isEmpty(s.toString())) {
                        ivClear.visibility = View.GONE
                    } else {
                        ivClear.visibility = View.VISIBLE
                    }
                }

                override fun afterTextChanged(s: Editable?) {
                }
            })
        }
    }

}