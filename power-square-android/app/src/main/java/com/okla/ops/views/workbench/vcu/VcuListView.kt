package com.okla.ops.views.workbench.vcu

import android.content.Context
import android.view.LayoutInflater
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.custom.NoLastDividerItemDecoration
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter

class VcuListView(context: Context) :
    VcuCustomView(context) {

    init {
        initView()
    }

    private lateinit var recyclerView: RecyclerView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.view_vcu_list, this)
        recyclerView = findViewById(R.id.recycler_view)
        recyclerView.layoutManager = LinearLayoutManager(context)
        createAdapter()
        val drawable = ContextCompat.getDrawable(context, com.base.common.R.drawable.divider_line)
        drawable?.let {
            recyclerView.addItemDecoration(NoLastDividerItemDecoration(it))
        }
        recyclerView.adapter = mAdapter
    }

    private var mData: VcuData? = null
    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<VcuData>
    private fun createAdapter(): RecyclerView.Adapter<*> {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<VcuData>(R.layout.item_vcu) {
            override fun convert(
                helper: BaseViewHolder,
                item: VcuData
            ) {
                super.convert(helper, item)
                val tvVcuData = helper.getView<AppCompatTextView>(R.id.tvVcuData)
                tvVcuData.isSelected = item.select
                tvVcuData.text = item.name
            }
        }
        mAdapter.setOnItemClickListener { adapter, _, position ->
            adapter.data.forEachIndexed { index, item ->
                val vcu = item as VcuData
                if (vcu.select) {
                    vcu.select = false
                    adapter.notifyItemChanged(index)
                }
            }
            val vcuData = adapter.data[position] as VcuData
            vcuData.select = true
            adapter.notifyItemChanged(position)
            mData = vcuData
        }
        return mAdapter
    }

    fun updateData(list: MutableList<VcuData>) {
        mAdapter.setNewData(list)
        if (list.isNotEmpty()) {
            mData = list[0]
        }
    }

    override fun newData(): VcuData {
        return mData ?: VcuData("", "", select = false, net = false)
    }

}