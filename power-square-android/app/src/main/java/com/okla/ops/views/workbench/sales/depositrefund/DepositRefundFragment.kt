package com.okla.ops.views.workbench.sales.depositrefund

import android.Manifest
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.dialog.CustomDialog
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.NumToStrUtil
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.base.common.utils.WindowInsetsHelper
import com.chad.library.adapter.base.BaseViewHolder
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.UserDetail
import com.okla.ops.databinding.FragmentDepositRefoundBinding
import com.okla.ops.dialog.DialogSelectRefundOrder
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.StringUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.qm.aftersalebind.AfterSaleUserInfoView
import com.okla.ops.weight.SnSearchInfoView
import com.luck.picture.lib.utils.SdkVersionUtils
import com.lxj.xpopup.XPopup

class DepositRefundFragment :
    BaseNormalVFragment<DepositRefundViewModel, FragmentDepositRefoundBinding>() {
    private var userId = ""
    private var orderId = ""
    private var refundOrderList = ArrayList<Deposit>()
    private var selectedOrderList = ArrayList<Deposit>()
    private var voucherList = ArrayList<String>()
    private lateinit var selectedOrderAdapter: SingleDataBindingNoPUseAdapter<Deposit>
    override fun getLayoutId(): Int {
        return R.layout.fragment_deposit_refound
    }

    override fun onCreateViewModel(): DepositRefundViewModel {
        return ViewModelProvider(this).get(DepositRefundViewModel::class.java);
    }

    private lateinit var permissionManager: PermissionManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this.mActivity)
        StatusBarUtil.StatusBarLightMode(this.mActivity)
        permissionManager = PermissionManager.getInstance(
            requireActivity().activityResultRegistry, this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        WindowInsetsHelper.applyForBottom(mBinding.layoutBottom)
        initAdapter()
        initListener()
        initObserver()
        initData()
        initClick()
    }

    private fun initClick() {
        mBinding.ivBack.setOnClickListener(this)
        mBinding.btnConfirm.setOnClickListener(this)
        mBinding.tvSeeReceipt.setOnClickListener(this)
        mBinding.tvReselect.setOnClickListener(this)
        mBinding.imgSelectOrder.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.ivBack -> {
                activity?.finish()
            }

            R.id.tv_reselect, R.id.img_select_order -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                if (refundOrderList.isNullOrEmpty()) {
                    ToastUtils.showShort(context?.getString(R.string.tip_no_order_canbe_deposit))
                    return
                }
                XPopup.Builder(context)
                    .enableDrag(false)
                    .dismissOnTouchOutside(false)
                    .asCustom(
                        context?.let {
                            DialogSelectRefundOrder(
                                it,
                                refundOrderList,
                                object : DialogSelectRefundOrder.SelectCallBack {
                                    override fun onSelectedRefundOrder(order: Deposit) {
                                        if (order != null) {
                                            selectedOrderList.clear()
                                            selectedOrderList.add(order)
                                            selectedOrderAdapter.setNewData(selectedOrderList)
                                            mBinding.imgSelectOrder.visibility = View.GONE
                                            mBinding.groupSelectOrder.visibility = View.VISIBLE
                                            mBinding.tvEmptyOrder.visibility = View.GONE
                                            var totalAmount = 0.0
                                            selectedOrderList.forEach { deposit ->
                                                orderId = deposit.orderNo ?: ""
                                                totalAmount += deposit.depositAmount
                                                voucherList.clear()
                                                if (!deposit.depositImgList.isNullOrBlank()) {
                                                    voucherList.addAll(StringUtils.strToList(deposit.depositImgList))
                                                }
                                                if (voucherList.isNullOrEmpty()) {
                                                    mBinding.groupVoucher.visibility = View.GONE
                                                } else {
                                                    mBinding.groupVoucher.visibility = View.VISIBLE
                                                }
                                            }
                                            mBinding.tvRefundAmount.text =
                                                "$".plus(NumToStrUtil.DoubleToStrWith2(totalAmount))
                                            enableBtnSubmit();
                                        } else {
                                            resetOrderInfo()
                                        }
                                    }
                                })
                        }
                    ).show()
            }

            R.id.btnConfirm -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                if (TextUtils.isEmpty(userId)) {
                    ToastUtils.showShort(context?.getString(R.string.hint_enter_user_id_or_scan_qr_code))
                    return
                }
                if (TextUtils.isEmpty(orderId)) {
                    ToastUtils.showShort(context?.getString(R.string.text_select_refund_order))
                    return
                }
                val remark = mBinding.edtRemark.text.toString()
                //调用退还押金的接口
                var recoveryFlag=1
                if (isChecked) {
                    recoveryFlag = 1
                    getViewModel().refundDeposit(userId, orderId, remark, recoveryFlag)
                } else {
                    recoveryFlag = 0
                    CustomDialog.Builder(context)
                        .setTitle(resources.getString(R.string.text_deposit_refund))
                        .setMessage(resources.getString(R.string.str_tip_voucher_not_confirmed))
                        .setPositiveButton(resources.getString(com.base.common.R.string.cc_str_confirm),
                            { dialog, _ ->
                                dialog.dismiss()
                                getViewModel().refundDeposit(userId, orderId, remark, recoveryFlag)
                            })
                        .setNegativeButton(context?.getString(com.base.common.R.string.dialog_cancel),
                            { dialog, _ ->
                                dialog.dismiss()
                            })
                        .create().show()
                }
            }

            R.id.tv_see_receipt -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                //凭证集合
