package com.okla.ops.views.workbench.sales.installmentPayment

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.widget.AppCompatButton
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.image.preview.ImagePreviewDialog
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.PicJumpUtils
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.base.library.utils.FileUtils
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.beans.PeriodOrder
import com.okla.ops.databinding.FragmentInstallmentpaymentBinding
import com.okla.ops.dialog.DialogSelectPaymentOrder
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.weight.SnSearchInfoView
import com.luck.picture.lib.basic.PictureSelector
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.SelectMimeType
import com.luck.picture.lib.config.SelectModeConfig
import com.luck.picture.lib.entity.LocalMedia
import com.luck.picture.lib.utils.SdkVersionUtils
import com.lxj.xpopup.XPopup
import com.orhanobut.logger.Logger

class InstallmentPaymentFragment :
    BaseNormalVFragment<InstallmentViewModel, FragmentInstallmentpaymentBinding>() {
    //    private lateinit var orderAdapter: SingleDataBindingNoPUseAdapter<PeriodOrder>
    private var userId = ""
    private var orderId = ""
    private var mImgList: String = ""
    private var currentPeriod = 0
    private var orderList = ArrayList<PeriodOrder>()
    override fun getLayoutId(): Int {
        return R.layout.fragment_installmentpayment
    }

    override fun onCreateViewModel(): InstallmentViewModel {
        return ViewModelProvider(this).get(InstallmentViewModel::class.java);
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

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        initListener()
        initData()
        initClick()
    }

    private fun initClick() {
        mBinding.imgSelectOrder.setOnClickListener(this)
        mBinding.tvReselect.setOnClickListener(this)
        mBinding.btnConfirm.setOnClickListener(this)
        mBinding.ivBack.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.ivBack -> {
                activity?.finish()
            }

            R.id.tv_reselect, R.id.img_select_order -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                if (orderList.isNullOrEmpty()) {
                    ToastUtils.showShort(context?.getString(R.string.str_no_order_yet))
                    return
                }
                XPopup.Builder(context)
                    .enableDrag(false)
                    .dismissOnTouchOutside(false)
                    .asCustom(
                        context?.let {
                            DialogSelectPaymentOrder(
                                it,
                                orderList,
                                object : DialogSelectPaymentOrder.SelectCallBack {
                                    override fun onSelectPaymentOrder(order: PeriodOrder) {
                                        if (order != null) {
                                            currentPeriod = order?.period ?: 0
                                            orderId = order.orderNo ?: ""
                                            mBinding.groupSelectedOrder.visibility = View.VISIBLE
                                            mBinding.imgSelectOrder.visibility = View.GONE
                                            mBinding.tvEmptyOrder.visibility = View.GONE
                                            mBinding.orderInfoView.updateInfo(order)
                                            enableSubmit()
                                        } else {
                                            resetOrderInfo()
                                        }
                                    }
                                })
                        }
                    )
                    .show()
            }

            R.id.btnConfirm -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                mBinding.btnConfirm.isEnabled = false
                getViewModel().payPeriod(
                    userId,
                    mImgList,
                    orderId,
                    currentPeriod
                )
            }
        }
    }

    private fun initObserver() {
        getViewModel().payPeriodResultLiveData.observe(this, {
            if (it != null) {
                findNavController().navigate(
                    InstallmentPaymentFragmentDirections.installmentFragmentToInstallmentSuccessFragment(
                        orderId
                    )
                )
                getViewModel().payPeriodResultLiveData.value = null
            } else {
                enableSubmit()
            }
        })
        getViewModel().installMmentInfoLiveData.observe(this, {
            resetUserInfo()
            resetVoucherView()
            if (it != null) {
                val userInfoView = context?.let { it1 -> InstallmentUserInfoView(it1) }
                userId = it.cardNum ?: ""
                userInfoView?.updateData(it)
                mBinding.userinfoView.updateData(userId, userInfoView)
                currentPeriod = -1
            }
        })
        getViewModel().orderListLiveData.observe(this, {
            resetOrderInfo()
            if (!it.isNullOrEmpty()) {
                orderList = it as ArrayList<PeriodOrder>
            }
        })
        getViewModel().uploadAttachmentLiveData.observe(this, {
            it?.let {
                mBinding.voucherview?.setImages(it)
            }
        })
    }

    private fun resetUserInfo() {
        userId = ""
        mBinding.userinfoView.removeSnInfo()
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetOrderInfo() {
        orderId = ""
        orderList.clear()
        currentPeriod = -1
        mBinding.groupSelectedOrder.visibility = View.GONE
        mBinding.imgSelectOrder.visibility = View.VISIBLE
        mBinding.tvEmptyOrder.visibility = View.VISIBLE
        mBinding.orderInfoView.updateInfo(null)
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetVoucherView() {
        mImgList = ""
        mBinding.voucherview.resetData()
        mBinding.btnConfirm.isEnabled = false
    }

    private fun initListener() {
        mBinding.userinfoView.setOnSnSearchInfoListener(object :
            SnSearchInfoView.OnSnSearchInfoListener {
            override fun onScanClick() {
                askPermission()
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                if (inputContent != null && !TextUtils.isEmpty(inputContent)) {
                    getViewModel().getInstallmentPayInfo(inputContent)
                } else {
                    mBinding.userinfoView.removeSnInfo()
                    userId = ""
                }
            }

            override fun onEditTextHasFocus() {

            }
        })
        mBinding.userinfoView.setOnEditTextActionListener {
            mBinding.userinfoView.clearEditTextForces()
        }
        mBinding.userinfoView.setOnClearInputListener {
            resetUserInfo()
            resetOrderInfo()
            resetVoucherView()
        }
        mBinding.voucherview.setOnPhotoListener(object : PaymentVoucherView.OnPhotoListener {
            override fun onTakePhoto(type: Int) {
                if(mBinding.voucherview.getCurrentImageSize()<5){
                    askPhotoPermission()
                }
            }

            override fun onWatchPhoto(imgs: ArrayList<String>, position: Int) {
                childFragmentManager?.let {
                    ImagePreviewDialog.getInstance(imgs, position)
                        .showNow(it, "")
                }
            }

            override fun onImageList(imgData: String) {
                mImgList = imgData
                enableSubmit()
            }
        })
    }

    private fun enableSubmit() {
        mBinding.btnConfirm.isEnabled =
            !mImgList.isNullOrBlank() &&
                    !TextUtils.isEmpty(userId) &&
                    !TextUtils.isEmpty(orderId)
    }

    private fun initData() {
        mBinding.userinfoView.setTitle(getString(R.string.text_user_id))
        mBinding.userinfoView.setEditTextHint(getString(R.string.hint_enter_userid_or_scan_qr_code))
        mBinding.userinfoView.setNoDataTips(getString(R.string.text_no_user_param))
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
                IntentIntegrator.forSupportFragment(this@InstallmentPaymentFragment)
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

//    override fun initPageData() {
//    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (data == null) {
            return
        }
        when (requestCode) {
            IntentIntegrator.REQUEST_CODE -> {
                val intentResult =
                    IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
                val mScanResult = intentResult?.contents.toString()
                //用户信息
                var userId = ""
                if (!mScanResult.contains(",")) {
                    userId = ScanUtils.getUserCarNum(requireContext(), mScanResult)
                } else {
                    val qrcodeCashPay = ScanUtils.parseQrCodeCashPay(mScanResult)
                    userId = qrcodeCashPay.cardNum
                }
                mBinding.userinfoView.updateData(userId)
                getViewModel().getInstallmentPayInfo(userId)
            }

            PictureConfig.CHOOSE_REQUEST -> {
                // 图片选择结果回调
                takePictureFinish(data)
            }

            PictureConfig.REQUEST_CAMERA -> {
                // 拍照结果回调
                takePictureFinish(data)
            }
        }
    }

    private fun takePictureFinish(data: Intent?) {
        val selectList = PictureSelector.obtainSelectorList(data)
        for (media in selectList) {
            Logger.i("是否压缩:" + media.isCompressed)
            Logger.i("压缩:" + media.compressPath)
            Logger.i("原图:" + media.path)
            Logger.i("是否裁剪:" + media.isCut)
            Logger.i("裁剪:" + media.cutPath)
            Logger.i("是否开启原图:" + media.isOriginal)
            Logger.i("原图路径:" + media.originalPath)
            Logger.i("宽高: " + media.width + "x" + media.height)
            Logger.i("Size: " + media.size)
            dealLocalMedia(media)
        }
    }

    private fun dealLocalMedia(media: LocalMedia) {
        if (mBinding.voucherview.getCurrentImageSize() > 5) {
            return
        }
        var path = ""
        if (TextUtils.isEmpty(media.compressPath)) {
            if (!TextUtils.isEmpty(media.path)) {
                path = FileUtils.getContentUriFilePath(
                    context,
                    Uri.parse(media.path)
                )
            }
        } else {
            path = media.compressPath
        }
        if (path.isNotEmpty()) {
            getLoading().onStart()
            getViewModel().uploadAttachment(path)
        } else {
            ToastUtils.showShort("take photo failure.")
        }
    }

    private fun askPhotoPermission() {
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
                initBottomSheet()
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(activity, "")
            }
        }, *permissions.toTypedArray())
    }

    private var mBottomSheetDialog: BottomSheetDialog? = null
    private fun initBottomSheet() {
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = context?.let { BottomSheetDialog(it) }
            val view = LayoutInflater.from(context)
                .inflate(com.base.common.R.layout.dialog_take_photo_sheet, null, false)
            view.findViewById<AppCompatButton>(com.base.common.R.id.take_photo_bt)
                .setOnClickListener {
                    mBottomSheetDialog?.dismiss()
                    PicJumpUtils.jumpCameraByFragment(
                        this,
                        PictureConfig.REQUEST_CAMERA,
                        SelectMimeType.ofImage()
                    )
                }
            view.findViewById<AppCompatButton>(com.base.common.R.id.picture_bt).setOnClickListener {
                mBottomSheetDialog?.dismiss()
                val maxSelectNum = 5 - mBinding.voucherview.getCurrentImageSize() + 1
                PicJumpUtils.jumpMultiChooseAlbumByFragment(
                    this, maxSelectNum,
                    SelectModeConfig.MULTIPLE,
                    PictureConfig.CHOOSE_REQUEST,
                    false,
                    SelectMimeType.ofImage()
                )
            }
            view.findViewById<AppCompatButton>(com.base.common.R.id.btn_cancel).setOnClickListener {
                mBottomSheetDialog?.dismiss()
            }
            mBottomSheetDialog?.setContentView(view)
        }
        mBottomSheetDialog?.show()
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        findNavController().currentBackStackEntry
            ?.savedStateHandle
            ?.getLiveData<Boolean>("fromInstallmentSuccessFragment")
            ?.observe(viewLifecycleOwner) {
                mBinding.userinfoView.updateData("")
                resetUserInfo()
                resetOrderInfo()
                resetVoucherView()
                findNavController().currentBackStackEntry
                    ?.savedStateHandle
                    ?.remove<Boolean>("fromInstallmentSuccessFragment")
            }

    }
}