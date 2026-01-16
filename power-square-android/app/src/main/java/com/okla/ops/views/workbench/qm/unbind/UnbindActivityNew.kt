//package com.okla.ops.views.workbench.qm.unbind
//
//import android.content.Context
//import android.content.DialogInterface
//import android.content.Intent
//import android.os.Bundle
//import android.text.TextUtils
//import android.view.View
//import androidx.core.content.ContextCompat
//import androidx.lifecycle.Observer
//import androidx.lifecycle.ViewModelProvider
//import com.base.common.base.mvvm.BaseNormalVActivity
//import com.base.common.dialog.CustomDialog
//import com.base.common.utils.StatusBarUtil
//import com.base.common.utils.ToastUtils
//import com.google.zxing.integration.android.IntentIntegrator
//import com.okla.ops.R
//import com.okla.ops.beans.DeviceTypeObject
//import com.okla.ops.custom.ScanOrInputComplexNewView
//import com.okla.ops.custom.ScanOrInputView
//import com.okla.ops.databinding.ActivityUnbindNewBinding
//import com.okla.ops.views.workbench.QRCodeActivity
//import io.reactivex.android.schedulers.AndroidSchedulers
//import io.reactivex.disposables.Disposable
//import io.reactivex.subjects.PublishSubject
//import java.util.concurrent.TimeUnit
//
///**
// * @Date: 2021/8/13 17:46
// * @Author: Craz
// * @Description:
// * @Version:
// */
//class UnbindActivityNew : BaseNormalVActivity<UnbindViewModel, ActivityUnbindNewBinding>(),
//    View.OnClickListener {
//    var isHaveUnFinishCarOrder = false;
//    var appointmentNo = "";
//
//    // 定义一个 PublishSubject 发射两个输入框的值，使用 Pair<String, String>
//    private val formInputSubject = PublishSubject.create<Pair<String, String>>()
//    private var inputDispose: Disposable? = null
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        StatusBarUtil.transparencyBar(this)
//        StatusBarUtil.StatusBarLightMode(this)
//    }
//
//    companion object {
//        fun getIntents(context: Context) {
//            var intent = Intent(context, UnbindActivityNew::class.java)
//            context.startActivity(intent)
//        }
//
//        fun getIntents(context: Context, type: Int) {
//            var intent = Intent(context, UnbindActivityNew::class.java)
//            intent.putExtra("type", type)
//            context.startActivity(intent)
//        }
//
//        fun getIntents(
//            context: Context,
//            type: Int,
//            cardNum: String,
//            device: ArrayList<String>
//        ) {
//            var intent = Intent(context, UnbindActivityNew::class.java)
//            intent.putExtra("type", type)
//            intent.putExtra("cardNum", cardNum)
//            intent.putStringArrayListExtra("device", device)
//            context.startActivity(intent)
//        }
//    }
//
//
//    override fun getLayoutId(): Int {
//        return R.layout.activity_unbind_new;
//    }
//
//    override fun onCreateViewModel(): UnbindViewModel {
//        return ViewModelProvider(this).get(UnbindViewModel::class.java);
//    }
//
////    override fun isInitImmersionBar(): Boolean {
////        return false
////    }
//
//    private var mType = 0
//
//    override fun initViews(savedInstanceState: Bundle?) {
//        super.initViews(savedInstanceState);
//        initObserver();
//        initClicks();
//        initData()
//        mType = intent.getIntExtra("type", 0) ?: 0
//        mUserId = intent.getStringExtra("cardNum").toString()
//        if (TextUtils.equals(mUserId, "null")) {
//            mUserId = ""
//        }
//        mBinding.sivUserID.setScanOrInputValue(mUserId)
//        val arrayList = intent.getStringArrayListExtra("device")
//        if (mType == DeviceTypeObject.TYPE_VEHICLE) {
//            mBinding.tvStationTitle.text = getString(R.string.workbench_vehicle_unbind)
//            mBinding.ivStationIcon.setImageDrawable(
//                ContextCompat.getDrawable(
//                    this,
//                    R.mipmap.icon_unbind_car
//                )
//            )
//            mBinding.sivBatterySn.visibility = View.GONE
//            mBinding.sivCenterControlSn.visibility = View.VISIBLE
//            if (arrayList != null) {
//                for (i in arrayList.indices) {
//                    if (i == 0) {
//                        mCenterControlSn = arrayList[i]
//                        mBinding.sivCenterControlSn.setScanOrInputValue(mCenterControlSn)
//                    }
//                }
//            }
//            mBinding.tvCheckTitle.text = getString(R.string.unbind_car_check_status)
//            mBinding.etCheckContent.hint = getString(R.string.unbind_car_check_status_hint)
//        } else if (mType == DeviceTypeObject.TYPE_BATTERY) {
//            mBinding.tvStationTitle.text = getString(R.string.workbench_battery_unbind)
//            mBinding.ivStationIcon.setImageDrawable(
//                ContextCompat.getDrawable(
//                    this,
//                    R.mipmap.icon_unbind_battery
//                )
//            )
//            mBinding.sivBatterySn.visibility = View.VISIBLE
//            mBinding.sivCenterControlSn.visibility = View.GONE
//            if (arrayList != null) {
//                for (i in arrayList.indices) {
//                    val sn = arrayList[i]
//                    if (i == 0) {
//                        mBatterySn = sn
//                    }
//                    if (i == 1) {
//                        mBatterySnSecond = sn
//                    }
//                    if (i == 2) {
//                        mBatterySnThird = sn
//                    }
//                }
//            }
//            mBinding.sivBatterySn.setScanOrInputValue(mBatterySn)
//            if (!TextUtils.isEmpty(mBatterySnSecond) && mBatterySnSecond != "null") {
//                mBinding.sivBatterySn.setBottomVisible(false)
//                mBinding.sivBatterySn.setTopRightTwoVisible(false)
//                mBinding.sivBatterySnSecond.setScanOrInputValue(mBatterySnSecond)
//                mBinding.sivBatterySnSecond.setTopRightTwoVisible(true)
//                mBinding.sivBatterySnSecond.setBottomVisible(false)
//                mBinding.sivBatterySnSecond.visibility = View.VISIBLE
//            }
//            if (!TextUtils.isEmpty(mBatterySnThird) && mBatterySnThird != "null") {
//                mBinding.sivBatterySn.setBottomVisible(false)
//                mBinding.sivBatterySn.setTopRightTwoVisible(false)
//                mBinding.sivBatterySnThird.setScanOrInputValue(mBatterySnSecond)
//                mBinding.sivBatterySnThird.setTopRightTwoVisible(true)
//                mBinding.sivBatterySnThird.setBottomVisible(false)
//                mBinding.sivBatterySnThird.visibility = View.VISIBLE
//            }
//            mBinding.tvCheckTitle.text = getString(R.string.unbind_battery_check_status)
//            mBinding.etCheckContent.hint = getString(R.string.unbind_battery_check_status_hint)
//        }
//        mBinding.sivUserID.setScanOrInputEnableState(true)
//    }
//
//    private fun initData() {
//        mBinding.feedbackReasons.setReasonTitleAndHint(
//            getString(R.string.unbind_reasons),
//            getString(R.string.unbind_reasons_hint)
//        )
//        mBinding.feedbackReasons.initCommonReasons(mBinding.feedbackReasons.unbindReasons)
//    }
//
//    var isUserIDClick: Boolean = false
//    var isBatterySnClick: Boolean = false
//    var isBatterySnSecondClick: Boolean = false
//    var isBatterySnThirdClick: Boolean = false
//    var isCenterControlClick: Boolean = false
//    var mUserId: String = ""
//    var mUserToken: String = ""
//    var mBatterySn: String = ""
//    var mBatterySnSecond: String = ""
//    var mBatterySnThird: String = ""
//    var mCenterControlSn: String = ""
//    var mContentSn: String = ""
//    var isBatterBind: Boolean = true
//    var isScooterBind: Boolean = true
//
//    fun initClicks() {
//        mBinding.ivBack.setOnClickListener(this)
//        mBinding.tvConfirm.setOnClickListener(this)
//        mBinding.sivUserID.setListener(object : ScanOrInputView.OnClickListerner {
//            override fun onClickListen() {
//                isBatterySnClick = false
//                isCenterControlClick = false
//                isUserIDClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mUserId = str
//                enableBtnConfirm()
//                // 将输入变化推送给 PublishSubject
//                formInputSubject.onNext(Pair(str, mCenterControlSn))
//            }
//        })
//        mBinding.sivBatterySn.setListener(object : ScanOrInputComplexNewView.OnClickListerner {
//            override fun onClickListen() {
//                isUserIDClick = false
//                isCenterControlClick = false
//                isBatterySnClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mBatterySn = str
//                enableBtnConfirm()
//            }
//
//            override fun onTextViewClickListern(position: Int) {
//                when (position) {
//                    0 -> {
//                        mBinding.sivBatterySn.setBottomVisible(false)
//                        mBinding.sivBatterySn.setTopRightTwoVisible(false)
//                        mBinding.sivBatterySnSecond.setTopRightTwoVisible(true)
//                        mBinding.sivBatterySnSecond.setBottomVisible(false)
//                        mBinding.sivBatterySnSecond.visibility = View.VISIBLE
//                    }
//                }
//            }
//        })
//        mBinding.sivBatterySnSecond.setListener(object :
//            ScanOrInputComplexNewView.OnClickListerner {
//            override fun onClickListen() {
//                isUserIDClick = false
//                isCenterControlClick = false
//                isBatterySnClick = false
//                isBatterySnSecondClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mBatterySnSecond = str
//                enableBtnConfirm()
//            }
//
//            override fun onTextViewClickListern(position: Int) {
//                when (position) {
//                    1 -> {//减
//                        mBinding.sivBatterySnSecond.visibility = View.GONE
//                        mBinding.sivBatterySnSecond.setScanOrInputValue("")
//                        mBinding.sivBatterySn.setBottomVisible(true)
//                        mBinding.sivBatterySn.setTopRightTwoVisible(false)
//                    }
//
//                    0 -> {
//                        mBinding.sivBatterySn.setBottomVisible(false)
//                        mBinding.sivBatterySn.setTopRightTwoVisible(false)
//                        mBinding.sivBatterySnSecond.setBottomVisible(false)
//                        mBinding.sivBatterySnSecond.setTopRightTwoVisible(false)
//                        mBinding.sivBatterySnThird.setTopRightTwoVisible(true)
//                        mBinding.sivBatterySnThird.setBottomVisible(false)
//                        mBinding.sivBatterySnThird.visibility = View.VISIBLE
//                    }
//                }
//            }
//        })
//        mBinding.sivBatterySnThird.setListener(object : ScanOrInputComplexNewView.OnClickListerner {
//            override fun onClickListen() {
//                isUserIDClick = false
//                isBatterySnClick = false
//                isBatterySnSecondClick = false
//                isBatterySnThirdClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mBatterySnThird = str
//            }
//
//            override fun onTextViewClickListern(position: Int) {
//                when (position) {
//                    1 -> {
//                        mBinding.sivBatterySnThird.visibility = View.GONE
//                        mBinding.sivBatterySnThird.setScanOrInputValue("")
//                        mBinding.sivBatterySnSecond.setBottomVisible(true)
//                        mBinding.sivBatterySnSecond.setTopRightTwoVisible(true)
//                        mBinding.sivBatterySn.setBottomVisible(false)
//                        mBinding.sivBatterySn.setTopRightTwoVisible(false)
//                    }
//                }
//            }
//        })
//        mBinding.sivCenterControlSn.setListener(object : ScanOrInputView.OnClickListerner {
//            override fun onClickListen() {
//                isCenterControlClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mCenterControlSn = str
//                enableBtnConfirm()
//                // 将输入变化推送给 PublishSubject
//                formInputSubject.onNext(Pair(mUserId, str))
//            }
//
//        })
//    }
//
//    private fun GetUnFinishedCarOder() {
//        if (checkCanGetUnFinishedCarOder()) {
//            getViewModel().checkExistUnCompletedCarOrder(mUserId, mCenterControlSn)
//        }
//    }
//
//    private fun checkCanGetUnFinishedCarOder(): Boolean {
//        if (!TextUtils.isEmpty(mUserId) && !TextUtils.isEmpty(mCenterControlSn)) {
//            return true;
//        } else {
//            return false;
//        }
//    }
//
//    private fun initializeScan(type: Int) {
//        IntentIntegrator(this)
//            .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
//            .setOrientationLocked(false)
//            .setCaptureActivity(QRCodeActivity::class.java) // 设置自定义的activity是CustomActivity
//            .initiateScan() //  初始化扫描
//    }
//
//    fun initObserver() {
//        getViewModel().unBindData.observe(this, Observer<String> {
//            ToastUtils.showShort(getString(R.string.cc_str_success))
//            mBinding.sivUserID.setScanOrInputValue("")
//            mBinding.sivBatterySn.setScanOrInputValue("")
//            mBinding.sivBatterySnSecond.setScanOrInputValue("")
//            mBinding.sivBatterySnThird.setScanOrInputValue("")
//            mBinding.sivCenterControlSn.setScanOrInputValue("")
//            mBinding.etCheckContent.setText("")
//            mBinding.feedbackReasons.clearFeedbackReasons()
//        })
//        getViewModel().mGetDeviceSn.observe(this, Observer<String> {
//            if (isBatterySnClick) {
//                isBatterySnClick = false
//                mBatterySn = it;
//                mBinding.sivBatterySn.setScanOrInputValue(mBatterySn)
//            } else if (isBatterySnSecondClick) {
//                isBatterySnSecondClick = false
//                mBatterySnSecond = it
//                mBinding.sivBatterySnSecond.setScanOrInputValue(mBatterySnSecond)
//            } else if (isBatterySnThirdClick) {
//                isBatterySnThirdClick = false
//                mBatterySnThird = it
//                mBinding.sivBatterySnThird.setScanOrInputValue(mBatterySnThird)
//            } else if (isCenterControlClick) {
//                isCenterControlClick = false
//                mCenterControlSn = it
//                mBinding.sivCenterControlSn.setScanOrInputValue(mCenterControlSn)
//            }
//            getLoading().onFinish()
//        })
//        // 设置订阅，防抖处理
//        inputDispose = formInputSubject
//            .debounce(1200, TimeUnit.MILLISECONDS)
//            .observeOn(AndroidSchedulers.mainThread())
//            .subscribe { pair ->
//                val (str1, str2) = pair
//                // 这里可以同时处理两个输入框的数据
//                mUserId = str1
//                mCenterControlSn = str2;
//                GetUnFinishedCarOder()
//            }
//        getViewModel().unCompletedCarOrderData.observe(this, {
//            if (it.trim().isNotBlank()) {
//                appointmentNo = it;
//                isHaveUnFinishCarOrder = true;
//            } else {
//                isHaveUnFinishCarOrder = false;
//            }
//        })
//    }
//
//    private fun enableBtnConfirm() {
//        if (mType == DeviceTypeObject.TYPE_VEHICLE) {
//            if (!TextUtils.isEmpty(mUserId) && !TextUtils.isEmpty(mCenterControlSn)) {
//                mBinding.tvConfirm.isEnabled = true
//            } else {
//                mBinding.tvConfirm.isEnabled = false
//            }
//        } else {
//            if (!TextUtils.isEmpty(mUserId) && (!TextUtils.isEmpty(mBatterySn) || !TextUtils.isEmpty(
//                    mBatterySnSecond
//                ))
//            ) {
//                mBinding.tvConfirm.isEnabled = true
//            } else {
//                mBinding.tvConfirm.isEnabled = false
//            }
//        }
//    }
//
//    override fun onClick(v: View) {
//        when (v.id) {
//            R.id.ivBack -> {
//                finish()
//            }
//
//            R.id.tvConfirm -> {
//                if (TextUtils.isEmpty(mUserId)) {
//                    ToastUtils.showShort(getString(R.string.bind_device_scan_user_id_or_qr_tip))
//                    return
//                }
//                if (TextUtils.isEmpty(mBatterySn) && TextUtils.isEmpty(mCenterControlSn)) {
//                    ToastUtils.showShort(getString(R.string.device_search_input_tip))
//                    return
//                }
//                val checkRemark: String
//                if (mType == DeviceTypeObject.TYPE_VEHICLE) {
//                    checkRemark = mBinding.etCheckContent.text.toString()
//                    if (TextUtils.isEmpty(checkRemark)) {
//                        ToastUtils.showShort(getString(R.string.unbind_car_check_status_hint))
//                        return
//                    }
//                } else {
//                    checkRemark = mBinding.etCheckContent.text.toString()
//                    if (TextUtils.isEmpty(checkRemark)) {
//                        ToastUtils.showShort(getString(R.string.unbind_battery_check_status_hint))
//                        return
//                    }
//                }
//                val remark = mBinding.feedbackReasons.getFeedbackReasons()
//                if (TextUtils.isEmpty(remark)) {
//                    ToastUtils.showShort(getString(R.string.bind_device_remark_tip))
//                    return
//                }
//                if (mType == DeviceTypeObject.TYPE_VEHICLE) {
//                    if (isHaveUnFinishCarOrder) {
//                        val builder = CustomDialog.Builder(
//                            activity
//                        )
//                            .setMessage(getString(R.string.tip_unbind_car_has_unfinished_service))
//                            .setNegativeButton { dialog: DialogInterface, which: Int -> dialog.dismiss() }
//                            .setPositiveButton { dialog: DialogInterface, which: Int ->
//                                dialog.dismiss()
//                                getViewModel().unBindCar(
//                                    mUserId,
//                                    mCenterControlSn,
//                                    remark,
//                                    checkRemark,
//                                    appointmentNo
//                                )
//                            }
//                        builder.create().show()
//                    } else {
//                        getViewModel().unBindCar(
//                            mUserId,
//                            mCenterControlSn,
//                            remark,
//                            checkRemark,
//                            ""
//                        );
//                    }
//                } else if (mType == DeviceTypeObject.TYPE_BATTERY) {
//
//                    var batteryArray: Array<String>? = null
//                    if (!TextUtils.isEmpty(mBatterySn) && !TextUtils.isEmpty(mBatterySnSecond)
//                        && !TextUtils.isEmpty(mBatterySnThird)
//                    ) {//1,2,3
//                        batteryArray = arrayOf(mBatterySn, mBatterySnSecond, mBatterySnThird)
//                    } else if (!TextUtils.isEmpty(mBatterySn) && !TextUtils.isEmpty(
//                            mBatterySnSecond
//                        )
//                    ) {//1,2
//                        batteryArray = arrayOf(mBatterySn, mBatterySnSecond)
//                    } else if (!TextUtils.isEmpty(mBatterySn) && !TextUtils.isEmpty(
//                            mBatterySnThird
//                        )
//                    ) {//1,3
//                        batteryArray = arrayOf(mBatterySn, mBatterySnThird)
//                    } else if (!TextUtils.isEmpty(mBatterySnSecond) && !TextUtils.isEmpty(
//                            mBatterySnThird
//                        )
//                    ) {//2,3
//                        batteryArray = arrayOf(mBatterySnSecond, mBatterySnThird)
//                    } else if (!TextUtils.isEmpty(mBatterySn)) {//1
//                        batteryArray = arrayOf(mBatterySn)
//                    } else if (!TextUtils.isEmpty(mBatterySnSecond)) {//2
//                        batteryArray = arrayOf(mBatterySnSecond)
//                    } else if (!TextUtils.isEmpty(mBatterySnThird)) {//3
//                        batteryArray = arrayOf(mBatterySnThird)
//                    }
//                    getViewModel().unBindBattery(
//                        batteryArray ?: arrayOf(),
//                        mUserId,
//                        remark,
//                        checkRemark
//                    )
//                }
//
//            }
//        }
//    }
//
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//        if (requestCode == IntentIntegrator.REQUEST_CODE) {
//            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
//            var mScanedMessage = intentResult?.contents ?: null
//            mScanedMessage?.run {
//                if (isUserIDClick) {
//                    isUserIDClick = false
//                    if (contains("cardNum")) {
//                        val index = indexOf("cardNum=")
//                        if (index > -1) {
//                            mUserId = this.substring(index + 8);
//                            mBinding.sivUserID.setScanOrInputValue(mUserId)
//                        }
//                    }
//                } else if (isBatterySnClick) {
//                    isBatterySnClick = false
//                    if (contains("sn=")) {
//                        //正常扫描换电
//                        val index = indexOf("sn=")
//                        if (index > -1) {
//                            mBatterySn = substring(index + 3)
//                            mBinding.sivBatterySn.setScanOrInputValue(mBatterySn)
//                        }
//                    } else if (!TextUtils.isEmpty(mScanedMessage)) {
//                        getLoading().onStart()
//                        isBatterySnClick = true
//                        getViewModel().getDeviceSn(0, mScanedMessage)
//                    } else {
//                        mBatterySn = this
//                        mBinding.sivBatterySn.setScanOrInputValue(mBatterySn)
//                    }
//                } else if (isBatterySnSecondClick) {
//                    isBatterySnSecondClick = false
//                    if (contains("sn=")) {
//                        //正常扫描换电
//                        val index = indexOf("sn=")
//                        if (index > -1) {
//                            mBatterySnSecond = substring(index + 3)
//                            mBinding.sivBatterySnSecond.setScanOrInputValue(mBatterySnSecond)
//                        }
//                    } else if (!TextUtils.isEmpty(mScanedMessage)) {
//                        getLoading().onStart()
//                        isBatterySnSecondClick = true
//                        getViewModel().getDeviceSn(0, mScanedMessage)
//                    } else {
//                        mBatterySnSecond = this
//                        mBinding.sivBatterySnSecond.setScanOrInputValue(mBatterySnSecond)
//                    }
//                } else if (isBatterySnThirdClick) {
//                    isBatterySnThirdClick = false
//                    if (contains("sn=")) {
//                        //正常扫描换电
//                        val index = indexOf("sn=")
//                        if (index > -1) {
//                            mBatterySnThird = substring(index + 3)
//                            mBinding.sivBatterySnThird.setScanOrInputValue(mBatterySnThird)
//                        }
//                    } else if (!TextUtils.isEmpty(mScanedMessage)) {
//                        getLoading().onStart()
//                        isBatterySnThirdClick = true
//                        getViewModel().getDeviceSn(0, mScanedMessage)
//                    } else {
//                        mBatterySnThird = this
//                        mBinding.sivBatterySnThird.setScanOrInputValue(mBatterySnThird)
//                    }
//                } else if (isCenterControlClick) {
//                    isCenterControlClick = false
//                    if (contains("sn=")) {
//                        //正常扫描换电
//                        val index = indexOf("sn=")
//                        if (index > -1) {
//                            mCenterControlSn = substring(index + 3)
//                            mBinding.sivCenterControlSn.setScanOrInputValue(mCenterControlSn)
//                        }
//                    } else if (!TextUtils.isEmpty(mScanedMessage)) {
//                        getLoading().onStart()
//                        isCenterControlClick = true
//                        getViewModel().getDeviceSn(2, mScanedMessage)
//                    } else {
//                        mCenterControlSn = this
//                        mBinding.sivCenterControlSn.setScanOrInputValue(mCenterControlSn)
//                    }
//                }
//            }
//        }
//    }
//
//    override fun onDestroy() {
//        inputDispose?.dispose()
//        inputDispose = null
//        super.onDestroy()
//    }
//}
