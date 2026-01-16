package com.okla.ops.dialog

import android.app.Dialog
import android.os.Bundle
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.viewModels
import androidx.recyclerview.widget.RecyclerView
import com.base.common.utils.DensityUtil
import com.base.common.utils.NumToStrUtil
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.ServicePlanBean
import com.okla.ops.views.workbench.sales.sellbind.SellBindViewModel
import com.okla.ops.weight.SnSearchInfoView.OnEditTextChangedListener
import com.scwang.smartrefresh.layout.SmartRefreshLayout
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.subjects.PublishSubject
import java.util.concurrent.TimeUnit

class SalebindPackageDialogFragment(private val callBack: SelectCallBack) : DialogFragment() {
    private var serviceId: String = ""
    private var selectBatteryType = ""
    private var selectCarType = ""
    private var serviceName = ""
    private var pageIndex = 1;
    private var pageSize = 10;
    private val inputSubject = PublishSubject.create<String>()
    private var inputDispose: Disposable? = null
    private lateinit var etSearch: EditText
    private lateinit var refreshlayout: SmartRefreshLayout
    private lateinit var flEmptyPackage: FrameLayout
    private lateinit var recyclerView: RecyclerView
    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<ServicePlanBean>
    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        // 获取布局
        val inflater: LayoutInflater = requireActivity().layoutInflater
        val view: View = inflater.inflate(R.layout.dialog_select_sellbind_package, null)
        etSearch = view.findViewById(R.id.edtSearch)
        refreshlayout = view.findViewById(R.id.refreshlayout)
        flEmptyPackage = view.findViewById(R.id.fl_empty_package)
        recyclerView = view.findViewById(R.id.rv_servers_info)
        val imgClose = view.findViewById<ImageView>(R.id.imgclose)
        imgClose.setOnClickListener {
            dismissAllowingStateLoss()
        }
        initAdapter()
        initObserver()
        initListener()
        viewModel.getServicePlanByName(serviceName, pageIndex, pageSize)
        val dialog = Dialog(requireContext())
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(view) // 使用自定义布局
        setupDialogWindow(dialog.window) // 统一设置窗口属性
        dialog.setCancelable(false) // 禁用返回键关闭
        dialog.setCanceledOnTouchOutside(false) // 禁用点击外部关闭
        return dialog
    }

    // 统一窗口配置逻辑
    private fun setupDialogWindow(window: Window?) {
        window?.apply {
            // 设置宽高
            setLayout(
                ViewGroup.LayoutParams.MATCH_PARENT,
                (DensityUtil.getScreenHeight(context) * 0.8).toInt()
            )
            // 样式配置
            setBackgroundDrawableResource(R.drawable.bg_top_r16_ffffff)
            setGravity(Gravity.BOTTOM)
        }
    }

    // 使用 by viewModels() 初始化独立的 ViewModel，作用域限定在 DialogFragment 内
    private val viewModel: SellBindViewModel by viewModels()


    private fun initObserver() {
        // 设置订阅，防抖处理
        inputDispose = inputSubject
            .debounce(1000, TimeUnit.MILLISECONDS)
            .observeOn(AndroidSchedulers.mainThread())
            .distinctUntilChanged() // 去重，输入没变化就不触发
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { inputText ->
                viewModel.getServicePlanByName(serviceName, pageIndex, pageSize)
            }
        viewModel.servicePlanBeanLiveData.observe(this, {
            if (it.isNullOrEmpty()) {
                if (pageIndex == 1) {
                    refreshlayout.visibility = View.GONE
                    flEmptyPackage.visibility = View.VISIBLE
                } else {
                    refreshlayout.finishLoadMoreWithNoMoreData()
                }
            } else {
                refreshlayout.setEnableLoadMore(true)
                refreshlayout.finishRefresh()
                refreshlayout.finishLoadMore()
                if (pageIndex == 1) {
                    refreshlayout.visibility = View.VISIBLE
                    flEmptyPackage.visibility = View.GONE
                    mAdapter.setNewData(it)
                } else {
                    mAdapter.addData(it)
                }
            }
        })
    }


    private fun initAdapter() {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<ServicePlanBean>(R.layout.layout_serviceplan_info) {
            override fun convert(
                helper: BaseViewHolder,
                item: ServicePlanBean
            ) {
                super.convert(helper, item)
                val tvDeviceType = helper.getView<AppCompatTextView>(R.id.tv_device_type)
                val tvPrice = helper.getView<AppCompatTextView>(R.id.tv_price)
                val tvServiceName = helper.getView<AppCompatTextView>(R.id.tv_service_name)
                val imgState = helper.getView<ImageView>(R.id.img_check_status)
                if (!TextUtils.isEmpty(item.carType?.trim())) {
                    tvDeviceType.text =
                        context?.getString(R.string.text_vehicle).plus(" • ").plus(item.carType)
                }
                if (!TextUtils.isEmpty(item.batteryType?.trim())) {
                    tvDeviceType.text =
                        context?.getString(R.string.text_battery).plus(" • ").plus(item.batteryType)
                }
                if (item.packageAmount != null) {
                    tvPrice.text = "$".plus(NumToStrUtil.DoubleToStrWith2(item.packageAmount))
                } else {
                    tvPrice.text = "$".plus("-")
                }
                tvServiceName.text = item.infoName ?: "-"
                if (item.isSelected) {
                    imgState.setImageResource(R.mipmap.icon_green_checked)
                } else {
                    imgState.setImageResource(R.mipmap.icon_grey_unchecked)
                }
            }
        }
        mAdapter.setOnItemClickListener { adapter, _, position ->
            mAdapter.data.forEachIndexed { index, servicePlanBean ->
                mAdapter.data.get(index).isSelected = index == position
            }
            mAdapter.notifyDataSetChanged()
            val servicePlanBean = adapter.data[position] as ServicePlanBean
            callBack.onSelected(servicePlanBean)
            recyclerView.postDelayed(kotlinx.coroutines.Runnable {
                dismissAllowingStateLoss()
            }, 500)
        }
        recyclerView.adapter = mAdapter
    }

    private fun initListener() {
        etSearch.addTextChangedListener(object : OnEditTextChangedListener, TextWatcher {
            override fun onTextChange(data: String?) {
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }

            override fun afterTextChanged(s: Editable?) {
                serviceName = etSearch.text.toString()
                // 将输入变化推送给 PublishSubject
                inputSubject.onNext(serviceName)
            }
        })
        etSearch.setOnEditorActionListener { v, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                serviceName = v.text.toString()
                pageIndex = 1
                viewModel.getServicePlanByName(serviceName, pageIndex, pageSize)
                true
            } else {
                false
            }
        }
        refreshlayout.setOnLoadMoreListener {
            pageIndex++
            viewModel.getServicePlanByName(serviceName, pageIndex, pageSize)
        }
    }

    interface SelectCallBack {
        fun onSelected(bean: ServicePlanBean)
    }

    override fun onDetach() {
        inputDispose?.dispose()
        inputDispose = null
        super.onDetach()
    }
}