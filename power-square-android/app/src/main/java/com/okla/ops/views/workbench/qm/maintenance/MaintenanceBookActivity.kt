package com.okla.ops.views.workbench.qm.maintenance

import android.Manifest
import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.net.Uri
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.EditText
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.beans.RxEvent
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.WindowInsetsHelper
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.databinding.ActivityMaintenanceBookBinding
import com.okla.ops.dialog.RoadSidePaymentDialog
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.PromoteWebActivity
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.equipmentsearch.EquipmentSearchActivityNew
import com.okla.ops.weight.SnSearchInfoView
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode


class MaintenanceBookActivity :
    BaseNormalVActivity<MaintenanceBookViewModel, ActivityMaintenanceBookBinding>(),
    View.OnClickListener {

    companion object {
        fun getIntents(context: Context) {
            context.startActivity(Intent(context, MaintenanceBookActivity::class.java))
        }
    }

    private lateinit var permissionManager: PermissionManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            this.activityResultRegistry, this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
    }

    override fun onCreateViewModel(): MaintenanceBookViewModel {
        return ViewModelProvider(this)[MaintenanceBookViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_maintenance_book
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        WindowInsetsHelper.applyForBottom(mBinding.llBottom)
        initObserver()
        initClick()
        initData()
    }

    private fun initClick() {
        mBinding.tvConfirm.setOnClickListener(this)
        mBinding.ivBack.setOnClickListener(this)
        mBinding.vehicleinfoView.setOnSnSearchInfoListener(object :
            SnSearchInfoView.OnSnSearchInfoListener {
            override fun onScanClick() {
                isSnScan = true
                initializeScan(QRCodeActivity.NORMAL)
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                if (inputContent != null && !TextUtils.isEmpty(inputContent)) {
                    getViewModel().queryAppointment(inputContent)
                }
            }

            override fun onEditTextHasFocus() {

            }
        })
        mBinding.vehicleinfoView.setOnClearInputListener {
            resetVehicleInfo()
            resetRemark()
        }
    }

    private fun initData() {
        mBinding.vehicleinfoView.setTitle(getString(R.string.str_vehicle_sn_vin))
        mBinding.vehicleinfoView.setEditTextHint(getString(R.string.maintenance_vehicle_scan_sn_or_qr_tips))
        mBinding.vehicleinfoView.setNoDataTips(getString(R.string.vehicle_info_tips))

    }

    private fun initObserver() {
        getViewModel().mBookMaintenance.observe(this) {
            resetVehicleInfo()
            resetRemark()
            if (it != null) {
                resetRemark()
                deviceSn = it.sn ?: ""
                bookNo = it.reservationNo ?: ""
                userId = it.cardNum ?: ""
                val mMaintenanceVehicleInfoView = MaintenanceVehicleInfoView(this)
                mMaintenanceVehicleInfoView?.updateData(it)
                mMaintenanceVehicleInfoView.setListener(object :
                    MaintenanceVehicleInfoView.OnClickListener {
                    override fun onClickListen(sn: String) {
                        startActivity(
                            EquipmentSearchActivityNew.getIntents(
                                mContext, sn, 2,EquipmentSearchActivityNew.QUERY_DEVICE,false
                            )
                        )
                    }

                    override fun onClickPhoneImg(phone: String) {
                        askPhonePermission(phone)

                    }
                })
                mBinding.vehicleinfoView.updateData(deviceSn ?: "", mMaintenanceVehicleInfoView)
            }
        }
        mBinding.etMaintenanceNotesValue.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }

            override fun afterTextChanged(s: Editable?) {
                canSubmit()
            }

        })

    }

    private fun resetRemark() {
        mBinding.etMaintenanceNotesValue.setText("")
    }

    private fun resetVehicleInfo() {
        bookNo = ""
        deviceSn = ""
        mBinding.vehicleinfoView.removeSnInfo()
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.content -> {
                hideSoftInput()
                mBinding.vehicleinfoView.clearEditTextForces()
            }

            R.id.ivBack -> {
                finish()
            }

            R.id.tvConfirm -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                RoadSidePaymentDialog.Companion.getInstance(
                    userId,
                    deviceSn,
                    remark,
                    RoadSidePaymentDialog.TYPE_MAINTENANCE
                )
                    .show(supportFragmentManager, "maintenance")
            }
        }

    }


    var isSnScan: Boolean = false
    private var bookNo = ""
    private var remark = ""
    private var userId = ""
    private var deviceSn = ""
    private fun initializeScan(type: Int) {
        IntentIntegrator(this)
            .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
            .setOrientationLocked(false)
            .setCaptureActivity(QRCodeActivity::class.java) // 设置自定义的activity是CustomActivity
            .initiateScan() //  初始化扫描
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            var mScanMessage = intentResult?.contents
            mScanMessage?.run {
                if (isSnScan) {
                    isSnScan = false
                    mScanMessage = ScanUtils.getDeviceSn(mContext, mScanMessage ?: "")
                    if (!TextUtils.isEmpty(mScanMessage)) {
                        getViewModel().queryAppointment(mScanMessage ?: "")
                    }
                    mBinding.vehicleinfoView.updateData(mScanMessage)
                }
            }
        } else if (requestCode == PromoteWebActivity.PARSE_REQUEST_CODE) {
            data?.let {
                var parseResult: String = it.getStringExtra("parse_result") ?: ""
                parseResult = ScanUtils.getDeviceSn(mContext, parseResult)
                if (!TextUtils.isEmpty(parseResult)) {
                    getViewModel().queryAppointment(parseResult)
                }
                mBinding.vehicleinfoView.updateData(parseResult)
            }
        }
    }

    fun canSubmit() {
        remark = mBinding.etMaintenanceNotesValue.text.toString()
        mBinding.tvConfirm.isEnabled = !TextUtils.isEmpty(bookNo) && !TextUtils.isEmpty(remark)
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

    private fun askPhonePermission(phoneStr: String) {
        val permissions = mutableListOf(
            Manifest.permission.CALL_PHONE,
        )
        permissionManager.checkPermissions(object : PermissionListenerImpl() {
            override fun passPermission() {
                super.passPermission()
                callPhone(phoneStr)
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(this@MaintenanceBookActivity, "")
            }
        }, *permissions.toTypedArray())
    }

    private fun callPhone(phoneStr: String) {
        mContext?.let {
            val intent = Intent()
            intent.setAction(Intent.ACTION_CALL)
            intent.setData(Uri.parse("tel:".plus(phoneStr)))
            it.startActivity(intent)
        }
    }

    override fun isBindEventBusHere(): Boolean {
        return true
    }

    //支付处理完成
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun paySucess(event: RxEvent.MaintenancePaySucessEvent) {
        finish()
    }
}