package com.okla.ops.views.workbench.sales.sellbind

import android.Manifest
import android.annotation.SuppressLint
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
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.beans.ServicePlanBean
import com.okla.ops.beans.ShopPaymentMethod
import com.okla.ops.databinding.FragmentSalebindBinding
import com.okla.ops.dialog.PaymentMethodDialogFragment
import com.okla.ops.dialog.SalebindPackageDialogFragment
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.sales.BindDeviceInfoView
import com.okla.ops.weight.SnSearchInfoView.OnSnSearchInfoListener
import com.luck.picture.lib.utils.SdkVersionUtils
import io.reactivex.disposables.Disposable
import io.reactivex.subjects.PublishSubject

class SellBindFragment :
    BaseNormalVFragment<SellBindViewModel, FragmentSalebindBinding>() {
    private var serviceName = ""
    private var deviceSn = ""
    private var serviceId = ""
    private var mDeviceType = -1
    private val inputSubject = PublishSubject.create<String>()
    private var inputDispose: Disposable? = null
    private var amount = 0.0
    private var selectBatteryType = ""
    private var selectCarType = ""


    override fun getLayoutId(): Int {
        return R.layout.fragment_salebind
    }

    override fun onCreateViewModel(): SellBindViewModel {
        return ViewModelProvider(this).get(SellBindViewModel::class.java);
    }

    private fun controlBtnConfirmEnable() {
        if (!TextUtils.isEmpty(serviceId) && !TextUtils.isEmpty(deviceSn)) {
            mBinding.btnConfirm.isEnabled = true
        } else {
            mBinding.btnConfirm.isEnabled = false
        }
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
        mBinding.deviceinfoView.setEditTextHint(context?.getString(R.string.hint_enter_device_sn_or_scan_qr_code))
        mBinding.deviceinfoView.setTitle(context?.getString(R.string.text_device_sn))
        initListener()
        initClick()
    }
    private var shopPaymentMethod: ShopPaymentMethod? = null

    private fun initObserver() {
        getViewModel().shopPaymentMethodLiveData.observe(this, {
            shopPaymentMethod = it

        })
        getViewModel().batterOrVehicleInfo.observe(this, {
            resetDeviceInfo()
            if (it != null) {
                val bindDeviceInfoView = context?.let { it1 -> BindDeviceInfoView(it1) }
                mDeviceType = it.deviceType
                //车
                if (it.carVo != null) {
                    bindDeviceInfoView?.updateData(it.carVo)
                    deviceSn = it.carVo.sn ?: ""
                }
                //电池
                else if (it?.batteryVo != null) {
                    deviceSn = it.batteryVo.sn ?: ""
                    bindDeviceInfoView?.updateData(it.batteryVo)
                }
                mBinding.deviceinfoView.updateData(deviceSn, bindDeviceInfoView)
                controlBtnConfirmEnable()
            }
        })
    }

    private fun resetPackageInfo() {
        selectCarType = ""
        selectBatteryType = ""
        amount = 0.0
        mBinding.packageinfoView.visibility = View.GONE
        mBinding.line2.visibility = View.GONE
        mBinding.flEmptyPackage.visibility = View.VISIBLE
        mBinding.deviceinfoView.visibility = View.GONE
        mBinding.flEmptyDeviceinfo.visibility = View.VISIBLE
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetDeviceInfo() {
        deviceSn = ""
        mDeviceType = -1
        mBinding.deviceinfoView.removeSnInfo()
        mBinding.btnConfirm.isEnabled = false
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initClick() {
        mBinding.btnConfirm.setOnClickListener(this)
        mBinding.tvSearch.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.tvSearch -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                SalebindPackageDialogFragment(object :
                    SalebindPackageDialogFragment.SelectCallBack {
                    override fun onSelected(bean: ServicePlanBean) {
                        if (bean != null) {
                            selectCarType = bean.carType ?: ""
                            selectBatteryType = bean.batteryType ?: ""
                            serviceId = bean.infoCode ?: ""
                            //填写好套餐信息
                            mBinding.packageinfoView.visibility = View.VISIBLE
                            mBinding.line2.visibility = View.VISIBLE
                            mBinding.deviceinfoView.visibility = View.VISIBLE
                            mBinding.flEmptyDeviceinfo.visibility = View.GONE
                            mBinding.packageinfoView.updateSellData(bean)
                            amount = bean.packageAmount ?: 0.0
                            mBinding.deviceinfoView.updateData("")
                            resetDeviceInfo()
                        } else {
                            resetPackageInfo()
                        }
                    }
                }).show(childFragmentManager, "salebindpackagedialog")
            }

            R.id.btnConfirm -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                if (TextUtils.isEmpty(deviceSn)) {
                    ToastUtils.showShort(context?.getString(R.string.hint_enter_device_sn_or_scan_qr_code))
                    return
                }
                PaymentMethodDialogFragment.getInstance(
                    serviceId,
                    deviceSn,
                    mDeviceType,
                    PaymentMethodDialogFragment.TYPE_SELLBIND, amount, shopPaymentMethod
                )
                    .show(this@SellBindFragment.childFragmentManager, "payment_method_dialog")
            }
        }
    }

    private fun initListener() {
        mBinding.deviceinfoView.setOnSnSearchInfoListener(object : OnSnSearchInfoListener {
            override fun onScanClick() {
                askPermission()
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                deviceSn = inputContent ?: ""
                hideSoftInput()
                if (!TextUtils.isEmpty(deviceSn)) {
                    getViewModel().queryBatteryOrVehicle(
                        deviceSn ?: "",
                        selectBatteryType,
                        selectCarType
                    )
                }
            }

            override fun onEditTextHasFocus() {

            }
        })
        mBinding.deviceinfoView.setOnClearInputListener {
            resetDeviceInfo()
        }
        mBinding.deviceinfoView.setNoDataTips(context?.getString(R.string.text_no_device_param))
        mBinding.ivBack.setOnClickListener {
            activity?.finish()
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
                IntentIntegrator.forSupportFragment(this@SellBindFragment)
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
            deviceSn = context?.let { ScanUtils.Companion.getDeviceSn(it, mScanResult) }!!
            mBinding.deviceinfoView.updateData(deviceSn)
            if (!TextUtils.isEmpty(deviceSn)) {
                getViewModel().queryBatteryOrVehicle(
                    deviceSn,
                    selectBatteryType,
                    selectCarType
                );
            }
        }
    }

    override fun onDestroy() {
        inputDispose?.dispose()
        inputDispose = null
        super.onDestroy()
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        findNavController().currentBackStackEntry
            ?.savedStateHandle
            ?.getLiveData<Boolean>("fromSellBindSuccessFragment")
            ?.observe(viewLifecycleOwner) {
                deviceSn = ""
                mBinding.deviceinfoView.updateData("")
                resetDeviceInfo()
                resetPackageInfo()
                findNavController().currentBackStackEntry
                    ?.savedStateHandle
                    ?.remove<Boolean>("fromSellBindSuccessFragment")
            }

    }
}