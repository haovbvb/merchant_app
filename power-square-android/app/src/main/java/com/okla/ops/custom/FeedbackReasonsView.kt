package com.okla.ops.custom

import android.content.Context
import android.text.Editable
import android.text.TextWatcher
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.EditText
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.base.common.utils.DensityUtil
import com.google.android.flexbox.FlexboxLayout
import com.okla.ops.R

class FeedbackReasonsView(context: Context, attrs: AttributeSet?) :
    ConstraintLayout(context, attrs) {

    private lateinit var flCommonFlexbox: FlexboxLayout
    private lateinit var etFeedbackContent: EditText
    private lateinit var tvReasonTitle: TextView

    private var selectReason: String? = null  // 单选，只保存一个

    private val allReasonViews = mutableListOf<TextView>()

//    private lateinit var unbindReasons: MutableList<String>

    init {
        initView()
    }

    private  var mOnTextInputListener: OnTextInputListener?=null
    fun setOnTextInputListener(listener: OnTextInputListener) {
        mOnTextInputListener = listener
    }

    interface OnTextInputListener {
        fun onTextInputed(content: String)
    }

    private fun initView() {
//        unbindReasons = mutableListOf()
//        unbindReasons.add(context.getString(R.string.unbind_common_reasons_1))
//        unbindReasons.add(context.getString(R.string.unbind_device_reason_equip_failure))

        LayoutInflater.from(context).inflate(R.layout.layout_reasons_retirement, this)
        flCommonFlexbox = findViewById(R.id.flexbox)
        tvReasonTitle = findViewById(R.id.tvUnshelveDesc)
        etFeedbackContent = findViewById(R.id.etUnshelve)

        etFeedbackContent.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}

            override fun afterTextChanged(s: Editable?) {
                val input = s?.toString()?.trim() ?: ""
                selectReason = input
                mOnTextInputListener?.onTextInputed(input)
                // 和input 完全相等选中
                allReasonViews.forEach { tv ->
                    val isSelected = tv.text.toString() == input
                    tv.isSelected = isSelected
                    tv.setTextColor(
                        ContextCompat.getColor(
                            context,
                            if (isSelected) R.color.main_color else R.color.color_99000000
                        )
                    )
                    if (isSelected) selectReason = tv.text.toString()
                }
            }
        })
    }

    fun initCommonReasons(list: List<String>) {
        flCommonFlexbox.removeAllViews()
        allReasonViews.clear()
        list.forEach { reason ->
            val tv = TextView(context).apply {
                isSelected = false
                background = ContextCompat.getDrawable(context, R.drawable.selector_feedback)
                textSize = 13f
                setTextColor(ContextCompat.getColor(context, R.color.color_99000000))
                text = reason
                setPadding(
                    DensityUtil.dp2px(8f),
                    DensityUtil.dp2px(8f),
                    DensityUtil.dp2px(8f),
                    DensityUtil.dp2px(8f)
                )
                val params = FlexboxLayout.LayoutParams(
                    FlexboxLayout.LayoutParams.WRAP_CONTENT,
                    FlexboxLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, DensityUtil.dp2px(8f), DensityUtil.dp2px(8f), 0)
                layoutParams = params

                setOnClickListener {
                    //清空之前选择
                    allReasonViews.forEach { child ->
                        child.isSelected = false
                        child.setTextColor(ContextCompat.getColor(context, R.color.color_99000000))
                    }
                    //选中当前
                    isSelected = true
                    setTextColor(ContextCompat.getColor(context, R.color.main_color))
                    selectReason = text.toString()
                    //同步到输入框
                    etFeedbackContent.setText(selectReason)
                    etFeedbackContent.setSelection(selectReason?.length?:0)
                }
            }
            allReasonViews += tv
            flCommonFlexbox.addView(tv)
        }
    }

    fun getFeedbackReason(): String? {
        return selectReason
    }


    fun clearFeedbackReason() {
        selectReason = ""
        etFeedbackContent.setText("")
        if(!allReasonViews.isNullOrEmpty()){
            allReasonViews.forEach { tv ->
                tv.isSelected = false
                tv.setTextColor(ContextCompat.getColor(context, R.color.color_99000000))
            }
        }
    }


    fun setReasonTitleAndHint(title: String, hint: String) {
        tvReasonTitle.text = title
        etFeedbackContent.hint = hint
    }
}