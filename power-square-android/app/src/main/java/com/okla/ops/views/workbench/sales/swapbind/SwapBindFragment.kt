package com.okla.ops.views.workbench.sales.swapbind

import android.Manifest
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.text.Spannable
import android.text.SpannableString
import android.text.TextUtils
import android.text.style.ForegroundColorSpan
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.base.common.utils.WindowInsetsHelper
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseViewHolder
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.BatteryVo
import com.okla.ops.beans.CarVo
import com.okla.ops.beans.ShopPaymentMethod
import com.okla.ops.beans.UserDetail
import com.okla.ops.databinding.FragmentSwapbindBinding
import com.okla.ops.dialog.DialogSelectSwapBindBattery
import com.okla.ops.dialog.DialogSelectSwapBindPackage
import com.okla.ops.dialog.DialogSelectSwapBindVehicle
import com.okla.ops.dialog.PaymentMethodDialogFragment
import com.okla.ops.utils.ScanUtils
import com.okla.ops.utils.StringUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.views.workbench.qm.aftersalebind.AfterSaleUserInfoView
import com.okla.ops.views.workbench.sales.rentbind.Pack
import com.okla.ops.weight.SnSearchInfoView
import com.luck.picture.lib.utils.SdkVersionUtils
import com.lxj.xpopup.XPopup

