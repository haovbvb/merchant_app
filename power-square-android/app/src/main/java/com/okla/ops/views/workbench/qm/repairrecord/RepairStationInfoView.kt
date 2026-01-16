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
import com.okla.ops.beans.StationVo

class RepairStationInfoView(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private lateinit var tvStationName: TextView
    private lateinit var tvStatus: TextView
    private lateinit var tvModel: TextView
    private lateinit var ivImage: ImageView
    private lateinit var tvAddress: TextView
    private lateinit var tvCreateTime: TextView


    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_repair_station_info, this)
        ivImage = findViewById(R.id.iv_device)
        tvStationName = findViewById(R.id.tv_station_name)
        tvStatus = findViewById(R.id.tv_status)
        tvModel = findViewById(R.id.tv_station_spec)
        ivImage = findViewById(R.id.iv_device)
        tvCreateTime = findViewById(R.id.tv_time_value)
        tvAddress= findViewById(R.id.tv_address)
    }

    fun updateData(stationVo: StationVo?): RepairStationInfoView {
        Glide.with(context).load(stationVo?.img).into(ivImage)
        if (stationVo?.onlineFlag == 0) {
            tvStatus.text = context?.getString(R.string.offline)
            tvStatus.setTextColor(ContextCompat.getColor(context, R.color.color_ffa4332))
            tvStatus.setBackgroundResource(R.drawable.bg_line_fa4332_r4)
        } else {
            tvStatus.text = context?.getString(R.string.text_online)
            tvStatus.setTextColor(ContextCompat.getColor(context, R.color.main_color))
            tvStatus.setBackgroundResource(R.drawable.bg_line_maincolor_r4)
        }
        tvStationName.text= stationVo?.name?:"-"
        tvModel.text= stationVo?.storeNum?.plus("plots")
        tvAddress.text = stationVo?.address ?: "-"
        tvCreateTime.text = DateTimeUtils.getTimeString(
            DateTimeUtils.dateFormatY,
            stationVo?.createTime,
            LanguageUtils.LanguageUtil.getLocalByLanguage()
        )
        return this
    }


}