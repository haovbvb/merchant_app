package com.okla.ops.views.workbench.qm.aftersalebind

import android.Manifest
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.TextView
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.beans.AfterSaleCanBindOrderBean
import com.okla.ops.databinding.FragmentAftersaleBindBinding
import com.okla.ops.dialog.DialogSelectAfterSaleBindOrder
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.sales.BindDeviceInfoView
import com.okla.ops.weight.SnSearchInfoView
import com.luck.picture.lib.utils.SdkVersionUtils
import com.lxj.xpopup.XPopup

class AfterSaleBindFragment :
    BaseNormalVFragment<AfterSaleBindViewModel, FragmentAftersaleBindBinding>() {
    //    private lateinit var mSingleDataBindingNoPUseAdapter: SingleDataBindingNoPUseAdapter<CanBindOrderBean>
    private var userId = ""
    private var mScanType = 1
    private var deviceSn = ""
    private var orderId = ""
    private var modelStr = ""
    private var deviceType = -1
    override fun getLayoutId(): Int {
        return R.layout.fragment_aftersale_bind
    }

    override fun onCreateViewModel(): AfterSaleBindViewModel {
        return ViewModelProvider(this).get(AfterSaleBindViewModel::class.java);
    }

    private lateinit var permissionManager: PermissionManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this.mActivity)
        StatusBarUtil.StatusBarLightMode(this.mActivity)
        permissionManager = PermissionManager.getInstance(
            requireActivity().activityResultRegistry, this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        initObserver()
    }

    private fun controlBtnConfirmEnable() {
        if (!TextUtils.isEmpty(userId) && !TextUtils.isEmpty(orderId) && !TextUtils.isEmpty(deviceSn)) {
            mBinding.btnConfirm.isEnabled = true
        } else {
            mBinding.btnConfirm.isEnabled = false
        }
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        mBinding.vehicleinfoView.setTitle(context?.getString(R.string.text_device_sn))
        mBinding.vehicleinfoView.setNoDataTips(context?.getString(R.string.text_no_device_param))
        mBinding.vehicleinfoView.setEditTextHint(context?.getString(R.string.hint_enter_device_sn_or_scan_qr_code))
        initListener()
        initData()
        initClick()
    }

    private fun initClick() {
        mBinding.imgSelectOrder.setOnClickListener(this)
        mBinding.tvReselect.setOnClickListener(this)
        mBinding.ivBack.setOnClickListener(this)
        mBinding.btnConfirm.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.img_select_order, R.id.tvReselect -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                if (!orderList.isNullOrEmpty()) {
                    //dialog
                    XPopup.Builder(context)
                        .enableDrag(false)
                        .dismissOnTouchOutside(false)
                        .asCustom(
                            context?.let { it1 ->
                                DialogSelectAfterSaleBindOrder(
                                    it1,
                                    orderList,
                                    object : DialogSelectAfterSaleBindOrder.SelectCallBack {
                                        override fun onSelected(order: AfterSaleCanBindOrderBean) {
                                            if (order != null) {
                                                mBinding.tvReselect.visibility = View.VISIBLE
                                                mBinding.layoutSelectedOrder.visibility =
                                                    View.VISIBLE
                                                mBinding.tvEmptyOrder.visibility = View.GONE
                                                mBinding.imgSelectOrder.visibility = View.GONE
                                                orderId = order.orderNo ?: ""
                                                deviceType = order.deviceType ?: -1
                                                if (order.deviceType == 1) {
                                                    modelStr = order.batteryType ?: ""
                                                } else {
                                                    //车
                                                    modelStr = order.carType ?: ""
                                                }
                                                val tvOrderNo =
                                                    mBinding.layoutSelectedOrder.findViewById<TextView>(
                                                        R.id.tv_order_no
                                                    )
                                                val tvStatus =
                                                    mBinding.layoutSelectedOrder.findViewById<TextView>(
                                                        R.id.tv_orderstatus
                                                    )
                                                val tvDevice =
                                                    mBinding.layoutSelectedOrder.findViewById<TextView>(
                                                        R.id.tv_device
                                                    )
                                                tvOrderNo.text = orderId
                                                if (order.deviceType == 1) {
                                                    //电池
                                                    tvDevice.text =
                                                        context?.getString(R.string.text_battery)
                                                            .plus(" | ")
                                                            .plus(order.batteryType)
                                                } else {
                                                    //车
                                                    tvDevice.text =
                                                        context?.getString(R.string.text_vehicle)
                                                            .plus(" | ").plus(order.carType)
                                                }
                                                var str1 = "-"
                                                if (order.type == 1) {
                                                    //销售
                                                    str1 = context?.getString(R.string.sale) ?: "-"
                                                } else if (order.type == 2) {
                                                    //租赁
                                                    str1 = context?.getString(R.string.lease) ?: "-"
                                                } else {
                                                    str1 = "-"
                                                }
                                                var str2 = "-"
                                                //status: 1=已支付 2=分期中 3=租赁中
                                                if (order.status == 1) {
                                                    str2 = context?.getString(R.string.paid) ?: "-"
                                                } else if (order.status == 2) {
                                                    str2 = context?.getString(R.string.in_progress)
                                                        ?: "-"
                                                } else if (order.status == 3) {
                                                    str2 = context?.getString(R.string.lease) ?: "-"
                                                } else {
                                                    str2 = "-"
                                                }
                                                tvStatus.text = str1.plus(" | ").plus(str2)
                                                //已经有设备信息了，需要重置
                                                mBinding.vehicleinfoView.updateData("")
                                                resetDeviceInfo()
                                            } else {
                                                resetOrderInfo()
                                            }

                                        }
                                    })
                            }
                        )
                        .show()
                } else {
                    ToastUtils.showShort(context?.getString(R.string.tip_there_no_order))
                }
            }

            R.id.ivBack -> {
                activity?.finish()
            }

            R.id.btnConfirm -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                getViewModel().afterSellBind(userId, deviceSn, deviceType, orderId);
            }
        }
    }

    private var orderList = ArrayList<AfterSaleCanBindOrderBean>()
    private fun initObserver() {
        getViewModel().userDetailLiveData.observe(this, {
            resetUserInfo()
            resetOrderInfo()
            resetDeviceInfo()
            if (it != null) {
                userId = it.cardNum ?: ""
                val userInfoView = context?.let { it1 -> AfterSaleUserInfoView(it1) }
                userInfoView?.updateData(it)
                mBinding.userinfoView.updateData(userId, userInfoView)
                getViewModel().queryOderCanBind(userId)
                mBinding.vehicleinfoView.updateData("")
            }
        })
        getViewModel().ordersLiveData.observe(this, {
            resetOrderInfo()
            if (!it.isNullOrEmpty()) {
                orderList = it as ArrayList<AfterSaleCanBindOrderBean>
            }
        })
        getViewModel().deviceDetailLiveData.observe(this, {
            resetDeviceInfo()
            if (it != null) {
                deviceType = it.deviceType
                val bindDeviceInfoView = context?.let { it1 -> BindDeviceInfoView(it1) }
                if (it.deviceType == 1) {
                    bindDeviceInfoView?.updateData(it.batteryVo)
                    deviceSn = it.batteryVo.sn ?: ""
                } else if (it.deviceType == 2) {
                    bindDeviceInfoView?.updateData(it.carVo)
                    deviceSn = it.carVo.sn ?: ""
                }
                mBinding.vehicleinfoView.updateData(deviceSn, bindDeviceInfoView)
                controlBtnConfirmEnable()
            }
        })
        getViewModel().afterSellBindLiveData.observe(this, {
            if (!it.isNullOrBlank()) {
                findNavController().navigate(
                    AfterSaleBindFragmentDirections.afterBindFragmentToAfterBindSucFragmnet(
                    )
                )
                getViewModel().afterSellBindLiveData.value = null
            }
        })
    }

    private var lastFocusedSnSearchView: SnSearchInfoView? = null

    private fun initListener() {
        mBinding.userinfoView.setOnSnSearchInfoListener(object :
            SnSearchInfoView.OnSnSearchInfoListener {
            override fun onScanClick() {
                mScanType = 1
                askPermission()
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                if (mBinding.userinfoView == lastFocusedSnSearchView) {
                    if (inputContent != null && !TextUtils.isEmpty(inputContent)) {
                        getViewModel().getUserDetail(inputContent)
                        mBinding.userinfoView.updateData(inputContent)
                    } else {
                        mBinding.userinfoView.removeSnInfo()
                        userId = ""
                    }
                }
            }

            override fun onEditTextHasFocus() {
                // 记录：这个才是“当前焦点”给后续失去焦点用
                lastFocusedSnSearchView = mBinding.userinfoView
            }

        })
        mBinding.userinfoView.setOnEditTextActionListener {
            mBinding.userinfoView.clearEditTextForces()
        }
        mBinding.vehicleinfoView.setOnSnSearchInfoListener(object :
            SnSearchInfoView.OnSnSearchInfoListener {
            override fun onScanClick() {
                mScanType = 2
                askPermission()
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                // 只有它自己被清焦，且它 == lastFocused，才触发搜索
                if (mBinding.vehicleinfoView == lastFocusedSnSearchView) {
                    if (inputContent != null && !TextUtils.isEmpty(inputContent)) {
                        getViewModel().getAfterSaleBindDeviceInfo(
                            inputContent,
                            modelStr,
                            deviceType
                        )
                    } else {
                        mBinding.vehicleinfoView.removeSnInfo()
                        deviceSn = ""
                    }
                }
            }

            override fun onEditTextHasFocus() {
                // 记录：这个才是“当前焦点”给后续失去焦点用
                lastFocusedSnSearchView = mBinding.vehicleinfoView
            }

        })

        mBinding.userinfoView.setOnClearInputListener {
            mBinding.userinfoView.removeSnInfo()
            mBinding.btnConfirm.isEnabled = false
            resetOrderInfo()
            resetDeviceInfo()
        }
        mBinding.vehicleinfoView.setOnClearInputListener {
            mBinding.vehicleinfoView.removeSnInfo()
            mBinding.btnConfirm.isEnabled = false
        }
    }

    private fun resetUserInfo() {
        userId = ""
        mBinding.userinfoView.removeSnInfo()
        mBinding.btnConfirm.isEnabled = false
        mBinding.vehicleinfoView.updateData("")
    }

    private fun resetOrderInfo() {
        orderId = ""
        orderList.clear()
        modelStr = ""
        mBinding.tvReselect.visibility = View.GONE
        mBinding.layoutSelectedOrder.visibility = View.GONE
        mBinding.tvEmptyOrder.visibility = View.VISIBLE
        mBinding.imgSelectOrder.visibility = View.VISIBLE
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetDeviceInfo() {
        deviceSn = ""
        mBinding.vehicleinfoView.updateData("")
    }

    private fun initData() {
        mBinding.userinfoView.setTitle(getString(R.string.text_user_id))
        mBinding.userinfoView.setEditTextHint(getString(R.string.hint_enter_userid_or_scan_qr_code))
        mBinding.userinfoView.setNoDataTips(getString(R.string.text_no_userinfo_param))

        mBinding.vehicleinfoView.setTitle(getString(R.string.text_device_sn))
        mBinding.vehicleinfoView.setEditTextHint(getString(R.string.hint_enter_device_or_scan_qr_code))
        mBinding.vehicleinfoView.setNoDataTips(getString(R.string.text_no_device_param))

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
                IntentIntegrator.forSupportFragment(this@AfterSaleBindFragment)
                    .setOrientationLocked(false)
                    .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                    .setCaptureActivity(QRCodeActivity::class.java)
                    .initiateScan() //  初始化扫描
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(mActivity, "")
            }
        }, *permissions.toTypedArray())
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (data == null) {
            return
        }
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            val mScanResult = intentResult?.contents.toString()
            if (mScanType == 1) {
                //用户信息
                val userId = context?.let { ScanUtils.getUserCarNum(it, mScanResult) }!!
                mBinding.userinfoView.updateData(userId)
                if (!TextUtils.isEmpty(userId)) {
                    getViewModel().getUserDetail(userId)
                }
            } else if (mScanType == 2) {
                //设备信息
                var deviceSn = ""
                deviceSn = context?.let { ScanUtils.getDeviceSn(it, mScanResult) }!!
                mBinding.vehicleinfoView.updateData(deviceSn)
                if (!TextUtils.isEmpty(deviceSn)) {
                    getViewModel().getAfterSaleBindDeviceInfo(deviceSn, modelStr, deviceType);

                }
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        findNavController().currentBackStackEntry
            ?.savedStateHandle
            ?.getLiveData<Boolean>("fromAfterSaleBindSuccessFragment")
            ?.observe(viewLifecycleOwner) {
                mBinding.userinfoView.updateData("")
                mBinding.vehicleinfoView.updateData("")
                resetUserInfo()
                resetOrderInfo()
                resetDeviceInfo()
                findNavController().currentBackStackEntry
                    ?.savedStateHandle
                    ?.remove<Boolean>("fromAfterSaleBindSuccessFragment")
            }

    }
}