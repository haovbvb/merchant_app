package com.okla.ops.views.mine

import android.app.Activity.RESULT_OK
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.widget.AppCompatButton
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.beans.RxEvent
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.LanguageUtils
import com.base.common.utils.PicJumpUtils
import com.base.common.utils.ToastUtils
import com.bumptech.glide.Glide
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.luck.picture.lib.basic.PictureSelector
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.PictureMimeType
import com.luck.picture.lib.config.SelectMimeType
import com.luck.picture.lib.config.SelectModeConfig
import com.lxj.xpopup.XPopup
import com.orhanobut.logger.Logger
import com.okla.ops.R
import com.okla.ops.databinding.FragmentMineBinding
import com.okla.ops.dialog.PopNicknameEdit
import com.yalantis.ucrop.UCrop
import okhttp3.MediaType
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import org.greenrobot.eventbus.EventBus
import java.io.File
import java.util.Locale

class MineFragment : BaseNormalVFragment<MineViewModel, FragmentMineBinding>() {

    companion object {
        fun newInstance(): MineFragment {
            return MineFragment()
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_mine
    }

    override fun onCreateViewModel(): MineViewModel {
        return ViewModelProvider(this)[MineViewModel::class.java]
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        initObserver()
        initClicks()
        initData()
    }

    private fun initData() {
        val local = DataStoreUtils.readStringData(
            DataStoreKeyUtils.LANGUAGE_SETTING,
            LanguageUtils.LanguageType.ENGLISH.language
        )
        when (local) {
            LanguageUtils.LanguageType.ENGLISH.language -> {
                mBinding.tvLanguageCurrent.text = Locale.ENGLISH.language.uppercase()
            }

            LanguageUtils.LanguageType.CHINESE.language -> {
                mBinding.tvLanguageCurrent.text = Locale.CHINESE.language.uppercase()
            }
        }
        getViewModel().getPersonalInfo()
    }

    override fun onResume() {
        super.onResume()
        getViewModel().getUnReadMsgCount()
    }
    private fun initClicks() {
        mBinding.tvLanguageSetting.setOnClickListener(this)
        mBinding.tvUserAgreement.setOnClickListener(this)
        mBinding.tvAboutApp.setOnClickListener(this)
        mBinding.tvChangePSW.setOnClickListener(this)
        mBinding.tvLogOut.setOnClickListener(this)
        mBinding.tvUserName.setOnClickListener(this)
        mBinding.ivAvator.setOnClickListener(this)
        mBinding.tvMsgCenter.setOnClickListener(this)
    }

    private fun initObserver() {
        getViewModel().logoutLiveData.observe(this) {
            ToastUtils.showShort(getString(com.base.common.R.string.cc_str_success))
            EventBus.getDefault().post(RxEvent.LoginOut())
        }
        getViewModel().personalLiveData.observe(this) {
            mBinding.tvUserName.text = it.nickName
            val index = it.userId.indexOf("@")
            val userId = it.userId.substring(0, index)
            mBinding.tvUserID.text = String.format(getString(R.string.text_ids), userId)
            context?.let { context ->
                Glide.with(context).load(it.avatarUrl)
                    .placeholder(R.drawable.icon_def_avator)
                    .error(R.drawable.icon_def_avator)
                    .into(mBinding.ivAvator)
            }
            if (!TextUtils.isEmpty(it.avatarUrl)) mBinding.ivAvatorEdit.visibility =
                View.GONE
        }
        getViewModel().editAvatarLiveData.observe(this) {
            getViewModel().getPersonalInfo()
        }
        getViewModel().editNicknameLiveData.observe(this) {
            mBinding.tvUserName.text = it
        }
        //获取未读消息数
        getViewModel().unReadMsgLiveData.observe(this, {
            it?.let {
                if (it > 0) {
                    val size = it
                    if (size > 99) {
                        mBinding.tvUnread.text = "99+"
                        mBinding.tvUnread.setBackgroundResource(R.drawable.bg_shape_red)
                    } else {
                        mBinding.tvUnread.text = it.toString()
                        if(size>=10){
                            mBinding.tvUnread.setBackgroundResource(R.drawable.bg_shape_red)
                        }else{
                            mBinding.tvUnread.setBackgroundResource(R.drawable.bg_circle_red)
                        }
                    }
                    mBinding.tvUnread.visibility = View.VISIBLE
                } else {
                    mBinding.tvUnread.visibility = View.GONE
                }
            }
        })
    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.tvMsgCenter -> {
                context?.let {
                    NotificationActivity.startNotificationActivity(it)
                }
            }

            R.id.tvLanguageSetting -> {
                context?.let {
                    LanguageSettingsActivity.startLanguageSettingsActivity(it)
                }
            }

            R.id.tvUserAgreement -> {
                context?.let {
                    ServiceAgreementActivity.startServiceAgreementActivity(it)
                }
            }

            R.id.tvAboutApp -> {
                context?.let {
                    AboutAppActivity.startAboutAppActivity(it)
                }
            }

            R.id.tvChangePSW -> {
                val personal = getViewModel().personalLiveData.value
                context?.let {
                    ChangePSWActivity.startChangePSWActivity(it, personal?.userId)
                }
            }

            R.id.tvLogOut -> {
                getViewModel().logout()
            }

            R.id.tvUserName -> {
                context?.let {
                    XPopup.Builder(it)
                        .asCustom(
                            PopNicknameEdit(
                                it,
                            ) { content ->
                                getViewModel().editNickname(content)
                            })
                        .show()
                }
            }

            R.id.ivAvator -> {
                initBottomSheet()
            }
        }
    }

