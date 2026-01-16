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
class DialogSelectRentBindPackage(
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
            SingleDataBindingNoPUseAdapter<Pack>(R.layout.item_rentbind_packageinfo) {
            override fun convert(helper: BaseViewHolder, item: Pack) {
                super.convert(helper, item)
                item.run {
                    val tvContent = helper.getView<AppCompatTextView>(R.id.tv_name)
                    tvContent.text = item.infoName
                    val packageAmount = item.packageAmount?.let { NumToStrUtil.DoubleToStrWith2(it) }
                    helper.setText(R.id.tv_amount, "$".plus(packageAmount))
                    //infotype 0包自然月 1固定周期
                    //havedeposit 0否 1是
                    var str1 = ""
                    var str2 = ""
                    if (infoType == 1) {
                        str1 = resources.getString(R.string.fixed_cycle)
                        if (item.duration != null) {
                            str2 = (" • ").plus(item.duration).plus(mContext.getString(R.string.str_days))
                        } else {
                            str2 = (" • ").plus("-").plus(mContext.getString(R.string.str_days))
                        }
                    } else {
                        str1 = resources.getString(R.string.full_calendar_month)
                    }
                    helper.setText(
                        R.id.tv_period, str1
                            .plus(str2)
                    )
                    val depositAmount = item.depositAmount?.let { NumToStrUtil.DoubleToStrWith2(it) }
                    helper.setText(R.id.tv_deposit, "$".plus(depositAmount))
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
                callBack.onSelectedRentPack(pack)
                mBinding?.rvRent?.postDelayed(Runnable {
                    dismiss()
                }, 1000)
            }
        mAdapter.setNewData(packList)
        mBinding?.rvRent?.adapter = mAdapter
    }

    interface SelectCallBack {
        fun onSelectedRentPack(pack: Pack)
    }
}