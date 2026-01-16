package com.okla.ops.views.workbench.qm.maintenance

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.databinding.ViewDataBinding
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.custom.SpaceItemDecoration
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils.LanguageUtil.getLocalByLanguage
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.BookMaintenanceBean
import com.okla.ops.beans.VehicleParamBean
import com.okla.ops.custom.deviceinfo.InformationView

class MaintenanceVehicleInfoView(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private lateinit var ivImage: ImageView
    private lateinit var tvDevicesn: TextView
    private lateinit var tvDeviceModel: TextView
    private lateinit var tvDeviceSpec: TextView
    private lateinit var ivUserImage: ImageView
    private lateinit var tvUserName: TextView
    private lateinit var tvUserId: TextView
    private lateinit var invBookNo: InformationView
    private lateinit var invBookDate: InformationView
    private lateinit var tvRepairRecord: AppCompatTextView
    private lateinit var recyclerView: RecyclerView
    private lateinit var imgPhone: ImageView

    private var adapter: SingleDataBindingNoPUseAdapter<VehicleParamBean>? = null

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_maintenance_vehicle_info, this)
        ivImage = findViewById(R.id.iv_vehicle)
        tvDevicesn = findViewById(R.id.tv_device_sn)
        tvDeviceModel = findViewById(R.id.tv_model)
        tvDeviceSpec = findViewById(R.id.tv_spec)
        ivUserImage = findViewById(R.id.iv_header)
        tvUserName = findViewById(R.id.tv_username)
        tvUserId = findViewById(R.id.tv_userid)
        invBookNo = findViewById(R.id.invBookNo)
        invBookDate = findViewById(R.id.invBookDate)
        tvRepairRecord = findViewById(R.id.tv_repair_record)
        tvRepairRecord.setOnClickListener {
            mOnClickListener?.onClickListen(mSn)
        }
        imgPhone = findViewById(R.id.img_phone)
        imgPhone.setOnClickListener {
            mOnClickListener?.onClickPhoneImg(phoneStr)
        }
        recyclerView = findViewById(R.id.recycler_view)
        recyclerView.layoutManager = LinearLayoutManager(context, RecyclerView.HORIZONTAL, false)
        recyclerView.addItemDecoration(SpaceItemDecoration(12, 0))
        adapter = object :
            SingleDataBindingNoPUseAdapter<VehicleParamBean>(R.layout.item_vehicle_ride_info) {

            override fun convert(
                helper: BaseViewHolder?,
                item: VehicleParamBean,
                viewDataBinding: ViewDataBinding
            ) {
                super.convert(helper, item, viewDataBinding)
                helper?.setText(R.id.tvTitle, item.title)
                helper?.setText(R.id.tvValue, item.value)
            }
        }
        recyclerView.adapter = adapter

    }

    fun getBookNo(): String {
        return invBookNo.getValue()
    }

    fun updateData(data: BookMaintenanceBean) {
        val vehicleParamList = mutableListOf(
            VehicleParamBean(
                context.getString(R.string.maintenance_vehicle_avg_mileage),
                "${data.day30AvgMilePerDay ?: 0}km"
            ),
            VehicleParamBean(
                context.getString(R.string.maintenance_vehicle_avg_speed),
                "${data.day30AvgSpeed ?: 0} km/hr"
            ),
            VehicleParamBean(
                context.getString(R.string.maintenance_vehicle_avg_swap),
                "${data.day30AvgSwapCount ?: 0}"
            )
        )
        adapter?.setNewData(vehicleParamList)
//        invTotalMileage.setValue(StringUtil.m2km(data.day30Mile?.toDouble() ?: 0.0))
        invBookNo.setValue(data.reservationNo ?: "")
        invBookDate.setValue(
            if (data.reservationDate != null) DateTimeUtils.getTimeString(
                DateTimeUtils.dateFormatY,
                DateTimeUtils.stringToLong(
                    data.reservationDate, DateTimeUtils.dateFormat,
                    getLocalByLanguage()
                )
            ) else {
                "-"
            }
        )
        tvDeviceModel.text = data.carModel ?: "-"
        tvDeviceSpec.text = data.carSpec ?: "-"
        mSn = data.sn ?: "-"
        phoneStr = data.phone ?: ""
        tvDevicesn.text = mSn
        Glide.with(context).load(data.img)
            .into(ivImage)
        Glide.with(context).load(data.avatar).error(R.mipmap.icon_def_avatar)
            .into(ivUserImage)
        tvUserName.text = data.username ?: "-"
        tvUserId.text = data.cardNum ?: "-"
    }

    private var mSn: String = "-"
    private var phoneStr = ""
    private var mOnClickListener: OnClickListener? = null
    fun setListener(listener: OnClickListener) {
        mOnClickListener = listener
    }

    interface OnClickListener {
        fun onClickListen(sn: String)
        fun onClickPhoneImg(phone: String)
    }

}