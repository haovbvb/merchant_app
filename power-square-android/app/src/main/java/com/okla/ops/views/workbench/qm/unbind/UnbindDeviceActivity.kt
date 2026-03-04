package com.okla.ops.views.workbench.qm.unbind

import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.View
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.dialog.CustomDialog
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.base.common.utils.WindowInsetsHelper
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.custom.FeedbackReasonsView
import com.okla.ops.custom.ScanOrInputView
import com.okla.ops.databinding.ActUnbindDeviceBinding
import com.okla.ops.utils.ScanUtils
import com.okla.ops.views.workbench.QRCodeActivity
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.subjects.PublishSubject
import java.util.concurrent.TimeUnit

/**
 * 解绑设备(车辆 电池)
 */
class UnbindDeviceActivity : BaseNormalVActivity<UnbindViewModel, ActUnbindDeviceBinding>(),
    View.OnClickListener {
    var isHaveUnFinishCarOrder = false;
    var appointmentNo = "";

    // 定义一个 PublishSubject 发射两个输入框的值，使用 Pair<String, String>
    private val formInputSubject = PublishSubject.create<Pair<String, String>>()
    private var inputDispose: Disposable? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
    }

    companion object {
        fun getIntents(context: Context) {
            var intent = Intent(context, UnbindDeviceActivity::class.java)
            context.startActivity(intent)
        }
    }


    override fun getLayoutId(): Int {
        return R.layout.act_unbind_device;
    }

    override fun onCreateViewModel(): UnbindViewModel {
        return ViewModelProvider(this).get(UnbindViewModel::class.java);
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState);
        WindowInsetsHelper.applyForBottom(mBinding.llBottom)
        initObserver();
        initClicks();
        initData()

    }

    private fun initData() {
        mBinding.feedbackReasons.setReasonTitleAndHint(
            getString(R.string.unbind_reasons),
            getString(R.string.unbind_reasons_hint)
        )
        val reasons: MutableList<String> = ArrayList()
        reasons.add(getString(R.string.stop_cabinet_unshelve_common_reasons_1))
        reasons.add(getString(R.string.stop_cabinet_unshelve_common_reasons_2))
        reasons.add(getString(R.string.stop_cabinet_unshelve_common_reasons_3))
        mBinding.feedbackReasons.initCommonReasons(reasons)
    }

    var isUserIDClick: Boolean = false
    var isDeviceSnClick: Boolean = false
    var mUserId: String = ""
    var mDeviceSnStr: String = ""
    fun initClicks() {
        mBinding.ivBack.setOnClickListener(this)
        mBinding.tvConfirm.setOnClickListener(this)
        mBinding.sivUserID.setListener(object : ScanOrInputView.OnClickListerner {
            override fun onClickListen() {
                isDeviceSnClick = false
                isUserIDClick = true
                initializeScan(QRCodeActivity.NORMAL)
            }

            override fun afterTextChanged(str: String) {
                mUserId = str
                enableBtnConfirm()
                if (!TextUtils.isEmpty(mDeviceSnStr)) {
                    // 将输入变化推送给 PublishSubject
                    formInputSubject.onNext(Pair(str, mDeviceSnStr))
                }
            }
        })

        mBinding.deviceSn.setListener(object : ScanOrInputView.OnClickListerner {
            override fun onClickListen() {
                isDeviceSnClick = true
                initializeScan(QRCodeActivity.NORMAL)
            }

            override fun afterTextChanged(str: String) {
                mDeviceSnStr = str
                enableBtnConfirm()
                // 将输入变化推送给 PublishSubject
                formInputSubject.onNext(Pair(mUserId, str))
            }

        })
        mBinding.etCheckContent.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

            override fun afterTextChanged(s: Editable?) {
                checkRemark= mBinding.etCheckContent.text.toString()
                enableBtnConfirm()
            }
        })
        mBinding.feedbackReasons.setOnTextInputListener(object :FeedbackReasonsView.OnTextInputListener{
            override fun onTextInputed(content: String) {
                remark = content?:""
                enableBtnConfirm()
            }
        })
    }

    private var checkRemark=""
    private var remark=""

    private fun GetUnFinishedCarOder() {
        if (checkCanGetUnFinishedCarOder()) {
            getViewModel().checkExistUnCompletedCarOrder(mUserId, mDeviceSnStr)
        }
    }

    private fun checkCanGetUnFinishedCarOder(): Boolean {
        if (!TextUtils.isEmpty(mUserId) && !TextUtils.isEmpty(mDeviceSnStr)) {
            return true;
        } else {
            return false;
        }
    }

    private fun initializeScan(type: Int) {
        IntentIntegrator(this)
            .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
            .setOrientationLocked(false)
            .setCaptureActivity(QRCodeActivity::class.java) // 设置自定义的activity是CustomActivity
            .initiateScan() //  初始化扫描
    }

    fun initObserver() {
        getViewModel().unBindDeviceLiveData.observe(this, Observer<Any?> {
            ToastUtils.showShort(getString(R.string.cc_str_success))
            mBinding.sivUserID.setScanOrInputValue("")
            mBinding.deviceSn.setScanOrInputValue("")
            mBinding.etCheckContent.setText("")
            mBinding.feedbackReasons.clearFeedbackReason()
            mBinding.tvConfirm.isEnabled = false
        })
        getViewModel().mGetDeviceSn.observe(this, Observer<String> {
            if (isDeviceSnClick) {
                isDeviceSnClick = false
                mDeviceSnStr = it
                mBinding.deviceSn.setScanOrInputValue(mDeviceSnStr)
            }
            getLoading().onFinish()
        })
        // 设置订阅，防抖处理
        inputDispose = formInputSubject
            .debounce(1200, TimeUnit.MILLISECONDS)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { pair ->
                val (str1, str2) = pair
                // 这里可以同时处理两个输入框的数据
                mUserId = str1
                mDeviceSnStr = str2;
                GetUnFinishedCarOder()
            }
        getViewModel().unCompletedCarOrderData.observe(this, {
            if (it.trim().isNotBlank()) {
                appointmentNo = it;
                isHaveUnFinishCarOrder = true;
            } else {
                isHaveUnFinishCarOrder = false;
            }
        })
    }

    private fun enableBtnConfirm() {
        if (!TextUtils.isEmpty(mUserId) && !TextUtils.isEmpty(mDeviceSnStr) && !TextUtils.isEmpty(
                checkRemark
            ) && !TextUtils.isEmpty(remark)
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
                if (TextUtils.isEmpty(mUserId)) {
                    ToastUtils.showShort(getString(R.string.bind_device_scan_user_id_or_qr_tip))
                    return
                }
                if (TextUtils.isEmpty(mDeviceSnStr)) {
                    ToastUtils.showShort(getString(R.string.device_search_input_tip))
                    return
                }
                val checkRemark: String
                checkRemark = mBinding.etCheckContent.text.toString()
                if (TextUtils.isEmpty(checkRemark)) {
                    ToastUtils.showShort(getString(R.string.unbind_device_check_status_hint))
                    return
                }
                val remark = mBinding.feedbackReasons.getFeedbackReason()
                if (TextUtils.isEmpty(remark)) {
                    ToastUtils.showShort(getString(R.string.bind_device_remark_tip))
                    return
                }
                if (isHaveUnFinishCarOrder) {
                    val builder = CustomDialog.Builder(
                        activity
                    )
                        .setMessage(getString(R.string.tip_unbind_car_has_unfinished_service))
                        .setNegativeButton { dialog: DialogInterface, which: Int -> dialog.dismiss() }
                        .setPositiveButton { dialog: DialogInterface, which: Int ->
                            dialog.dismiss()
                            getViewModel().unBindDevice(
                                mDeviceSnStr,
                                mUserId,
                                checkRemark,
                                remark?:"",
                            )
                        }
                    builder.create().show()
                } else {
                    getViewModel().unBindDevice(
                        mDeviceSnStr,
                        mUserId,
                        checkRemark,
                        remark?:"",
                    )
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            var mScanedMessage = intentResult?.contents ?: null
            mScanedMessage?.run {
                if (isUserIDClick) {
                    isUserIDClick = false
                    mUserId = ScanUtils.getUserCarNum(mContext,this)
                    mBinding.sivUserID.setScanOrInputValue(mUserId)
                } else if (isDeviceSnClick) {
                    isDeviceSnClick = false
                    mDeviceSnStr = ScanUtils.getDeviceSn(mContext,this)
                    mBinding.deviceSn.setScanOrInputValue(mDeviceSnStr)
                }
            }
        }
    }

    override fun onDestroy() {
        inputDispose?.dispose()
        inputDispose = null
        super.onDestroy()
    }
}
