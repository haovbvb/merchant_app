//package com.okla.ops.dialog
//
//import android.app.Activity.RESULT_OK
//import android.app.Dialog
//import android.content.Intent
//import android.os.Build
//import android.os.Bundle
//import android.text.TextUtils
//import android.util.Log
//import android.view.Gravity
//import android.view.LayoutInflater
//import android.view.View
//import android.view.ViewGroup
//import android.view.Window
//import androidx.appcompat.widget.AppCompatButton
//import androidx.appcompat.widget.AppCompatTextView
//import androidx.core.content.ContextCompat
//import androidx.fragment.app.DialogFragment
//import androidx.fragment.app.viewModels
//import com.base.common.utils.PicJumpUtils
//import com.base.common.utils.ToastUtils
//import com.google.android.material.bottomsheet.BottomSheetDialog
//import com.google.android.material.progressindicator.LinearProgressIndicator
//import com.okla.ops.R
//import com.okla.ops.utils.ViewClickUtils
//import com.okla.ops.views.workbench.WorkbenchViewModel
//import com.luck.picture.lib.basic.PictureSelector
//import com.luck.picture.lib.config.PictureConfig
//import com.luck.picture.lib.config.SelectMimeType
//import com.luck.picture.lib.config.SelectModeConfig
//import com.orhanobut.logger.Logger
//import com.yalantis.ucrop.UCrop
//
//class UploadProofDialogFragment : DialogFragment() {
//
//    private var filePath = ""
//    private var onlineUrl = ""
//    private lateinit var progressBar: LinearProgressIndicator
//
//    companion object {
//        private lateinit var uploadProofCallBack: UploadProofDialogFragment.UploadProofCallBack
//        const val TYPE_ROADSIDE = 1
//        fun getInstance(calBack: UploadProofCallBack): UploadProofDialogFragment {
//            uploadProofCallBack = calBack;
//            return UploadProofDialogFragment()
//        }
//    }
//
//    interface UploadProofCallBack {
//        fun successUploadProff() {
//
//        }
//    }
//
//    // 使用 by viewModels() 初始化独立的 ViewModel，作用域限定在 DialogFragment 内
//    private val viewModel: WorkbenchViewModel by viewModels()
//
//    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
//        // 获取布局
//        val inflater: LayoutInflater = requireActivity().layoutInflater
//        val view: View = inflater.inflate(R.layout.dialog_upload_proof, null)
//
//        // 获取布局内的控件
//        progressBar = view.findViewById<LinearProgressIndicator>(R.id.progress)
//        val tvUpload = view.findViewById<AppCompatTextView>(R.id.tv_upload)
//        val tvConfirm = view.findViewById<AppCompatTextView>(R.id.tv_confirm)
//        tvUpload.setOnClickListener {
//            initBottomSheet()
//        }
//        tvConfirm.setOnClickListener {
//            if (ViewClickUtils.isFastClick()) {
//                return@setOnClickListener
//            }
//            if (TextUtils.isEmpty(onlineUrl)) {
//                ToastUtils.showShort(context?.getString(R.string.upload_file_first))
//                return@setOnClickListener
//            }
//            viewModel.uploadProof(onlineUrl, TYPE_ROADSIDE)
//        }
//        viewModel.progressLiveData.observe(this, {
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//                progressBar.setProgress(it, true)
//            }
//        })
//        // 观察 ViewModel 数据（例如数据加载完成后更新 UI）
//        viewModel.uploadProofFileLiveData.observe(this) { data ->
//            onlineUrl = data
//            tvConfirm.isEnabled = true
//        }
//
//        viewModel.uploadProofLiveData.observe(this) {
//            uploadProofCallBack.successUploadProff()
//            dismissAllowingStateLoss()
//        }
//
//        val dialog = Dialog(requireContext())
//        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
//        dialog.setContentView(view) // 使用自定义布局
//        dialog.setCancelable(false) // 禁用返回键关闭
//        dialog.setCanceledOnTouchOutside(true) // 禁用点击外部关闭
//        return dialog
//    }
//
//    override fun onStart() {
//        super.onStart()
//        dialog?.window?.apply {
//            // 设置对话框宽度为屏幕宽度，高度为包裹内容
//            setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
//            // 设置对话框显示在底部
//            setGravity(Gravity.BOTTOM)
//            // 设置背景为透明
//            setBackgroundDrawable(ContextCompat.getDrawable(context, R.drawable.bg_top_r16_ffffff))
//            // 去除默认的边距
//            decorView.setPadding(0, 0, 0, 0)
//        }
//    }
//
//    private var mBottomSheetDialog: BottomSheetDialog? = null
//    private fun initBottomSheet() {
//        context?.let {
//            if (mBottomSheetDialog == null) {
//                mBottomSheetDialog = BottomSheetDialog(it)
//                val view = LayoutInflater.from(it)
//                    .inflate(com.base.common.R.layout.dialog_take_photo_sheet, null, false)
//                view.findViewById<AppCompatButton>(com.base.common.R.id.take_photo_bt)
//                    .setOnClickListener {
//                        mBottomSheetDialog?.dismiss()
//                        PicJumpUtils.jumpCameraByFragment(
//                            this,
//                            PictureConfig.REQUEST_CAMERA,
//                            SelectMimeType.ofImage()
//                        )
//                    }
//                view.findViewById<AppCompatButton>(com.base.common.R.id.picture_bt)
//                    .setOnClickListener {
//                        mBottomSheetDialog?.dismiss()
//                        PicJumpUtils.jumpMultiChooseAlbumByFragment(
//                            this,
//                            1,
//                            SelectModeConfig.SINGLE,
//                            PictureConfig.CHOOSE_REQUEST,
//                            false,
//                            SelectMimeType.ofImage()
//                        )
//                    }
//                view.findViewById<AppCompatButton>(com.base.common.R.id.btn_cancel)
//                    .setOnClickListener {
//                        mBottomSheetDialog?.dismiss()
//                    }
//                mBottomSheetDialog?.setContentView(view)
//            }
//            mBottomSheetDialog?.show()
//        }
//    }
//
//
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//        if (resultCode == RESULT_OK) {
//            when (requestCode) {
//                PictureConfig.CHOOSE_REQUEST -> {
//                    // 图片选择结果回调
//                    takePictureFinish(data)
//                }
//
//                PictureConfig.REQUEST_CAMERA -> {
//                    // 拍照结果回调
//                    takePictureFinish(data)
//                }
//            }
//        } else if (resultCode == UCrop.RESULT_ERROR) {
//            if (data != null) {
//                Log.d("xxxxx", "error: ${UCrop.getError(data)}")
//            }
//        }
//    }
//
//    /**
//     * 取得照片
//     */
//    private fun takePictureFinish(data: Intent?) {
//        val selectList = PictureSelector.obtainSelectorList(data)
//        for (media in selectList) {
//            Logger.i("是否压缩:" + media.isCompressed)
//            Logger.i("压缩:" + media.compressPath)
//            Logger.i("原图:" + media.path)
//            Logger.i("是否裁剪:" + media.isCut)
//            Logger.i("裁剪:" + media.cutPath)
//            Logger.i("是否开启原图:" + media.isOriginal)
//            Logger.i("原图路径:" + media.originalPath)
//            Logger.i("宽高: " + media.width + "x" + media.height)
//            Logger.i("Size: " + media.size)
//            filePath = if (TextUtils.isEmpty(media.compressPath)) media.path else media.compressPath
//            viewModel.uploadProofFile(filePath)
//        }
//    }
//}
