package com.base.common.utils

import android.content.Context
import android.location.Geocoder
import com.base.library.utils.GsonUtils

object LocationAddressUtils {
    fun getAddressByLocal(
        latitude: Double,
        longitude: Double,
        key: String,
    ): String {
        val data = DataStoreUtils.readStringData(key, "")
        val localAdr = GsonUtils.fromGson(data, LocationAddr::class.java)
        localAdr?.let {
            if (localAdr.latitude == latitude && localAdr.longitude == longitude) {
                return localAdr.address
            }
        }
        return ""
    }

    fun saveAddressToLocal(
        latitude: Double,
        longitude: Double,
        key: String,
        address: String,
    ) {
        val json = GsonUtils.toGson(
            LocationAddr(latitude, longitude, address)
        )
        DataStoreUtils.putSyncData(key, json)
    }

    fun getAddressByCoroutine(
        latitude: Double,
        longitude: Double,
        context: Context
    ): String {
        if (Geocoder.isPresent()) {
            val geocoder = Geocoder(context)
            try {
                val fromLocation =
                    geocoder.getFromLocation(
                        latitude,
                        longitude,
                        1
                    )
                return if (fromLocation != null && fromLocation.size > 0) {
                    var addressStr = "-"
                    for (address in fromLocation) {
                        addressStr =
                            address.getAddressLine(address.maxAddressLineIndex)
                        break
                    }
                    addressStr
                } else {
                    "-"
                }
            } catch (e: Exception) {
                e.printStackTrace()
                return "-"
            }
        } else {
            return "-"
        }
    }
}

data class LocationAddr(
    var latitude: Double = 0.0,
    var longitude: Double = 0.0,
    var address: String = "",
)