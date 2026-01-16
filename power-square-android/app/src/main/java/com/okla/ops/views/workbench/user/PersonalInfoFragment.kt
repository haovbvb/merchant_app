package com.okla.ops.views.workbench.user

import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.ImageView
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.custom.SpaceItemDecoration
import com.base.common.image.preview.ImagePreviewDialog
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.base.library.utils.DensityUtils
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.BindDevice
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.beans.UserDetail
import com.okla.ops.databinding.FragmentPersonalInfoBinding
import com.okla.ops.dialog.DialogMyBindDeviceList
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.devicedetail.DeviceDetailActivity
import com.lxj.xpopup.XPopup

class PersonalInfoFragment :
    BaseNormalVFragment<UserViewModel, FragmentPersonalInfoBinding>() {

    companion object {
        fun getInstance(userDetail: UserDetail): PersonalInfoFragment {
            val fragment = PersonalInfoFragment()
            val bundle = Bundle()
            bundle.putParcelable("userDetail", userDetail)
            fragment.arguments = bundle
            return fragment
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_personal_info
    }

    override fun onCreateViewModel(): UserViewModel {
        return ViewModelProvider(this)[UserViewModel::class.java]
    }

    private var mUserDetail: UserDetail? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mUserDetail = arguments?.getParcelable("userDetail")
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        initRecyclerview()
        initClick()
        initData()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<String>
    private fun initRecyclerview() {
        mBinding.rvPhotos.layoutManager =
            LinearLayoutManager(context, RecyclerView.HORIZONTAL, false)
        mBinding.rvPhotos.addItemDecoration(
            SpaceItemDecoration(DensityUtils.dp2px(10.0f), 0)
        )
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<String>(R.layout.item_photo_80) {
            override fun convert(helper: BaseViewHolder, item: String) {
                super.convert(helper, item)
                item.run {
                    helper.getView<ImageView>(R.id.ivDelete).visibility = View.GONE
                    val imageView = helper.getView<ImageView>(R.id.ivPhoto)
                    context.let {
                        Glide.with(this@PersonalInfoFragment).load(item).into(imageView)
                    }
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                val fragmentManager: FragmentActivity =
                    mActivity as FragmentActivity
                ImagePreviewDialog.getInstance(adapter.data as List<String>, position)
                    .showNow(fragmentManager.supportFragmentManager, "")
            }
        mBinding.rvPhotos.adapter = mAdapter
    }

    private var batteryListSale: MutableList<BindDevice>? = mutableListOf()
    private var batteryListRent: MutableList<BindDevice>? = mutableListOf()
    private var vehicleListSale: MutableList<BindDevice>? = mutableListOf()
    private var vehicleListRent: MutableList<BindDevice>? = mutableListOf()
    private fun initClick() {
        mBinding.kvVehicle.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            if (vehicleListSale.isNullOrEmpty() && vehicleListRent.isNullOrEmpty()) {
                return@setOnClickListener
            }
            context?.let {
                XPopup.Builder(it)
                    .asCustom(
                        DialogMyBindDeviceList(
                            it,
                            null,
                            null,
                            vehicleListSale,
                            vehicleListRent,
                            DialogMyBindDeviceList.Companion.TYPE_VEHICLE
                        ) { data ->
                            DeviceDetailActivity.startDeviceDetailActivity(
                                it,
                                data, DeviceTypeObject.TYPE_VEHICLE
                            )
                        }).show()
            }
        }

        mBinding.kvBattery.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            if (batteryListSale.isNullOrEmpty() && batteryListRent.isNullOrEmpty()) {
                return@setOnClickListener
            }
            context?.let {
                XPopup.Builder(it)
                    .asCustom(
                        DialogMyBindDeviceList(
                            it,
                            batteryListSale,
                            batteryListRent,
                            null,
                            null,
                            DialogMyBindDeviceList.Companion.TYPE_BATTERY
                        ) { data ->
                            DeviceDetailActivity.startDeviceDetailActivity(
                                it,
                                data, DeviceTypeObject.TYPE_BATTERY
                            )
                        }).show()
            }
        }
    }

    private var imgList: MutableList<String>? = null
    private fun initData() {
        context?.let {
            //车
            mBinding.kvVehicle.setKey(it.getString(R.string.text_vehicle))
            vehicleListSale?.clear()
            vehicleListRent?.clear()
            mUserDetail?.vehicleList?.forEach {
                //bindSource 1销售 2租赁
                if (it.bindSource == 1) {
                    vehicleListSale?.add(it)

                } else if (it.bindSource == 2) {
                    vehicleListRent?.add(it)
                }
            }
            val vehicleCountSale = if (vehicleListSale == null) 0 else vehicleListSale?.size ?: 0
            val vehicleCountRent = if (vehicleListRent == null) 0 else vehicleListRent?.size ?: 0
            mBinding.kvVehicle.setValue((vehicleCountSale + vehicleCountRent).toString())
            if ((vehicleCountSale + vehicleCountRent) > 0) {
                mBinding.kvVehicle.showArrow()
            } else {
                mBinding.kvVehicle.hideArrow()
            }
            //电池
            mBinding.kvBattery.setKey(it.getString(R.string.text_battery))
            batteryListSale?.clear()
            batteryListRent?.clear()
            mUserDetail?.batteryList?.forEach {
                //bindSource 1销售 2租赁
                if (it.bindSource == 1) {
                    batteryListSale?.add(it)

                } else if (it.bindSource == 2) {
                    batteryListRent?.add(it)
                }
            }
            val batteryCountSale = if (batteryListSale == null) 0 else batteryListSale?.size ?: 0
            val batteryCountRent = if (batteryListRent == null) 0 else batteryListRent?.size ?: 0
            mBinding.kvBattery.setValue((batteryCountSale + batteryCountRent).toString())
            if ((batteryCountSale + batteryCountRent) > 0) {
                mBinding.kvBattery.showArrow()
            } else {
                mBinding.kvBattery.hideArrow()
            }

            //register time
            mBinding.kvRegisterTime.setKey(it.getString(R.string.text_registration_time))
            mBinding.kvRegisterTime.setValue(
                DateTimeUtils.getTimeString(
                    DateTimeUtils.defaultFormat, mUserDetail?.createTime,
                    LanguageUtils.LanguageUtil.getLocalByLanguage()
                )
            )
            mBinding.kvUserType.setKey(it.getString(R.string.text_user_type))
            //type //1=正常，2逾期 3失信 4 已结束
            mBinding.kvUserType.setValue(
                when (mUserDetail?.type) {
                    1 -> it.getString(R.string.str_normal)
                    2 -> it.getString(R.string.text_overdue)
                    3 -> it.getString(R.string.text_dishonest)
                    4 -> it.getString(R.string.str_ended)
                    else -> "-"
                }
            )
            mBinding.kvBirthday.setKey(it.getString(R.string.text_birthday))
            mBinding.kvBirthday.setValue(mUserDetail?.birthday ?: "-")
            if (mUserDetail?.birthday.isNullOrBlank()) {
                mBinding.kvBirthday.setValue("-")
            }
            mBinding.kvPhoneNumber.setKey(it.getString(R.string.text_phone_number))
            mBinding.kvPhoneNumber.setValue(
                "${
                    DataStoreUtils.readStringData(
                        DataStoreKeyUtils.AREA_CODE,
                        ""
                    )
                } ${mUserDetail?.phone}"
            )
            mBinding.kvPhoneNumber.setValueColor(ContextCompat.getColor(it, R.color.color_0b61d9))
            mBinding.kvEmail.setKey(it.getString(R.string.text_email))
            if (null != mUserDetail?.email && !TextUtils.isEmpty(mUserDetail?.email)) {
                mBinding.kvEmail.setValue(mUserDetail?.email ?: "-")
            } else {
                mBinding.kvEmail.setValue("-")
            }
            mBinding.kvEmail.setValueColor(ContextCompat.getColor(it, R.color.color_0b61d9))
            mBinding.kvEmail.hideLine()
            mBinding.tvRemark.text = mUserDetail?.remark
        }
        mUserDetail?.imgList?.let {
            if (!TextUtils.isEmpty(it)) {
                imgList = it.split(",").toMutableList()
                mAdapter.setNewData(imgList)
            }
        }
    }

}