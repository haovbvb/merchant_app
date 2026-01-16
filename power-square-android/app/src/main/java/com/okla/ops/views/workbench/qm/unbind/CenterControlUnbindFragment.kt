package com.okla.ops.views.workbench.qm.unbind//package com.okla.ops.views.home.workbench.bindorunbind
//
//import android.content.DialogInterface
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
//import com.okla.ops.R
//import com.okla.ops.adapters.SingleDataBindingNoPUseAdapter
//import com.okla.ops.custom.ScanOrInputView
//import com.okla.ops.databinding.FragmentUnbindCenterControlBinding
//import com.okla.ops.views.home.workbench.QRCodeActivity
//import io.reactivex.android.schedulers.AndroidSchedulers
//import io.reactivex.disposables.Disposable
//import io.reactivex.subjects.PublishSubject
//import java.util.concurrent.TimeUnit
//
///**
// * @Date: 2021/8/13 17:13
// * @Author: Craz
// * @Description:
// * @Version:
// */
//class CenterControlUnbindFragment :
//    BaseNormalVFragment<UnbindViewModel, FragmentUnbindCenterControlBinding>(),
//    View.OnClickListener {
//    // 定义一个 PublishSubject 发射两个输入框的值，使用 Pair<String, String>
//    private val formInputSubject = PublishSubject.create<Pair<String, String>>()
//    private var inputDispose: Disposable? = null
//    var isHaveUnFinishCarOrder = false;
//    var appointmentNo = "";
//
//    override fun getLayoutId(): Int {
//        return R.layout.fragment_unbind_center_control
//    }
//
//
//    fun getInstance(): CenterControlUnbindFragment? {
//        val fragment = CenterControlUnbindFragment()
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
//        mBinding.includeTitle.topTitle.setText(R.string.bind_device_center_control_unbind)
//
//        if (arguments != null) {
//            if (requireArguments().containsKey("token")) {
//                mUserToken = requireArguments().getString("token").toString()
//            }
//            if (requireArguments().containsKey("cardNum")) {
//                mUserId = requireArguments().getString("cardNum").toString()
//            }
//            if (requireArguments().containsKey("device0")) {
//                mCenterControlSn = requireArguments().getString("device0").toString()
//            }
//
//            mBinding.sivUserID.setScanOrInputValue(mUserId)
//
//            mBinding.sivCenterControlSn.setScanOrInputValue(mCenterControlSn)
//        }
//
//    }
//
//
//    //设置责任人
//    private fun setRemarkTip() {
//        var remarkList = mutableListOf(
//            getString(R.string.bind_device_unbind_reason_control_example_1),
//            getString(R.string.bind_device_unbind_reason_control_example_2),
//            getString(R.string.bind_device_unbind_reason_control_example_3),
//            getString(R.string.bind_device_unbind_reason_control_example_4),
//            getString(R.string.bind_device_unbind_reason_control_example_5)
//        )
//        mBinding.rvFlexBox.layoutManager = FlexboxLayoutManager(requireContext())
//        val mFlexBoxAdapter =
//            object : SingleDataBindingNoPUseAdapter<String>(R.layout.item_flexbox_str) {
//                override fun convert(
//                    helper: BaseViewHolder?,
//                    item: String?,
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
//    var isCenterControlClick: Boolean = false
//    var mUserId: String = ""
//    var mUserToken: String = ""
//    var mCenterControlSn: String = ""
//    fun initClicks() {
//        mBinding.includeTitle.topBack.setOnClickListener(this)
//        mBinding.tvConfirm.setOnClickListener(this)
//        mBinding.sivUserID.setListener(object : ScanOrInputView.OnClickListerner {
//            override fun onClickListen() {
//                isCenterControlClick = false
//                isUserIDClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mUserId = str
//                // 将输入变化推送给 PublishSubject
//                formInputSubject.onNext(Pair(str, mCenterControlSn))
//            }
//        })
//        mBinding.sivCenterControlSn.setListener(object : ScanOrInputView.OnClickListerner {
//            override fun onClickListen() {
//                isUserIDClick = false
//                isCenterControlClick = true
//                initializeScan(QRCodeActivity.NORMAL)
//            }
//
//            override fun afterTextChanged(str: String) {
//                mCenterControlSn = str
//                // 将输入变化推送给 PublishSubject
//                formInputSubject.onNext(Pair(mUserId, str))
//            }
//
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
//            mBinding.sivCenterControlSn.setScanOrInputValue("")
//            mBinding.sivRemark.setScanOrInputValue("")
//        })
//        getViewModel().mGetDeviceSn.observe(this, Observer<String> {
//            if (isCenterControlClick) {
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
//    private fun GetUnFinishedCarOder() {
//        if (checkCanGetUnFinishedCarOder()) {
//            getViewModel().checkExistUnCompletedCarOrder(mUserId, mCenterControlSn)
//        }
//    }
//
//    private fun checkCanGetUnFinishedCarOder(): Boolean {
//        return !TextUtils.isEmpty(mUserId) && !TextUtils.isEmpty(mCenterControlSn)
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
//                if (TextUtils.isEmpty(mUserId)) {
//                    ToastUtils.showShort(getString(R.string.bind_device_scan_user_id_or_qr_tip))
//                    return
//                }
//                if (TextUtils.isEmpty(mCenterControlSn)) {
//                    ToastUtils.showShort(getString(R.string.bind_device_scan_center_control_sn_or_qr_tip))
//                    return
//                }
//                if (isHaveUnFinishCarOrder) {
//                    val builder = com.okla.ops.dialog.CustomDialog.Builder(
//                        activity
//                    )
//                        .setMessage(getString(R.string.tip_unbind_car_has_unfinished_service))
//                        .setNegativeButton { dialog: DialogInterface, which: Int -> dialog.dismiss() }
//                        .setPositiveButton { dialog: DialogInterface, which: Int ->
//                            dialog.dismiss()
//                            getViewModel().unBindCar(
//                                mUserId,
//                                mCenterControlSn,
//                                "",
//                                "",
//                                appointmentNo
//                            )
//                        }
//                    builder.create().show()
//                } else {
//                    getViewModel().unBindCar(
//                        mUserId,
//                        mCenterControlSn,
//                        "",
//                        "",
//                        ""
//                    );
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
//                    /*if (contains("token") && contains("cardNum")) {
//                        var mUserUnbindBean =
//                            GsonUtils.fromGson<UserUnbindBean>(this, UserUnbindBean::class.java)
//                        mUserToken = mUserUnbindBean?.token ?: ""
//                        mUserId = mUserUnbindBean?.cardNum ?: ""
//                        mBinding.sivUserID.setScanOrInputValue(mUserId)
//                    }*/
//                    if (contains("cardNum")) {
//                        val index = indexOf("cardNum=")
//                        if (index > -1) {
//                            mUserId = this.substring(index + 8);
//                            mBinding.sivUserID.setScanOrInputValue(mUserId)
//                        }
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
//
//    override fun onDestroyView() {
//        inputDispose?.dispose()
//        inputDispose = null
//        super.onDestroyView()
//    }
//}
