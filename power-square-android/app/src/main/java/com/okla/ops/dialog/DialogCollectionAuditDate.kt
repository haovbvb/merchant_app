package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import android.text.TextUtils
import androidx.databinding.DataBindingUtil
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.lxj.xpopup.core.BottomPopupView
import com.okla.ops.R
import com.okla.ops.databinding.DialogCollectionAuditDateBinding

@SuppressLint("ViewConstructor")
class DialogCollectionAuditDate(
    context: Context,
    private val callBack: (start: String, end: String, name: String, dateOption: Int?) -> Unit
) : BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_collection_audit_date
    }

    private lateinit var today: String
    private lateinit var yesterday: String
    private lateinit var firstDayOfMonth: String
    private lateinit var lastDayOfMonth: String
    private var tempStartTime: String? = ""
    private var tempEndTime: String? = ""
    private var mBinding: DialogCollectionAuditDateBinding? = null
    override fun onCreate() {
        super.onCreate()
        val local = LanguageUtils.LanguageUtil.getLocalByLanguage();
        today = DateTimeUtils.getToday(local)
        yesterday = DateTimeUtils.getYesterday(local)
        firstDayOfMonth = DateTimeUtils.getFirstDayOfMonth(local)
        lastDayOfMonth = DateTimeUtils.getLastDayOfMonth(local)
        tempEndTime = DateTimeUtils.getToday(LanguageUtils.LanguageUtil.getLocalByLanguage())
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.let {
            it.tvToday.isSelected = true
            it.btnCancel.setOnClickListener {
                mBinding?.tvDateStart?.text = tempStartTime
                mBinding?.tvDateEnd?.text = tempEndTime
                dismiss()
            }
            it.tvToday.setOnClickListener {
                mBinding?.tvDateStart?.text = today
                mBinding?.tvDateEnd?.text = today
                selectTime()
                dismiss()
            }
            it.tvYesterday.setOnClickListener {
                mBinding?.tvDateStart?.text = yesterday
                mBinding?.tvDateEnd?.text = yesterday
                selectTime()
                dismiss()
            }
            it.tvMonth.setOnClickListener {
                mBinding?.tvDateStart?.text = firstDayOfMonth
                mBinding?.tvDateEnd?.text = lastDayOfMonth
                selectTime()
                dismiss()
            }
            it.tvOtherDate.setOnClickListener {
                onDialogDateListener?.onOtherDateClick()
            }
            it.tvDateStart.setOnClickListener {
                val startTime = if (TextUtils.equals(
                        mBinding?.tvDateStart?.text.toString(),
                        context.getString(R.string.text_start_time)
                    )
                ) "" else mBinding?.tvDateStart?.text.toString()
                onDialogDateListener?.onStartClick(startTime)
            }
            it.tvDateEnd.setOnClickListener {
                val endTime = if (TextUtils.equals(
                        mBinding?.tvDateEnd?.text.toString(),
                        context.getString(R.string.text_end_time)
                    )
                ) "" else mBinding?.tvDateEnd?.text.toString()
                onDialogDateListener?.onEndClick(endTime)
            }
        }
    }

    private fun selectTime() {
        mBinding?.tvToday?.isSelected = false
        mBinding?.tvYesterday?.isSelected = false
        mBinding?.tvMonth?.isSelected = false
        mBinding?.tvOtherDate?.isSelected = false
        val startTime = mBinding?.tvDateStart?.text.toString()
        val endTime = mBinding?.tvDateEnd?.text.toString()
        mBinding?.tvToday?.isSelected = startTime == today && endTime == today
        mBinding?.tvYesterday?.isSelected = startTime == yesterday && endTime == yesterday
        mBinding?.tvMonth?.isSelected = startTime == firstDayOfMonth && endTime == lastDayOfMonth
        mBinding?.tvOtherDate?.isSelected =
            startTime == endTime && startTime != today && startTime != yesterday
    }

    override fun dismiss() {
        super.dismiss()
        tempStartTime = mBinding?.tvDateStart?.text.toString()
        tempEndTime = mBinding?.tvDateEnd?.text.toString()
        val dateOption: Int
        val name: String
        if (mBinding?.tvToday?.isSelected == true) {
            name = context.getString(R.string.text_today)
            dateOption = 1
        } else if (mBinding?.tvYesterday?.isSelected == true) {
            name = context.getString(R.string.text_yesterday)
            dateOption = 2
        } else if (mBinding?.tvMonth?.isSelected == true) {
            name = context.getString(R.string.text_this_month)
            dateOption = 3
        } else {
            name = "$tempStartTime - $tempEndTime"
            dateOption = 4
        }
        callBack.invoke(
            mBinding?.tvDateStart?.text.toString(),
            mBinding?.tvDateEnd?.text.toString(),
            name,
            dateOption
        )
    }

    fun setStartDate(date: String) {
        mBinding?.tvDateStart?.text = date
        selectTime()
    }

    fun getStartDate(): String {
        return mBinding?.tvDateStart?.text.toString()
    }

    fun setEndDate(date: String) {
        mBinding?.tvDateEnd?.text = date
        selectTime()
    }

    fun getEndDate(): String {
        return mBinding?.tvDateEnd?.text.toString()
    }

    fun setOtherDate(date: String) {
        mBinding?.tvDateStart?.text = date
        mBinding?.tvDateEnd?.text = date
        selectTime()
        dismiss()
    }

    interface OnDialogDateListener {
        fun onStartClick(s: String)

        fun onEndClick(s: String)

        fun onOtherDateClick()
    }

    private var onDialogDateListener: OnDialogDateListener? = null
    fun setDialogDateListener(listener: OnDialogDateListener) {
        this.onDialogDateListener = listener
    }

}