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
import com.okla.ops.beans.BatteryNew
import com.okla.ops.beans.BatteryType
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.beans.ScanDeviceBean
import com.okla.ops.databinding.ActivityBatteryEntryBinding
import com.okla.ops.dialog.DialogBatteryInput
import com.okla.ops.utils.ScanUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.QRCodeListActivity
import com.okla.ops.views.workbench.warehouse.devicetransport.DeviceTransportCreateActivity
import com.luck.picture.lib.utils.SdkVersionUtils

class BatteryEntryActivity :
    BaseNormalVActivity<DeviceShipViewModel, ActivityBatteryEntryBinding>() {
    private val snList = ArrayList<String>()
    private var battery: BatteryType? = null

    companion object {
        fun startBatteryEntryActivity(context: Context, batteryType: BatteryType) {
            val intent = Intent(context, BatteryEntryActivity::class.java)
            intent.putExtra("batterType", batteryType)
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
        return R.string.title_battery_entry
    }

    override fun getIntentExtras(intent: Intent?) {
        battery = intent?.getParcelableExtra("batterType")
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
        getViewModel().newBatteryListLiveData.observe(this) {
            val newBatteryCount = getViewModel().getNewBatteryCount();
            mBinding.btnConfirm.isEnabled = newBatteryCount > 0
            if (newBatteryCount > 0) {
                mBinding.layoutScrollview.visibility = View.VISIBLE
                mBinding.layoutEmpty.visibility = View.GONE
            } else {
                mBinding.layoutScrollview.visibility = View.GONE
                mBinding.layoutEmpty.visibility = View.VISIBLE
            }
            mBinding.tvTotal.text =
                getString(R.string.text_battery_total, newBatteryCount)
        }
        var gotoShipMsg = getString(R.string.dialog_go_to_ship)
        getViewModel().registerBatteryLiveData.observe(this) {
            CustomDialog.Builder(this)
                .setTitle(getString(R.string.dialog_submit_completed))
                .setMessage(gotoShipMsg)
                .setNegativeButton(com.base.common.R.string.cc_str_close) { dialog, _ ->
                    dialog.dismiss()
                    ShipSucActivity.startActivity(
                        mContext,
                        "",
                        DeviceTypeObject.TYPE_BATTERY
                    )
                    finish()
                }
                .setPositiveButton(R.string.title_ship) { dialog, _ ->
                    dialog.dismiss()
                    getViewModel().getNewBatteryList().forEach { newBattery ->
                        snList.add(newBattery.sn)
                    }
                    DeviceTransportCreateActivity.getIntents(
                        this,
                        DeviceTypeObject.TYPE_BATTERY,
                        snList
                    )
                    finish()
                }.create().show()
        }
    }

    private fun initClick() {
        mBinding.btnManualEntry.setOnClickListener(this)
        mBinding.btnScanEntry.setOnClickListener(this)
        mBinding.btnConfirm.setOnClickListener(this)
    }

    private fun initData() {
        mBinding.tvBatteryDimension.text = mContext.getString(R.string.text_dimension)
        mBinding.tvBatteryWeight.text = mContext.getString(R.string.text_net_weight)
        battery?.let {
            Glide.with(this).load(it.img).into(mBinding.ivBattery)
            mBinding.tvBatteryModel.text = "${it.model} (${it.modelName})"
            mBinding.tvBatteryDetail.text = it.remark
            mBinding.tvDimension.text = it.dimension ?: "-"
            mBinding.tvWeight.text = it.weight ?: "-"
        }
        mBinding.tvTotal.text =
            getString(R.string.text_battery_total, getViewModel().getNewBatteryCount())

    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.btnManualEntry -> {
                showDialogBatteryInput(0, null, getString(R.string.btn_manual_entry))
            }

            R.id.btnScanEntry -> {
                mScanType = 1
                askPermission()
            }

            R.id.btnConfirm -> {
                val newBatteryCount = getViewModel().getNewBatteryCount();
                if (newBatteryCount <= 0) {
                    ToastUtils.showShort(getString(R.string.tips_battery_not_empty))
                    return
                }
                var batteryStr = getString(R.string.text_batteries)
                val string = getString(
                    R.string.dialog_battery_content,
                    "$newBatteryCount $batteryStr"
                )
                val start = string.indexOf("$newBatteryCount")
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
                        getViewModel().registerBattery(battery?.model ?: "")
                    }.create().show()
            }
        }
    }

    private fun addBatteryItem(index: Int, batterSn: String, imei: String, iccid: String) {
        val result = getViewModel().addNewBattery(BatteryNew(batterSn, imei, iccid))
        if (result) {
            val item = BatteryInfoItem(this)
            item.setData(batterSn, imei, iccid, "",DeviceTypeObject.TYPE_BATTERY)
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
                    getViewModel().removeNewBattery(v.getSn())
                    mBinding.llBattery.removeView(v)
                }

            })
            mBinding.llBattery.addView(item, index)
        }
