package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import android.view.View
import androidx.databinding.DataBindingUtil
import com.lxj.xpopup.core.BottomPopupView
import com.okla.ops.R
import com.okla.ops.databinding.DialogSelectApplicantBinding
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.weight.InputScanView.OnInputScanListener

@SuppressLint("ViewConstructor")
class DialogSelectApplicant(
    context: Context,
    private val callBack: () -> Unit
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_select_applicant
    }

    private var mBinding: DialogSelectApplicantBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.btnConfirm?.setOnClickListener {
            if(ViewClickUtils.isFastClick()){
                return@setOnClickListener
            }
            callBack.invoke()
        }
        mBinding?.inputScanView?.setOnInputScanListener(object : OnInputScanListener {
            override fun onScanClick() {
                onDialogSelectListener?.onScanClick()
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                onDialogSelectListener?.onEditTextNotHasFocus(inputContent)
            }

        })
        mBinding?.inputScanView?.setOnHasFocusListener {
            onDialogSelectListener?.onEditHasFocus(it)
        }
        mBinding?.inputScanView?.setHint(context.getString(R.string.hint_enter_user_id_or_scan_qr_code))
    }

    fun removePurchasingUserView() {
        mBinding?.flContent?.removeAllViews()
//        mBinding?.btnConfirm?.isEnabled = false
    }

    fun addPurchasingUserView(view: View?) {
        mBinding?.nsvContent?.let {
            val screenHeight = resources.displayMetrics.heightPixels
            val maxHeight = (screenHeight * 0.7).toInt() // 高度限制为屏幕的70%
            it.layoutParams.height = maxHeight
        }
        mBinding?.flContent?.removeAllViews()
        view?.let {
            mBinding?.flContent?.addView(it)
        }
    }

    fun isExistPurchasingUserView(): Boolean {
        return (mBinding?.flContent?.childCount ?: 0) > 0
    }

    fun setConfirmBtnEnable(enable: Boolean) {
        mBinding?.btnConfirm?.isEnabled = enable
    }

    fun setEditContent(content: String) {
        mBinding?.inputScanView?.setContent(content)
    }

    interface OnDialogSelectListener {
        fun onScanClick()

        fun onEditTextNotHasFocus(inputContent: String?)

        fun onEditHasFocus(hasFocus: Boolean)
    }

    private var onDialogSelectListener: OnDialogSelectListener? = null
    fun setOnDialogSelectListener(listener: OnDialogSelectListener) {
        this.onDialogSelectListener = listener
    }

}