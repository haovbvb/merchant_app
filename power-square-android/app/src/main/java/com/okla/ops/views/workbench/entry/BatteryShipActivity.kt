package com.okla.ops.views.workbench.entry

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.NavOptions
import androidx.navigation.fragment.findNavController
import com.base.common.base.mvvm.BaseNormalVActivity
import com.okla.ops.R
import com.okla.ops.beans.Battery
import com.okla.ops.beans.Car
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.beans.Station
import com.okla.ops.databinding.ActivityBatteryShipBinding
import com.okla.ops.utils.TextUtil

class BatteryShipActivity : BaseNormalVActivity<DeviceShipViewModel, ActivityBatteryShipBinding>(),
    TextUtil {

    companion object {
        fun startBatteryShipActivity(context: Context, batteryList: ArrayList<Battery>) {
            val intent = Intent(context, BatteryShipActivity::class.java)
            intent.putExtra("batteryList", batteryList)
            context.startActivity(intent)
        }

        fun startVehicleShipActivity(context: Context, carList: ArrayList<Car>) {
            val intent = Intent(context, BatteryShipActivity::class.java)
            intent.putExtra("carList", carList)
            context.startActivity(intent)
        }

        fun startStationShipActivity(context: Context, carList: ArrayList<Station>) {
            val intent = Intent(context, BatteryShipActivity::class.java)
            intent.putExtra("stationList", carList)
            context.startActivity(intent)
        }
    }


    override fun onCreateViewModel(): DeviceShipViewModel {
        return ViewModelProvider(this)[DeviceShipViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_battery_ship
    }

    private var batteryList: ArrayList<Battery>? = null
    private var carList: ArrayList<Car>? = null
    private var stationList:ArrayList<Station>?=null
    override fun getIntentExtras(intent: Intent?) {
        batteryList = intent?.getParcelableArrayListExtra("batteryList")
        carList = intent?.getParcelableArrayListExtra("carList")
        stationList = intent?.getParcelableArrayListExtra("stationList")
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        val navHostFragment = supportFragmentManager.findFragmentById(R.id.navHostFragment)
        var bundle: Bundle? = null
        if (!batteryList.isNullOrEmpty()) {
            bundle = Bundle().apply {
                putParcelableArrayList(
                    "batteryList",
                    batteryList
                )
                putInt("deviceType", DeviceTypeObject.TYPE_BATTERY)
            }
        } else if(!carList.isNullOrEmpty()){
            bundle = Bundle().apply {
                putParcelableArrayList(
                    "carList",
                     carList
                )
                putInt("deviceType", DeviceTypeObject.TYPE_VEHICLE)
            }
        }else if(!stationList.isNullOrEmpty()){
            bundle = Bundle().apply {
                putParcelableArrayList(
                    "stationList",
                    carList
                )
                putInt("deviceType", DeviceTypeObject.TYPE_STATION)
            }
        }

        val options = NavOptions.Builder()
//            .setLaunchSingleTop(true) // 避免重复创建
            .setPopUpTo(R.id.batterShipFragment, true) // 避免重复创建，与 setLaunchSingleTop 一样效果
            .build()
        navHostFragment?.findNavController()?.navigate(R.id.batterShipFragment, bundle, options)
    }

}