class SwapBindFragment :
    BaseNormalVFragment<SwapBindViewModel, FragmentSwapbindBinding>() {
    private var carAdapter: SingleDataBindingNoPUseAdapter<CarVo>? = null
    private var batteryAdapter: SingleDataBindingNoPUseAdapter<BatteryVo>? = null
    private var userId = ""
    private var carType = ""
    private var selectCarRentDay: Int? = null
    private var batteryType = ""
    private var selectInfoCode = ""
    private var amount = 0.0
    private var selectRentDays = mutableListOf<Int?>()
    private var carList = ArrayList<CarVo>()
    private var batteryList = ArrayList<BatteryVo>()
    private var packageList = ArrayList<Pack>()
    private var selectBatteryList = ArrayList<BatteryVo>()
    private var batteryTypeList = ArrayList<String>()

    override fun getLayoutId(): Int {
        return R.layout.fragment_swapbind
    }

    override fun onCreateViewModel(): SwapBindViewModel {
        return ViewModelProvider(this).get(SwapBindViewModel::class.java);
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
        initObserver()
        viewModel.getShopPaymentMethod(DataStoreUtils.readStringData(DataStoreKeyUtils.SHOP_NO))
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        WindowInsetsHelper.applyForBottom(mBinding.layoutBottom)
        initAdapter()
        initListener()
        initData()
        initClick()
    }

    private fun initClick() {
        mBinding.imgSelectCar.setOnClickListener(this)
        mBinding.imgSelectPack.setOnClickListener(this)
        mBinding.imgSelectBattery.setOnClickListener(this)
        mBinding.tvReselect.setOnClickListener(this)
        mBinding.btnConfirm.setOnClickListener(this)
        mBinding.ivBack.setOnClickListener {
            activity?.finish()
        }
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.img_select_car -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                if (carList.isNullOrEmpty()) {
                    ToastUtils.showShort(context?.getString(R.string.tip_no_vehicle_available))
                    return
                }
                XPopup.Builder(context)
                    .dismissOnTouchOutside(false)
                    .enableDrag(false)
                    .asCustom(
                        context?.let { it1 ->
                            DialogSelectSwapBindVehicle(
                                it1,
                                carList,
                                object : DialogSelectSwapBindVehicle.SelectCallBack {
                                    override fun onSelectedCar(car: CarVo) {
                                        if (car != null) {
                                            carType = car.model
                                            selectCarRentDay = car.rentDay
                                            mBinding.tvemptyCar.visibility = View.GONE
                                            mBinding.layoutcar.visibility = View.VISIBLE
                                            val imgCar =
                                                mBinding.layoutcar.findViewById<ImageView>(R.id.img_car)
                                            val tvSn =
                                                mBinding.layoutcar.findViewById<TextView>(R.id.tv_sn)
                                            val tvModel =
                                                mBinding.layoutcar.findViewById<TextView>(R.id.tv_model)
                                            val tvRemainDay =
                                                mBinding.layoutcar.findViewById<TextView>(R.id.tv_remain_day)
                                            tvSn.text = car.sn
                                            tvModel.text = car.model.plus(" • ").plus(car.spec)
                                            Glide.with(this@SwapBindFragment).load(car.img)
                                                .into(imgCar)
                                            if (car.bindSource == 1) {
                                                tvRemainDay.visibility = View.GONE
                                            } else if (car.bindSource == 2) {
                                                tvRemainDay.visibility = View.VISIBLE
                                                if (car.rentDay != null) {
                                                    val rentDays = car.rentDay?.toString() ?: "-"
                                                    val fullText = context?.getString(
                                                        com.base.common.R.string.str_remain_rental_days,
                                                        rentDays
                                                    )
                                                    val spannable = SpannableString(fullText)
                                                    val colonIndex = fullText?.indexOf(":")
                                                    if (colonIndex != -1 && colonIndex!! + 1 < fullText.length) {
                                                        spannable.setSpan(
                                                            ForegroundColorSpan(Color.parseColor("#00B88A")),
                                                            colonIndex + 1,
                                                            fullText.length,
                                                            Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                                                        )
                                                    }
                                                    tvRemainDay.text = spannable
                                                } else {
                                                    tvRemainDay.text = context?.getString(
                                                        com.base.common.R.string.str_remain_rental_days,
                                                        "-"
                                                    )
                                                }
                                            }

                                            if (!TextUtils.isEmpty(selectInfoCode)) {
                                                //如果已经选择了套餐，则要清空套餐，重新获取
                                                resetPackInfo()
                                            }
                                        } else {
                                            resetVehicleInfo()
                                        }
                                    }

                                })
                        })
                    .show()
            }

            R.id.img_select_battery -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                if (batteryList.isNullOrEmpty()) {
                    ToastUtils.showShort(context?.getString(R.string.tip_no_battery_available))
                    return
                }
                XPopup.Builder(context)
                    .enableDrag(false)
                    .dismissOnTouchOutside(false)
                    .asCustom(context?.let { it1 ->
                        DialogSelectSwapBindBattery(
                            it1,
                            batteryList, 2, false, "",
                            object : DialogSelectSwapBindBattery.SelectCallBack {
                                override fun onSelectedBattery(battery: List<BatteryVo>) {
                                    if (!battery.isNullOrEmpty()) {
                                        selectBatteryList = battery as ArrayList<BatteryVo>
                                        batteryAdapter?.setNewData(selectBatteryList)
                                        mBinding.rvBatterys.visibility = View.VISIBLE
                                        mBinding.tvemptyBattery.visibility = View.GONE
                                        mBinding.imgSelectBattery.visibility = View.GONE
                                    } else {
                                        resetBatteryInfo()
                                    }
                                    if (!TextUtils.isEmpty(selectInfoCode)) {
                                        //如果已经选择了套餐，则要清空套餐，重新获取
                                        resetPackInfo()
                                    }
                                }
                            })
                    })
                    .show()
            }

            R.id.img_select_pack, R.id.tv_reselect -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                selectRentDays.clear()
                batteryTypeList.clear()
                selectRentDays.add(selectCarRentDay)

                selectBatteryList.forEach {
                    selectRentDays.add(it.rentDay)
                    batteryTypeList.add(it.model ?: "")
                }
                batteryType = batteryTypeList.joinToString(",")
                if (!TextUtils.isEmpty(batteryType) && !TextUtils.isEmpty(carType)) {
                    val list = ArrayList<Int>()
                    if (selectRentDays.contains(null)) {
                        selectRentDays.forEach {
                            if (it != null) {
                                list.add(it);
                            }
                        }
                    }
                    if (selectRentDays.size > 0 && list.size == 0) {
                        getViewModel().getSwapPackInfo(batteryType, carType, null)
                    } else {
                        getViewModel().getSwapPackInfo(
                            batteryType,
                            carType,
                            list.minOrNull()
                        )
                    }
                } else {
                    ToastUtils.showShort(context?.getString(R.string.tip_select_vehicle_battery))
                }
            }

            R.id.btnConfirm -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                PaymentMethodDialogFragment.getInstance(
                    selectInfoCode,
                    "",
                    -1,
                    PaymentMethodDialogFragment.TYPE_SWAPBIND, amount,shopPaymentMethod
                )
                    .show(this@SwapBindFragment.childFragmentManager, "payment_method_dialog")
                PaymentMethodDialogFragment.setSwapUserId(userId)
            }
        }
    }

    private fun enableSubmit() {
        if (!TextUtils.isEmpty(userId) && !TextUtils.isEmpty(
                selectInfoCode
            )
        ) {
            mBinding.btnConfirm.isEnabled = true
        } else {
            mBinding.btnConfirm.isEnabled = false
        }
    }

    private fun initAdapter() {
        batteryAdapter =
            object :
                SingleDataBindingNoPUseAdapter<BatteryVo>(R.layout.item_swapbind_select_battery) {
                override fun convert(helper: BaseViewHolder, item: BatteryVo?) {
                    super.convert(helper, item)
                    val tvSn = helper.getView<TextView>(R.id.tv_sn)
                    val ivBattery = helper.getView<ImageView>(R.id.img_battery)
                    val tvModel = helper.getView<TextView>(R.id.tv_model)
                    tvModel.text = item?.sn
                    context?.let { Glide.with(it).load(item?.img).into(ivBattery) }
                    tvSn.text = item?.model.plus(" • ").plus(item?.spec)
                    val tvRentDay = helper.getView<TextView>(R.id.tv_remain_day)
                    if (item?.bindSource == 1) {
                        tvRentDay.visibility = View.GONE
                    } else if (item?.bindSource == 2) {
                        if (item?.rentDay != null) {
                            val rentDays = item.rentDay?.toString() ?: "-"
                            val fullText = context?.getString(
                                com.base.common.R.string.str_remain_rental_days,
                                rentDays
                            )
                            val spannable = SpannableString(fullText)
                            val colonIndex = fullText?.indexOf(":")
                            if (colonIndex != -1 && colonIndex!! + 1 < fullText.length) {
                                spannable.setSpan(
                                    ForegroundColorSpan(Color.parseColor("#00B88A")),
                                    colonIndex + 1,
                                    fullText.length,
                                    Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                                )
                            }
                            tvRentDay.text = spannable
                        } else {
                            tvRentDay.text =
                                context?.getString(
                                    com.base.common.R.string.str_remain_rental_days,
                                    "-"
                                )
                        }
                    }
                    helper.addOnClickListener(R.id.img_select)
                }
            }
        batteryAdapter?.setOnItemChildClickListener { adapter, view, position ->
            if (view?.id == R.id.img_select) {
                var maxSelectCount = 0;
                var haveSelectModel = ""
                selectPos = position;
                var showList: MutableList<BatteryVo> = ArrayList<BatteryVo>()
                showList = batteryList.toMutableList()
                if (selectBatteryList.size == 1) {
                    maxSelectCount = 2;
                    haveSelectModel = selectBatteryList.get(0).model ?: ""
                } else if (selectBatteryList.size == 2) {
                    maxSelectCount = 1;
                    selectBatteryList.forEachIndexed { index, batteryVo ->
                        if (index != selectPos) {
                            showList.remove(batteryVo)
                            haveSelectModel = batteryVo.model ?: ""
                        }
                    }
                }
                showList.forEachIndexed { index, batteryVo ->
                    if (batteryVo.sn == selectBatteryList.get(selectPos).sn) {
                        batteryVo.isSelected = true
                    } else {
                        batteryVo.isSelected = false
                    }
                }
                XPopup.Builder(context)
                    .enableDrag(false)
                    .dismissOnTouchOutside(false)
                    .asCustom(context?.let { it1 ->
                        DialogSelectSwapBindBattery(
                            it1,
                            showList, maxSelectCount, true, haveSelectModel,
                            object : DialogSelectSwapBindBattery.SelectCallBack {
                                override fun onSelectedBattery(battery: List<BatteryVo>) {
                                    if (!battery.isNullOrEmpty()) {
                                        if (maxSelectCount == 1) {
                                            //替换
                                            val newBean = battery.get(0)
                                            selectBatteryList.set(selectPos, newBean)
                                        } else if (maxSelectCount == 2) {
                                            selectBatteryList = battery as ArrayList<BatteryVo>
                                        }
                                        batteryAdapter?.setNewData(selectBatteryList)
                                        mBinding.rvBatterys.visibility = View.VISIBLE
                                        mBinding.tvemptyBattery.visibility = View.GONE
                                        mBinding.imgSelectBattery.visibility = View.GONE
                                    } else {
                                        if (maxSelectCount == 1) {
                                            selectBatteryList.remove(selectBatteryList.get(selectPos))
                                            batteryAdapter?.setNewData(selectBatteryList)
                                            mBinding.rvBatterys.visibility = View.VISIBLE
                                            mBinding.tvemptyBattery.visibility = View.GONE
                                            mBinding.imgSelectBattery.visibility = View.GONE
                                        } else if (maxSelectCount == 2) {
                                            batteryType = "";
                                            selectBatteryList.clear()
                                            batteryAdapter?.setNewData(selectBatteryList)
                                            mBinding.rvBatterys.visibility = View.GONE
                                            mBinding.tvemptyBattery.visibility = View.VISIBLE
                                            mBinding.imgSelectBattery.visibility = View.VISIBLE
                                        }

                                    }
                                    if (!TextUtils.isEmpty(selectInfoCode)) {
                                        //如果已经选择了套餐，则要清空套餐，重新获取
                                        resetPackInfo()
                                    }

                                }
                            })
                    })
                    .show()
            }


        }
        mBinding.rvBatterys.adapter = batteryAdapter
    }

    private var selectPos = -1

    private fun textIsEmpty(text: String?): String {
        return if (TextUtils.isEmpty(text)) "-" else text ?: ""
    }

    private var shopPaymentMethod: ShopPaymentMethod ?=null
    private fun initObserver() {
        getViewModel().shopPaymentMethodLiveData.observe(this, {
            shopPaymentMethod =it
        })
        getViewModel().swapBindInfoLiveData.observe(this, {
            if (it != null) {
                val userInfoView = context?.let { it1 -> AfterSaleUserInfoView(it1) }
                val userDetail = UserDetail()
                userDetail.cardNum = it.cardNum
                userDetail.avatar = it.avatar
                userDetail.phone = it.phone
                userDetail.username = it.username
                userId = it.cardNum ?: ""
                userInfoView?.updateData(userDetail)
                mBinding.userinfoView.updateData(userId, userInfoView)
            } else {
                resetAllInfo()
            }
        })
        getViewModel().carListLiveData.observe(this, {
            if (!it.isNullOrEmpty()) {
                carList = it as ArrayList<CarVo>
            } else {
                carType = ""
                carList.clear()
                mBinding.layoutcar.visibility = View.GONE
                mBinding.tvemptyCar.visibility = View.VISIBLE
            }
        })
        getViewModel().batteryListLiveData.observe(this, {
            if (!it.isNullOrEmpty()) {
                batteryList = it as ArrayList<BatteryVo>
            } else {
                resetBatteryInfo()
            }
        })
        getViewModel().packListLiveData.observe(this, {
            if (it != null) {
                packageList = it as ArrayList<Pack>
                if (packageList.isNullOrEmpty()) {
                    ToastUtils.showShort(context?.getString(R.string.tip_no_package_available))
                    return@observe
                }
                XPopup.Builder(context)
                    .enableDrag(false)
                    .dismissOnTouchOutside(false)
                    .asCustom(
                        context?.let { it1 ->
                            DialogSelectSwapBindPackage(
                                it1,
                                it,
                                object : DialogSelectSwapBindPackage.SelectCallBack {
                                    override fun onSelectedSwapBindPack(pack: Pack) {
                                        mBinding.imgSelectPack.visibility = View.GONE
                                        mBinding.groupPackageInfo.visibility = View.VISIBLE
                                        mBinding.bindpackageinfoview.updateSwapBindData(pack)
                                        selectInfoCode = pack.infoCode ?: ""
                                        amount = pack.packageAmount ?: 0.0
                                        enableSubmit()
                                    }
                                })
                        }
                    ).show()
            } else {
                resetPackInfo()
            }
        })
    }

    private fun resetPackInfo() {
        packageList.clear()
        selectInfoCode = ""
        mBinding.bindpackageinfoview.updateSwapBindData(null)
        mBinding.imgSelectPack.visibility = View.VISIBLE
        mBinding.tvemptyPack.visibility = View.VISIBLE
        mBinding.groupPackageInfo.visibility = View.GONE
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetBatteryInfo() {
        batteryType = "";
        selectBatteryList.clear()
        batteryList.clear()
        batteryTypeList.clear()
        batteryAdapter?.setNewData(selectBatteryList)
        mBinding.rvBatterys.visibility = View.GONE
        mBinding.tvemptyBattery.visibility = View.VISIBLE
        mBinding.imgSelectBattery.visibility = View.VISIBLE
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetVehicleInfo() {
        carType = ""
        selectCarRentDay = -1
        carList.clear()
        carAdapter?.setNewData(carList)
        mBinding.tvemptyCar.visibility = View.VISIBLE
        mBinding.layoutcar.visibility = View.GONE
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetUserInfo() {
        userId = ""
        mBinding.userinfoView.removeSnInfo()
        mBinding.btnConfirm.isEnabled = false
    }

    private fun resetAllInfo() {
        resetUserInfo()
        resetVehicleInfo()
        resetBatteryInfo()
        resetPackInfo()
    }

    private fun initListener() {
        mBinding.userinfoView.setOnSnSearchInfoListener(object :
            SnSearchInfoView.OnSnSearchInfoListener {
            override fun onScanClick() {
                askPermission()
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                if (inputContent != null && !TextUtils.isEmpty(inputContent)) {
                    getViewModel().getSwapBindInfo(inputContent)
                } else {
                    mBinding.userinfoView.removeSnInfo()
                    userId = ""
                    mBinding.btnConfirm.isEnabled = false
                }
            }

            override fun onEditTextHasFocus() {

            }
        })
        mBinding.userinfoView.setOnEditTextActionListener {
            mBinding.userinfoView.clearEditTextForces()
        }
        mBinding.userinfoView.setOnClearInputListener {
            resetAllInfo()
        }
    }

    private fun initData() {
        mBinding.userinfoView.setTitle(getString(R.string.text_user_id))
        mBinding.userinfoView.setEditTextHint(context?.getString(R.string.hint_enter_userid_or_scan_qr_code))
        mBinding.userinfoView.setNoDataTips(context?.getString(R.string.text_no_userinfo_param))
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
                IntentIntegrator.forSupportFragment(this@SwapBindFragment)
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
                getViewModel().getSwapBindInfo(userId);
            }
        }

    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        findNavController().currentBackStackEntry
            ?.savedStateHandle
            ?.getLiveData<Boolean>("fromSellBindSuccessFragment")
            ?.observe(viewLifecycleOwner) {
                mBinding.userinfoView.updateData("")
                resetAllInfo()
                findNavController().currentBackStackEntry
                    ?.savedStateHandle
                    ?.remove<Boolean>("fromSellBindSuccessFragment")
            }

    }
}