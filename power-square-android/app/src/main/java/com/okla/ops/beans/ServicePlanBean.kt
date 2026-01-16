package com.okla.ops.beans
data class ServicePlanInfo(
    val list: List<ServicePlanBean>,
    val total: Int
)


data class ServicePlanBean(
    val infoName:String?="-",
    val packageAmount:Double?,
    val batteryType:String?="-",
    val carType:String?="-",
    val infoCode:String?="-",
    val deviceModel:String?="-",
    var isSelected:Boolean
)
