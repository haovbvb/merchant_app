package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.BatteryVo
import com.okla.ops.databinding.DialogSwapbindSelectBatteryBinding
import com.lxj.xpopup.core.BottomPopupView

@SuppressLint("ViewConstructor")
class DialogSelectSwapBindBattery(
    context: Context,
    private val batteryList: MutableList<BatteryVo>,
    private val maxSelectCount: Int,
    private val isReplace: Boolean,
    private var haveSelectModel: String,
    private val callBack: SelectCallBack
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_swapbind_select_battery
    }

    private var selectTotalCount = 0;
    private var lastSelectModel = ""
    private var selectBatteryList = ArrayList<BatteryVo>()
    private var mBinding: DialogSwapbindSelectBatteryBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.btnCancel?.setOnClickListener {
            dismiss()
        }
//        mBinding?.btnConfirm?.setOnClickListener {
//            callBack.onSelectedBattery(selectBatteryList)
//            dismiss()
//        }
//        if (isReplace) {
//            batteryList.forEachIndexed { index, batteryVo ->
//                if (batteryVo.isSelected) {
//                    selectBatteryList.add(batteryVo)
//                }
//            }
//            selectTotalCount = 1;
//        }
        createAdapter()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<BatteryVo>
    private fun createAdapter() {
        mBinding?.rvBatterys?.layoutManager =
            LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<BatteryVo>(R.layout.item_swapbind_select_battery) {
            override fun convert(helper: BaseViewHolder, item: BatteryVo) {
                super.convert(helper, item)
                item.run {
                    if(helper.adapterPosition==batteryList.size-1){
                        helper.setGone(R.id.devideline,false)
                    }else{
                        helper.setGone(R.id.devideline,true)
                    }
                    val img = helper.getView<ImageView>(R.id.img_battery)
                    Glide.with(context).load(item.img).into(img)
                    helper.setText(R.id.tv_sn, "SN:".plus(item.sn))
                    helper.setText(R.id.tv_model, item.model.plus(" • ").plus(item.spec))
                    if (item.isSelected) {
                        helper.setImageResource(R.id.img_select, R.mipmap.icon_green_checked)
                    } else {
                        helper.setImageResource(R.id.img_select, R.mipmap.icon_grey_unchecked)
                    }
                    val tvRentDay = helper.getView<TextView>(R.id.tv_remain_day)
                    if (item.bindSource == 1) {
                        tvRentDay.visibility = View.GONE
                    } else if (bindSource == 2) {
                        tvRentDay.visibility = View.VISIBLE
                        if (item.rentDay != null) {
                            val rentDays = item.rentDay?.toString() ?: "-"
                            val fullText:String? = context.getString(
                                com.base.common.R.string.str_remain_rental_days,
                                rentDays
                            )
                            fullText?.let {
                                val spannable = SpannableString(fullText)
                                val colonIndex = fullText?.indexOf(":")
                                if (colonIndex != null) {
                                    if (colonIndex != -1 && colonIndex + 1 < fullText.length) {
                                        spannable.setSpan(
                                            ForegroundColorSpan(Color.parseColor("#00B88A")),
                                            colonIndex + 1,
                                            fullText.length?:0,
                                            Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                                        )
                                    }
                                }
                                tvRentDay.text = spannable
                            }

                        } else {
                            tvRentDay.text =
                                context.getString(
                                    com.base.common.R.string.str_remain_rental_days,
                                    "-"
                                )
                        }

                    }

                }
            }
        }
        mAdapter.setOnItemClickListener(listener)
        mAdapter.setNewData(batteryList)
        mBinding?.rvBatterys?.adapter = mAdapter
    }

    val listener = object : BaseQuickAdapter.OnItemClickListener {
        override fun onItemClick(adapter: BaseQuickAdapter<*, *>?, view: View?, position: Int) {
//            //多选 最多选maxSelectCount个
//            val item = adapter?.getItem(position) as BatteryVo
//            if (selectTotalCount >= maxSelectCount && !item.isSelected) {
//                // 超出最大选择数量，且当前项不是已选的，不允许选择
//                ToastUtils.showShort(context.getString(R.string.str_select_limit,maxSelectCount))
//                return
//            }
//            if(!TextUtils.isEmpty(haveSelectModel)&&!item.model.equals(haveSelectModel)){
//                ToastUtils.showShort("must select the same model")
//                return
//            }
//            if (!TextUtils.isEmpty(lastSelectModel) && !item.model.equals(lastSelectModel)) {
//                ToastUtils.showShort("must select the same model")
//                return
//            }
//            item.isSelected = !item.isSelected
//            if (item.isSelected) {
//                selectTotalCount += 1
//                selectBatteryList.add(item)
//                lastSelectModel = item.model?:""
//            } else {
//                selectTotalCount -= 1
//                selectBatteryList.remove(item)
//                if(!selectBatteryList.isNullOrEmpty()){
//                    selectBatteryList.forEach {
//                        if(it.isSelected){
//                            lastSelectModel = it.model?:""
//                        }
//                    }
//                }else{
//                    lastSelectModel=""
//                }
//
            //单选
            selectBatteryList.clear()
            val item = adapter?.getItem(position) as BatteryVo
            adapter.data.forEachIndexed { index, item ->
                mAdapter.data.get(index).isSelected = index == position
            }
            selectBatteryList.add(item)
            mAdapter.notifyDataSetChanged()
            callBack?.onSelectedBattery(selectBatteryList)
            dismiss()
        }
    }

    interface SelectCallBack {
        fun onSelectedBattery(battery: List<BatteryVo>)
    }
}