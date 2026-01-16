package com.okla.ops.views.workbench.entry

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.bumptech.glide.Glide
import com.okla.ops.R
import com.okla.ops.utils.ViewClickUtils

class BatteryInfoItem2(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private lateinit var tvSn: AppCompatTextView
    private lateinit var tvModelName: AppCompatTextView
    private lateinit var ivBattery: ImageView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.item_battery_info2, this, true)
        tvSn = findViewById(R.id.tvSn)
        tvModelName = findViewById(R.id.tvModelName)
        ivBattery = findViewById(R.id.ivBattery)
        findViewById<ImageView>(R.id.imgDelete).setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            if (onBatteryInfo2Listener != null) onBatteryInfo2Listener?.onDelete(this)
        }
    }

    fun setData(sn: String, model: String, modelName: String, src: String) {
        tvSn.text = String.format("SN: $sn")
        tvModelName.text = String.format("$model ($modelName)")
        Glide.with(context).load(src).into(ivBattery)
    }

    fun getSn(): String {
        return tvSn.text.toString().replace("SN: ", "")
    }

    interface OnBatteryInfo2Listener {
        fun onDelete(v: BatteryInfoItem2)
    }

    private var onBatteryInfo2Listener: OnBatteryInfo2Listener? = null
    fun setOnBatteryInfo2Listener(listener: OnBatteryInfo2Listener) {
        onBatteryInfo2Listener = listener
    }

}