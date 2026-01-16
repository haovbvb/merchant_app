package com.okla.ops.views.workbench.qm.repairrecord

import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.os.Build
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.beans.DeviceFixProject
import com.okla.ops.beans.DeviceFixResult
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.databinding.ActivityRepairRecordBinding
import com.okla.ops.dialog.SelectFixProjectDialog
import com.okla.ops.dialog.SelectFixResultDialog
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.PromoteWebActivity
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.weight.SnSearchInfoView

class RepairRecordActivity :
    BaseNormalVActivity<RepairRecordViewModel, ActivityRepairRecordBinding>(),
    View.OnClickListener {

    companion object {
        fun getIntents(context: Context, isFromStation: Boolean) {
            val intent = Intent(context, RepairRecordActivity::class.java)
            intent.putExtra("isFromStation", isFromStation)
            context.startActivity(intent)
        }
    }

    private var isFromStation = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
    }

    override fun onCreateViewModel(): RepairRecordViewModel {
        return ViewModelProvider(this)[RepairRecordViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_repair_record
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        isFromStation = intent?.getBooleanExtra("isFromStation", false) ?: false
        initObserver()
        initClick()
        initData()
    }

    private fun initData() {
        if (isFromStation) {
            mBinding.deviceInfoView.setTitle(getString(R.string.repair_station_sn))
            mBinding.deviceInfoView.setEditTextHint(getString(R.string.hint_enter_station_sn_or_scan_qr_code))
        } else {
            mBinding.deviceInfoView.setTitle(getString(R.string.repair_device_sn))
            mBinding.deviceInfoView.setEditTextHint(getString(R.string.hint_enter_device_sn_or_scan_qr_code))
        }
        mBinding.deviceInfoView.setNoDataTips(getString(R.string.repair_device_no_data_tips))
        mBinding.deviceInfoView.setEditTextAction(EditorInfo.IME_ACTION_DONE)
        mBinding.etRepairRemarkValue.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

            override fun afterTextChanged(s: Editable?) {
                enableBtnConfirm()
            }

        })
    }

    fun initObserver() {
        getViewModel().mGetFixDeviceInfo.observe(this) {
            resetDeviceInfo()
            resetProjectValue()
            resetProjectResult()
            resetReMark()
            if (it != null) {
                deviceType = it?.deviceType ?: -1
                if (deviceType == 1) {
                    //电池
                    deviceSn = it.batteryVo?.sn ?: ""
                    if (!TextUtils.isEmpty(deviceSn)) {
                        mBinding.deviceInfoView.updateData(
                            it.batteryVo?.sn ?: "",
                            RepairDeviceInfoView(this).updateData(it.batteryVo)
                        )
                    }
                } else if (deviceType == 2) {
                    //车
                    deviceSn = it.carVo?.sn ?: ""
                    if (!TextUtils.isEmpty(deviceSn)) {
                        mBinding.deviceInfoView.updateData(
                            it.carVo?.sn ?: "",
                            RepairDeviceInfoView(this).updateData(it.carVo)
                        )
                    }

                } else if (deviceType == 3) {
                    deviceSn = it.stationVo?.sn ?: ""
                    if (!TextUtils.isEmpty(deviceSn)) {
                        mBinding.deviceInfoView.updateData(
                            it.stationVo?.sn ?: "",
                            RepairStationInfoView(this).updateData(it.stationVo)
                        )
                    }
                }
                if (!it.itemList.isNullOrEmpty()) {
                    itemList = it.itemList as MutableList<DeviceFixProject>?
                }
                if (!it.resultList.isNullOrEmpty()) {
                    resultList = it.resultList as MutableList<DeviceFixResult>?
                }
            }
        }
        getViewModel().mAddFixDeviceResult.observe(this) {
            getViewModel().mGetFixDeviceInfo.value = null
            ToastUtils.showShort(getString(R.string.cc_str_success))
            mBinding.deviceInfoView.updateData("")
            resetReMark()
        }
        getViewModel().mGetDeviceSn.observe(this) {
            if (!TextUtils.isEmpty(it)) {
                if (!it.contains("sn=") && it.contains("http")) {
                    startActivityForResult(
                        PromoteWebActivity.getIntents(this, it, true),
                        PromoteWebActivity.PARSE_REQUEST_CODE
                    )
                } else {
                    getViewModel().getDeviceListSearchData(it ?: "")
                }
            }
        }
        getViewModel().mEquipmentDeviceSearchBeanData.observe(this) {
            if (it != null) {
                getViewModel().getFixDeviceInfo(it.deviceInfo.sn)
            }
        }
        mBinding.etRepairRemarkValue.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

            override fun afterTextChanged(s: Editable?) {
                enableBtnConfirm()
            }
        })
    }

    private fun initClick() {
        mBinding.content.setOnClickListener(this)
        mBinding.ivBack.setOnClickListener(this)
        mBinding.tvConfirm.setOnClickListener(this)
        mBinding.tvRepairProjectValue.setOnClickListener(this)
        mBinding.tvRepairResultValue.setOnClickListener(this)
        mBinding.deviceInfoView.setOnSnSearchInfoListener(object :
            SnSearchInfoView.OnSnSearchInfoListener {
            override fun onScanClick() {
                isSnScan = true
                initializeScan(QRCodeActivity.NORMAL)
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                if (inputContent != null && !TextUtils.isEmpty(inputContent)) {
                    getViewModel().getFixDeviceInfo(inputContent)
                    mBinding.deviceInfoView.updateData(inputContent)
                }
            }

            override fun onEditTextHasFocus() {

            }

        })
        mBinding.deviceInfoView.setOnClearInputListener {
            deviceSn = ""
            deviceType = -1
            mBinding.deviceInfoView.removeSnInfo()
            resetProjectValue()
            resetProjectResult()
        }
        mBinding.deviceInfoView.setOnEditTextActionListener {
            mBinding.deviceInfoView.clearEditTextForces()
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            mBinding.nsc.setOnScrollChangeListener { _, _, _, _, _ ->
                hideSoftInput()
                mBinding.deviceInfoView.clearEditTextForces()
            }
        }
    }

    private var deviceSn: String = ""
    private var cardNum = ""
    private var deviceType: Int = -1
    private var fixItemCode = ""
    private var result = ""
    private var remark = ""
    private var resultList: MutableList<DeviceFixResult>? = null
    private var itemList: MutableList<DeviceFixProject>? = null
    override fun onClick(v: View) {
        when (v.id) {
            R.id.content -> {
                hideSoftInput()
                mBinding.deviceInfoView.clearEditTextForces()
            }

            R.id.ivBack -> {
                finish()
            }

            R.id.tvConfirm -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                val deviceSn = mBinding.deviceInfoView.sn
                getViewModel().addFixDeviceRecord(
                    cardNum,
                    deviceSn,
                    deviceType,
                    fixItemCode,
                    remark,
                    result
                )
            }

            R.id.tvRepairProjectValue -> {
                if (!itemList.isNullOrEmpty()) {
                    itemList?.let { showSelectDeviceFixProjectDialog(it) }
                } else {
                    ToastUtils.showShort(mContext.getString(R.string.tips_no_data))
                }
            }

            R.id.tvRepairResultValue -> {
                if (resultList.isNullOrEmpty()) {
                    ToastUtils.showShort(mContext.getString(R.string.tips_no_data))
                    return
                } else {
                    showSelectDeviceFixResultDialog(resultList!!)
                }
            }
        }
    }

    var isSnScan: Boolean = false
    private fun initializeScan(type: Int) {
        IntentIntegrator(this)
            .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
            .setOrientationLocked(false)
            .setCaptureActivity(QRCodeActivity::class.java) // 设置自定义的activity是CustomActivity
            .initiateScan() //  初始化扫描
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            IntentIntegrator.REQUEST_CODE -> {
                val intentResult =
                    IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
                var mScanMessage = intentResult?.contents
                mScanMessage?.run {
                    if (isSnScan) {
                        isSnScan = false
                        var sn = ""
//                        if (isFromStation) {
//                            //只能扫码电柜
//                            if (mScanMessage.contains("sn=") && mScanMessage.contains("tenantId=")) {
//                                sn = ScanUtils.parseStationQr(mContext, this)?.sn!!
//                            } else {
//                                ToastUtils.showShort(getString(R.string.invalid_station_qr_code))
//                                return
//                            }
//                        } else {
                            sn = ScanUtils.getDeviceSn(mContext, this)
//                        }
                        getViewModel().getFixDeviceInfo(sn ?: "")
                        mBinding.deviceInfoView.updateData(sn)
                    }
                }
            }

            PromoteWebActivity.PARSE_REQUEST_CODE -> {
                data?.let {
                    var parseResult: String = it.getStringExtra("parse_result") ?: ""
                    var sn = ""
                    if (deviceType == DeviceTypeObject.TYPE_STATION) {
                        sn = ScanUtils.parseStationQr(mContext, parseResult)?.sn!!
                    } else {
                        sn = ScanUtils.getDeviceSn(mContext, parseResult)
                    }
                    getViewModel().getFixDeviceInfo(sn)
                }
            }

//            else -> {
//                selectImageFactory?.onActivityResult(requestCode, resultCode, data, null, this)
//            }
        }
    }

    private var mSelectDeviceFixProjectDialog: SelectFixProjectDialog? = null
    private fun showSelectDeviceFixProjectDialog(list: List<DeviceFixProject?>) {
        if (mSelectDeviceFixProjectDialog == null) {
            mSelectDeviceFixProjectDialog =
                SelectFixProjectDialog(this, getString(R.string.str_select_repair_project))
            mSelectDeviceFixProjectDialog?.setOnClickListener {
                it?.let {
                    mBinding.tvRepairProjectValue.text = it.itemName
                    fixItemCode = it.itemNo
                    enableBtnConfirm()
                }
            }
        }
        mSelectDeviceFixProjectDialog?.setCanceledOnTouchOutside(false)
        mSelectDeviceFixProjectDialog?.updateData(list)
        mSelectDeviceFixProjectDialog?.show()
    }

    private var mSelectDeviceFixResultDialog: SelectFixResultDialog? = null
    private fun showSelectDeviceFixResultDialog(list: MutableList<DeviceFixResult>) {
        if (mSelectDeviceFixResultDialog == null) {
            mSelectDeviceFixResultDialog =
                SelectFixResultDialog(this, list, getString(R.string.repair_device_result))
            mSelectDeviceFixResultDialog?.setOnClickListener {
                it?.let {
                    mBinding.tvRepairResultValue.text = it.result
                    result = it.code ?: ""
                    enableBtnConfirm()
                }
            }
        }
        mSelectDeviceFixResultDialog?.updateData(list)
        mSelectDeviceFixResultDialog?.setCanceledOnTouchOutside(false)
        mSelectDeviceFixResultDialog?.show()
    }

    private fun enableBtnConfirm() {
        remark = mBinding.etRepairRemarkValue.text.toString()
        mBinding.tvConfirm.isEnabled =
            fixItemCode.trim().isNotBlank() && !TextUtils.isEmpty(deviceSn) && !TextUtils.isEmpty(
                remark
            ) && !TextUtils.isEmpty(result)
    }


    private fun resetDeviceInfo() {
        deviceSn = ""
        deviceType = -1
        mBinding.deviceInfoView.removeSnInfo()
        mBinding.tvConfirm.isEnabled = false
    }

    private fun resetProjectValue() {
        fixItemCode = ""
        itemList?.clear()
        mBinding.tvRepairProjectValue.text = ""
        mBinding.tvConfirm.isEnabled = false

    }

    private fun resetProjectResult() {
        result = ""
        resultList?.clear()
        mBinding.tvRepairResultValue.text = ""
        mBinding.tvConfirm.isEnabled = false

    }

    private fun resetReMark() {
        mBinding.etRepairRemarkValue.setText("")
        mBinding.tvConfirm.isEnabled = false

    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        if (ev.action == MotionEvent.ACTION_DOWN) {
            val view = currentFocus
            if (view is EditText) {
                val outRect = Rect()
                view.getGlobalVisibleRect(outRect)
                if (!outRect.contains(ev.rawX.toInt(), ev.rawY.toInt())) {
                    view.clearFocus()
                    hideSoftInput()
                }
            }
        }
        return super.dispatchTouchEvent(ev)
    }
}