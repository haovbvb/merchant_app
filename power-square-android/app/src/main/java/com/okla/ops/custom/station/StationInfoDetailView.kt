package com.okla.ops.custom.station

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.bumptech.glide.Glide
import com.okla.ops.beans.NewCabinetBean
import com.okla.ops.R

class StationInfoDetailView(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private lateinit var tvStationName: TextView
    private lateinit var tvModelInfo: TextView
    private lateinit var tvAddress: TextView
    private lateinit var ivImage: ImageView
    private lateinit var ivLocalImg: ImageView

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_station_info_detail, this)
        ivImage = findViewById(R.id.iv_station)
        tvStationName = findViewById(R.id.tv_station_name)
        tvModelInfo = findViewById(R.id.tv_station_model)
        tvAddress = findViewById(R.id.tv_address)
        ivLocalImg = findViewById(R.id.iv_location)
    }

    fun setData(newCabinetBean: NewCabinetBean?) {
        Glide.with(context).load(newCabinetBean?.standardImg).into(ivImage)
        tvStationName.text = newCabinetBean?.stationName
        tvModelInfo.text = "${newCabinetBean?.stationModel} | ${newCabinetBean?.stationModelName}"
        newCabinetBean?.address.let {
            if (TextUtils.isEmpty(it)) {
                tvAddress.visibility = INVISIBLE
                ivLocalImg.visibility = INVISIBLE
            } else {
                tvAddress.text = it
                ivLocalImg.visibility = VISIBLE
            }
        }
    }

}