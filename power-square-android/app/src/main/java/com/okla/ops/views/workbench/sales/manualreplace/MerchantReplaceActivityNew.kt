package com.okla.ops.views.workbench.sales.manualreplace

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.View
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.base.common.utils.WindowInsetsHelper
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.custom.ScanOrInputView
import com.okla.ops.databinding.ActivityMerchantReplaceNewBinding
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.QRCodeActivity

class MerchantReplaceActivityNew :
    BaseNormalVActivity<ManualReplaceViewModel, ActivityMerchantReplaceNewBinding>(),
    View.OnClickListener {

    companion object {
        fun getIntents(context: Context) {
            context.startActivity(Intent(context, MerchantReplaceActivityNew::class.java))
        }
    }

    override fun onCreateViewModel(): ManualReplaceViewModel {
        return ViewModelProvider(this).get(ManualReplaceViewModel::class.java);
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_merchant_replace_new;
    }


    private fun initializeScan(type: Int) {
        IntentIntegrator(this)
            .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
            .setOrientationLocked(false)
            .setCaptureActivity(QRCodeActivity::class.java) // 设置自定义的activity是CustomActivity
            .initiateScan() //  初始化扫描
    }

    var isUserIDClick: Boolean = false
    var boolBatterySN: Boolean = false
    var boolBatteryNewSN: Boolean = false
    var mUserId: String = ""
    var mBatterySN: String = ""
    var mBatteryNewSN: String = ""

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        WindowInsetsHelper.applyForBottom(mBinding.llBottom)
        initObserver();
        initClicks()
        mBinding.sivUserID.setScanOrInputEnableState(true)
    }

    fun initObserver() {
//        getViewModel().mGetDeviceSn.observe(this, Observer<String> {
//            if (boolBatterySN) {
//                boolBatterySN = false
//                mBatterySN = it;
//                mBinding.sivBatterySN.setScanOrInputValue(mBatterySN)
//            } else if (boolBatteryNewSN) {
//                boolBatteryNewSN = false
//                mBatteryNewSN = it
//                mBinding.sivBatteryNewSN.setScanOrInputValue(mBatteryNewSN)
//            }
//            getLoading().onFinish()
//        })
        getViewModel().manualReplaceData.observe(this, Observer<String> {
            if (it.equals("success")) {
                ToastUtils.showShort(mContext.getString(R.string.str_replace_success))
                mBinding.sivUserID.setScanOrInputValue("")
                mBinding.sivBatterySN.setScanOrInputValue("")
                mBinding.sivBatteryNewSN.setScanOrInputValue("")
                mBinding.etreason.setText("")
                mBinding.tvConfirm.isEnabled= false
            }
        })
    }

    fun initClicks() {
        mBinding.ivBack.setOnClickListener(this)
        mBinding.tvConfirm.setOnClickListener(this)
        mBinding.sivUserID.setListener(object : ScanOrInputView.OnClickListerner {
            override fun onClickListen() {
                boolBatteryNewSN = false
                boolBatterySN = false
                isUserIDClick = true
                initializeScan(QRCodeActivity.NORMAL)
            }

            override fun afterTextChanged(str: String) {
                mUserId = str.trim()
                btnConfirmEnable()

            }
        })
        mBinding.sivBatterySN.setListener(object : ScanOrInputView.OnClickListerner {
            override fun onClickListen() {
                boolBatteryNewSN = false
                boolBatterySN = true
                isUserIDClick = false
                initializeScan(QRCodeActivity.NORMAL)
            }

            override fun afterTextChanged(str: String) {
                mBatterySN = str.trim()
                btnConfirmEnable()

            }
        })
        mBinding.sivBatteryNewSN.setListener(object : ScanOrInputView.OnClickListerner {
            override fun onClickListen() {
                boolBatterySN = false
                boolBatteryNewSN = true
                isUserIDClick = false
                initializeScan(QRCodeActivity.NORMAL)
            }

            override fun afterTextChanged(str: String) {
                mBatteryNewSN = str.trim()
                btnConfirmEnable()
            }
        })
        mBinding.etreason.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

            override fun afterTextChanged(s: Editable?) {
                btnConfirmEnable()
            }
        })
    }

    private fun btnConfirmEnable() {
        if (!TextUtils.isEmpty(mUserId) && !TextUtils.isEmpty(mBatterySN) && !TextUtils.isEmpty(
                mBatteryNewSN
            )
            && !TextUtils.isEmpty(mBinding.etreason.text.toString())
        ) {
            mBinding.tvConfirm.isEnabled = true
        } else {
            mBinding.tvConfirm.isEnabled = false

        }
    }

    override fun onClick(v: View) {
        when (v.id) {
            R.id.ivBack -> {
                finish()
            }

            R.id.tvConfirm -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                if (mBatterySN.equals(mBatteryNewSN)) {
                    ToastUtils.showShort(mContext.getString(R.string.tip_newbattery_cannot_same_old))
                    return
                }
                val reason = mBinding.etreason.text.toString()
                getViewModel().manualReplace(mBatterySN, mBatteryNewSN, mUserId, reason)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val parseActivityResult =
                IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            val mScanedMessage = parseActivityResult?.contents ?: ""
            mScanedMessage.run {
                if (isUserIDClick) {
                    isUserIDClick = false
                    mUserId = ScanUtils.getUserCarNum(mContext,this)
                    mBinding.sivUserID.setScanOrInputValue(mUserId)
                } else if (boolBatterySN) {
                    boolBatterySN = false
                    mBatterySN = ScanUtils.getDeviceSn(mContext,this)
                    mBinding.sivBatterySN.setScanOrInputValue(mBatterySN)
                }
                if (boolBatteryNewSN) {
                    boolBatteryNewSN = false
                    mBatteryNewSN = ScanUtils.getDeviceSn(mContext,this)
                    mBinding.sivBatteryNewSN.setScanOrInputValue(mBatteryNewSN)
                }
            }
        }
    }

}