package com.okla.ops.views.workbench.sales

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.Group
import com.bumptech.glide.Glide
import com.okla.ops.R
import com.okla.ops.beans.BatteryVo
import com.okla.ops.beans.CarVo

class BindDeviceInfoView(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private lateinit var tvSn: AppCompatTextView
    private lateinit var ivDevice: AppCompatImageView

    private lateinit var tvSoc: AppCompatTextView
    private lateinit var tvSoh: AppCompatTextView
    private lateinit var tvCycle: AppCompatTextView

    private lateinit var tvVin: AppCompatTextView
    private lateinit var tvPlate: AppCompatTextView

    private lateinit var tvValue1: AppCompatTextView
    private lateinit var tvValue2: AppCompatTextView

    private lateinit var batteryGroup: Group
    private lateinit var vehicleGroup: Group

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_bind_device_info, this)
        tvSn = findViewById(R.id.tv_device_sn)
        ivDevice = findViewById(R.id.img_device)

        tvValue1 = findViewById(R.id.tv_value1)
        tvValue2 = findViewById(R.id.tv_value2)

        tvSoc = findViewById(R.id.tv_soc);
        tvSoh = findViewById(R.id.tv_soh)
        tvCycle = findViewById(R.id.tv_cycle)

        tvVin = findViewById(R.id.tv_vin)
        tvPlate = findViewById(R.id.tv_plate)

        batteryGroup = findViewById(R.id.group_battery)
        vehicleGroup = findViewById(R.id.group_vehicle)

    }

    fun updateData(vehicle: CarVo) {
        batteryGroup.visibility = View.GONE
        vehicleGroup.visibility = View.VISIBLE
        tvSn.text = vehicle.sn
        Glide.with(context).load(vehicle.img).into(ivDevice)
        var vinStr = "-"
        if(!vehicle.vin.isNullOrBlank()){
            vinStr= vehicle.vin.toString()
        }
        tvVin.text = vinStr
        var plateStr = "-"
        if(!vehicle.carNumber.isNullOrBlank()){
           plateStr = vehicle.carNumber
        }
        tvPlate.text = plateStr
        var carModelValueStr = vehicle.carModel
        if (carModelValueStr == null || carModelValueStr?.isNullOrBlank() == true) {
            carModelValueStr = vehicle.carType
        }
        if (carModelValueStr == null || carModelValueStr?.isNullOrBlank() == true) {
            carModelValueStr = "-"
        }
        tvValue1.text = context.getString(R.string.text_vehicle).plus(" • ").plus(carModelValueStr)
        var sepcStr="-"
        if(!vehicle.carSpec.isNullOrBlank()){
            sepcStr = vehicle.carSpec
        }
        tvValue2.text =sepcStr
    }

    fun updateData(battery: BatteryVo) {
        batteryGroup.visibility = View.VISIBLE
        vehicleGroup.visibility = View.GONE
        tvSn.text = battery.sn
        Glide.with(context).load(battery.img).into(ivDevice)
        if (battery.soc != null) {
            tvSoc.text = battery.soc.toString()
        } else {
            tvSoc.text = "-"
        }
        if (battery.soh != null) {
            tvSoh.text = battery.soh.toString()
        }else{
            tvSoh.text="-"
        }
        if (battery.cycle != null) {
            tvCycle.text = battery.cycle.toString()
        }else{
            tvCycle.text="-"
        }
        var batteryModelValueStr = battery.batModel
        if (batteryModelValueStr == null || batteryModelValueStr?.isNullOrBlank() == true) {
            batteryModelValueStr = battery.batteryType
        }
        if (batteryModelValueStr == null || batteryModelValueStr?.isNullOrBlank() == true) {
            batteryModelValueStr = "-"
        }
        tvValue1.text =
            context.getString(R.string.text_battery).plus(" • ").plus(batteryModelValueStr)
        tvValue2.text = battery.batSpec ?: "-"
    }


}