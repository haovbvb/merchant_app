package com.okla.ops.views.workbench.entry

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.utils.ViewClickUtils

class BatteryInfoItem(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private lateinit var tvSn: AppCompatTextView
    private lateinit var tvImei: AppCompatTextView
    private lateinit var tvIccid: AppCompatTextView
    private lateinit var tvLockDevId: AppCompatTextView

    // 添加实例变量来存储数据
    private var currentSn: String = ""
    private var currentImei: String = ""
    private var currentIccid: String = ""
    private var currentLockDevId: String = ""
    private var currentDeviceType: Int = -1

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.item_battery_info, this, true)
        tvSn = findViewById(R.id.tvSn)
        tvImei = findViewById(R.id.tvImei)
        tvIccid = findViewById(R.id.tvIccid)
        tvLockDevId = findViewById(R.id.tvLockId)
        findViewById<View>(R.id.btnEdit).setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            if (onBatteryInfoListener != null) onBatteryInfoListener?.onEdit(this)
        }
        findViewById<View>(R.id.btnDelete).setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            if (onBatteryInfoListener != null) onBatteryInfoListener?.onDelete(this)
        }
    }

    fun setData(sn: String, imei: String, iccid: String, lockDevId: String, deviceType: Int) {
        // 存储到实例变量
        this.currentSn = sn
        this.currentImei = imei
        this.currentIccid = iccid
        this.currentLockDevId = lockDevId
        this.currentDeviceType = deviceType

        // 更新UI
        tvSn.text = "SN: $sn"
        if (deviceType == DeviceTypeObject.TYPE_BATTERY) {
            tvIccid.visibility = View.VISIBLE
            if (TextUtils.isEmpty(iccid)) {
                tvIccid.text = "ICCID:-"
            } else {
                tvIccid.text = "ICCID:$iccid"
            }
        } else if (deviceType == DeviceTypeObject.TYPE_VEHICLE) {
            tvIccid.visibility = View.VISIBLE
            if (TextUtils.isEmpty(iccid)) {
                tvIccid.text = "VCU:-"
            } else {
                tvIccid.text = "VCU:$iccid"
            }
        } else if (deviceType == DeviceTypeObject.TYPE_STATION) {
            tvIccid.visibility = View.GONE
        }

        if (deviceType == DeviceTypeObject.TYPE_BATTERY) {
            tvImei.visibility = View.VISIBLE
            if (TextUtils.isEmpty(imei)) {
                tvImei.text = "IMEI:-"
            } else {
                tvImei.text = "IMEI:$imei"
            }
        } else if (deviceType == DeviceTypeObject.TYPE_VEHICLE) {
            tvImei.visibility = View.VISIBLE
            if (TextUtils.isEmpty(imei)) {
                tvImei.text = "VIN:-"
            } else {
                tvImei.text = "VIN:$imei"
            }
        } else if (deviceType == DeviceTypeObject.TYPE_STATION) {
            tvImei.visibility = View.GONE
        }

        if (deviceType == DeviceTypeObject.TYPE_STATION) {
            tvLockDevId.visibility = View.VISIBLE
            if (TextUtils.isEmpty(lockDevId)) {
                tvLockDevId.text = "LOCKDEVID:-"
            } else {
                tvLockDevId.text = "LOCKDEVID:$lockDevId"
            }
        } else {
            tvLockDevId.visibility = View.GONE
        }
    }

    fun getSn(): String {
        return currentSn
    }

    fun getImei(): String {
        return currentImei
    }

    fun getIccid(): String {
        return currentIccid
    }

    fun getLockDevId(): String {
        return currentLockDevId
    }

    interface OnBatteryInfoListener {
        fun onEdit(v: BatteryInfoItem)
        fun onDelete(v: BatteryInfoItem)
    }

    private var onBatteryInfoListener: OnBatteryInfoListener? = null
    fun setOnBatteryInfoListener(listener: OnBatteryInfoListener) {
        onBatteryInfoListener = listener
    }
}