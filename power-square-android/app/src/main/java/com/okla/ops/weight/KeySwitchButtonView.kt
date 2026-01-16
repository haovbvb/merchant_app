package com.okla.ops.weight

import android.content.Context
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.CompoundButton
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R

class KeySwitchButtonView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs) {

    init {
        initView()
    }

    private lateinit var tvKey: AppCompatTextView
    private lateinit var iosSwitch: SwitchButton
    private lateinit var vLine: View
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_key_switch, this)
        tvKey = findViewById(R.id.tvKey)
        iosSwitch = findViewById(R.id.iosSwitch)
        vLine = findViewById(R.id.vLine)
    }

    fun setKey(key: String) {
        tvKey.text = key
    }

    fun hideLine() {
        vLine.visibility = View.GONE
    }

    fun setChecked() {
        iosSwitch.isChecked = !iosSwitch.isChecked
        iosSwitch.startAnimate()
        setSwitchOnCheckedListener()
    }

    fun setChecked(isChecked: Boolean) {
        iosSwitch.isChecked = isChecked
        iosSwitch.startAnimate()
        setSwitchOnCheckedListener()
    }

    private val onCheckedChangeListener: CompoundButton.OnCheckedChangeListener =
        CompoundButton.OnCheckedChangeListener { _, isChecked ->
            Log.d("setChecked", "setChecked: $isChecked")
            iosSwitch.setOnCheckedChangeListener(null) // 暂时移除监听器避免循环调用
            iosSwitch.isChecked = !isChecked          // 恢复原状态
            onSwitchListener?.invoke(isChecked)
        }

    fun setSwitchOnCheckedListener() {
        iosSwitch.setOnCheckedChangeListener(onCheckedChangeListener)
    }

    private var onSwitchListener: ((Boolean) -> Unit)? = null
    fun setOnSwitchListener(listener: (Boolean) -> Unit) {
        this.onSwitchListener = listener
    }

}