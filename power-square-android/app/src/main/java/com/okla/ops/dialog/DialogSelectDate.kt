package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import androidx.databinding.DataBindingUtil
import com.okla.ops.R
import com.okla.ops.databinding.DialogSelectDateBinding
import com.lxj.xpopup.core.BottomPopupView

@SuppressLint("ViewConstructor")
class DialogSelectDate(
    context: Context,
    private val callBack: (start: String, end: String, isCancel: Boolean) -> Unit
) : BottomPopupView(context) {

    private var mBinding: DialogSelectDateBinding? = null
    private var isClickCancel: Boolean = false
    private var pendingStartDate: String? = null
    private var pendingEndDate: String? = null

    override fun getImplLayoutId() = R.layout.dialog_select_date

    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        pendingStartDate?.let { mBinding?.tvStartDate?.text = it }
        pendingEndDate?.let { mBinding?.tvStartEnd?.text = it }

        mBinding?.btnCancel?.setOnClickListener {
            isClickCancel = true
            dismiss()
        }
        mBinding?.tvStartDate?.setOnClickListener {
            onDialogDateListener?.onStartClick(mBinding?.tvStartDate?.text.toString())
        }
        mBinding?.tvStartEnd?.setOnClickListener {
            onDialogDateListener?.onEndClick(mBinding?.tvStartEnd?.text.toString())
        }

    }

    override fun onShow() {
        super.onShow()
        // 每次 show 时再次应用缓存，保证无论首次还是重复弹出都刷新
        pendingStartDate?.let { mBinding?.tvStartDate?.text = it }
        pendingEndDate?.let { mBinding?.tvStartEnd?.text = it }
    }


    /** 外部在 show 之前调用，缓存并尝试刷新 */
    fun setStartDate(date: String) {
        pendingStartDate = date
        mBinding?.tvStartDate?.text = date
    }

    fun getStartDate(): String {
        return mBinding?.tvStartDate?.text.toString()
    }

    fun setEndDate(date: String) {
        pendingEndDate = date
        mBinding?.tvStartEnd?.text = date
    }

    fun getEndDate(): String {
        return mBinding?.tvStartEnd?.text.toString()
    }

    interface OnDialogDateListener {
        fun onStartClick(s: String)

        fun onEndClick(s: String)
    }

    private var onDialogDateListener: OnDialogDateListener? = null
    fun setDialogDateListener(listener: OnDialogDateListener) {
        this.onDialogDateListener = listener
    }

    override fun dismiss() {
        super.dismiss()
        val start = mBinding?.tvStartDate?.text?.toString()?.trim()
        val end = mBinding?.tvStartEnd?.text?.toString()?.trim()

        val isValidDate = { date: String? ->
            !date.isNullOrBlank()
        }

        if (isValidDate(start) && isValidDate(end)) {
            pendingStartDate = start!!
            pendingEndDate = end!!
        }

        callBack.invoke(
            pendingStartDate ?: "",
            pendingEndDate ?: "",
            isClickCancel
        )

        isClickCancel = false // 重置取消标志
    }

    override fun onDismiss() {
        super.onDismiss()
        callBack.invoke("", "", true)
    }
}