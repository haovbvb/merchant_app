package com.okla.ops.views.workbench.sales.rentbind

import android.Manifest
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.base.common.utils.WindowInsetsHelper
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.beans.ShopPaymentMethod
import com.okla.ops.databinding.FragmentRentbindBinding
import com.okla.ops.dialog.DialogSelectRentBindPackage
import com.okla.ops.dialog.PaymentMethodDialogFragment
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.sales.BindDeviceInfoView
import com.okla.ops.weight.SnSearchInfoView
import com.luck.picture.lib.utils.SdkVersionUtils
import com.lxj.xpopup.XPopup

class RentBindFragment :
    BaseNormalVFragment<RentBindViewModel, FragmentRentbindBinding>() {
    private var rentPrice: Double = 0.0
    private var depositPrice: Double = 0.0
    private var amount = 0.0
    private var infoCode: String = ""
    private lateinit var mSingleDataBindingNoPUseAdapter: SingleDataBindingNoPUseAdapter<Pack>
    private var deviceSn = ""
    private var deviceType = -1
    private var packList = ArrayList<Pack>()
    override fun getLayoutId(): Int {
        return R.layout.fragment_rentbind
    }

    override fun onCreateViewModel(): RentBindViewModel {
        return ViewModelProvider(this).get(RentBindViewModel::class.java);
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
        getViewModel().getShopPaymentMethod(DataStoreUtils.readStringData(DataStoreKeyUtils.SHOP_NO))
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        WindowInsetsHelper.applyForBottom(mBinding.clbottom)
        initListener()
        initData()
        mBinding.packageinfoview.visibility = View.GONE
        mBinding.line1.visibility = View.GONE
        mBinding.tvReselect.visibility = View.GONE
        mBinding.imgSelectPackage.visibility = View.VISIBLE
        initClick()
    }

    private fun initClick() {
        mBinding.ivBack.setOnClickListener(this)
        mBinding.btnConfirm.setOnClickListener(this)
        mBinding.tvNoInfo.setOnClickListener(this)
        mBinding.tvReselect.setOnClickListener(this)
        mBinding.imgSelectPackage.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.ivBack -> {
                activity?.finish()
            }

            R.id.tv_reselect, R.id.img_select_package -> {
                if (packList.isNullOrEmpty()) {
                    ToastUtils.showShort(context?.getString(R.string.tip_no_package_available))
                    return
                }
                val screenHeight = resources.displayMetrics.heightPixels
                val maxHeight = (screenHeight * 0.7).toInt() // 高度限制为屏幕的70%
                XPopup.Builder(context)
                    .enableDrag(false)
                    .maxHeight(maxHeight)
                    .dismissOnTouchOutside(false)
                    .asCustom(
                        context?.let {
                            DialogSelectRentBindPackage(
                                it,
                                packList, object : DialogSelectRentBindPackage.SelectCallBack {
                                    override fun onSelectedRentPack(pack: Pack) {
                                        if (pack != null) {
                                            mBinding.tvNoInfo.visibility = View.GONE
                                            mBinding.packageinfoview.visibility = View.VISIBLE
                                            mBinding.line1.visibility = View.VISIBLE
                                            mBinding.tvReselect.visibility = View.VISIBLE
                                            mBinding.packageinfoview.updateRentData(pack)
                                            infoCode = pack.infoCode ?: ""
                                            rentPrice =
                                                pack.packageAmount ?: (0.0 - (pack.depositAmount
                                                    ?: 0.0))
                                            depositPrice = pack.depositAmount ?: 0.0
                                            amount = pack.packageAmount ?: 0.0
                                            controlBtnConfirmEnable()
                                        }
                                    }
                                }
                            )
                        }).show()
            }

            R.id.btnConfirm -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                PaymentMethodDialogFragment.getInstance(
                    infoCode,
                    deviceSn,
                    deviceType,
                    rentPrice,
                    depositPrice,
                    amount,
                    PaymentMethodDialogFragment.TYPE_RENT,shopPaymentMethod
                )
                    .show(childFragmentManager, "rent_payment_dialog")
            }
        }
    }

    private var shopPaymentMethod: ShopPaymentMethod? = null

    private fun initObserver() {
        getViewModel().shopPaymentMethodLiveData.observe(this, {
            shopPaymentMethod = it
        })
        getViewModel().deviceInfoLiveData.observe(this, {
            resetDeviceInfo()
            //租赁只能选一个设备
            if (it != null) {
                val bindDeviceInfoView = context?.let { it1 -> BindDeviceInfoView(it1) }
                //车
                if (it.carVo != null) {
                    deviceSn = it.carVo.sn ?: ""
                    deviceType = DeviceTypeObject.TYPE_VEHICLE
                    bindDeviceInfoView?.updateData(it.carVo)
                    mBinding.vehicleinfoView.updateData(deviceSn, bindDeviceInfoView)
                }
                //电池
                else if (it.batteryVo != null) {
                    deviceSn = it.batteryVo.sn ?: ""
                    deviceType = DeviceTypeObject.TYPE_BATTERY
                    bindDeviceInfoView?.updateData(it.batteryVo)
                    mBinding.vehicleinfoView.updateData(deviceSn, bindDeviceInfoView)
                }
            }
        })
        getViewModel().packListLiveData.observe(this, {
            resetPackageInfo()
            if (!it.isNullOrEmpty()) {
                packList = it as ArrayList<Pack>
            }
        })
    }

    private fun controlBtnConfirmEnable() {
        if (!TextUtils.isEmpty(deviceSn) && !TextUtils.isEmpty(infoCode)) {
            mBinding.btnConfirm.isEnabled = true
        } else {
            mBinding.btnConfirm.isEnabled = false
        }
    }

    private fun initListener() {
        mBinding.vehicleinfoView.setOnSnSearchInfoListener(object :
            SnSearchInfoView.OnSnSearchInfoListener {
            override fun onScanClick() {
                askPermission()
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                if (inputContent != null && !TextUtils.isEmpty(inputContent)) {
                    deviceSn = inputContent
                    getViewModel().getRentInfo(inputContent)
                } else {
                    mBinding.vehicleinfoView.removeSnInfo()
                    deviceSn = ""
                    mBinding.vehicleinfoView.updateData(deviceSn)
                }
            }

            override fun onEditTextHasFocus() {

            }
        })
        mBinding.vehicleinfoView.setOnEditTextActionListener {
            mBinding.vehicleinfoView.clearEditTextForces()
        }
        mBinding.vehicleinfoView.setOnClearInputListener {
            resetDeviceInfo()
            resetPackageInfo()
        }
    }

    private fun initData() {
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
                IntentIntegrator.forSupportFragment(this@RentBindFragment)
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
            //设备信息
            deviceSn = ScanUtils.Companion.getDeviceSn(requireContext(), mScanResult)
            mBinding.vehicleinfoView.updateData(deviceSn)
            if (!TextUtils.isEmpty(deviceSn)) {
                getViewModel().getRentInfo(deviceSn);
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        findNavController().currentBackStackEntry
            ?.savedStateHandle
            ?.getLiveData<Boolean>("fromSellBindSuccessFragment")
            ?.observe(viewLifecycleOwner) {
                mBinding.vehicleinfoView.updateData("")
                resetDeviceInfo()
                resetPackageInfo()
                findNavController().currentBackStackEntry
                    ?.savedStateHandle
                    ?.remove<Boolean>("fromSellBindSuccessFragment")
            }

    }

    private fun resetDeviceInfo() {
        deviceSn = ""
        deviceType = -1
        mBinding.vehicleinfoView.removeSnInfo()
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetPackageInfo() {
        infoCode = ""
        packList.clear()
        infoCode = ""
        mBinding.packageinfoview.visibility = View.GONE
        mBinding.packageinfoview.updateRentData(null)
        mBinding.tvNoInfo.visibility = View.VISIBLE
        mBinding.line1.visibility = View.GONE
        mBinding.tvReselect.visibility = View.GONE
        mBinding.btnConfirm.isEnabled = false

    }
}