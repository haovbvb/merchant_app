package com.okla.ops.dialog

import android.Manifest
import android.app.Activity.RESULT_OK
import android.app.Dialog
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.text.TextUtils
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.widget.AppCompatButton
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.Group
import androidx.core.content.ContextCompat
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.base.common.image.preview.ImagePreviewDialog
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.NumToStrUtil
import com.base.common.utils.PicJumpUtils
import com.base.common.utils.ToastUtils
import com.base.library.utils.FileUtils
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.beans.PayFullTypeObject
import com.okla.ops.beans.PayTypeObject
import com.okla.ops.beans.PaymentPlan
import com.okla.ops.beans.ShopPaymentMethod
import com.okla.ops.utils.StringUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.entry.PurchasingUserView
import com.okla.ops.views.workbench.entry.PurchasingUserView2
import com.okla.ops.views.workbench.sales.rentbind.RentBindFragmentDirections
import com.okla.ops.views.workbench.sales.sellbind.SellBindFragmentDirections
import com.okla.ops.views.workbench.sales.sellbind.SellBindViewModel
import com.okla.ops.views.workbench.sales.swapbind.SwapBindFragmentNewDirections
import com.luck.picture.lib.basic.PictureSelector
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.SelectMimeType
import com.luck.picture.lib.config.SelectModeConfig
import com.luck.picture.lib.utils.SdkVersionUtils
import com.lxj.xpopup.XPopup
import com.lxj.xpopup.core.BasePopupView
import com.orhanobut.logger.Logger

class PaymentMethodDialogFragment : DialogFragment() {

    private var paySource: Int = PayTypeObject.TYPE_ONLINE  //默认线上
    private lateinit var paymentPlanList: MutableList<PaymentPlan>
    private var infoCode = ""
    private var showType = 0
    private var onlinePayType = PayFullTypeObject.TYPE_FULL

    // 现金 线上
    private var payTypeArrayList = ArrayList<String>()
    private var installmentTypeList = ArrayList<String>()

    //分期方案id
    private var planId = ""
    private var amount = 0.0
    private var rentPrice = 0.0
    private var depostPrice = 0.0

    companion object {
        const val TYPE_ROADSIDE = 1
        const val TYPE_SELLBIND = 2
        const val TYPE_RENT = 3
        const val TYPE_SWAPBIND = 4
        private var swapUsrid = ""

        fun getInstance(
            infoCode: String,
            deviceSn: String,
            deviceType: Int,
            type: Int,
            packageAmount: Double,
            shopPaymentMethod: ShopPaymentMethod?
        ): PaymentMethodDialogFragment {
            val paymentMethodDialogFragment = PaymentMethodDialogFragment()
            val bundle = Bundle()
            bundle.putString("infoCode", infoCode)
            bundle.putString("deviceSn", deviceSn)
            bundle.putInt("deviceType", deviceType)
            bundle.putInt("type", type)
            bundle.putDouble("amount", packageAmount)
            bundle.putParcelable("paymethod", shopPaymentMethod)
            paymentMethodDialogFragment.arguments = bundle
            return paymentMethodDialogFragment;
        }

        fun getInstance(
            infoCode: String,
            deviceSn: String,
            deviceType: Int,
            rentAmount: Double,
            depositAmount: Double,
            packageAmount: Double,
            type: Int,
            shopPaymentMethod: ShopPaymentMethod?
        ): PaymentMethodDialogFragment {
            val paymentMethodDialogFragment = PaymentMethodDialogFragment()
            val bundle = Bundle()
            bundle.putString("infoCode", infoCode)
            bundle.putString("deviceSn", deviceSn)
            bundle.putInt("deviceType", deviceType)
            bundle.putDouble("rentPrice", rentAmount)
            bundle.putDouble("depositPrice", depositAmount)
            bundle.putDouble("amount", packageAmount)
            bundle.putInt("type", type)
            bundle.putParcelable("paymethod", shopPaymentMethod)
            paymentMethodDialogFragment.arguments = bundle
            return paymentMethodDialogFragment;
        }

        fun setSwapUserId(id: String) {
            swapUsrid = id;
        }

    }


