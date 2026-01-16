package com.okla.ops.weight

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R

class KeyValueTextView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs) {

    init {
        initView()
    }

    private lateinit var tvKey: AppCompatTextView
    private lateinit var tvValue: AppCompatTextView
    private lateinit var ivArrow: ImageView
    private lateinit var vLine: View
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_key_value, this)
        tvKey = findViewById(R.id.tvKey)
        tvValue = findViewById(R.id.tvValue)
        ivArrow = findViewById(R.id.ivArrow)
        vLine = findViewById(R.id.vLine)
    }

    fun setKey(key: String) {
        tvKey.text = key
    }

    fun setValue(value: String) {
        tvValue.text = value
    }

    fun setValueColor(color: Int) {
        tvValue.setTextColor(color)
    }

    fun showArrow() {
        ivArrow.visibility = View.VISIBLE
    }

    fun hideArrow(){
        ivArrow.visibility = View.GONE

    }

    fun hideLine() {
        vLine.visibility = View.GONE
    }

}