package com.okla.ops.views.workbench.sales.sellbind

import android.content.Context
import android.view.LayoutInflater
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R
import com.okla.ops.beans.ServicePlanBean
import com.okla.ops.utils.TextUtil

class ServicePlanInfoView (context: Context) : ConstraintLayout(context), TextUtil {

    init {
        initView()
    }

    private lateinit var tvDeviceType: AppCompatTextView
//    private lateinit var tvDeviceModel: AppCompatTextView
    private lateinit var tvPrice: AppCompatTextView
    private lateinit var tvServiceName: AppCompatTextView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_serviceplan_info, this)
        tvDeviceType = findViewById(R.id.tv_device_type)
//        tvDeviceModel = findViewById(R.id.tv_device_model)
        tvPrice = findViewById(R.id.tv_price)
        tvServiceName = findViewById(R.id.tv_service_name)
    }

    fun updateData(servicePlanBean: ServicePlanBean) {
        tvDeviceType.text = servicePlanBean.carType?:servicePlanBean.batteryType
//        tvDeviceModel.text = servicePlanBean.infoCode
        tvPrice.text = servicePlanBean.packageAmount.toString()
        tvServiceName.text = servicePlanBean.infoName
    }

}