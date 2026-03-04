package com.okla.ops.views.workbench.sales.offlineregister

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Bundle
import android.text.TextUtils
import android.text.method.HideReturnsTransformationMethod
import android.text.method.PasswordTransformationMethod
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.permission.PermissionManager
import com.base.common.timepicker.CustomDatePicker
import com.base.common.timepicker.DateFormatUtils
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.base.common.utils.MD5Util
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.chad.library.adapter.base.BaseViewHolder
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.AreaCountry
import com.okla.ops.databinding.UserFragmentRegisterBinding
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.TextUtil
import com.okla.ops.views.workbench.QRCodeActivity
import com.orhanobut.logger.Logger
import okhttp3.MultipartBody
import java.util.Calendar

class OfflineUserRegisterActivity :
    BaseNormalVActivity<OfflineUserRegisterViewModel, UserFragmentRegisterBinding>(),
    TextUtil {

    private var areaCode = ""

    companion object {
        fun getIntents(context: Context) {
            context.startActivity(Intent(context, OfflineUserRegisterActivity::class.java))
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
    }

    override fun getLayoutId(): Int {
        return R.layout.user_fragment_register
    }

    override fun onBack() {
        super.onBack()
        activity?.finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        mTimerPicker?.onDestroy()
    }

    override fun onCreateViewModel(): OfflineUserRegisterViewModel {
        return ViewModelProvider(this)[OfflineUserRegisterViewModel::class.java]
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
//        initToolbarAndNavigationBar()
        initObserver()
        initClicks()
        initData()
        initTextListener()
        mBinding.tvTitlePhone.text = textAddStart(mBinding.tvTitlePhone.text.toString())
        mBinding.codeTv.text = textAddStart(mBinding.codeTv.text.toString())
        mBinding.passwordTv.text = textAddStart(mBinding.passwordTv.text.toString())
        mBinding.firstNameTv.text = textAddStart(mBinding.firstNameTv.text.toString())
        mBinding.lastNameTv.text = textAddStart(mBinding.lastNameTv.text.toString())
        mBinding.accountTv.text = textAddStart(mBinding.accountTv.text.toString())
        textFilterBlank(mBinding.passwordEdt)
        textFilterChinese(mBinding.passwordEdt)
        textFilterChinese(mBinding.accountEdt)
    }

//    private fun initToolbarAndNavigationBar() {
//        mBinding.includeTitle.rlContent.setBackgroundColor(
//            ContextCompat.getColor(
//                this,
//                android.R.color.transparent
//            )
//        )
//        mBinding.includeTitle.topTitle.gravity = Gravity.CENTER
//        mBinding.includeTitle.topTitle.typeface = Typeface.DEFAULT_BOLD
//    }

    override fun title(): Int {
        return R.string.title_offline_user_register
    }

    private var mTimerPicker: CustomDatePicker? = null
    private var mBirthday: String = ""

    private fun initTimerPicker() {
        val calendar: Calendar = Calendar.getInstance()
        val currentYear: Int = calendar.get(Calendar.YEAR) - 100
        val local = LanguageUtils.LanguageUtil.getLocalByLanguage()
        val beginTime: Long = DateFormatUtils.str2Long("$currentYear/01/01", false, local)
        val endTime: Long = System.currentTimeMillis()
        if (mTimerPicker == null) {
            mTimerPicker = CustomDatePicker(
                this,
                {
                    if (it > 0) {
                        mBinding.birthdayEdt.text = DateTimeUtils.getTimeString(
                            DateTimeUtils.dateFormat2,
                            it,
                            LanguageUtils.LanguageUtil.getLocalByLanguage()
                        )
                        mBirthday = DateFormatUtils.long2Str(
                            it,
                            false,
                            LanguageUtils.LanguageUtil.getLocalByLanguage()
                        )
                    }

                },
                beginTime,
                endTime,
                local
//                context?.getString(R.string.us_title_select_birthday)
            )
            mTimerPicker?.setCancelable(true)
            mTimerPicker?.setCanShowPreciseTime(false)
            mTimerPicker?.setScrollLoop(true)
            mTimerPicker?.setCanShowAnim(true)
            mTimerPicker?.setOnlyShowDate(true)
        }
        if (!TextUtils.isEmpty(mBirthday)) {
            mTimerPicker?.show(mBirthday)
        } else {
            mTimerPicker?.show(System.currentTimeMillis())
        }
    }

    private var mCountryAreaAdapter: SingleDataBindingNoPUseAdapter<AreaCountry>? = null
    private var mBottomCountryDialog: BottomSheetDialog? = null

    private fun initBottomCountry() {
        if (mBottomCountryDialog == null) {
            mBottomCountryDialog =
                BottomSheetDialog(this, R.style.us_style_bottom_sheet_dialog)
            val view = LayoutInflater.from(this)
                .inflate(R.layout.us_dialog_country_sheet, null, false)
            view.findViewById<AppCompatTextView>(R.id.tv_cancel).setOnClickListener {
                mBottomCountryDialog?.dismiss()
            }
            val recyclerView = view.findViewById<RecyclerView>(R.id.rvCountry)
            recyclerView.layoutManager = LinearLayoutManager(this)
            mCountryAreaAdapter = object :
                SingleDataBindingNoPUseAdapter<AreaCountry>(R.layout.us_item_select_country_area_view) {
                override fun convert(helper: BaseViewHolder, item: AreaCountry) {
                    super.convert(helper, item)
                }
            }
            recyclerView.adapter = mCountryAreaAdapter
            mCountryAreaAdapter?.setNewData(getViewModel().mCountryAreaListLiveData.value)
            mCountryAreaAdapter?.setOnItemClickListener { adapter, _, position ->
                mBottomCountryDialog?.dismiss()
                val areaCountry: AreaCountry = adapter.data[position] as AreaCountry
                getViewModel().setCurrentCountryArea(areaCountry)
            }
            mBottomCountryDialog?.setContentView(view)
            mBottomCountryDialog?.window?.findViewById<FrameLayout>(com.google.android.material.R.id.design_bottom_sheet)
                ?.setBackgroundColor(
                    Color.TRANSPARENT
                )
        }
        mBottomCountryDialog?.show()
    }

    private fun initObserver() {

        getViewModel().mCountryAreaListLiveData.observe(this) {
            if (!it.isNullOrEmpty()) {
                mCountryAreaAdapter?.setNewData(it.toList())
                getViewModel().setCurrentCountryArea(it[0])
                areaCode = it[0].areaCode.toString()
            }
        }

        getViewModel().mSelectedPhoneCountryAreaLiveData.observe(this) {
            areaCode = it?.areaCode.toString()
            mBinding.phoneCodeTv.text = "${it?.countrySimpleName}${it?.areaCode}"
        }

        getViewModel().mPhoneLiveData.observe(this) {
            mBinding.phoneEdt.setText(it)
        }

        getViewModel().mSendSmsLiveData.observe(this) {
            if (it && !mBinding.getCodeBtn.isEnabled) {
                mBinding.getCodeBtn.startTimer()
            } else mBinding.getCodeBtn.isEnabled = true
        }

        getViewModel().mRegisterLiveData.observe(this) {
            if (mBinding.btnConfirm.isEnabled)
                activity?.finish()
        }
    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.img_back -> {
                finish()
            }

            R.id.phoneBtn -> {
                initBottomCountry()
                getViewModel().getCountryAreaList()
            }

            R.id.getCodeBtn -> {
                if (mBinding.phoneEdt.text.toString().isEmpty()) {
                    ToastUtils.showShort(getString(R.string.us_input_phone))
                    return
                }
                if (mBinding.getCodeBtn.isEnabled) {
                    mBinding.getCodeBtn.isEnabled = false
                    getViewModel().sendSms(mBinding.phoneEdt.text.toString(), 1)
                }
            }

            R.id.birthdayEdt -> {
                initTimerPicker()
            }

            R.id.dateIv -> {
                initTimerPicker()
            }

            R.id.scanIv -> {
                val permission = Manifest.permission.CAMERA
                if (hasPermission(permission)) {
                    IntentIntegrator(this@OfflineUserRegisterActivity)
                        .setOrientationLocked(false)
                        .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                        .setCaptureActivity(QRCodeActivity::class.java)
                        .initiateScan() //  初始化扫描
                } else {
                    requestPermissionLauncher.launch(permission)
                }
            }

            R.id.btnConfirm -> {
                hideSoftInput()
                when {
                    mBinding.phoneEdt.text.toString().isEmpty() -> {
                        ToastUtils.showShort(getString(R.string.us_input_phone))
                        return
                    }

                    mBinding.codeEdt.text.toString().isEmpty() -> {
                        ToastUtils.showShort(getString(R.string.us_input_code_number))
                        return
                    }

                    mBinding.passwordEdt.text.toString().isEmpty() -> {
                        ToastUtils.showShort(getString(R.string.us_input_pwd))
                        return
                    }

                    mBinding.passwordEdt.text.toString().length < 8 || mBinding.passwordEdt.text.toString().length > 16 -> {
                        ToastUtils.showShort(getString(R.string.us_tips_input_pwd_length))
                        return
                    }

                    mBinding.firstNameEdt.text.toString().isEmpty() -> {
                        ToastUtils.showShort(getString(R.string.us_hint_input_fist_name))
                        return
                    }

                    mBinding.lastNameEdt.text.toString().isEmpty() -> {
                        ToastUtils.showShort(getString(R.string.us_hint_input_last_name))
                        return
                    }

                    mBinding.accountEdt.text.toString().isEmpty() -> {
                        ToastUtils.showShort(getString(R.string.us_hint_input_account))
                        return
                    }
                }
                mBinding.mailEdt.text.toString().let {
                    if (it.isNotEmpty() && !it.contains("@")) {
                        ToastUtils.showShort(getString(R.string.us_tips_input_correct_mail))
                        return
                    }
                }
                Logger.i("注册")
                val imgList = mutableListOf<MultipartBody.Part>()
                imgList.add(
                    MultipartBody.Part.createFormData(
                        "phone",
                        mBinding.phoneEdt.text.toString()
                    )
                )
                imgList.add(
                    MultipartBody.Part.createFormData(
                        "smsCode",
                        mBinding.codeEdt.text.toString()
                    )
                )
                imgList.add(
                    MultipartBody.Part.createFormData(
                        "password",
                        MD5Util.encode(mBinding.passwordEdt.text)
                            ?: mBinding.passwordEdt.text.toString()
                    )
                )
                imgList.add(
                    MultipartBody.Part.createFormData(
                        "firstName",
                        mBinding.firstNameEdt.text.toString().trimEnd().trimStart()
                    )
                )
                imgList.add(
                    MultipartBody.Part.createFormData(
                        "lastName",
                        mBinding.lastNameEdt.text.toString().trim()
                    )
                )
                if (mBinding.accountEdt.text.toString().isNotEmpty()) {
                    imgList.add(
                        MultipartBody.Part.createFormData(
                            "username",
                            mBinding.accountEdt.text.toString()
                        )
                    )
                }
                if (!TextUtils.isEmpty(mBirthday)) {
                    imgList.add(
                        MultipartBody.Part.createFormData(
                            "birthDay",
                            mBirthday
                        )
                    )
                }
                if (mBinding.mailEdt.text.toString().isNotEmpty()) {
                    imgList.add(
                        MultipartBody.Part.createFormData(
                            "email",
                            mBinding.mailEdt.text.toString().trim()
                        )
                    )
                }
                if (mBinding.referrerEdt.text.toString().isNotEmpty()) {
                    imgList.add(
                        MultipartBody.Part.createFormData(
                            "referId",
                            mBinding.referrerEdt.text.toString().trim()
                        )
                    )
                }
                getViewModel().register(imgList)
            }
        }
    }

    private fun initClicks() {
        mBinding.imgBack.setOnClickListener(this)
        mBinding.getCodeBtn.setOnClickListener(this)
        mBinding.passwordEdt.setOnDrawableEndClick {
            if (mBinding.passwordEdt.isSelected) {
                mBinding.passwordEdt.isSelected = false
                mBinding.passwordEdt.transformationMethod =
                    PasswordTransformationMethod.getInstance()
            } else {
                mBinding.passwordEdt.isSelected = true
                mBinding.passwordEdt.transformationMethod =
                    HideReturnsTransformationMethod.getInstance()
            }
        }
        mBinding.birthdayEdt.setOnClickListener(this)
        mBinding.dateIv.setOnClickListener(this)
        mBinding.phoneBtn.setOnClickListener(this)
        mBinding.btnConfirm.setOnClickListener(this)
        mBinding.scanIv.setOnClickListener(this)
    }

    private fun initData() {
        getViewModel().getCountryAreaList()
    }

    private fun initTextListener() {
        mBinding.phoneEdt.addTextChangedListener(this)
        mBinding.codeEdt.addTextChangedListener(this)
        mBinding.passwordEdt.addTextChangedListener(this)
        mBinding.firstNameEdt.addTextChangedListener(this)
        mBinding.lastNameEdt.addTextChangedListener(this)
        mBinding.accountEdt.addTextChangedListener(this)
        textFilterChinese(mBinding.accountEdt)
    }

    override fun onTextChange(s: CharSequence?) {
        checkInputState()
    }

    private fun checkInputState() {
        mBinding.btnConfirm.isEnabled =
            mBinding.phoneEdt.text.toString().isNotBlank() &&
                    mBinding.codeEdt.text.toString().isNotBlank() &&
                    mBinding.passwordEdt.text.toString().isNotBlank() &&
                    mBinding.firstNameEdt.text.toString().isNotBlank() &&
                    mBinding.lastNameEdt.text.toString().isNotBlank() &&
                    mBinding.accountEdt.text.toString().isNotBlank()
    }

    // 注册权限请求
    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        if (isGranted) {
//            requestScanLauncher.launch(QrCodeUtils.getScanIntent(this))
            IntentIntegrator(this@OfflineUserRegisterActivity)
                .setOrientationLocked(false)
                .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                .setCaptureActivity(QRCodeActivity::class.java)
                .initiateScan() //  初始化扫描
        } else {
            // 权限被拒绝
            PermissionManager.askForPermission(this, "")
        }
    }


    // 检查权限
    private fun hasPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            permission
        ) == PackageManager.PERMISSION_GRANTED
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode != RESULT_OK || data == null) {
            return
        }
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            var scanResult = intentResult?.contents ?: ""
            if (scanResult.matches(ScanUtils.chinesePattern)) {
                ToastUtils.showShort(mContext.getString(R.string.tip_no_chinese))
                return
            }
            if (!TextUtils.isEmpty(scanResult)) {
                if (scanResult.contains("cardNum=")) {
                    val indexOf = scanResult.indexOf("cardNum=")
                    if (indexOf > -1) {
                        scanResult = scanResult.substring(indexOf + 8)
                    }
                }
            }
            mBinding.referrerEdt.setText(scanResult)
        }
    }


}
