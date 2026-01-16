package com.okla.ops.views.workbench.qm.repairrecord

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.bumptech.glide.Glide
import com.okla.ops.R
import com.okla.ops.beans.BatteryVo
import com.okla.ops.beans.CarVo

class RepairDeviceInfoView(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private lateinit var tvDeviceSn: TextView
    private lateinit var tvTitle1: TextView
    private lateinit var tvTitle2: TextView
    private lateinit var tvValue1: TextView
    private lateinit var tvValue2: TextView
    private lateinit var ivImage: ImageView
    private lateinit var tvStatus: TextView
    private lateinit var tvCarSpec: TextView
    private lateinit var tvBindUser: TextView
    private lateinit var tvTitleBindUser: TextView
    private lateinit var tvEntryTime: TextView


    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_repair_device_info, this)
        ivImage = findViewById(R.id.iv_device)
        tvDeviceSn = findViewById(R.id.tv_device_sn)
        tvStatus = findViewById(R.id.tv_status)
        tvCarSpec = findViewById(R.id.tv_car_spec)
        tvTitle1 = findViewById(R.id.tv_title1)
        tvTitle2 = findViewById(R.id.tv_title2)
        tvValue1 = findViewById(R.id.tv_value1)
        tvValue2 = findViewById(R.id.tv_value2)
        tvBindUser = findViewById(R.id.tv_binduser)
        tvEntryTime = findViewById(R.id.tv_entrytime)
        tvTitleBindUser = findViewById(R.id.tv_title_binduserid)
    }

    fun updateData(car: CarVo?): RepairDeviceInfoView {
        tvTitle1.text = context.getString(R.string.str_model)
        tvTitle2.text = context.getString(R.string.str_plate_number)
        tvCarSpec.visibility = View.VISIBLE
        car?.let {
            tvDeviceSn.text = it.sn
            if (null != it.carSpec) {
                tvCarSpec.text = it.carSpec
            }
            if (null != it.carModel) {
                tvValue1.text = it.carModel
            }
            if (null != it.carNumber) {
                tvValue2.text = it.carNumber
            }
            Glide.with(context).load(it.img).into(ivImage)
            if (it.cardNum == null || TextUtils.isEmpty(it.cardNum)) {
                tvBindUser.visibility = View.GONE
                tvTitleBindUser.visibility = View.GONE

                tvStatus.text = context?.getString(R.string.str_unbound)
                tvStatus.setTextColor(ContextCompat.getColor(context, R.color.color_ffa4332))
                tvStatus.setBackgroundResource(R.drawable.bg_fff3f2_r4)
            } else {
                tvBindUser.visibility = View.VISIBLE
                tvTitleBindUser.visibility = View.VISIBLE
                tvBindUser.text = it.cardNum

                tvStatus.text = context?.getString(R.string.str_bound)
                tvStatus.setTextColor(ContextCompat.getColor(context, R.color.main_color))
                tvStatus.setBackgroundResource(R.drawable.bg_line_maincolor_r4)
            }
            tvEntryTime.text = DateTimeUtils.getTimeString(DateTimeUtils.dateFormatY,it.createTime,LanguageUtils.LanguageUtil.getLocalByLanguage())
        }
        return this
    }

    fun updateData(car: BatteryVo?): RepairDeviceInfoView {
        tvTitle1.text = context.getString(R.string.str_model)
        tvTitle2.text = context.getString(R.string.str_specification)
        tvCarSpec.visibility = View.GONE
        car?.let {
            tvDeviceSn.text = it.sn
            if(null!=it.batModel){
                tvValue1.text = it.batModel
            }
            if(null!=it.batSpec){
                tvValue2.text = it.batSpec
            }
            Glide.with(context).load(it.img).into(ivImage)
            if (it.cardNum == null || TextUtils.isEmpty(it.cardNum)) {
                tvBindUser.visibility = View.GONE
                tvTitleBindUser.visibility = View.GONE

                tvStatus.text = context?.getString(R.string.str_unbound)
                tvStatus.setTextColor(ContextCompat.getColor(context, R.color.color_ffa4332))
                tvStatus.setBackgroundResource(R.drawable.bg_fff3f2_r4)
            } else {
                tvBindUser.visibility = View.VISIBLE
                tvTitleBindUser.visibility = View.VISIBLE
                tvBindUser.text = it.cardNum

                tvStatus.text = context?.getString(R.string.str_bound)
                tvStatus.setTextColor(ContextCompat.getColor(context, R.color.main_color))
                tvStatus.setBackgroundResource(R.drawable.bg_line_maincolor_r4)
            }
            tvEntryTime.text = DateTimeUtils.getTimeString(DateTimeUtils.dateFormatY,it.createTime,LanguageUtils.LanguageUtil.getLocalByLanguage())
        }
        return this
    }
}