package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.utils.DateTimeUtils
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.BindDevice
import com.okla.ops.databinding.DialogMybindDeviceListBinding
import com.lxj.xpopup.core.BottomPopupView
import net.lucode.hackware.magicindicator.FragmentContainerHelper
import net.lucode.hackware.magicindicator.buildins.UIUtil
import net.lucode.hackware.magicindicator.buildins.commonnavigator.CommonNavigator
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.CommonNavigatorAdapter
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerIndicator
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerTitleView
import net.lucode.hackware.magicindicator.buildins.commonnavigator.indicators.LinePagerIndicator
import net.lucode.hackware.magicindicator.buildins.commonnavigator.titles.ColorTransitionPagerTitleView
import net.lucode.hackware.magicindicator.buildins.commonnavigator.titles.SimplePagerTitleView

@SuppressLint("ViewConstructor")
class DialogMyBindDeviceList(
    context: Context,
    private val batteryListSale: MutableList<BindDevice>?,
    private val batteryListRent: MutableList<BindDevice>?,
    private val vehicleListSale: MutableList<BindDevice>?,
    private val vehicleListRent: MutableList<BindDevice>?,
    private var showType: Int,
    private val callBack: (data: String) -> Unit
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_mybind_device_list
    }

    companion object {
        const val TYPE_BATTERY = 1
        const val TYPE_VEHICLE = 2
    }


    private var mBinding: DialogMybindDeviceListBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        if (showType == TYPE_BATTERY) {
            mBinding?.tvTitleDevicetype?.text = context.getString(R.string.text_battery)
        } else if (showType == TYPE_VEHICLE) {
            mBinding?.tvTitleDevicetype?.text = context.getString(R.string.text_vehicle)
        }
        initIndicator()
        createAdapter(showType)
        refreshData(0)

    }

    private val mFragmentContainerHelper: FragmentContainerHelper = FragmentContainerHelper()
    private val mTitleDataList = ArrayList<String>()
    private lateinit var commonNavigator: CommonNavigator
    private fun initIndicator() {
        context?.let { context ->
            if (showType == TYPE_VEHICLE) {
                mTitleDataList.add(
                    context.getString(
                        R.string.str_userinfo_salebind_account,
                        vehicleListSale?.size
                    )
                )
                mTitleDataList.add(
                    context.getString(
                        R.string.str_userinfo_rentbind_account,
                        vehicleListRent?.size
                    )
                )
            } else {
                mTitleDataList.add(
                    context.getString(
                        R.string.str_userinfo_salebind_account,
                        batteryListSale?.size
                    )
                )
                mTitleDataList.add(
                    context.getString(
                        R.string.str_userinfo_rentbind_account,
                        batteryListRent?.size
                    )
                )

            }
            commonNavigator = CommonNavigator(context)
            commonNavigator.isAdjustMode = true
            commonNavigator.adapter = object : CommonNavigatorAdapter() {
                override fun getCount(): Int {
                    return mTitleDataList.size
                }

                override fun getTitleView(context: Context?, index: Int): IPagerTitleView {
                    val titleView: SimplePagerTitleView = ColorTransitionPagerTitleView(context)
                    titleView.text = mTitleDataList[index]
                    titleView.normalColor = Color.parseColor("#66000000")
                    titleView.selectedColor = Color.parseColor("#e6000000")
                    titleView.textSize = 13f
                    titleView.setOnClickListener {
                        mFragmentContainerHelper.handlePageSelected(index)
                        refreshData(index)
                    }
                    return titleView
                }

                override fun getIndicator(context: Context?): IPagerIndicator {
                    val indicator = LinePagerIndicator(context)
                    indicator.mode = LinePagerIndicator.MODE_EXACTLY
                    indicator.lineWidth = UIUtil.dip2px(context, 68.0).toFloat()
                    indicator.setColors(Color.parseColor("#FF56B327"))
                    return indicator
                }
            }
            mBinding?.magicIndicator?.navigator = commonNavigator
            mFragmentContainerHelper.attachMagicIndicator(mBinding?.magicIndicator)
        }
    }

    private fun refreshData(index: Int) {
        when (index) {
            0 -> {
                //销售绑定
                when (showType) {
                    TYPE_BATTERY -> {
                        batteryAdapter.setNewData(batteryListSale)
                        switchViewByData(batteryListSale)
                    }

                    TYPE_VEHICLE -> {
                        vehicleAdapter.setNewData(vehicleListSale)
                        switchViewByData(vehicleListSale)

                    }
                }
            }

            1 -> {
                //租赁绑定
                when (showType) {
                    TYPE_BATTERY -> {
                        batteryAdapter.setNewData(batteryListRent)
                        switchViewByData(batteryListRent)

                    }

                    TYPE_VEHICLE -> {
                        vehicleAdapter.setNewData(vehicleListRent)
                        switchViewByData(vehicleListRent)

                    }
                }
            }
        }
    }

    private fun switchViewByData(list: List<BindDevice>?) {
        if (list.isNullOrEmpty()) {
            mBinding?.emptyLayout?.dataErrorView?.visibility = View.VISIBLE
            mBinding?.emptyLayout?.dataErrorInfoIv?.setImageResource(R.mipmap.empty_user_binddevice)
            mBinding?.emptyLayout?.dataErrorInfoTv?.text =
                context.getString(R.string.empty_user_bind_device)
            mBinding?.rvList?.visibility = View.GONE
        } else {
            mBinding?.emptyLayout?.dataErrorView?.visibility = View.GONE
            mBinding?.rvList?.visibility = View.VISIBLE
        }
    }

    private lateinit var batteryAdapter: SingleDataBindingNoPUseAdapter<BindDevice>
    private lateinit var vehicleAdapter: SingleDataBindingNoPUseAdapter<BindDevice>
    private fun createAdapter(showType: Int) {
        mBinding?.rvList?.layoutManager =
            LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        if (showType == TYPE_VEHICLE) {
            vehicleAdapter = object :
                SingleDataBindingNoPUseAdapter<BindDevice>(R.layout.item_userdetail_bindvehicle) {
                override fun convert(helper: BaseViewHolder, item: BindDevice) {
                    super.convert(helper, item)
                    val imgDevice = helper.getView<ImageView>(R.id.img_device)
                    Glide.with(mContext).load(item.img).into(imgDevice)
                    //status 1正常 2待保养
                    if (item.status == 2) {
                        helper.setGone(R.id.tv_status, true)
                    } else {
                        helper.setGone(R.id.tv_status, false)
                    }
                    helper.setText(R.id.tv_device_sn, item.deviceSn)
                    helper.setText(
                        R.id.tv_bindtime, DateTimeUtils.getTimeString(
                            DateTimeUtils.dateFormat3, item.bindDate ?: 0
                        ).plus(" ").plus(context.getString(R.string.str_bind))
                    )
                    helper.setText(R.id.tv_model, item.model)
                    if (!item.carNumber.isNullOrBlank()) {
                        helper.setText(R.id.tv_platenumber, item.carNumber)
                    }
                    helper.setText(R.id.tv_spec, item.modelName)
                }
            }
            vehicleAdapter.setNewData(vehicleListSale)
            vehicleAdapter.onItemClickListener =
                BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                    val item = adapter.data[position] as BindDevice
                    callBack.invoke(item.deviceSn ?: "")
                    dismiss()
                }
            mBinding?.rvList?.adapter = vehicleAdapter
        } else if (showType == TYPE_BATTERY) {
            batteryAdapter = object :
                SingleDataBindingNoPUseAdapter<BindDevice>(R.layout.item_userdetail_bindbattery) {
                override fun convert(helper: BaseViewHolder, item: BindDevice) {
                    super.convert(helper, item)
                    val imgDevice = helper.getView<ImageView>(R.id.img_battery)
                    Glide.with(mContext).load(item.img).into(imgDevice)
                    helper.setText(R.id.tv_device_sn, item.deviceSn)
                    helper.setText(
                        R.id.tv_bindtime, DateTimeUtils.getTimeString(
                            DateTimeUtils.dateFormat3, item.bindDate ?: 0
                        ).plus(" ").plus(context.getString(R.string.str_bind))
                    )
                    if (null != item.soc) {
                        helper.setText(R.id.tv_soc, item.soc.toString().plus("%"))
                    } else {
                        helper.setText(R.id.tv_soc, "-".plus("%"))
                    }
                    helper.setText(R.id.tv_spec, item.modelName)
                    helper.setText(R.id.tv_model, item.model)
                    val tvStatus = helper.getView<TextView>(R.id.tv_status)
                    if (null != item.onlineFlag) {
                        if (item.onlineFlag == 0) {
                            tvStatus.text = mContext.getString(R.string.offline)
                            tvStatus.setTextColor(mContext.getColor(R.color.color_ffa4332))
                            tvStatus.setBackgroundResource(R.drawable.bg_line_fa4332_r4)
                        } else if (item.onlineFlag == 1) {
                            tvStatus.text = mContext.getString(R.string.online)
                            tvStatus.setTextColor(mContext.getColor(R.color.main_color))
                            tvStatus.setBackgroundResource(R.drawable.bg_line_maincolor_r4)
                        }
                    }
                }
            }
            batteryAdapter.setNewData(batteryListSale)
            batteryAdapter.onItemClickListener =
                BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                    val item = adapter.data[position] as BindDevice
                    callBack.invoke(item.deviceSn ?: "")
                    dismiss()
                }
            mBinding?.rvList?.adapter = batteryAdapter
        }
    }
}