//                val remotePdf = "https://www.gjtool.cn/pdfh5/git.pdf"
//                voucherList.add(remotePdf)
                ViewReceiptDialogFragment(voucherList)
                    .show(parentFragmentManager, "view_receipt")
            }
        }
    }

    private fun enableBtnSubmit() {
        if (!TextUtils.isEmpty(userId) && !TextUtils.isEmpty(orderId)) {
            mBinding.btnConfirm.isEnabled = true
        } else {
            mBinding.btnConfirm.isEnabled = false
        }
    }

    private fun initObserver() {
        getViewModel().refundResultLiveData.observe(this, {
            if (it != null) {
                findNavController().navigate(DepositRefundFragmentDirections.tooRefundSuccessFragment())
                getViewModel().refundResultLiveData.value = null  // 避免回退后再次触发
                mBinding.userinfoView.updateData("")
                resetUserInfo()
                resetOrderInfo()
                resetRemark()
            }
        })
        getViewModel().refundInfoLiveData.observe(this, {
            resetUserInfo()
            resetRemark()
            if (it != null) {
                val userInfoView = context?.let { it1 -> AfterSaleUserInfoView(it1) }
                val userDetail = UserDetail()
                userDetail.avatar = it.avatar ?: ""
                userDetail.username = it.username ?: ""
                userDetail.phone = it.phone ?: ""
                userInfoView?.updateData(userDetail)
                userId = it.cardNum
                mBinding.userinfoView.updateData(userId, userInfoView)
            }
        })
        getViewModel().refundOrderListLiveData.observe(this, {
            resetOrderInfo()
            if (!it.isNullOrEmpty()) {
                refundOrderList = it as ArrayList<Deposit>
            }
        })
    }

    private var isChecked = true
    private fun initListener() {
        mBinding.checkbox.setOnCheckedChangeListener { buttonView, isChecked ->
            this.isChecked = isChecked
        }
        mBinding.userinfoView.setOnSnSearchInfoListener(object :
            SnSearchInfoView.OnSnSearchInfoListener {
            override fun onScanClick() {
                askPermission()
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                if (inputContent != null && !TextUtils.isEmpty(inputContent)) {
                    mBinding.userinfoView.updateData(inputContent)
                    getViewModel().getRefundInfoByUserId(inputContent)
                } else {
                    mBinding.userinfoView.updateData("")
                    mBinding.userinfoView.removeSnInfo()
                }
            }

            override fun onEditTextHasFocus() {

            }

        })
        mBinding.userinfoView.setOnEditTextActionListener {
            mBinding.userinfoView.clearEditTextForces()
        }
        mBinding.userinfoView.setOnClearInputListener {
            resetUserInfo()
            resetOrderInfo()
        }
    }

    private fun resetUserInfo() {
        userId = ""
        mBinding.userinfoView.removeSnInfo()
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetOrderInfo() {
        mBinding.tvEmptyOrder.visibility = View.VISIBLE
        mBinding.imgSelectOrder.visibility = View.VISIBLE
        mBinding.groupSelectOrder.visibility = View.GONE
        mBinding.groupVoucher.visibility = View.GONE
        selectedOrderList.clear()
        selectedOrderAdapter.setNewData(selectedOrderList)
        orderId = ""
        voucherList.clear()
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetRemark() {
        mBinding.edtRemark.setText("")
    }

    private fun initData() {
        mBinding.userinfoView.setTitle(getString(R.string.text_user_id))
        mBinding.userinfoView.setEditTextHint(getString(R.string.hint_enter_user_id_or_scan_qr_code))
        mBinding.userinfoView.setNoDataTips(getString(R.string.text_no_userinfo_param))

    }

    private fun initAdapter() {
        selectedOrderAdapter = object :
            SingleDataBindingNoPUseAdapter<Deposit>(R.layout.item_selected_refund_order) {
            override fun convert(helper: BaseViewHolder, item: Deposit) {
                super.convert(helper, item)
                item.run {
                    val tvOrderId = helper.getView<AppCompatTextView>(R.id.tvOrderId)
                    val tvTimeAndState = helper.getView<AppCompatTextView>(R.id.tvContent)
                    tvOrderId.text = item.orderNo
                    if (item.unbindTime != null) {
                        tvTimeAndState.text =
                            DateTimeUtils.getTimeString(DateTimeUtils.dateFormatY, item.unbindTime)
                                .plus(mContext.getString(R.string.str_unbinding))
                    } else {
                        tvTimeAndState.text = "-"
                    }
                }
            }
        }
        mBinding.rvOrders.adapter = selectedOrderAdapter
    }

    private fun askPermission() {
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
                IntentIntegrator.forSupportFragment(this@DepositRefundFragment)
                    .setOrientationLocked(false)
                    .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                    .setCaptureActivity(QRCodeActivity::class.java)
                    .initiateScan() //  初始化扫描
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(mActivity, "")
            }
        }, *permissions.toTypedArray())
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (data == null) {
            return
        }
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            val mScanResult = intentResult?.contents.toString()
            userId = context?.let { ScanUtils.getUserCarNum(it, mScanResult) }!!
            mBinding.userinfoView.updateData(userId)
            if (!TextUtils.isEmpty(userId)) {
                getViewModel().getRefundInfoByUserId(userId);
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        findNavController().currentBackStackEntry
            ?.savedStateHandle
            ?.getLiveData<Boolean>("fromRefundSuccessFragment")
            ?.observe(viewLifecycleOwner) {
                mBinding.userinfoView.updateData("")
                resetUserInfo()
                resetOrderInfo()
                resetRemark()
                findNavController().currentBackStackEntry
                    ?.savedStateHandle
                    ?.remove<Boolean>("fromRefundSuccessFragment")
            }
    }
}