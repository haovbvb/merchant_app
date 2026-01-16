package com.okla.ops.utils

import android.content.Context
import android.location.LocationManager
import android.os.Build

class LocationUtil {
    companion object {
        /**
         * 检查设备的定位服务（GPS 或 网络定位）是否至少开启一个。
         */
        fun isLocationServiceEnabled(mContext: Context): Boolean {
            val lm = mContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager

            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // Android 9.0 及以上推荐用 isLocationEnabled()
                lm.isLocationEnabled
            } else {
                // Android 9.0 以下，则分别检查 GPS_PROVIDER 和 NETWORK_PROVIDER
                lm.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                        lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
            }
        }
    }
}