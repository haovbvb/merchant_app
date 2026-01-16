package com.okla.ops.custom.station

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.bumptech.glide.Glide
import com.okla.ops.beans.NewCabinetBean
import com.okla.ops.R


class StationInfoSimpleView(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private lateinit var tvModelName: TextView
    private lateinit var tvModel: TextView
    private lateinit var ivImage: ImageView

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_station_info_simple, this)
        ivImage = findViewById(R.id.iv_station)
        tvModelName = findViewById(R.id.tv_station_name)
        tvModel = findViewById(R.id.tv_station_model)
    }

    fun setData(newCabinetBean: NewCabinetBean?) {
        Glide.with(context).load(newCabinetBean?.standardImg).into(ivImage)
        tvModelName.text = newCabinetBean?.stationModel
        tvModel.text = newCabinetBean?.stationModelName
    }

}