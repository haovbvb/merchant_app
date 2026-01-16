package com.okla.ops.dialog

import android.Manifest
import android.app.Dialog
import android.content.Intent
import android.media.Image
import android.net.Uri
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.widget.AppCompatButton
import androidx.constraintlayout.widget.Group
import androidx.core.content.ContextCompat
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.viewModels
import com.base.common.beans.RxEvent
import com.base.common.image.preview.ImagePreviewDialog
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.PicJumpUtils
import com.base.common.utils.ToastUtils
import com.base.library.utils.FileUtils
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.okla.ops.R
import com.okla.ops.beans.PayTypeObject
import com.okla.ops.utils.StringUtils
import com.okla.ops.utils.TextUtil
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.qm.maintenance.MaintenanceSuccessActivity
import com.okla.ops.views.workbench.qm.roadassistance.RoadSideViewModel
import com.okla.ops.views.workbench.sales.installmentPayment.PaymentVoucherView
import com.luck.picture.lib.basic.PictureSelector
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.SelectMimeType
import com.luck.picture.lib.config.SelectModeConfig
import com.luck.picture.lib.entity.LocalMedia
import com.luck.picture.lib.utils.SdkVersionUtils
import com.orhanobut.logger.Logger
import org.greenrobot.eventbus.EventBus

class RoadSidePaymentDialog : DialogFragment(),TextUtil {
    private lateinit var permissionManager: PermissionManager
    private var mImgList: String = ""
    private var voucherView: PaymentVoucherView? = null

    //    private var tvTitleUpload:TextView?=null
    private var tvConfirm: TextView? = null
    private var edtAmout: EditText? = null
    private var tvCash: TextView? = null

    private var imgCash: ImageView? = null
    private var imgOnline: ImageView? = null

    private var tvOnline: TextView? = null
    private var groupPayInfo: Group? = null

    private var showType = 0
    private var deviceSn = ""
    private var userId = ""
    private var amountStr = ""
    private var paySource = PayTypeObject.TYPE_ONLINE; //默认线上
    private var remark = ""
    private var recordNo = ""

    private var tvNotPay: TextView? = null
    private var tvPay: TextView? = null

