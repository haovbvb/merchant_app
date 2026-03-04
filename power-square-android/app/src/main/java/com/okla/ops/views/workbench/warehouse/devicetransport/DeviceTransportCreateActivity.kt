package com.okla.ops.views.workbench.warehouse.devicetransport

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.InputFilter.LengthFilter
import android.text.TextUtils
import android.text.TextWatcher
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.ToastUtils
import com.base.common.utils.WindowInsetsHelper
import com.bumptech.glide.Glide
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.okla.ops.R
import com.okla.ops.beans.City
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.beans.ScanDeviceBean
import com.okla.ops.beans.WarehouseBean
import com.okla.ops.databinding.ActivityDeviceTransportCreateBinding
import com.okla.ops.dialog.PopContentEdit
import com.okla.ops.dialog.SelectWarehouseReceiveDialog
import com.okla.ops.views.workbench.QRCodeListActivity
import com.okla.ops.views.workbench.entry.ShipSucActivity
import com.luck.picture.lib.utils.SdkVersionUtils
import com.lxj.xpopup.XPopup

class DeviceTransportCreateActivity :
    BaseNormalVActivity<DeviceTransportViewModel, ActivityDeviceTransportCreateBinding>(),
    View.OnClickListener {
    private var permissionManager: PermissionManager? = null
    private var intentSnList: ArrayList<String>? = null

    companion object {

        private const val DEVICE_TYPE: String = "device_type"
        const val TRANSPORT_MAX: Int = Int.MAX_VALUE
        const val CREATE_REQUEST_CODE: Int = 1001
        const val CREATE_RESULT_CODE: Int = 1002

        fun getIntents(context: Activity, deviceType: Int) {
            val intent = Intent()
            intent.putExtra(DEVICE_TYPE, deviceType)
            intent.setClass(context, DeviceTransportCreateActivity::class.java)
            context.startActivityForResult(intent, CREATE_REQUEST_CODE)
        }

        fun getIntents(context: Activity, deviceType: Int, snList: ArrayList<String>) {
            val intent = Intent()
            intent.putExtra(DEVICE_TYPE, deviceType)
            intent.putStringArrayListExtra("snList", snList)
            intent.setClass(context, DeviceTransportCreateActivity::class.java)
            context.startActivityForResult(intent, CREATE_REQUEST_CODE)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            this.activityResultRegistry,
            javaClass.name, this
        )
        permissionManager?.let {
            lifecycle.addObserver(it)
        }
    }


    override fun onCreateViewModel(): DeviceTransportViewModel {
        return ViewModelProvider(this).get(DeviceTransportViewModel::class.java)
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_device_transport_create
    }

    private var mDeviceType: Int = 0
    private var mDeviceTitleType: String = ""
    override fun getIntentExtras(intent: Intent?) {
        super.getIntentExtras(intent)
        mDeviceType = intent?.getIntExtra(DEVICE_TYPE, 0) ?: 0
        intentSnList = intent?.getStringArrayListExtra("snList")
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        WindowInsetsHelper.applyForBottom(mBinding.llBottom)
        if (mDeviceType == 0) {
            finish()
            return
        }
        if (!intentSnList.isNullOrEmpty()) {
            intentSnList?.forEach {
                mSnList.add(it)
                addSnView(it)
            }
        }
        val topTitle = mBinding.includeTitle.topTitle
        if (topTitle != null && title() != 0) {
            when (mDeviceType) {
                DeviceTypeObject.TYPE_BATTERY -> mDeviceTitleType =
                    getString(R.string.transport_battery)

                DeviceTypeObject.TYPE_VEHICLE -> mDeviceTitleType =
                    getString(R.string.transport_vehicle)
                DeviceTypeObject.TYPE_STATION -> mDeviceTitleType =
                    getString(R.string.transport_station)
            }
            topTitle.text = getString(R.string.transport_create_device_issue, mDeviceTitleType)
            topTitle.gravity = Gravity.CENTER
            mBinding.tvSelectTitle.text =
                getString(R.string.transport_select_device, mDeviceTitleType)
        }
        initObserver()
        initClick()
        initData()
    }

    var mTrackNumber = ""
//    private fun initListener() {
//        mBinding.tvPostNumber.addTextChangedListener(object : TextWatcher {
//            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
//
//            }
//
//            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
//
//            }
//
//            override fun afterTextChanged(s: Editable?) {
//                mTrackNumber = s.toString()
//            }
//        })
//    }

    private fun initData() {
        getViewModel().queryMyWarehouseInfo()
        mBinding.tvTotalValue.text = String.format("%d", mSnList.size)
    }

    private fun initObserver() {
        getViewModel().myWarehouseBeanLiveData.observe(this, {
            if (it != null) {
                Glide.with(this).load(it.img).error(R.mipmap.icon_issue_warehouse)
                mBinding.tvSendAddress.text = it.cityName
                myWareHouseNo = it.warehouseNo?:""
                if (it.warehouseType == 1) {
                    mBinding.tvSendname.text =
                        mContext.getString(R.string.text_platform)
                } else {
                    mBinding.tvSendname.text = it.warehouseName
                }
            }
        })
        getViewModel().mCheckDeviceSn.observe(this) {
            mEnterSnBottomSheetDialog?.dismiss()
            it.let {
                if (mSnList.isEmpty() || !mSnList.contains(it)) {
                    mSnList.add(it)
                    addSnView(it)
                }
                canCreate()
            }
        }
        getViewModel().mInWarehouseBeanListLiveData.observe(this) {
            it?.let { it1 ->
                mSelectReceiveWarehouseDialog?.updateList(it1)
            }
        }
        getViewModel().cityListLiveData.observe(this, {
            it?.let {
                mSelectReceiveWarehouseDialog?.setCityList(it)
            }
        })
        getViewModel().mCreateIssueLiveData.observe(this) {
            ToastUtils.showShort(getString(R.string.sucess))
            if (!intentSnList.isNullOrEmpty()) {
                ShipSucActivity.startActivity(mContext, it.toString(), mDeviceType)
                finish()
            } else {
                setResult(CREATE_RESULT_CODE)
                finish()
            }
        }
    }

    private fun addSnView(sn: String) {
        mBinding.tvTotalValue.text = String.format("%d", mSnList.size)
        val deviceTransportSnLayout = DeviceTransportSnLayout(this)
        deviceTransportSnLayout.tvSn = sn
        deviceTransportSnLayout.setOnDeleteListener { snLayout ->
            mBinding.llSn.removeView(snLayout)
            mSnList.remove(snLayout.tvSn)
            mBinding.tvTotalValue.text = String.format("%d", mSnList.size)
            canCreate()
        }
        mBinding.llSn.addView(deviceTransportSnLayout, 0)
    }

    private fun initClick() {
        mBinding.tvSendAddress.setOnClickListener(this)
        mBinding.tvReceiveAddress.setOnClickListener(this)
        mBinding.tvEnterDeviceSn.setOnClickListener(this)
        mBinding.tvScanQRCode.setOnClickListener(this)
        mBinding.tvConfirm.setOnClickListener(this)
        mBinding.tvPostNumber.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.tvReceiveAddress -> {
                initReceiveWareHouseDialog()
                showSelectReceiveWarehouseDialog()
                queryInWarehouseList()
                getViewModel().getCityList()
            }

            R.id.tvEnterDeviceSn -> {
//                if (TextUtils.isEmpty(myWareHouseNo)) {
//                    ToastUtils.showShort(getString(R.string.transport_select_warehouse))
//                    return
//                }
                if (mSnList.size >= TRANSPORT_MAX) {
                    ToastUtils.showShort(getString(R.string.transport_max_device, TRANSPORT_MAX))
                    return
                }
                initEnterDeviceSnBottomSheet()
            }

            R.id.tvPostNumber -> {
                XPopup.Builder(this)
                    .enableDrag(false)
                    .dismissOnTouchOutside(false)
                    .asCustom(
                        PopContentEdit(
                            this, mContext.getString(R.string.text_tracking_number)
                        ) { content ->
                            mTrackNumber = content
                            mBinding.tvPostNumber.text = mTrackNumber
                            canCreate()
                        })
                    .show()

            }

            R.id.tvScanQRCode -> {
//                if (TextUtils.isEmpty(myWareHouseNo)) {
//                    ToastUtils.showShort(getString(R.string.transport_select_warehouse))
//                    return
//                }
                if (mSnList.size >= TRANSPORT_MAX) {
                    ToastUtils.showShort(getString(R.string.transport_max_device, TRANSPORT_MAX))
                    return
                }
                askPermission();
            }

            R.id.tvConfirm -> {
                getViewModel().createIssue(
                    mInWarehouseNo,
                    myWareHouseNo,
                    mDeviceType,
                    mSnList,
                    mTrackNumber
                )
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
        permissionManager?.checkPermissions(object : PermissionListenerImpl() {
            override fun passPermission() {
                super.passPermission()
                val bundle = Bundle();
                bundle.putString("deviceType", mDeviceType.toString());
                bundle.putString("warehouseNo", myWareHouseNo)
                bundle.putInt("snSize", mSnList.size)
                bundle.putInt("snMaxSize", TRANSPORT_MAX);
                startActivityForResult(
                    QRCodeListActivity.getIntents(
                        this@DeviceTransportCreateActivity,
                        mDeviceType,
                        myWareHouseNo,
                        mSnList.size,
                        TRANSPORT_MAX
                    ),
                    QRCodeListActivity.REQUEST_CODE
                )
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(this@DeviceTransportCreateActivity, "")
            }
        }, *permissions.toTypedArray())
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == QRCodeListActivity.REQUEST_CODE && resultCode == QRCodeListActivity.RESULT_CODE) {
            val listExtra =
                data?.getParcelableArrayListExtra<ScanDeviceBean>(QRCodeListActivity.SN_LIST)
            if (!listExtra.isNullOrEmpty()) {
                for (scanBean in listExtra) {
                    val sn = scanBean.sn
                    if (!mSnList.contains(sn)) {
                        mSnList.add(sn?:"")
                        addSnView(sn?:"")
                    }
                }
                canCreate()
            }
        }
    }

    private var mSnList: MutableList<String> = mutableListOf()

    /**
     * 初始化修改SN输入框
     */
    private var mEnterSnBottomSheetDialog: BottomSheetDialog? = null
    private var mEnterSn = ""
    private fun initEnterDeviceSnBottomSheet() {
        if (mEnterSnBottomSheetDialog == null) {
            mEnterSnBottomSheetDialog = BottomSheetDialog(this)
            val view =
                LayoutInflater.from(this).inflate(R.layout.dialog_edit_text, null, false)
            view.findViewById<TextView>(R.id.tvTitle).setText(R.string.user_device_sn)
            val editText = view.findViewById<EditText>(R.id.etInput)
            editText.setHint(R.string.transport_enter_device_sn)
            editText.filters = arrayOf(LengthFilter(64))
            val mIvClear = view.findViewById<ImageView>(R.id.ivClear)
            mIvClear.setOnClickListener {
                editText.setText("")
            }
            val btnConfirm = view.findViewById<TextView>(R.id.btnConfirm)
            val btnCancel = view.findViewById<TextView>(R.id.btnClose)
            editText.addTextChangedListener(object : TextWatcher {
                override fun beforeTextChanged(
                    s: CharSequence?,
                    start: Int,
                    count: Int,
                    after: Int
                ) {
                }

                override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
                    if (TextUtils.isEmpty(s.toString())) {
                        mIvClear.visibility = View.GONE
                    } else {
                        mIvClear.visibility = View.VISIBLE
                    }
                }

                override fun afterTextChanged(s: Editable) {
                    mEnterSn = s.toString()
                }
            })
            btnConfirm.setOnClickListener(View.OnClickListener {
                if (TextUtils.isEmpty(mEnterSn)) {
                    ToastUtils.showShort(getString(R.string.transport_enter_sn))
                    return@OnClickListener
                }
                getViewModel().checkDeviceSn(mDeviceType, mEnterSn, myWareHouseNo)//创建出库
                editText.setText("")
                hideSoftInput()
            })
            btnCancel.setOnClickListener {
                mEnterSnBottomSheetDialog?.dismiss()
                hideSoftInput()
            }
            mEnterSnBottomSheetDialog?.setContentView(view)
        }
        if (mEnterSnBottomSheetDialog?.window != null) mEnterSnBottomSheetDialog?.window?.setSoftInputMode(
            WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
        )
        mEnterSnBottomSheetDialog?.show()
    }

    override fun title(): Int {
        return R.string.title_create_entry
    }

    /**
     * 选择出仓
     */
    private var myWareHouseNo = ""