    // 使用 by viewModels() 初始化独立的 ViewModel，作用域限定在 DialogFragment 内
    private val viewModel: SellBindViewModel by viewModels()
    private lateinit var permissionManager: PermissionManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            requireActivity().activityResultRegistry, this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        initObserver()
    }

    private var shopPaymentMethod: ShopPaymentMethod? = null
    private var tvFull: TextView? = null
    private var imgfull: ImageView? = null
    private var imgInstallment: ImageView? = null
    private var groupInstallment1: Group? = null
    private var groupInstallment2: Group? = null
    private var layoutThreeAmountLayout: ConstraintLayout? = null
    private var tvValue2: TextView? = null
    private var layoutFullTotal: LinearLayout? = null
    private var tvTitleAmount1: TextView? = null
    private var tvTitleAmount2: TextView? = null
    private var tvAmout1Value: TextView? = null
    private var line2: View? = null

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        infoCode = arguments?.getString("infoCode") ?: ""
        mDeviceSn = arguments?.getString("deviceSn") ?: ""
        mDeviceType = arguments?.getInt("deviceType") ?: -1
        showType = arguments?.getInt("type") ?: 0
        amount = arguments?.getDouble("amount") ?: 0.0
        rentPrice = arguments?.getDouble("rentPrice") ?: 0.0
        depostPrice = arguments?.getDouble("depositPrice") ?: 0.0
        shopPaymentMethod = arguments?.getParcelable("paymethod")
        if (showType == TYPE_SELLBIND) {
            viewModel.getPaymentPlanList(amount)
            if (shopPaymentMethod != null) {
                if (!StringUtils.strToList(shopPaymentMethod?.salePayWay).isNullOrEmpty()) {
                    payTypeArrayList =
                        StringUtils.strToList(shopPaymentMethod?.salePayWay) as ArrayList<String>
                }
            }
        }
        if (showType == TYPE_RENT || showType == TYPE_SWAPBIND) {
            if (shopPaymentMethod != null) {
                if (!StringUtils.strToList(shopPaymentMethod?.otherPayWay).isNullOrEmpty()) {
                    payTypeArrayList =
                        StringUtils.strToList(shopPaymentMethod?.otherPayWay) as ArrayList<String>
                }
            }
        }

//        viewModel.getShopPaymentMethod(DataStoreUtils.readStringData(DataStoreKeyUtils.SHOP_NO))

        // 获取布局
        val inflater: LayoutInflater = requireActivity().layoutInflater
        val view: View = inflater.inflate(R.layout.dialog_payment_method, null)

        // 获取布局内的控件
        val tvConfirm = view.findViewById<AppCompatTextView>(R.id.btn_confirm)
        val tvCash = view.findViewById<AppCompatTextView>(R.id.cash)
        val tvOnline = view.findViewById<AppCompatTextView>(R.id.online)
        val flPayInfo = view.findViewById<FrameLayout>(R.id.flPayInfo)
        line2 = view.findViewById<View>(R.id.line2)
        groupInstallment1 = view.findViewById<Group>(R.id.group_installment_1)
        groupInstallment2 = view.findViewById<Group>(R.id.group_installment_2)
        val imgOnline = view.findViewById<ImageView>(R.id.img_online)
        val imgcash = view.findViewById<ImageView>(R.id.img_cash)
        tvFull = view.findViewById<TextView>(R.id.tvFullPay)
        val tvInstallment = view.findViewById<TextView>(R.id.tvInstallmentPay)
        imgfull = view.findViewById<ImageView>(R.id.img_fullpay)
        imgInstallment = view.findViewById<ImageView>(R.id.img_installment)
        val tvFinancial = view.findViewById<TextView>(R.id.tv_title_financial)
        val tvValue1 = view.findViewById<TextView>(R.id.tv_select_value1)
        tvValue2 = view.findViewById<TextView>(R.id.tv_select_value2)
        layoutFullTotal = view.findViewById<LinearLayout>(R.id.layout_full_total_amount)
