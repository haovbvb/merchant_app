package com.okla.ops.custom

import android.content.Context
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.base.common.utils.DensityUtil
import com.google.android.flexbox.FlexboxLayout
import com.okla.ops.R
import com.okla.ops.beans.SearchHistory

class SearchHistoryView(context: Context, attrs: AttributeSet?) :
    ConstraintLayout(context, attrs) {

    init {
        initView()
    }

    private lateinit var tvSearchTitle: TextView
    private lateinit var imGarbage: ImageView
    private lateinit var fbSearchName: FlexboxLayout

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_search_history, this)
        tvSearchTitle = findViewById(R.id.tvSearchTitle)
        imGarbage = findViewById(R.id.imGarbage)
        fbSearchName = findViewById(R.id.fbSearchName)
        imGarbage.setOnClickListener {
            fbSearchName.removeAllViews()
            mOnClickListener?.onClearSearchName()
            imGarbage.visibility = GONE
        }
    }

    fun isExistHistoryData(name: String): Boolean {
        for (i in 0..fbSearchName.childCount) {
            val view = fbSearchName.getChildAt(i)
            if (view is TextView) {
                if (view.text == name) {
                    return true
                }
            }
        }
        return false
    }

    fun setHistoryData(histories: List<SearchHistory>) {
        val list = histories
        fbSearchName.removeAllViews()
        for (item in list) {
            val tv = TextView(context)
            tv.isSelected = false
            tv.background = ContextCompat.getDrawable(context, R.drawable.bg_ffffff_r16)
            tv.textSize = 13f
            tv.setTextColor(ContextCompat.getColor(context, R.color.color_b30c0c0d))
            tv.text = item.name
            tv.tag = item.id
            tv.setPadding(
                DensityUtil.dp2px(14f),
                DensityUtil.dp2px(4f),
                DensityUtil.dp2px(14f),
                DensityUtil.dp2px(4f)
            )
            val params = FlexboxLayout.LayoutParams(
                FlexboxLayout.LayoutParams.WRAP_CONTENT,
                FlexboxLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, DensityUtil.dp2px(12f), DensityUtil.dp2px(12f), 0)
            tv.layoutParams = params
            tv.setOnClickListener {
//                val id = (it as TextView).tag as String
                mOnClickListener?.onSelectedName(tv.text.toString())
            }
            fbSearchName.addView(tv)
        }
        imGarbage.visibility= VISIBLE
    }

    private var mOnClickListener: OnClickListener? = null
    fun setListener(listener: OnClickListener) {
        mOnClickListener = listener
    }

    interface OnClickListener {
        fun onSelectedName(id: String)
        fun onClearSearchName()
    }

}