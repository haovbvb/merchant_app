package com.okla.ops.custom.deviceinfo

import android.content.Context
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.okla.ops.R

class InformationView(context: Context, attrs: AttributeSet?) :
    ConstraintLayout(context, attrs) {

    init {
        initTypeValue(context, attrs)
        initView(context)
    }

    private var mTitle: String? = ""
    private var isShowLine: Boolean = true
    private var addLeftArrow: Boolean = true

    private fun initTypeValue(context: Context, attrs: AttributeSet?) {
        val typeArray = context.obtainStyledAttributes(attrs, R.styleable.DeviceInfoView)
        mTitle = typeArray.getString(R.styleable.DeviceInfoView_DeviceInfoTitle)
        isShowLine = typeArray.getBoolean(R.styleable.DeviceInfoView_isShowLine, true)
        addLeftArrow = typeArray.getBoolean(R.styleable.DeviceInfoView_addRightArrow, false)
        typeArray.recycle()
    }

    lateinit var tvTitle: TextView
    lateinit var tvValue: TextView
    lateinit var vLine: View

    private fun initView(context: Context) {
        val inflate =
            LayoutInflater.from(context).inflate(R.layout.layout_device_info_desc, this)
        tvTitle = inflate.findViewById<TextView>(R.id.tvTitle)
        tvTitle.text = mTitle
        tvValue = inflate.findViewById<TextView>(R.id.tvValue)
        vLine = inflate.findViewById<View>(R.id.vLine)
        vLine.visibility = if (isShowLine) VISIBLE else GONE
        if (addLeftArrow) {
            val drawable = ContextCompat.getDrawable(context, R.mipmap.arrow_next)
            tvValue.setCompoundDrawablesRelativeWithIntrinsicBounds(null, null, drawable, null)
        }
    }

    fun setTitle(title: String) {
        tvTitle.text = title
    }

    fun setValue(value: String) {
        tvValue.text = value
    }

    fun getValue(): String {
        return tvValue.text.toString()
    }

    fun setValueColor(color: Int) {
        tvValue.setTextColor(color)
    }

    fun addValueDrawable(drawable: Drawable?) {
        tvValue.setCompoundDrawablesRelativeWithIntrinsicBounds(drawable, null, null, null)
    }

    fun showLine(isShow: Boolean) {
        vLine.visibility = if (isShow) VISIBLE else GONE
    }

}