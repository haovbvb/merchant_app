package com.okla.ops.views.workbench.device

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R
import com.okla.ops.weight.BatteryDataView

class KeyBatterySocView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs) {

    init {
        initView()
    }

    private lateinit var tvKey: AppCompatTextView
    private lateinit var batteryData: BatteryDataView
    private lateinit var vLine: View
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_key_battery_soc, this)
        tvKey = findViewById(R.id.tvKey)
        batteryData = findViewById(R.id.batteryData)
        vLine = findViewById(R.id.vLine)
    }

    fun setKey(key: String) {
        tvKey.text = key
    }

    fun setBatterySoc(soc: Int?) {
        batteryData.setData(soc, 0)
    }

    fun hideLine() {
        vLine.visibility = View.GONE
    }

}