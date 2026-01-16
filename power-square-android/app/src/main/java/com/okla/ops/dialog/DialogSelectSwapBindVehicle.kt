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
import com.okla.ops.beans.CarVo
import com.okla.ops.databinding.DialogSwapbindSelectVehicleBinding
import com.lxj.xpopup.core.BottomPopupView

@SuppressLint("ViewConstructor")
class DialogSelectSwapBindVehicle(
    context: Context,
    private val carVoList: MutableList<CarVo>,
    private val callBack: SelectCallBack
) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_swapbind_select_vehicle
    }

    private var mBinding: DialogSwapbindSelectVehicleBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.btnCancel?.setOnClickListener {
            dismiss()
        }
        createAdapter()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<CarVo>
    private fun createAdapter() {
        mBinding?.rvCars?.layoutManager = LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<CarVo>(R.layout.item_swapbind_select_car) {
            override fun convert(helper: BaseViewHolder, item: CarVo) {
                super.convert(helper, item)
                item.run {
                    val img = helper.getView<ImageView>(R.id.img_car)
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
                    } else if(item.bindSource==2){
                        tvRentDay.visibility = View.VISIBLE
                        if (item.rentDay != null) {
                            val rentDays = item.rentDay?.toString() ?: "-"
                            val fullText = context.getString(
                                com.base.common.R.string.str_remain_rental_days,
                                rentDays
                            )
                            if(fullText!=null){
                                val spannable = SpannableString(fullText)
                                val colonIndex = fullText.indexOf(":")
                                if (colonIndex != -1 && colonIndex + 1 < fullText.length) {
                                    spannable.setSpan(
                                        ForegroundColorSpan(Color.parseColor("#00B88A")),
                                        colonIndex + 1,
                                        fullText.length,
                                        Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                                    )
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
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                val car = adapter.data[position] as CarVo
                adapter.data.forEachIndexed { index, item ->
                    mAdapter.data.get(index).isSelected = index == position
                }
                mAdapter.notifyDataSetChanged()
                callBack.onSelectedCar(car)
                mBinding?.rvCars?.postDelayed(Runnable {
                    dismiss()
                }, 800)
            }
        mAdapter.setNewData(carVoList)
        mBinding?.rvCars?.adapter = mAdapter
    }

    interface SelectCallBack {
        fun onSelectedCar(car: CarVo)
    }
}