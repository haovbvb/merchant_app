package com.okla.ops.views.workbench.entry

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.okla.ops.R
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.databinding.FragmentShipSuccessBinding
import com.okla.ops.utils.TextUtil

class ShipSucActivity : BaseNormalVActivity<DeviceShipViewModel, FragmentShipSuccessBinding>(),
    TextUtil {

    companion object {
        fun startActivity(context: Context, documentId: String, deviceType: Int) {
            val intent = Intent(context, ShipSucActivity::class.java)
            intent.putExtra("documentNo", documentId)
            intent.putExtra("deviceType", deviceType)
            context.startActivity(intent)
        }
    }

    private var mDeviceType = 0

    override fun getLayoutId(): Int {
        return R.layout.fragment_ship_success
    }


    override fun title(): Int {
        return R.string.title_battery_ship
    }

    override fun onCreateViewModel(): DeviceShipViewModel {
        return ViewModelProvider(this)[DeviceShipViewModel::class.java]
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
//        mBinding.tvNumber.setOnClickListener(this)
        mBinding.btnReturn.setOnClickListener(this)
//        val documentNo = intent?.getStringExtra("documentNo") ?: ""
//        if(!TextUtils.isEmpty(documentNo)){
//            mBinding.tvDocumentNumber.visibility = View.VISIBLE
//            mBinding.tvNumber.visibility=View.VISIBLE
//            mBinding.tvNumber.text = documentNo
//        }else{
//            mBinding.tvDocumentNumber.visibility = View.GONE
//            mBinding.tvNumber.visibility= View.GONE
//        }
        mDeviceType = intent?.getIntExtra("deviceType", 0) ?: 0
        when (mDeviceType) {
            DeviceTypeObject.TYPE_BATTERY -> {
                mBinding.includeTitle.topTitle.text =
                    mContext.getString(R.string.title_battery_entry)
            }

            DeviceTypeObject.TYPE_VEHICLE -> {
                mBinding.includeTitle.topTitle.text =
                    mContext.getString(R.string.title_vehicle_entry)
            }

            DeviceTypeObject.TYPE_STATION ->{
                mBinding.includeTitle.topTitle.text= getString(R.string.title_station_entry)
            }
        }
    }


    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.tvNumber -> {
                mBinding.tvNumber.copyTextToClipboard(
                    mContext,
                    getString(R.string.tips_copid_to_clipboard)
                )
            }

            R.id.btnReturn -> {
                activity?.finish()
            }
        }
    }

}