    private var imgClose: ImageView?=null
    companion object {
        const val TYPE_ROADSIDE = 1
        const val TYPE_MAINTENANCE = 2
        const val TYPE_JUST_UPLOAD_VOUCHER = 3
        fun getInstance(
            userid: String,
            deviceSn: String,
            remark: String,
            type: Int
        ): RoadSidePaymentDialog {
            val roadSidePaymentDialog = RoadSidePaymentDialog()
            val bundle = Bundle()
            bundle.putString("userid", userid)
            bundle.putString("sn", deviceSn)
            bundle.putString("remark", remark)
            bundle.putInt("type", type)
            roadSidePaymentDialog.arguments = bundle
            return roadSidePaymentDialog;
        }

        fun getInstance(
            orderNo: String,
            type: Int
        ): RoadSidePaymentDialog {
            val roadSidePaymentDialog = RoadSidePaymentDialog()
            val bundle = Bundle()
            bundle.putString("orderNo", orderNo)
            bundle.putInt("type", type)
            roadSidePaymentDialog.arguments = bundle
            return roadSidePaymentDialog;
        }

        fun getInstance(
            userid: String,
            orderNo: String,
            type: Int
        ): RoadSidePaymentDialog {
            val roadSidePaymentDialog = RoadSidePaymentDialog()
            val bundle = Bundle()
            bundle.putString("userid", userid)
            bundle.putString("orderNo", orderNo)
            bundle.putInt("type", type)
            roadSidePaymentDialog.arguments = bundle
            return roadSidePaymentDialog;
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            requireActivity().activityResultRegistry, this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        initObserver()
    }

    private val viewModel: RoadSideViewModel by viewModels()
    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        showType = arguments?.getInt("type") ?: 0
        deviceSn = arguments?.getString("sn") ?: ""
        userId = arguments?.getString("userid") ?: ""
        remark = arguments?.getString("remark") ?: ""
        recordNo = arguments?.getString("orderNo") ?: ""
        // 获取布局
        val inflater: LayoutInflater = requireActivity().layoutInflater
        val view: View = inflater.inflate(R.layout.dialog_pay_roadside, null)
        voucherView = view.findViewById<PaymentVoucherView>(R.id.voucherview)
        voucherView?.findViewById<TextView>(R.id.tv_title)?.text =
            context?.getString(R.string.str_upload_voucher)
        edtAmout = view.findViewById(R.id.edtamount)
        tvConfirm = view.findViewById<TextView>(R.id.btnConfirm)
        tvCash = view.findViewById(R.id.tv_cash)
        tvOnline = view.findViewById(R.id.tv_online)
        groupPayInfo = view.findViewById(R.id.group_payinfo)
        tvNotPay = view.findViewById(R.id.tv_not_pay)
        tvPay = view.findViewById(R.id.tv_pay)
        imgCash = view.findViewById(R.id.img_cash)
        imgOnline = view.findViewById(R.id.img_online)
        imgClose = view.findViewById(R.id.imgclose)
        val tvTitle = view.findViewById<TextView>(R.id.tv_title)
        edtAmout?.let {
            setDecimalLimit(it)
        }
        when (showType) {
            TYPE_MAINTENANCE -> {
                tvTitle.text = context?.getString(R.string.title_maintenance_costs)
                tvConfirm?.visibility = View.VISIBLE
                tvNotPay?.visibility = View.GONE
                tvPay?.visibility = View.GONE
                voucherView?.visibility = View.GONE
                groupPayInfo?.visibility = View.VISIBLE
                imgCash?.setImageResource(R.mipmap.icon_grey_unchecked)
                imgOnline?.setImageResource(R.mipmap.icon_green_checked)
            }

            TYPE_ROADSIDE -> {
                tvTitle.text = context?.getString(R.string.title_roadside_costs)
                imgCash?.setImageResource(R.mipmap.icon_grey_unchecked)
                imgOnline?.setImageResource(R.mipmap.icon_green_checked)
                voucherView?.visibility = View.GONE
                groupPayInfo?.visibility = View.VISIBLE
                if (tag == "roadside_detail") {
                    tvConfirm?.visibility = View.VISIBLE
                    tvNotPay?.visibility = View.GONE
                    tvPay?.visibility = View.GONE
                } else {
                    tvConfirm?.visibility = View.GONE
                    tvNotPay?.visibility = View.VISIBLE
                    tvPay?.visibility = View.VISIBLE
                }
            }

            TYPE_JUST_UPLOAD_VOUCHER -> {
                tvTitle.text = context?.getString(R.string.str_upload_voucher)
                tvConfirm?.visibility = View.GONE
                tvNotPay?.visibility = View.VISIBLE
                tvPay?.visibility = View.VISIBLE
                tvNotPay?.text = context?.getString(com.base.common.R.string.cc_str_cancel)
                tvPay?.text = context?.getString(com.base.common.R.string.cc_str_confirm)
                voucherView?.visibility = View.VISIBLE
                groupPayInfo?.visibility = View.GONE
            }
        }
        tvNotPay?.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            if(showType== TYPE_ROADSIDE){
                EventBus.getDefault().post(RxEvent.RoadSideNotPayEvent())
            }
            dismissAllowingStateLoss()
        }
        tvPay?.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            if (showType == TYPE_ROADSIDE) {
                viewModel?.payRoadSideRecord(
                    mImgList,
                    amountStr,
                    paySource,
                    recordNo
                )
            } else if (showType == TYPE_JUST_UPLOAD_VOUCHER) {
                viewModel.userConfirmPayOrder(
                    mImgList,
                    userId, recordNo
                )
            }
        }
        voucherView?.setOnPhotoListener(object : PaymentVoucherView.OnPhotoListener {
            override fun onTakePhoto(type: Int) {
                if(voucherView?.getCurrentImageSize()!! <5){
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
                if (showType == TYPE_JUST_UPLOAD_VOUCHER) {
                    if (mImgList.isNullOrBlank()) {
                        tvPay?.isEnabled = false
                    } else {
                        tvPay?.isEnabled = true
                    }
                } else {
                    enableBtnPay()
                    enableBtnConfirm()
                }
            }
        })
        edtAmout?.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

            override fun afterTextChanged(s: Editable?) {
                amountStr = edtAmout?.text.toString()
                enableBtnConfirm()
                enableBtnPay()
            }
        })
        tvCash?.setOnClickListener {
            paySource = PayTypeObject.TYPE_CASH
            imgCash?.setImageResource(R.mipmap.icon_green_checked)
            imgOnline?.setImageResource(R.mipmap.icon_grey_unchecked)
            voucherView?.visibility = View.VISIBLE
            enableBtnConfirm()
            enableBtnPay()
        }
        tvOnline?.setOnClickListener {
            paySource = PayTypeObject.TYPE_ONLINE
            imgCash?.setImageResource(R.mipmap.icon_grey_unchecked)
            imgOnline?.setImageResource(R.mipmap.icon_green_checked)
            voucherView?.visibility = View.GONE
            enableBtnConfirm()
            enableBtnPay()
        }
        imgClose?.setOnClickListener {
            if(ViewClickUtils.isFastClick()){
                return@setOnClickListener
            }
            dismiss()
        }
        tvConfirm?.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            if (showType == TYPE_MAINTENANCE) {
                viewModel.genMaintainRecord(
                    mImgList,
                    userId,
                    paySource,
                    amountStr,
                    remark,
                    deviceSn
                )
            } else if (showType == TYPE_ROADSIDE) {
                viewModel.payRoadSideRecord(
                    mImgList,
                    amountStr,
                    paySource,
                    recordNo
                )
            }
        }
        val dialog = Dialog(requireContext())
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(view) // 使用自定义布局
        dialog.setCancelable(false) // 禁用返回键关闭
        if (showType == TYPE_ROADSIDE || showType == TYPE_MAINTENANCE) {
            imgClose?.visibility= View.VISIBLE
            dialog.setCanceledOnTouchOutside(false)
        } else {
            imgClose?.visibility= View.GONE
            dialog.setCanceledOnTouchOutside(true)
        }
        return dialog
    }

    override fun onStart() {
        super.onStart()
        dialog?.window?.apply {
            // 设置对话框宽度为屏幕宽度，高度为包裹内容
            setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            // 设置对话框显示在底部
            setGravity(Gravity.BOTTOM)
            // 设置背景为透明
            setBackgroundDrawable(ContextCompat.getDrawable(context, R.drawable.bg_top_f3f4f5_r16))
            // 去除默认的边距
            decorView.setPadding(0, 0, 0, 0)
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

    private var selectPathSize = 0
    private fun takePictureFinish(data: Intent?) {
        val selectList = PictureSelector.obtainSelectorList(data)
        selectPathSize += selectList.size
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
        if (voucherView?.getCurrentImageSize()!! >5) {
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
            if (showType == TYPE_JUST_UPLOAD_VOUCHER) {
                viewModel.userUplaodAttachment(path)
            } else {
                viewModel.uplaodMaintenanceVoucher(path)
            }
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
                val maxSelectNum = 5 - voucherView?.getCurrentImageSize()!! + 1
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

    private fun initObserver() {
        viewModel.confirmPayResultLiveData.observe(this, {
            if (it != null) {
                ToastUtils.showShort(context?.getString(R.string.cc_str_success))
                if (null != mCallBack) {
                    val list = StringUtils.strToList(mImgList)
                    mCallBack?.onUploadAttachmentCallBack(list)
                }
                EventBus.getDefault().post(RxEvent.RoadSidePaySucessEvent())
                dismiss()
            } else {
                enableBtnPay()
                enableBtnConfirm()
            }
        })

        viewModel.UserUploadAttachmentLiveDATA.observe(this, {
            it?.let {
                voucherView?.setImages(it)
            }
        })
        viewModel.uploadAttachmentLiveData.observe(this, {
           it?.let {
               voucherView?.setImages(it)
           }
        })
        viewModel.genMaintenanceResultLiveData.observe(this, {
            //去提交成功页面
            context?.let { it1 -> MaintenanceSuccessActivity.Companion.getIntents(it1) }
            EventBus.getDefault().post(RxEvent.MaintenancePaySucessEvent())
            dismissAllowingStateLoss()
        })
        viewModel.payRoadSideResultLiveData.observe(this, {
            if (it != null) {
                ToastUtils.showShort(context?.getString(R.string.cc_str_success))
                EventBus.getDefault().post(RxEvent.RoadSidePaySucessEvent())
                dismiss()
            } else {
                enableBtnPay()
                enableBtnConfirm()
            }
        })
    }

    private fun enableBtnConfirm() {
        when (paySource) {
            //现金
            PayTypeObject.TYPE_CASH-> {
                if (!mImgList.isNullOrEmpty() &&isAmountMeaningful(amountStr) && paySource != 0) {
                    tvConfirm?.isEnabled = true
                } else {
                    tvConfirm?.isEnabled = false
                }
            }
            //线上
            PayTypeObject.TYPE_ONLINE -> {
                if (isAmountMeaningful(amountStr) && paySource != 0) {
                    tvConfirm?.isEnabled = true
                } else {
                    tvConfirm?.isEnabled = false
                }
            }
        }

    }

    private fun enableBtnPay() {
        when (paySource) {
            //现金
            PayTypeObject.TYPE_CASH-> {
                if (!mImgList.isNullOrEmpty() && isAmountMeaningful(amountStr) && paySource != 0) {
                    tvPay?.isEnabled = true
                } else {
                    tvPay?.isEnabled = false
                }
            }
            //线上
            PayTypeObject.TYPE_ONLINE -> {
                if (isAmountMeaningful(amountStr) && paySource != 0) {
                    tvPay?.isEnabled = true
                } else {
                    tvPay?.isEnabled = false
                }
            }
        }
    }

    // 工具函数：判断输入是否“有意义”（至少包含一个数字，且不全是小数点）
    private fun isAmountMeaningful(amountStr: String?): Boolean {
        if (amountStr.isNullOrBlank()) return false
        // 只由点组成的，全部拦截：".", ".." 都是 false
        if (amountStr.all { it == '.' }) return false
        // 必须至少有一个数字字符
        if (!amountStr.any { it.isDigit() }) return false
        return true
    }

    override fun onDestroy() {
        super.onDestroy()

    }

    private var mCallBack: OnUploadAttachmentCallBack? = null
    fun setUploadCallBack(callBack: OnUploadAttachmentCallBack) {
        mCallBack = callBack;
    }

    interface OnUploadAttachmentCallBack {
        fun onUploadAttachmentCallBack(list: ArrayList<String>)
    }
}