    /**
     * 取得照片
     */
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
            val localPath =
                if (TextUtils.isEmpty(media.compressPath)) media.path else media.compressPath
            startCrop(localPath)
        }
    }

    /**
     * 去裁剪
     *
     * @param originalPath
     */
    private fun startCrop(originalPath: String?) {
        if (originalPath.isNullOrBlank())
            return
        val options = UCrop.Options()
        options.setToolbarColor(
            ContextCompat.getColor(
                mActivity,
                com.base.common.R.color.cc_color_222222
            )
        )
        options.setStatusBarColor(
            ContextCompat.getColor(
                mActivity,
                com.base.common.R.color.cc_color_222222
            )
        )
        options.setToolbarWidgetColor(
            ContextCompat.getColor(
                mActivity,
                com.base.common.R.color.white
            )
        )
        options.setCircleDimmedLayer(true)
        options.setShowCropFrame(false)
        options.setShowCropGrid(false)
        options.setCompressionQuality(100)
        options.setHideBottomControls(true)
        options.setFreeStyleCropEnabled(false)
        val isHttp = PictureMimeType.isHasHttp(originalPath)
        val isContent = PictureMimeType.isContent(originalPath)
        val uri =
            if (isHttp || isContent) Uri.parse(originalPath) else Uri.fromFile(File(originalPath))
        context?.let {
            UCrop.of<Uri>(
                uri, Uri.fromFile(
                    File(it.cacheDir, "${System.currentTimeMillis()}.jpg")
                )
            ).withOptions(options).start(it, this)
        }
    }

    private var mBottomSheetDialog: BottomSheetDialog? = null

    private fun initBottomSheet() {
        context?.let {
            if (mBottomSheetDialog == null) {
                mBottomSheetDialog = BottomSheetDialog(it)
                val view = LayoutInflater.from(it)
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
                view.findViewById<AppCompatButton>(com.base.common.R.id.picture_bt)
                    .setOnClickListener {
                        mBottomSheetDialog?.dismiss()
                        PicJumpUtils.jumpMultiChooseAlbumByFragment(
                            this,
                            1,
                            SelectModeConfig.SINGLE,
                            PictureConfig.CHOOSE_REQUEST,
                            false,
                            SelectMimeType.ofImage()
                        )
                    }
                view.findViewById<AppCompatButton>(com.base.common.R.id.btn_cancel)
                    .setOnClickListener {
                        mBottomSheetDialog?.dismiss()
                    }
                mBottomSheetDialog?.setContentView(view)
            }
            mBottomSheetDialog?.show()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == RESULT_OK) {
            when (requestCode) {
                PictureConfig.CHOOSE_REQUEST -> {
                    // 图片选择结果回调
                    takePictureFinish(data)
                }

                PictureConfig.REQUEST_CAMERA -> {
                    // 拍照结果回调
                    takePictureFinish(data)
                }

                UCrop.REQUEST_CROP -> if (data != null) {
                    val resultUri = UCrop.getOutput(data)
                    if (resultUri != null) {
                        val cutPath = resultUri.path
                        cutPath?.let {
                            val file = File(it)
                            val requestFile =
                                RequestBody.create("multipart/form-data".toMediaTypeOrNull(), file)
                            val body =
                                MultipartBody.Part.createFormData("file", file.name, requestFile)
                            getViewModel().editAvatar(body)
                        }
                    }
                }
            }
        } else if (resultCode == UCrop.RESULT_ERROR) {
            if (data != null) {
                Log.d("xxxxx", "error: ${UCrop.getError(data)}")
            }
        }
    }
}