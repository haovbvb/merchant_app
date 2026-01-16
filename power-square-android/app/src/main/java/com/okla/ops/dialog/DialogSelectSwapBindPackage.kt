package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import androidx.appcompat.widget.AppCompatTextView
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.utils.NumToStrUtil
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.databinding.DialogRentbindSelectpackageBinding
import com.okla.ops.views.workbench.sales.rentbind.Pack
import com.lxj.xpopup.core.BottomPopupView
import java.util.Locale

@SuppressLint("ViewConstructor")
class DialogSelectSwapBindPackage(
    context: Context,
    private val packList: MutableList<Pack>,
    private val callBack: SelectCallBack
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_rentbind_selectpackage
    }

    private var mBinding: DialogRentbindSelectpackageBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.tvCancel?.setOnClickListener {
            dismiss()
        }
        createAdapter()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<Pack>
    private fun createAdapter() {
        mBinding?.rvRent?.layoutManager = LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<Pack>(R.layout.item_swapbind_select_package) {
            override fun convert(helper: BaseViewHolder, item: Pack) {
                super.convert(helper, item)
                item.run {
                    helper.setText(R.id.tv_battery_available, item.batteryType ?: "-")
                    helper.setText(R.id.tv_vehicle_available, item.carType ?: "-")
                    val tvContent = helper.getView<AppCompatTextView>(R.id.tv_name)
                    tvContent.text = item.infoName
                    val amount = item.packageAmount?.let { NumToStrUtil.DoubleToStrWith2(it) }
                    helper.setText(R.id.tv_amount, "$".plus(amount))
                    //infotype 0包自然月 1固定周期
                    //havedeposit 0否 1是
                    val infoType = item.infoType;
                    var str1 = ""
                    var str2 = ""
                    if (infoType != null) {
                        if (infoType == 1) {
                            str1 = resources.getString(R.string.fixed_cycle)
                            if (item.duration != null) {
                                str2 = (" • ").plus(item.duration)
                                    .plus(mContext.getString(R.string.str_days))
                            } else {
                                str2 = (" • ").plus("-").plus(mContext.getString(R.string.str_days))
                            }
                        } else {
                            str1 = resources.getString(R.string.full_calendar_month)
                        }
                    } else {
                        str1 = "-"
                    }
                    helper.setText(
                        R.id.tv_period, str1.plus(str2)
                    )

                    if (item.times != null) {
                        helper.setText(R.id.tv_swaptime, item.times.toString())
                    }
                    if (item.isSelected) {
                        helper.setImageResource(R.id.img_select, R.mipmap.icon_green_checked)
                    } else {
                        helper.setImageResource(R.id.img_select, R.mipmap.icon_grey_unchecked)
                    }
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                val pack = adapter.data[position] as Pack
                adapter.data.forEachIndexed { index, item ->
                    mAdapter.data.get(index).isSelected = index == position
                }
                mAdapter.notifyDataSetChanged()
                callBack.onSelectedSwapBindPack(pack)
                mBinding?.rvRent?.postDelayed(Runnable {
                    dismiss()
                }, 1000)
            }
        mAdapter.setNewData(packList)
        mBinding?.rvRent?.adapter = mAdapter
    }

    interface SelectCallBack {
        fun onSelectedSwapBindPack(pack: Pack)
    }
}