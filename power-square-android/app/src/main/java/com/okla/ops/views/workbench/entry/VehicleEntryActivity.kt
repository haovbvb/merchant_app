package com.okla.ops.views.workbench.entry

import android.Manifest
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.dialog.CustomDialog
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.qrcode.QrCodeUtils
import com.base.common.utils.ToastUtils
import com.base.common.utils.WindowInsetsHelper
import com.bumptech.glide.Glide
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.beans.CarNew
import com.okla.ops.beans.CarType
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.beans.ScanDeviceBean
import com.okla.ops.databinding.ActivityBatteryEntryBinding
import com.okla.ops.dialog.DialogBatteryInput
import com.okla.ops.utils.ScanUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.QRCodeListActivity
import com.okla.ops.views.workbench.warehouse.devicetransport.DeviceTransportCreateActivity
import com.luck.picture.lib.utils.SdkVersionUtils

class VehicleEntryActivity :
    BaseNormalVActivity<DeviceShipViewModel, ActivityBatteryEntryBinding>() {
    private val snList = ArrayList<String>()
    private var carType: CarType? = null

    companion object {
        fun startVehicleEntryActivity(context: Context, carType: CarType) {
            val intent = Intent(context, VehicleEntryActivity::class.java)
            intent.putExtra("carType", carType)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): DeviceShipViewModel {
        return ViewModelProvider(this)[DeviceShipViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_battery_entry
    }

    override fun title(): Int {
        return R.string.title_vehicle_entry
    }

    override fun getIntentExtras(intent: Intent?) {
        carType = intent?.getParcelableExtra("carType")
    }

    private lateinit var permissionManager: PermissionManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            this.activityResultRegistry, this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        initObserver()
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        initClick()
        initData()
        WindowInsetsHelper.applyForBottom(mBinding.clbottom)
    }

    private fun initObserver() {
        getViewModel().newCarListLiveData.observe(this) {
            val newCarCount = getViewModel().getNewCarCount();
            mBinding.btnConfirm.isEnabled = newCarCount > 0
            if (newCarCount > 0) {
                mBinding.layoutScrollview.visibility = View.VISIBLE
                mBinding.layoutEmpty.visibility = View.GONE
            } else {
                mBinding.layoutScrollview.visibility = View.GONE
                mBinding.layoutEmpty.visibility = View.VISIBLE
            }
            mBinding.tvTotal.text =
                getString(R.string.text_vehicle_total, newCarCount)

        }
        val gotoShipMsg = getString(R.string.dialog_go_to_ship_vehicles)
        getViewModel().registerCarLiveData.observe(this) {
            CustomDialog.Builder(this)
                .setTitle(getString(R.string.dialog_submit_completed))
                .setMessage(gotoShipMsg)
                .setNegativeButton(com.base.common.R.string.cc_str_close) { dialog, _ ->
                    dialog.dismiss()
                    ShipSucActivity.startActivity(mContext, "", DeviceTypeObject.TYPE_VEHICLE)
                    finish()
                }
                .setPositiveButton(R.string.title_ship) { dialog, _ ->
                    dialog.dismiss()
//                    val arrayList = ArrayList<Car>()
                    getViewModel().getNewCarList().forEach { newCar ->
//                        arrayList.add(
//                            Car(
//                                newCar.sn,
//                                newCar.vin,
//                                carType?.model,
//                                carType?.modelName,
//                                carType?.img
//                            )
//                        )
                        snList.add(newCar.sn)
                    }
//                    arrayList.forEach {
//                        it.sn?.let { it1 -> snList.add(it1) }
//                    }
                    DeviceTransportCreateActivity.getIntents(
                        this,
                        DeviceTypeObject.TYPE_VEHICLE,
                        snList
                    )
//                    BatteryShipActivity.startVehicleShipActivity(this, arrayList)
                    finish()
                }.create().show()
        }
    }

    private fun initClick() {
        mBinding.bgManualentry.setOnClickListener(this)
        mBinding.bgScanentry.setOnClickListener(this)
        mBinding.btnConfirm.setOnClickListener(this)
    }

    private fun initData() {
        mBinding.tvBatteryDimension.text =
            mContext.getString(R.string.text_engine_model)
        mBinding.tvBatteryWeight.text = mContext.getString(R.string.text_made_date)
        carType?.let {
            Glide.with(this).load(it.img).into(mBinding.ivBattery)
            mBinding.tvBatteryModel.text = "${it.model} (${it.modelName})"
            mBinding.tvBatteryDetail.text = it.remark
            mBinding.tvDimension.text = it.engineModel ?: "-"
            mBinding.tvWeight.text = it.engineDate ?: "-"
        }
        mBinding.tvTotal.text =
            getString(R.string.text_vehicle_total, getViewModel().getNewCarCount())
    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.bg_manualentry -> {
                showDialogBatteryInput(0, null, mContext.getString(R.string.btn_manual_entry))
            }

            R.id.bg_scanentry -> {
                mScanType = 1
                askPermission()
            }

            R.id.btnConfirm -> {
                val newCarCount = getViewModel().getNewCarCount();
                if (newCarCount <= 0) {
                    ToastUtils.showShort(getString(R.string.tips_vehicle_not_empty))
                    return
                }
                getViewModel().newCarListLiveData.value?.forEach {
                    if (it.vin.trim().isNullOrBlank()) {
                        ToastUtils.showShort(mContext.getString(R.string.str_vin_is_required))
                        return
                    }
                }
                val batteryStr = getString(R.string.text_vehicles)

                val string = getString(
                    R.string.dialog_battery_content,
                    "$newCarCount $batteryStr"
                )
                val start = string.indexOf("$newCarCount")
                val end = string.indexOf(batteryStr) + batteryStr.length
                val spannableString = SpannableString(string)
                val color = Color.parseColor("#FF08983B")
                spannableString.setSpan(
                    ForegroundColorSpan(color),
                    start,
                    end,
                    Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                )
                CustomDialog.Builder(this)
                    .setTitle(getString(R.string.dialog_confirm_submit))
                    .setSpannableMessage(spannableString)
                    .setNegativeButton { dialog, _ -> dialog.dismiss() }
                    .setPositiveButton { dialog, _ ->
                        dialog.dismiss()
                        getViewModel().registerCar(carType?.model ?: "")
                    }.create().show()
            }
        }
    }

    private fun addCarItem(index: Int, batterSn: String, vin: String, iccid: String) {
        val result = getViewModel().addNewCar(CarNew(batterSn, vin, iccid))
        if (result) {
            val item = BatteryInfoItem(this)
            item.setData(batterSn, vin, iccid,"", DeviceTypeObject.TYPE_VEHICLE)
            item.setOnBatteryInfoListener(object : BatteryInfoItem.OnBatteryInfoListener {
                override fun onEdit(v: BatteryInfoItem) {
                    for (i in 0 until mBinding.llBattery.childCount) {
                        val childView = mBinding.llBattery.getChildAt(i)
                        if (childView is BatteryInfoItem) {
                            if (childView.getSn() == v.getSn()) {
                                showDialogBatteryInput(
                                    i,
                                    v,
                                    mContext.getString(R.string.title_edit_info)
                                )
                                break
                            }
                        }
                    }
                }

                override fun onDelete(v: BatteryInfoItem) {
                    getViewModel().removeNewCar(v.getSn())
                    mBinding.llBattery.removeView(v)
                }

            })
            mBinding.llBattery.addView(item, index)
        }
//        else {
//            ToastUtils.showShort(getString(R.string.tips_battery_exist))
//        }
    }

    private fun updateCarItem(index: Int, batterSn: String, vin: String, iccid: String) {
        getViewModel().updateNewCarInfo(index, batterSn, vin, iccid)
        for (i in 0 until mBinding.llBattery.childCount) {
            if (index == i) {
                val childView = mBinding.llBattery.getChildAt(i)
                if (childView is BatteryInfoItem) {
                    childView.setData(batterSn, vin, iccid,"", DeviceTypeObject.TYPE_VEHICLE)
                }
                break
            }
        }
    }

    private fun askPermission() {
        val permissions = mutableListOf(
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.CAMERA,
        )
        if (SdkVersionUtils.isTIRAMISU()) {
            permissions.remove(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
        permissionManager.checkPermissions(object : PermissionListenerImpl() {
            override fun passPermission() {
                super.passPermission()
                if (mScanType == 1) {
                    val list = getViewModel().newCarListLiveData.value ?: mutableListOf()
                    val scanBeanList: ArrayList<ScanDeviceBean> = arrayListOf()
                    list.forEach {
                        scanBeanList.add(ScanDeviceBean(it.sn, it.vin,""))
                    }
                    startActivityForResult(
                        QRCodeListActivity.getIntents(
                            activity,
                            false,
                            scanBeanList,
                            true,true,DeviceTypeObject.TYPE_VEHICLE
                        ),
                        QrCodeUtils.REQUEST_CODE_SCAN_SN_LIST
                    );
//                    startActivityForResult(
//                        ScanSnQrCodeListActivity.getIntents(activity, false, snList),
//                        QrCodeUtils.REQUEST_CODE_SCAN_SN_LIST
//                    )
                } else {
//                    startActivityForResult(Intent(this@BatteryEntryActivity, QRCodeActivity::class.java),QrCodeUtils.REQUEST_CODE_DEFINE)
//                    QrCodeUtils.startScanQrCode(this@BatteryEntryActivity)
                    IntentIntegrator(this@VehicleEntryActivity)
                        .setOrientationLocked(false)
                        .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                        .setCaptureActivity(QRCodeActivity::class.java)
                        .initiateScan() //  初始化扫描
                }
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(this@VehicleEntryActivity, "")
            }
        }, *permissions.toTypedArray())
    }


    private var dialogBatteryInput: DialogBatteryInput? = null
    private fun showDialogBatteryInput(
        index: Int,
        batteryInfoItem: BatteryInfoItem?,
        title: String
    ) {
        if (dialogBatteryInput == null) {
            dialogBatteryInput =
                DialogBatteryInput(
                    this,
                    title,
                    DeviceTypeObject.TYPE_VEHICLE ?: 0
                )
        }
        dialogBatteryInput?.setOnInputListener(object :
            DialogBatteryInput.OnInputListener {
            override fun onConfirm(
                index: Int,
                batterSn: String?,
                imei: String?,
                iccid: String?,
                lockDevId:String?
            ) {
                if (batteryInfoItem == null) {
                    addCarItem(index, batterSn ?: "", imei ?: "", iccid ?: "")
                } else {
                    updateCarItem(index, batterSn ?: "", imei ?: "", iccid ?: "")
                }
            }

            override fun onScan(scanType: Int) {
                mScanType = scanType
                askPermission()
            }

        })
        dialogBatteryInput?.updateTitle(title)
        dialogBatteryInput?.setIndex(index)
        if (batteryInfoItem == null) {
            dialogBatteryInput?.updateBatterySn("")
            dialogBatteryInput?.updateIMEI("")
            dialogBatteryInput?.updateICCID("")
        } else {
            dialogBatteryInput?.updateBatterySn(batteryInfoItem.getSn())
            dialogBatteryInput?.updateIMEI(batteryInfoItem.getImei())
            dialogBatteryInput?.updateICCID(batteryInfoItem.getIccid())
        }
        dialogBatteryInput?.show()
    }

    private var mScanType: Int = 0
    var mScanResult: String = ""

    /**
     * Event for receiving the activity result.
     *
     * @param requestCode Request code.
     * @param resultCode Result code.
     * @param data        Result.
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (data == null) {
            return
        }
        if (requestCode == QrCodeUtils.REQUEST_CODE_SCAN_SN_LIST) {
            if (mScanType == 1) {//sn list
                val list =
                    data?.getParcelableArrayListExtra<ScanDeviceBean>(QRCodeListActivity.SN_LIST)
                list?.let {
                    it.forEachIndexed { index, scanDeviceBean ->
                        addCarItem(index, scanDeviceBean.sn?:"", scanDeviceBean.vin?:"", scanDeviceBean.vcu?:"")
                    }
                }
            }
        } else if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            mScanResult = intentResult?.contents.toString()
            if (mScanResult.matches(ScanUtils.chinesePattern)) {
                ToastUtils.showShort(mContext.getString(R.string.tip_no_chinese))
                return
            }
//            if (mScanType == 2) {//input sn
//                val deviceSn = ScanUtils.getDeviceSn(mContext,mScanResult)
//                dialogBatteryInput?.updateBatterySn(deviceSn)
//            }
//            if (mScanType == 3) {//vin
//                val vin = ScanUtils.getVehicleVin(mContext,mScanResult)
//                dialogBatteryInput?.updateIMEI(vin)
//            }
//            if (mScanType == 4) {//iccid
//                dialogBatteryInput?.updateICCID(mScanResult)
//            }
            if(mScanType == 2 || mScanType == 3 || mScanType == 4) {
                val qrcodeVehicle = ScanUtils.parseVehicleQr(mContext,mScanResult,mScanType-2)
                dialogBatteryInput?.updateBatterySn(qrcodeVehicle?.sn)
                dialogBatteryInput?.updateIMEI(qrcodeVehicle?.vin)
                dialogBatteryInput?.updateICCID(qrcodeVehicle?.vcu)
            }
        }
    }

}