//        val layoutFullInstall = view.findViewById<ConstraintLayout>(R.id.layout_fullpay)
        val tvFullPayTotal = view.findViewById<TextView>(R.id.tv_fullpay_total)
        layoutThreeAmountLayout = view.findViewById<ConstraintLayout>(R.id.layout_three_amount)
        tvTitleAmount1 = view.findViewById<TextView>(R.id.tv_title_amount1)
        tvTitleAmount2 = view.findViewById<TextView>(R.id.tv_title_amount2)
        tvAmout1Value = view.findViewById<TextView>(R.id.tv_amount1_value)
        val tvAmout2Value = view.findViewById<TextView>(R.id.tv_amount2_value)
        val tvAmout3Value = view.findViewById<TextView>(R.id.tv_amount3_value)

        //默认是线上 全款
        paySource = PayTypeObject.TYPE_ONLINE
        onlinePayType = PayFullTypeObject.TYPE_FULL
        when (showType) {
            //线上 现金 全额 分期
            TYPE_SELLBIND -> {
                groupInstallment1?.visibility = View.VISIBLE
                groupInstallment2?.visibility = View.GONE
                layoutFullTotal?.visibility = View.VISIBLE
                tvFullPayTotal?.text = "$".plus(NumToStrUtil.DoubleToStrWith2(amount))
                tvTitleAmount1?.text = context?.getString(R.string.str_principal)
                tvTitleAmount2?.text = context?.getString(R.string.str_total_interest)
                tvAmout1Value?.text = "$".plus(NumToStrUtil.DoubleToStrWith2(amount))
            }
            // 线上 现金 全额
            TYPE_RENT -> {
                line2?.visibility= View.GONE
                groupInstallment1?.visibility = View.GONE
                layoutThreeAmountLayout?.visibility = View.VISIBLE
                layoutFullTotal?.visibility = View.GONE
                groupInstallment2?.visibility = View.GONE
                imgInstallment?.visibility = View.GONE
                tvTitleAmount1?.text = context?.getString(R.string.str_lease_amount)
                tvTitleAmount2?.text = context?.getString(R.string.str_depoist)
                tvAmout1Value?.text = "$".plus(NumToStrUtil.DoubleToStrWith2(rentPrice))
                tvAmout2Value.text = "$".plus(NumToStrUtil.DoubleToStrWith2(depostPrice))
                val totalCount = rentPrice + depostPrice
                tvAmout3Value.text = "$".plus(NumToStrUtil.DoubleToStrWith2(totalCount))
            }
            //线上 现金 全额
            TYPE_SWAPBIND -> {
                line2?.visibility= View.GONE
                groupInstallment1?.visibility = View.GONE
                groupInstallment2?.visibility = View.GONE
                layoutThreeAmountLayout?.visibility = View.GONE
                layoutFullTotal?.visibility = View.VISIBLE
                tvFullPayTotal?.text = "$".plus(NumToStrUtil.DoubleToStrWith2(amount))
                groupInstallment2?.visibility = View.GONE
                imgInstallment?.visibility = View.GONE
            }
        }
        if (!payTypeArrayList.isNullOrEmpty()) {
            //现金支付，在线支付 显示 控制
            if (!payTypeArrayList.contains(PayTypeObject.TYPE_CASH.toString())) {
                tvCash.visibility = View.GONE
                imgcash.visibility = View.GONE
                tvOnline.visibility = View.VISIBLE
                imgOnline.visibility = View.VISIBLE
                imgOnline.setImageResource(R.mipmap.icon_green_checked)
                paySource = PayTypeObject.TYPE_ONLINE
                controlShowFullOrInstallByOnline()
            }
            if (!payTypeArrayList.contains(PayTypeObject.TYPE_ONLINE.toString())) {
                tvOnline.visibility = View.GONE
                imgOnline.visibility = View.GONE
                tvCash.visibility = View.VISIBLE
                imgcash.visibility = View.VISIBLE
                imgcash.setImageResource(R.mipmap.icon_green_checked)
                paySource = PayTypeObject.TYPE_CASH
                controlShowFullOrInstallByCash()
            }
        }
        if (showType == TYPE_SELLBIND) {
            if (payTypeArrayList.contains(PayTypeObject.TYPE_ONLINE.toString())) {
                controlShowFullOrInstallByOnline()
            }
        }
        tvCash.setOnClickListener {
            paySource = PayTypeObject.TYPE_CASH;
            imgcash.setImageResource(R.mipmap.icon_green_checked)
            imgOnline.setImageResource(R.mipmap.icon_grey_unchecked)
//            if (showType == TYPE_RENT) {
//                layoutThreeAmountLayout?.visibility = View.VISIBLE
//                imgInstallment?.visibility = View.GONE
//            } else if (showType == TYPE_SWAPBIND) {
//                layoutFullInstall.visibility = View.VISIBLE
//                imgInstallment?.visibility = View.GONE
//            } else
            if (showType == TYPE_SELLBIND) {
                tvFull?.visibility = View.VISIBLE
                imgfull?.visibility = View.VISIBLE
                line2?.visibility = View.VISIBLE
                imgfull?.setImageResource(R.mipmap.icon_green_checked)
                imgInstallment?.setImageResource(R.mipmap.icon_grey_unchecked)
                groupInstallment2?.visibility = View.GONE
                layoutFullTotal?.visibility = View.VISIBLE
                layoutThreeAmountLayout?.visibility = View.GONE
                controlShowFullOrInstallByCash()
            }

        }
        tvOnline.setOnClickListener {
            paySource = PayTypeObject.TYPE_ONLINE;
            imgcash.setImageResource(R.mipmap.icon_grey_unchecked)
            imgOnline.setImageResource(R.mipmap.icon_green_checked)
            if(showType== TYPE_SELLBIND){
                tvFull?.visibility = View.VISIBLE
                imgfull?.visibility = View.VISIBLE
                line2?.visibility = View.VISIBLE
                imgfull?.setImageResource(R.mipmap.icon_green_checked)
                imgInstallment?.setImageResource(R.mipmap.icon_grey_unchecked)
                groupInstallment2?.visibility = View.GONE
                layoutFullTotal?.visibility = View.VISIBLE
                layoutThreeAmountLayout?.visibility = View.GONE
                controlShowFullOrInstallByOnline()
            }
        }
        tvFull?.setOnClickListener {
            onlinePayType = PayFullTypeObject.TYPE_FULL
            imgfull?.setImageResource(R.mipmap.icon_green_checked)
            imgInstallment?.setImageResource(R.mipmap.icon_grey_unchecked)
            groupInstallment2?.visibility = View.GONE
            if (showType == TYPE_RENT) {
                layoutFullTotal?.visibility = View.GONE
                layoutThreeAmountLayout?.visibility = View.VISIBLE
            } else {
                layoutFullTotal?.visibility = View.VISIBLE
                layoutThreeAmountLayout?.visibility = View.GONE
            }

        }
        tvInstallment.setOnClickListener {
            onlinePayType = PayFullTypeObject.TYPE_INSTALLMENT
            imgfull?.setImageResource(R.mipmap.icon_grey_unchecked)
            imgInstallment?.setImageResource(R.mipmap.icon_green_checked)
            groupInstallment2?.visibility = View.VISIBLE
            layoutFullTotal?.visibility = View.GONE
            if (!TextUtils.isEmpty(tvValue2?.text)) {
                layoutThreeAmountLayout?.visibility = View.VISIBLE
            }
        }
        tvFinancial.setOnClickListener {
            layoutThreeAmountLayout?.visibility = View.VISIBLE
            XPopup.Builder(context)
                .asCustom(
                    context?.let {
                        DialogPaymentPlanList(
                            it,
                            paymentPlanList,
                        ) { paymentPlan ->
                            selectPlan(
                                paymentPlan,
                                tvValue1,
                                tvValue2,
                                tvAmout2Value,
                                tvAmout3Value
                            )
                            //onPaymentMethodListener?.invoke(2, planNo)
                        }
                    }).show()
        }
        tvConfirm.setOnClickListener {
            if (showType == TYPE_SWAPBIND) {
                viewModel.createSwapBindOrder(infoCode, paySource, swapUsrid)
            } else {
                //分期付款
                if (onlinePayType == PayFullTypeObject.TYPE_INSTALLMENT) {
                    if (TextUtils.isEmpty(planId)) {
                        ToastUtils.showShort(context?.getString(R.string.hint_select_installment_plan))
                        return@setOnClickListener
                    } else {
                        //选择申请人 弹窗
                        showApplicantDialog()
                    }
                } else {
                    showApplicantDialog()
                }
            }

        }

        val dialog = Dialog(requireContext())
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(view) // 使用自定义布局
        dialog.setCancelable(false) // 禁用返回键关闭
        dialog.setCanceledOnTouchOutside(true) // 禁用点击外部关闭
        return dialog
    }

    private fun showFullPayOnly() {
        line2?.visibility = View.GONE
        layoutFullTotal?.visibility = View.VISIBLE
        layoutThreeAmountLayout?.visibility = View.GONE
        groupInstallment1?.visibility = View.GONE
        groupInstallment2?.visibility = View.GONE
        tvFull?.visibility = View.VISIBLE
        imgfull?.visibility = View.VISIBLE
        imgfull?.setImageResource(R.mipmap.icon_green_checked)
        onlinePayType = PayFullTypeObject.TYPE_FULL
    }

    private fun showInstallPayOnly() {
        tvFull?.visibility = View.GONE
        imgfull?.visibility = View.GONE
        line2?.visibility = View.GONE
        groupInstallment1?.visibility = View.VISIBLE
        groupInstallment2?.visibility = View.VISIBLE
        layoutFullTotal?.visibility = View.GONE
        imgInstallment?.setImageResource(R.mipmap.icon_green_checked)
        if (!TextUtils.isEmpty(tvValue2?.text)) {
            layoutThreeAmountLayout?.visibility = View.VISIBLE
        }
        onlinePayType = PayFullTypeObject.TYPE_INSTALLMENT
    }

    private fun controlShowFullOrInstallByOnline() {
        if (payTypeArrayList.contains(
                PayTypeObject.TYPE_ONLINE.toString()
            ) && showType == TYPE_SELLBIND
        ) {
            saleOnlineOption = shopPaymentMethod?.saleOnlineOption ?: ""
            if (!StringUtils.strToList(saleOnlineOption).isNullOrEmpty()) {
                installmentTypeList =
                    StringUtils.strToList(saleOnlineOption) as ArrayList<String>
            }
            if (!installmentTypeList.isNullOrEmpty()) {
                // 分期 全额 显示控制
                if (!installmentTypeList.contains("1")) {
                    //不展示全额
                    showInstallPayOnly()
                }
                if (!installmentTypeList.contains("2")) {
                    //不展示分期
                    showFullPayOnly()
                }
            }
        }

    }


    private fun controlShowFullOrInstallByCash() {
        if (payTypeArrayList.contains(
                PayTypeObject.TYPE_CASH.toString()
            ) && showType == TYPE_SELLBIND
        ) {
            saleCashOption = shopPaymentMethod?.saleCashOption ?: ""
            if (!StringUtils.strToList(saleCashOption).isNullOrEmpty()) {
                installmentTypeList =
                    StringUtils.strToList(saleCashOption) as ArrayList<String>
            }
            if (!installmentTypeList.isNullOrEmpty()) {
                // 分期 全额 显示控制
                if (!installmentTypeList.contains("1")) {
                    //不展示全额
                    showInstallPayOnly()
                }
                if (!installmentTypeList.contains("2")) {
                    //不展示分期
                    showFullPayOnly()
                }
            }
        }

    }


    private fun selectPlan(
        plan: PaymentPlan,
        tvValue1: TextView,
        tvValue2: TextView?,
        tvAmount2Value: TextView,
        tvAmount3Value: TextView
    ) {
        planId = plan.planNo ?: ""
        tvValue1.text =
            context?.getString(R.string.text_payment_plan_periods, plan.period.toString())
        val rate = if (plan.rate != null) {
            "${plan.rate * 100}%"
        } else {
            "-"
        }
        tvValue2?.text = rate.plus(context?.getString(R.string.str_annual_interest_rate))
        tvAmount2Value.text = "$".plus(NumToStrUtil.DoubleToStrWith2(plan.fee ?: 0.00))
        val totalFee = plan.fee?.plus((amount))?.let { NumToStrUtil.DoubleToStrWith2(it) }
        tvAmount3Value.text = "$".plus(totalFee.toString())
    }

    override fun onStart() {
        super.onStart()
        dialog?.window?.apply {
            // 设置对话框宽度为屏幕宽度，高度为包裹内容
            setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            // 设置对话框显示在底部
            setGravity(Gravity.BOTTOM)
            // 设置背景为透明
            setBackgroundDrawable(ContextCompat.getDrawable(context, R.drawable.bg_top_r16_ffffff))
            // 去除默认的边距
            decorView.setPadding(0, 0, 0, 0)
        }
    }

    private var saleCashOption = ""
    private var saleOnlineOption = ""
    private fun initObserver() {
//        viewModel.shopPaymentMethodLiveData.observe(this, {
//            it.let {
//                when (showType) {
//                    TYPE_RENT, TYPE_SWAPBIND -> {
//                        if (StringUtils.strToList(it?.otherPayWay) != null) {
//                            payTypeArrayList =
//                                StringUtils.strToList(it?.otherPayWay) as ArrayList<Int>
//                        }
//                    }
//
//                    TYPE_SELLBIND -> {
//                        if (StringUtils.strToList(it?.salePayWay) != null) {
//                            payTypeArrayList =
//                                StringUtils.strToList(it?.salePayWay) as ArrayList<Int>
//                        }
//                    }
//                }
//            }
//
//        })
        viewModel.createSwapBindOrderLiveData.observe(this, {
            if (it != null) {
                dialogSelectApplicant?.dismiss()
                findNavController().navigate(
                    SwapBindFragmentNewDirections.swapBindFragmentToSaleBindSuccessFragment(
                        it.toString(),
                        paySource,
                        context?.getString(R.string.title_swapbind) ?: ""
                    )
                )
                dismiss()
            } else {
                //请求失败 可以重试
                dialogSelectApplicant?.setConfirmBtnEnable(true)
            }
        })
        viewModel.paymentPlanListLiveData.observe(this) {
            paymentPlanList = it as MutableList<PaymentPlan>
        }
        viewModel.purchasingUserLiveData.observe(this) {
            if (it != null) {
                mCardNum = it?.cardNum ?: ""
                //线上并且全额
                if (paySource == PayTypeObject.TYPE_ONLINE && onlinePayType == 1) {
                    context?.let { context ->
                        val purchasingUserView = PurchasingUserView(context)
                        purchasingUserView.setOnPurchasingUserEditListener { firstName, lastName, phone, idNumber, cardImg, personalImg, birthday, email, address ->
                            mFirstName = firstName
                            mLastName = lastName
                            mPhone = phone
                            mIdNumber = idNumber
                            mCardImg = cardImg
                            mPersonalImg = personalImg
                            mBirthday = birthday
                            mEmail = email
                            mAddress = address
                        }
                        purchasingUserView.setOnSubmitListener { submit ->
                            dialogSelectApplicant?.setConfirmBtnEnable(submit)
                        }
                        dialogSelectApplicant?.addPurchasingUserView(purchasingUserView)
                        purchasingUserView.updateData(it)
                    }
                } else {
                    context?.let { context ->
                        purchasingUserView2 = PurchasingUserView2(context)
                        purchasingUserView2?.setOnPurchasingUserEditListener { firstName, lastName, phone, idNumber, cardImg, personalImg, birthday, email, address ->
                            mFirstName = firstName
                            mLastName = lastName
                            mPhone = phone
                            mIdNumber = idNumber
                            mCardImg = cardImg
                            mPersonalImg = personalImg
                            mBirthday = birthday
                            mEmail = email
                            mAddress = address
                        }
                        purchasingUserView2?.setOnSubmitListener { submit ->
                            dialogSelectApplicant?.setConfirmBtnEnable(submit)
                        }
                        purchasingUserView2?.setOnPhotoListener(object :
                            PurchasingUserView2.OnPhotoListener {
                            override fun onTakePhoto(type: Int) {
                                mTakePhotoType = type
                                initBottomSheet()
                            }

                            override fun onWatchPhoto(imgs: ArrayList<String>, position: Int) {
                                fragmentManager?.let { it1 ->
                                    ImagePreviewDialog.getInstance(imgs, position)
                                        .showNow(it1, "")
                                }
                            }

                        })
                        dialogSelectApplicant?.addPurchasingUserView(purchasingUserView2!!)
                        purchasingUserView2?.updateData(it)
                    }
                }
            } else {
                dialogSelectApplicant?.setConfirmBtnEnable(false)
            }

        }
        viewModel.uploadCardLiveData.observe(this) {
            when (mTakePhotoType) {
                1 -> purchasingUserView2?.setImages(it)

                2 -> purchasingUserView2?.setPersonalImg(it)
            }
        }
        viewModel.sellResultLiveData.observe(this) {
            if (it != null) {
                dialogSelectApplicant?.removePurchasingUserView()
                clearTempUserData()
                dialogSelectApplicant?.dismiss()
                findNavController().navigate(
                    SellBindFragmentDirections.saleBindFragmentToSaleBindSuccessFragment(
                        it.toString(),
                        paySource,
                        context?.getString(R.string.title_salebind) ?: ""
                    )
                )
                dismiss()
            } else {
                //请求失败 可以重试
                dialogSelectApplicant?.setConfirmBtnEnable(true)
            }

        }
        viewModel.rentResultLiveData.observe(this, {
            if (it != null) {
                dialogSelectApplicant?.removePurchasingUserView()
                dialogSelectApplicant?.dismiss()
                clearTempUserData()
                findNavController().navigate(
                    RentBindFragmentDirections.rentBindFragmentToSaleBindSuccessFragment(
                        it.toString(),
                        paySource,
                        context?.getString(R.string.title_rentbind) ?: ""
                    )
                )
                dismiss()
            } else {
                dialogSelectApplicant?.setConfirmBtnEnable(true)
            }
        })
    }

    private var purchasingUserView2: PurchasingUserView2? = null
    private var dialogSelectApplicant: DialogSelectApplicant? = null
    private var popupView: BasePopupView? = null
    private var mAddress: String = ""
    private var mBirthday: String = ""
    private var mCardImg: String = ""
    private var mCardNum: String = ""
    private var mDeviceSn: String = ""
    private var mDeviceType: Int = -1
    private var mEmail: String = ""
    private var mFirstName: String = ""
    private var mLastName: String = ""
    private var mIdNumber: String = ""
    private var mPhone: String = ""
    private var mPersonalImg: String = ""
    private var mTakePhotoType = 0
    private fun clearTempUserData() {
        mAddress = ""
        mBirthday = ""
        mCardImg = ""
        mCardNum = ""
        mEmail = ""
        mFirstName = ""
        mLastName = ""
        mIdNumber = ""
        mPhone = ""
        mPersonalImg = ""
    }

    private fun showApplicantDialog() {
        context?.let {
            val screenHeight = resources.displayMetrics.heightPixels
            val maxHeight = (screenHeight * 0.95).toInt() // 高度限制为屏幕的80%
            dialogSelectApplicant = DialogSelectApplicant(it, {
                if (!TextUtils.isEmpty(mEmail) && !mEmail.contains("@")) {
                    ToastUtils.showShort(it.getString(R.string.tips_enter_correct_email))
                    return@DialogSelectApplicant
                }
                dialogSelectApplicant?.setConfirmBtnEnable(false)
                if (showType == TYPE_SELLBIND) {
                    viewModel.sellBind(
                        mAddress,
                        mBirthday,
                        mCardImg,
                        mCardNum,
                        mEmail,
                        mFirstName,
                        mLastName,
                        mIdNumber,
                        mPhone,
                        onlinePayType,
                        planId,
                        mPersonalImg,
                        infoCode, paySource, mDeviceSn, mDeviceType
                    )
                } else if (showType == TYPE_RENT) {
                    viewModel.rentBind(
                        mAddress,
                        mBirthday,
                        mCardImg,
                        mCardNum,
                        mEmail,
                        mFirstName,
                        mLastName,
                        mIdNumber,
                        mPhone,
                        onlinePayType,
                        mPersonalImg,
                        infoCode, paySource, mDeviceSn, mDeviceType
                    )
                }

            })
            dialogSelectApplicant?.setOnDialogSelectListener(object :
                DialogSelectApplicant.OnDialogSelectListener {
                override fun onScanClick() {
                    askPermission()
                }

                override fun onEditTextNotHasFocus(inputContent: String?) {
                    if (!TextUtils.isEmpty(inputContent)) {
                        if (showType == TYPE_SELLBIND) {
                            viewModel.queryUserForSell(inputContent ?: "")
                        } else if (showType == TYPE_RENT) {
                            viewModel.queryUserForRent(inputContent ?: "")
                        }
                    }
                }

                override fun onEditHasFocus(hasFocus: Boolean) {
                    if (dialogSelectApplicant?.isExistPurchasingUserView() == true) {
                        if (hasFocus) {
                            popupView?.getHostWindow()
                                ?.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING)
                        } else {
                            popupView?.getHostWindow()
                                ?.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
                        }
                    }
                }
            })
            popupView = XPopup.Builder(it)
                .maxHeight(maxHeight)
                .enableDrag(false)
                .asCustom(dialogSelectApplicant)
            popupView?.show()
        }

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
                IntentIntegrator.forSupportFragment(this@PaymentMethodDialogFragment)
                    .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                    .setOrientationLocked(false)
                    .setCaptureActivity(QRCodeActivity::class.java) // 设置自定义的activity是CustomActivity
                    .initiateScan() //  初始化扫描
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
            val view = LayoutInflater.from(activity)
                .inflate(com.base.common.R.layout.dialog_take_photo_sheet, null, false)
            view.findViewById<AppCompatButton>(com.base.common.R.id.take_photo_bt)
                .setOnClickListener {
                    mBottomSheetDialog?.dismiss()
                    PicJumpUtils.jumpCameraByFragment(
                        this@PaymentMethodDialogFragment,
                        PictureConfig.REQUEST_CAMERA,
                        SelectMimeType.ofImage()
                    )
                }
            view.findViewById<AppCompatButton>(com.base.common.R.id.picture_bt).setOnClickListener {
                var maxSelectNum = 1
                if (mTakePhotoType == 1) {
                    maxSelectNum = 4 - purchasingUserView2?.getIdCardImageCount()!!
                }
                mBottomSheetDialog?.dismiss()
                PicJumpUtils.jumpMultiChooseAlbumByFragment(
                    this@PaymentMethodDialogFragment,
                    maxSelectNum,
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

                IntentIntegrator.REQUEST_CODE -> {
                    val intentResult =
                        IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
                    var scanResult = intentResult?.contents ?: ""
                    if (!TextUtils.isEmpty(scanResult)) {
                        if (scanResult.contains("cardNum=")) {
                            val indexOf = scanResult.indexOf("cardNum=")
                            if (indexOf > -1) {
                                scanResult = scanResult.substring(indexOf + 8)
                            }
                        }
                        dialogSelectApplicant?.setEditContent(scanResult)
                    }
                }
            }
        }
    }

    private fun takePictureFinish(data: Intent?) {
        val selectList = PictureSelector.obtainSelectorList(data)
        var path = ""
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
                viewModel.uploadCardImg(path)
            } else {
                ToastUtils.showShort("take photo failure.")
            }
        }

    }


}
