package com.okla.ops.dialog

import android.annotation.SuppressLint
import android.content.Context
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.custom.BackgroundItemDecoration
import com.base.common.custom.SpaceItemDecoration
import com.base.library.utils.DensityUtils
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.lxj.xpopup.core.BottomPopupView
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.City
import com.okla.ops.databinding.DialogCityListBinding

@SuppressLint("ViewConstructor")
class DialogCityList(
    context: Context,
    private val cityList: MutableList<City>,
    private val callBack: (city: City) -> Unit
) : BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.dialog_city_list
    }

    private var mBinding: DialogCityListBinding? = null
    override fun onCreate() {
        super.onCreate()
        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
        mBinding?.btnCancel?.setOnClickListener {
            callBack.invoke(City(null,0.0,0.0,context.getString(R.string.text_all_city),false))
            dismiss()
        }
        createAdapter()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<City>
    private fun createAdapter() {
        mBinding?.rvCity?.layoutManager =
            LinearLayoutManager(context, RecyclerView.VERTICAL, false)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<City>(R.layout.layout_text_simple) {
            override fun convert(helper: BaseViewHolder, item: City) {
                super.convert(helper, item)
                item.run {
                    val tvContent = helper.getView<AppCompatTextView>(R.id.tvContent)
                    tvContent.text = item.name
                    tvContent.setTextColor(
                        if (selected) ContextCompat.getColor(
                            context,
                            R.color.main_color
                        ) else ContextCompat.getColor(context, R.color.color_e60c0c0d)
                    )
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                val city = adapter.data[position] as City
                adapter.data.forEachIndexed { index, item ->
                    if (item is City) {
                        if (item.selected) {
                            item.selected = false
                            mAdapter.notifyItemChanged(index)
                        }
                    }
                }
                city.selected = true
                mAdapter.notifyItemChanged(position)
                callBack.invoke(city)
                dismiss()
            }
        mBinding?.rvCity?.adapter = mAdapter
        mAdapter.setNewData(cityList)
    }

    fun setCityList(list: MutableList<City>) {
        mAdapter.setNewData(list)
    }
}