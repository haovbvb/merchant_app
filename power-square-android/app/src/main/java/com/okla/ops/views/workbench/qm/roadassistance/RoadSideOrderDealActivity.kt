package com.okla.ops.views.workbench.qm.roadassistance

import android.Manifest
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.widget.AppCompatButton
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.beans.RxEvent
import com.base.common.beans.RxEvent.RoadSideNotPayEvent
import com.base.common.image.preview.ImagePreviewDialog
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.PicJumpUtils
import com.base.common.utils.ToastUtils
import com.base.library.utils.FileUtils
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.okla.ops.R
import com.okla.ops.beans.WorkOrderReport
import com.okla.ops.databinding.LayoutWorktaskCompleteBinding
import com.okla.ops.dialog.RoadSidePaymentDialog
import com.okla.ops.dialog.RoadSidePaymentDialog.Companion.getInstance
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.sales.installmentPayment.PaymentVoucherView
import com.luck.picture.lib.basic.PictureSelector
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.SelectMimeType
import com.luck.picture.lib.config.SelectModeConfig
import com.luck.picture.lib.entity.LocalMedia
import com.luck.picture.lib.utils.SdkVersionUtils
import com.orhanobut.logger.Logger
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class RoadSideOrderDealActivity :
    BaseNormalVActivity<RoadSideViewModel, LayoutWorktaskCompleteBinding>() {

    private var permissionManager: PermissionManager? = null
    private val workOrderReport: WorkOrderReport? = WorkOrderReport()

    companion object {
        fun getIntents(context: Context?, sheetNo: String?): Intent {
            val intent = Intent(context, RoadSideOrderDealActivity::class.java)
            intent.putExtra("sheetNo", sheetNo)
            context?.startActivity(intent)
            return intent
        }

    }

    override fun onCreateViewModel(): RoadSideViewModel {
        return ViewModelProvider(this)[RoadSideViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.layout_worktask_complete
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


    private var mRecordNo = ""
    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        mRecordNo = intent.getStringExtra("sheetNo") ?: ""
        initVoucherView()
        initObserver()
        initClick()
    }

    override fun title(): Int {
        return R.string.str_processing_result
    }

    private fun initObserver() {
        getViewModel().dealRoadSideResultLiveData.observe(this, {
            it?.let {
                EventBus.getDefault().post(RxEvent.RoadSideDealSuccessEvent())
                //进行中
                getInstance(mRecordNo, RoadSidePaymentDialog.TYPE_ROADSIDE)
                    .show(supportFragmentManager, "roadside_deal")
            }

        })
        getViewModel().mRoadSideUploadImageLiveData.observe(this, {
            it?.let {
                mBinding.voucherview?.setImages(it)
            }
        })
    }


    private fun initClick() {
        mBinding.btnSubmit.setOnClickListener(View.OnClickListener { v: View? ->
            if (ViewClickUtils.isFastClick()) {
                return@OnClickListener
            }
            submitWorkTask()
        })
        mBinding.btnComplete.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            enableComplete()
        }
        mBinding.btnIncomplete.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            enableIncomplete()
        }
    }


    private fun submitWorkTask() {
        workOrderReport?.imgList = mImgList
        workOrderReport?.sheetNo = mRecordNo
        workOrderReport?.processDesc = mBinding.etDescription.text.toString()
        workOrderReport?.let {
            getViewModel().dealRoadSideOrder(it)
        }
    }

    private fun enableComplete() {
        mBinding.btnSubmit.isEnabled = true;
        workOrderReport?.result = 2 //已完成
        mBinding.tvComplete.setTextColor(ContextCompat.getColor(this, R.color.main_color))
        mBinding.tvComplete.setCompoundDrawablesRelativeWithIntrinsicBounds(
            ContextCompat.getDrawable(
                this, R.mipmap.icon_result_completed_green
            ), null, null, null
        )
        mBinding.btnComplete.setBackground(
            ContextCompat.getDrawable(
                this,
                R.drawable.bg_return_factory
            )
        )
        mBinding.tvIncomplete.setTextColor(ContextCompat.getColor(this, R.color.color_99000000))
        mBinding.tvIncomplete.setCompoundDrawablesRelativeWithIntrinsicBounds(
            ContextCompat.getDrawable(
                this, R.mipmap.icon_deal_uncomplete_unselected
            ), null, null, null
        )
        mBinding.btnIncomplete.setBackground(
            ContextCompat.getDrawable(
                this,
                R.drawable.bg_f5f8fb_r8
            )
        )
    }

    private fun enableIncomplete() {
        mBinding.btnSubmit.isEnabled = true;
        workOrderReport?.result = 1//未完成
        mBinding.tvIncomplete.setTextColor(ContextCompat.getColor(this, R.color.main_color))
        mBinding.tvIncomplete.setCompoundDrawablesRelativeWithIntrinsicBounds(
            ContextCompat.getDrawable(
                this, R.mipmap.icon_deal_uncomplete_selected
            ), null, null, null
        )
        mBinding.btnIncomplete.setBackground(
            ContextCompat.getDrawable(
                this,
                R.drawable.bg_return_factory
            )
        )
        mBinding.tvComplete.setTextColor(ContextCompat.getColor(this, R.color.color_99000000))
        mBinding.tvComplete.setCompoundDrawablesRelativeWithIntrinsicBounds(
            ContextCompat.getDrawable(
                this, R.mipmap.icon_deal_complete_unselected
            ), null, null, null
        )
        mBinding.btnComplete.setBackground(ContextCompat.getDrawable(this, R.drawable.bg_f5f8fb_r8))
    }

    private var mImgList: String = ""

    private fun initVoucherView() {
        mBinding.voucherview?.setOnPhotoListener(object : PaymentVoucherView.OnPhotoListener {
            override fun onTakePhoto(type: Int) {
                    askPhotoPermission()
            }

            override fun onWatchPhoto(imgs: ArrayList<String>, position: Int) {
                supportFragmentManager?.let {
                    ImagePreviewDialog.getInstance(imgs, position)
                        .showNow(it, "")
                }
            }

            override fun onImageList(imgData: String) {
                mImgList = imgData
            }
        })
        mBinding.voucherview?.setTitle(mContext.getString(R.string.str_photo))
    }


    private var mBottomSheetDialog: BottomSheetDialog? = null
    private fun initBottomSheet() {
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = mContext?.let { BottomSheetDialog(it) }
            val view = LayoutInflater.from(mContext)
                .inflate(com.base.common.R.layout.dialog_take_photo_sheet, null, false)
            view.findViewById<AppCompatButton>(com.base.common.R.id.take_photo_bt)
                .setOnClickListener {
                    mBottomSheetDialog?.dismiss()
                    PicJumpUtils.jumpCamera(
                        this,
                        PictureConfig.REQUEST_CAMERA,
                        SelectMimeType.ofImage()
                    )
                }
            view.findViewById<AppCompatButton>(com.base.common.R.id.picture_bt).setOnClickListener {
                mBottomSheetDialog?.dismiss()
                val maxSelectNum = 5 - (mBinding.voucherview.getCurrentImageSize() ?: 1) + 1
                PicJumpUtils.jumpMultiChooseAlbum(
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

    private fun askPhotoPermission() {
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
                initBottomSheet()
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(activity, "")
            }
        }, *permissions.toTypedArray())
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
        if (mBinding.voucherview.getCurrentImageSize() >5) {
            return
        }
        var path = ""
        if (TextUtils.isEmpty(media.compressPath)) {
            if (!TextUtils.isEmpty(media.path)) {
                path = FileUtils.getContentUriFilePath(
                    mContext,
                    Uri.parse(media.path)
                )
            }
        } else {
            path = media.compressPath
        }
        if (path.isNotEmpty()) {
            viewModel.uploadRoadSideImage(path)
        } else {
            ToastUtils.showShort("take photo failure.")
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (data == null) {
            return
        }
        when (requestCode) {
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

    override fun isBindEventBusHere(): Boolean {
        return true
    }

    //支付处理完成
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun paySucess(event: RxEvent.RoadSidePaySucessEvent) {
        finish()
    }


    //不支付
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun notPay(event: RoadSideNotPayEvent?) {
        finish()
    }
}