package com.okla.ops.views.workbench.qm.unbind//package com.okla.ops.views.workbench.qm.unbind
//
//import android.content.Intent
//import android.os.Bundle
//import android.text.TextUtils
//import android.view.KeyEvent
//import android.view.View
//import androidx.databinding.ViewDataBinding
//import androidx.databinding.library.baseAdapters.BR
//import androidx.lifecycle.Observer
//import androidx.lifecycle.ViewModelProvider
//import androidx.navigation.findNavController
//import com.base.common.base.mvvm.BaseNormalVFragment
//import com.base.common.utils.ToastUtils
//import com.chad.library.adapter.base.BaseViewHolder
//import com.google.android.flexbox.FlexboxLayoutManager
//import com.google.zxing.integration.android.IntentIntegrator
//import com.okla.ops.views.workbench.qm.unbind.UnbindViewModel
//import com.okla.ops.R
//
///**
// * @Date: 2021/8/13 15:30
// * @Author: Craz
// * @Description:
// * @Version:
// */
//class BatteryUnbindFragment : BaseNormalVFragment<UnbindViewModel, FragmentUnbindBatteryBinding>(),
//    View.OnClickListener {
//
//    override fun getLayoutId(): Int {
//        return R.layout.fragment_unbind_battery;
//    }
//
//    fun getInstance(): BatteryUnbindFragment? {
//        val fragment = BatteryUnbindFragment()
//        val bundle = Bundle()
//        fragment.arguments = bundle
//        return fragment
//    }
//
//    override fun onCreateViewModel(): UnbindViewModel {
//        return ViewModelProvider(this).get(UnbindViewModel::class.java);
//    }
//
//    override fun initViews(view: View?, savedInstanceState: Bundle?) {
//        super.initViews(view, savedInstanceState);
//        initObserver()
//        initClicks()
//        setRemarkTip()
//        mBinding.includeTitle.topTitle.setText(R.string.bind_device_battery_unbind)
//
//        if (arguments != null) {
//            if (requireArguments().containsKey("token")) {
//                mUserToken = requireArguments().getString("token").toString()
//            }
//            if (requireArguments().containsKey("cardNum")) {
//                mUserId = requireArguments().getString("cardNum").toString()
//            }
//            if (requireArguments().containsKey("device0")) {
//                mBatterySn = requireArguments().getString("device0").toString()
//            }
//            if (requireArguments().containsKey("device1")) {
//                mBatterySnSecond = requireArguments().getString("device1").toString()
//            }
//            mBinding.sivUserID.setScanOrInputValue(mUserId)
//            mBinding.sivBatterySn.setScanOrInputValue(mBatterySn)
//            if (!TextUtils.isEmpty(mBatterySnSecond) && !mBatterySnSecond.equals("null")) {
//                mBinding.sivBatterySn.setBottomVisible(false)
//                mBinding.sivBatterySn.setTopRightTwoVisible(false)
//                mBinding.sivBatterySnSecond.setScanOrInputValue(mBatterySnSecond)
//                mBinding.sivBatterySnSecond.setTopRightTwoVisible(true)
//                mBinding.sivBatterySnSecond.setBottomVisible(false)
//                mBinding.sivBatterySnSecond.visibility = View.VISIBLE
//            }
//        }
//        mBinding.sivUserID.setScanOrInputEnableState(true)
//    }
//
//    //设置责任人
//    private fun setRemarkTip() {
//        var remarkList = mutableListOf(
//            getString(R.string.bind_device_unbind_reason_battery_example_1),
//            getString(R.string.bind_device_unbind_reason_battery_example_2)
//        )
//        mBinding.rvFlexBox.layoutManager = FlexboxLayoutManager(requireContext())
//        val mFlexBoxAdapter =
//            object : SingleDataBindingNoPUseAdapter<String>(R.layout.item_flexbox_str) {
//                override fun convert(
//                    helper: BaseViewHolder?,
//                    item: String,
//                    viewDataBinding: ViewDataBinding
//                ) {
//                    super.convert(helper, item, viewDataBinding)
//                    viewDataBinding.setVariable(BR.index, data.indexOf(item))
//                }
//            }
//        mFlexBoxAdapter.setOnItemClickListener { adapter, view, position ->
//            if (!TextUtils.isEmpty(mBinding.sivRemark.getScanOrInputValue())) {
//                mBinding.sivRemark.setScanOrInputValue(mBinding.sivRemark.getScanOrInputValue() + "," + adapter.data[position] as String)
//
//            } else {
//                mBinding.sivRemark.setScanOrInputValue(adapter.data[position] as String)
//
//            }
//        }
//        mBinding.rvFlexBox.adapter = mFlexBoxAdapter
//        mFlexBoxAdapter.setNewData(remarkList)
//    }
//
//    var isUserIDClick: Boolean = false
//    var isBatterySnClick: Boolean = false
//    var isBatterySnSecondClick: Boolean = false
//    var mUserId: String = ""
//    var mUserToken: String = ""
//    var mBatterySn: String = ""
//    var mBatterySnSecond: String = ""
//    fun initClicks() {
//        mBinding.includeTitle.topBack.setOnClickListener(this)
//        mBinding.tvConfirm.setOnClickListener(this)
//        mBinding.sivUserID.setListener(object : ScanOrInputView.OnClickListerner {
//            override fun onClickListen() {
//                isBatterySnSecondClick = false
//                isBatterySnClick = false
//                isUserIDClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mUserId = str
//            }
//        })
//        mBinding.sivBatterySn.setListener(object : ScanOrInputComplexView.OnClickListerner {
//            override fun onClickListen() {
//                isUserIDClick = false
//                isBatterySnSecondClick = false
//                isBatterySnClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mBatterySn = str
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
//        mBinding.sivBatterySnSecond.setListener(object : ScanOrInputComplexView.OnClickListerner {
//            override fun onClickListen() {
//                isUserIDClick = false
//                isBatterySnClick = false
//                isBatterySnSecondClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mBatterySnSecond = str
//            }
//
//            override fun onTextViewClickListern(position: Int) {
//                when (position) {
//                    1 -> {
//                        mBinding.sivBatterySnSecond.visibility = View.GONE
//                        mBinding.sivBatterySnSecond.setScanOrInputValue("")
//                        mBinding.sivBatterySn.setBottomVisible(true)
//                        mBinding.sivBatterySn.setTopRightTwoVisible(false)
//                    }
//                }
//            }
//        })
//    }
//
//    private fun initializeScan(type: Int) {
//        IntentIntegrator.forSupportFragment(this)
//            .setOrientationLocked(false)
//            .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
//            .setCaptureActivity(QRCodeActivity::class.java)
//            .initiateScan() //  初始化扫描
//
//    }
//
//    fun initObserver() {
//        getViewModel().unBindData.observe(this, Observer<String> {
//            mBinding.sivUserID.setScanOrInputValue("")
//            mBinding.sivBatterySn.setScanOrInputValue("")
//            mBinding.sivBatterySnSecond.setScanOrInputValue("")
//            mBinding.sivRemark.setScanOrInputValue("")
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
//            }
//            getLoading().onFinish()
//        })
//    }
//
//    override fun onClick(v: View) {
//        when (v.id) {
//            R.id.topBack -> {
//                if (arguments != null) {
//                    activity?.finish()
//                } else {
//                    mBinding.includeTitle.topBack.findNavController().navigateUp()
//                }
//            }
//
//            R.id.tvConfirm -> {
//                if (ViewClickUtils.isFastClick()) {
//                    return
//                }
//                if (TextUtils.isEmpty(mUserId)) {
//                    ToastUtils.showShort(getString(R.string.bind_device_scan_user_id_or_qr_tip))
//                    return
//                }
//                if (TextUtils.isEmpty(mBatterySn)) {
//                    ToastUtils.showShort(getString(R.string.bind_device_scan_battery_sn_or_qr_tip))
//                    return
//                }
//                if (TextUtils.isEmpty(mBinding.sivRemark.getScanOrInputValue())) {
//                    ToastUtils.showShort(getString(R.string.bind_device_remark_tip))
//                    return
//                }
//                var batteryArray: Array<String>? = null
//                if (!TextUtils.isEmpty(mBatterySn) && !TextUtils.isEmpty(mBatterySnSecond) && !mBatterySnSecond.equals(
//                        "null"
//                    )
//                ) {
//                    batteryArray = arrayOf(mBatterySn, mBatterySnSecond)
//                } else if (!TextUtils.isEmpty(mBatterySn)) {
//                    batteryArray = arrayOf(mBatterySn)
//                } else if (!TextUtils.isEmpty(mBatterySnSecond) && !mBatterySnSecond.equals("null")) {
//                    batteryArray = arrayOf(mBatterySnSecond)
//                }
//                batteryArray?.run {
//                    getViewModel().unBindDevice(
//                        mUserToken,
//                        this,
//                        mUserId,
//                        "",
//                        mBinding.sivRemark.getScanOrInputValue(),
//                        ""
//                    )
//                }
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
////                    if (contains("token") && contains("cardNum")) {
////                        var mUserUnbindBean =
////                            GsonUtils.fromGson<UserUnbindBean>(this, UserUnbindBean::class.java)
////                        mUserToken = mUserUnbindBean?.token ?: ""
////                        mUserId = mUserUnbindBean?.cardNum ?: ""
////                        mBinding.sivUserID.setScanOrInputValue(mUserId)
////                    }
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
//                }
//            }
//        }
//    }
//
//    override fun onResume() {
//        super.onResume()
//
//        requireView().isFocusableInTouchMode = true
//        requireView().requestFocus()
//        requireView().setOnKeyListener(View.OnKeyListener { view, i, keyEvent ->
//            if (keyEvent.action === KeyEvent.ACTION_DOWN && i == KeyEvent.KEYCODE_BACK) {
//                if (arguments != null) {
//                    activity?.finish()
//                } else {
//                    mBinding.includeTitle.topBack.findNavController().navigateUp()
//                }
//                return@OnKeyListener true
//            }
//            false
//        })
//    }
//}
