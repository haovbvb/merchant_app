package com.okla.ops.views.monitor

import android.content.Context
import android.location.Location
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.base.common.beans.LocationData
import com.base.common.map.navigation.GoogleMapNavigation
import com.base.common.map.popup.MapPopup
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.LocationAddressUtils
import com.base.library.utils.StringUtil
import com.bumptech.glide.Glide
import com.okla.ops.R
import com.okla.ops.beans.NearByVehicle
import com.luck.picture.lib.thread.PictureThreadUtils.runOnUiThread
import com.lxj.xpopup.XPopup
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.util.concurrent.Executors

class BatteryMapInfoView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs) {

    init {
        initView()
    }

    private lateinit var ivDevice: AppCompatImageView
    private lateinit var tvSn: AppCompatTextView
    private lateinit var tvStatus: AppCompatTextView
    private lateinit var tvAddress: AppCompatTextView
    private lateinit var tvDistance: AppCompatTextView
    private lateinit var tvBindId: AppCompatTextView
    private lateinit var tvMileageValue: AppCompatTextView
    private lateinit var tvPhone: TextView
    private lateinit var tvCarNumber: TextView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_battery_map_info, this)
        ivDevice = findViewById(R.id.ivDevice)
        tvSn = findViewById(R.id.tvSn)
        tvStatus = findViewById(R.id.tvStatus)
        tvAddress = findViewById(R.id.tvAddress)
        tvDistance = findViewById(R.id.tvDistance)
        tvBindId = findViewById(R.id.tvBindid)
        tvMileageValue = findViewById(R.id.tvMileageValue)
        tvPhone = findViewById(R.id.tv_phone)
        tvCarNumber = findViewById(R.id.tvPlateNumValue)
        findViewById<AppCompatTextView>(R.id.btnMore).setOnClickListener {
            onMoreClickListener?.invoke(mDeviceSn)
        }
    }

    private var mDeviceSn: String = ""
    fun updateData(battery: NearByVehicle, centerLocationData: LocationData) {
        Glide.with(context).load(battery.img).into(ivDevice)
        if (battery.needMaintenance == true) {
            tvStatus.visibility = View.VISIBLE
        } else {
            tvStatus.visibility = View.GONE
        }
        mDeviceSn = battery.sn ?: "-"
        tvSn.text = String.format("SN: $mDeviceSn")
        tvCarNumber.text = battery.carNumber ?: ""
        tvMileageValue.text =
            if (battery.mile == null) "-km" else StringUtil.m2km(battery.mile)
        if (battery.latitude != null && battery.latitude != 0.0 && battery.longitude != null && battery.longitude != 0.0) {
            val distance = FloatArray(1)
            Location.distanceBetween(
                centerLocationData.latitude,
                centerLocationData.longitude,
                battery.latitude,
                battery.longitude,
                distance
            )
            tvDistance.text = StringUtil.m2km(distance[0].toDouble())
            tvDistance.setOnClickListener {
                XPopup.Builder(context)
                    .asCustom(MapPopup(context) {
                        GoogleMapNavigation.startNavigation(
                            context,
                            centerLocationData.latitude,
                            centerLocationData.longitude
                        )
                    })
                    .show()
            }
            LocationAddressUtils.getAddressByLocal(
                battery.latitude,
                battery.longitude,
                battery.sn ?: ""
            ).apply {
                if (TextUtils.isEmpty(this)) {
                    Executors.newSingleThreadExecutor().execute {
                        runBlocking {
                            launch {
                                val result =
                                    LocationAddressUtils.getAddressByCoroutine(
                                        battery.latitude,
                                        battery.longitude,
                                        context
                                    )
                                LocationAddressUtils.saveAddressToLocal(
                                    battery.latitude,
                                    battery.longitude, battery.sn ?: "", result
                                )
                                runOnUiThread {
                                    tvAddress.text = result
                                }
                            }
                        }
                    }
                } else {
                    tvAddress.text = this
                }
            }
        }
        tvBindId.text = context.getString(R.string.str_binding_id, battery.cardNum ?: "-")

    }

    private var onMoreClickListener: ((String) -> Unit)? = null
    fun setOnMoreClickListener(listener: (String) -> Unit) {
        this.onMoreClickListener = listener
    }

    fun updatePhone(phone: String) {
        val areaCode = DataStoreUtils.readStringData(
            DataStoreKeyUtils.AREA_CODE, ""
        )
        tvPhone.text = areaCode.plus(phone)
    }

}