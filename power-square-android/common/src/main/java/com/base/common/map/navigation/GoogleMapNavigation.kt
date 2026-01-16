package com.base.common.map.navigation

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.base.common.R
import com.base.common.utils.ToastUtils

object GoogleMapNavigation {

    //在google官网：Maps SDK for Android-->启动 Google 地图
    fun startNavigation(context: Context, latitude: Double, longitude: Double) {
        val mStringBuilder = StringBuilder()
        mStringBuilder.append("google.navigation:q=")
        mStringBuilder.append(latitude)
        mStringBuilder.append(",")
        mStringBuilder.append(longitude)
        val googleAddrUri = Uri.parse(mStringBuilder.toString())
        val mapIntent = Intent(Intent.ACTION_VIEW, googleAddrUri)
        mapIntent.setPackage("com.google.android.apps.maps")
        /*if (mapIntent.resolveActivity(requireActivity().packageManager) != null) {
            startActivity(mapIntent)
        } else {
            ToastUtils.showShort(getString(R.string.bs_google_map_install_tip))
        }*/
        try {
            context.startActivity(mapIntent)
        } catch (ex: Exception) {
            ToastUtils.showShort(context.getString(R.string.google_map_install_tip))
        }
    }

}