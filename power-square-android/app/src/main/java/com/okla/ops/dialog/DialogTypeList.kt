//package com.okla.ops.dialog
//
//import android.annotation.SuppressLint
//import android.content.Context
//import androidx.appcompat.widget.AppCompatTextView
//import androidx.core.content.ContextCompat
//import androidx.databinding.DataBindingUtil
//import androidx.recyclerview.widget.LinearLayoutManager
//import androidx.recyclerview.widget.RecyclerView
//import com.chad.library.adapter.base.BaseQuickAdapter
//import com.chad.library.adapter.base.BaseViewHolder
//import com.lxj.xpopup.core.BottomPopupView
//import com.okla.ops.R
//import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
//import com.okla.ops.beans.DataType
//import com.okla.ops.databinding.DialogListBinding
//
//@SuppressLint("ViewConstructor")
//class DialogTypeList(
//    context: Context,
//    private val dataTypeList: MutableList<DataType>,
//    private val callBack: (dataType: DataType) -> Unit
//) :
//    BottomPopupView(context) {
//
//    override fun getImplLayoutId(): Int {
//        return R.layout.dialog_list
//    }
//
//    private var mBinding: DialogListBinding? = null
//    override fun onCreate() {
//        super.onCreate()
//        mBinding = DataBindingUtil.bind(bottomPopupContainer.getChildAt(0))
//        mBinding?.btnCancel?.setOnClickListener {
//            dismiss()
//        }
//        createAdapter()
//    }
//
//    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<DataType>
//    private fun createAdapter() {
//        mBinding?.rvList?.layoutManager =
//            LinearLayoutManager(context, RecyclerView.VERTICAL, false)
//        mAdapter = object :
//            SingleDataBindingNoPUseAdapter<DataType>(R.layout.layout_text_simple) {
//            override fun convert(helper: BaseViewHolder, item: DataType) {
//                super.convert(helper, item)
//                item.run {
//                    val tvContent = helper.getView<AppCompatTextView>(R.id.tvContent)
//                    tvContent.text = name
//                    tvContent.setTextColor(
//                        if (selected) ContextCompat.getColor(
//                            context,
//                            R.color.main_color
//                        ) else ContextCompat.getColor(context, R.color.color_e60c0c0d)
//                    )
//                }
//            }
//        }
//        mAdapter.onItemClickListener =
//            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
//                val dataType = adapter.data[position] as DataType
//                adapter.data.forEachIndexed { index, item ->
//                    if (item is DataType) {
//                        if (item.selected) {
//                            item.selected = false
//                            mAdapter.notifyItemChanged(index)
//                        }
//                    }
//                }
//                dataType.selected = true
//                mAdapter.notifyItemChanged(position)
//                callBack.invoke(dataType)
//                dismiss()
//            }
//        var isItemSelected = false
//        dataTypeList.forEach {
//            if (it.selected) {
//                isItemSelected = true
//            }
//        }
//        if (!isItemSelected) {
//            dataTypeList.firstOrNull()?.selected = true
//        }
//        mBinding?.rvList?.adapter = mAdapter
//        mAdapter.setNewData(dataTypeList)
//    }
//
//}