//    private var mSelectIssueWarehouseDialog: SelectWarehouseDialog? = null
//    private fun showSelectIssueWarehouseDialog(list: List<WarehouseBean>) {
//        if (mSelectIssueWarehouseDialog == null) {
//            mSelectIssueWarehouseDialog =
//                SelectWarehouseDialog(
//                    this,
//                    list,
//                    getString(
//                        R.string.transport_choose_warehouse,
//                        getString(R.string.transport_issue_warehouse)
//                    )
//                )
//            mSelectIssueWarehouseDialog?.setOnClickListener {
//                it?.let {
//                    mBinding.tvSendAddress.text = it.outWarehouseName
//                    myWareHouseNo = it.outWarehouseNo
//                    mInWarehouseNo = ""
//                    mBinding.tvReceiveAddress.text = ""
//                    canCreate()
//                }
//            }
//        } else {
//            mSelectIssueWarehouseDialog?.updateList(list)
//        }
//        mSelectIssueWarehouseDialog?.show()
//    }

    private fun queryInWarehouseList() {
        getViewModel().queryInWarehouseList(mKeyWord, mCityCode)
    }

    /**
     * 选择接收仓
     */
    private var mInWarehouseNo = ""
    private var mCityCode = ""
    private var mKeyWord = ""
    private var mSelectReceiveWarehouseDialog: SelectWarehouseReceiveDialog? = null
    private fun initReceiveWareHouseDialog() {
        if (mSelectReceiveWarehouseDialog == null) {
            mSelectReceiveWarehouseDialog =
                SelectWarehouseReceiveDialog(
                    this,
                    emptyList(),
                    getString(
                        R.string.transport_choose_warehouse,
                        getString(R.string.str_choose_warehouse)
                    )
                )
            mSelectReceiveWarehouseDialog?.setOnClickListener(object :
                SelectWarehouseReceiveDialog.OnClickListener {
                override fun onItemClick(warehouseBean: WarehouseBean) {
                    // 处理 item 点击
                    warehouseBean?.let {
                        mBinding.tvReceiveAddress.text = it.inWarehouseName
                        mInWarehouseNo = it.inWarehouseNo
                        canCreate()
                    }
                }

                override fun onSelectCity(city: City) {
                    // 处理城市选择
                    if (city == null) {
                        mCityCode = ""
                        queryInWarehouseList()
                    } else {
                        mCityCode = city.code ?: ""
                        queryInWarehouseList()
                    }
                }

                override fun onKeyWordChange(content: String?) {
                    mKeyWord = content ?: ""
                    queryInWarehouseList()
                }
            })

        }
    }

    private fun showSelectReceiveWarehouseDialog() {
        if (mSelectReceiveWarehouseDialog != null) {
            if (mSelectReceiveWarehouseDialog?.isShowing != true) {
                mSelectReceiveWarehouseDialog?.show()
            }
        }
    }

    private fun canCreate() {
        val canCreate =
            !TextUtils.isEmpty(mInWarehouseNo) && mSnList.isNotEmpty()
        if (canCreate) {
            mBinding.tvConfirm.isEnabled = true
        } else {
            mBinding.tvConfirm.isEnabled = false
        }
    }

}