package com.base.common.beans

/**
 * @Date: 2021/1/11 17:37
 * @Author: Craz
 * @Description:
 * @Version:
 */
class LocationData {
    constructor()
    constructor(latitude: Double, longitude: Double) {
        this.latitude = latitude
        this.longitude = longitude
    }

    val latitudeStr: String
        get() = latitude.toString()

    fun setLatitude(latitude: String) {
        this.latitude = latitude.toDouble()
    }

    val longitudeStr: String
        get() = longitude.toString()

    fun setLongitude(longitude: String) {
        this.longitude = longitude.toDouble()
    }

    /**
     * 火星经纬度：谷歌、高德、腾讯纬度
     * 百度经纬度：百度
     */
    var latitude: Double = 0.0 //纬度
    var longitude: Double = 0.0 //经度
}