//        else {
//            ToastUtils.showShort(getString(R.string.tips_battery_exist))
//        }
    }

    private fun updateBatteryItem(index: Int, batterSn: String, imei: String, iccid: String) {
        getViewModel().updateNewBatteryInfo(index, batterSn, imei, iccid)
        for (i in 0 until mBinding.llBattery.childCount) {
            if (index == i) {
                val childView = mBinding.llBattery.getChildAt(i)
                if (childView is BatteryInfoItem) {
                    childView.setData(batterSn, imei, iccid,"",DeviceTypeObject.TYPE_BATTERY)
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
                    val list = getViewModel().newBatteryListLiveData.value ?: mutableListOf()
                    val snList: ArrayList<ScanDeviceBean> = arrayListOf()
                    list.forEach {
                        snList.add(ScanDeviceBean(it.sn, "",""))
                    }
                    startActivityForResult(
                        QRCodeListActivity.getIntents(
                            activity,
                            false,
                            snList,
                            false,true,DeviceTypeObject.TYPE_BATTERY
                        ),
                        QrCodeUtils.REQUEST_CODE_SCAN_SN_LIST
                    );
                } else {
                    IntentIntegrator(this@BatteryEntryActivity)
                        .setOrientationLocked(false)
                        .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                        .setCaptureActivity(QRCodeActivity::class.java)
                        .initiateScan() //  初始化扫描
                }
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(this@BatteryEntryActivity, "")
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
                    DeviceTypeObject.TYPE_BATTERY ?: 0
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
                    addBatteryItem(index, batterSn ?: "", imei ?: "", iccid ?: "")
                } else {
                    updateBatteryItem(index, batterSn ?: "", imei ?: "", iccid ?: "")
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
                        addBatteryItem(index, scanDeviceBean.sn?:"", scanDeviceBean.vin?:"", scanDeviceBean.vcu?:"")
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
//                val deviceSn = ScanUtils.getDeviceSn(mContext, mScanResult)
//                dialogBatteryInput?.updateBatterySn(deviceSn)
//            }
//            if (mScanType == 3) {//imei
//                if (mScanResult != null) {
//                    dialogBatteryInput?.updateIMEI(mScanResult)
//                }
//            }
//            if (mScanType == 4) {//iccid
//                if (mScanResult != null) {
//                    dialogBatteryInput?.updateICCID(mScanResult)
//                }
//            }
            if(mScanType == 2 || mScanType == 3 || mScanType == 4) {
                val qrcodeBattery = ScanUtils.parseBatteryQr(mContext,mScanResult,mScanType-2)
                dialogBatteryInput?.updateBatterySn(qrcodeBattery?.sn)
                dialogBatteryInput?.updateIMEI(qrcodeBattery?.imei)
                dialogBatteryInput?.updateICCID(qrcodeBattery?.iccid)
            }
        }
    }

}