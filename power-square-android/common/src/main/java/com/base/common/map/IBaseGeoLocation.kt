package com.base.common.map

interface IBaseGeoLocation {
    //初始化定位
    fun initLocationClient()

    //开始定位
    fun onStartLocate(listener: GeoLocationCallback, minTimeMs: Long, minDistanceM: Float)

    //停止定位
    fun onPauseLocate()

    //销毁定位及监听
    fun onStopLocate()
}