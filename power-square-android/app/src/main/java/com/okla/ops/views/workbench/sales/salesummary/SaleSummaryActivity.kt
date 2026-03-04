package com.okla.ops.views.workbench.sales.salesummary

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.text.SpannableString
import android.text.Spanned
import android.text.TextUtils
import android.text.style.ForegroundColorSpan
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.dialog.CustomDialog
import com.base.common.timepicker.CustomDatePicker
import com.base.common.timepicker.DateFormatUtils
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.base.common.utils.LanguageUtils
import com.base.common.utils.NumToStrUtil
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.chad.library.adapter.base.BaseViewHolder
import com.github.mikephil.charting.components.XAxis
import com.github.mikephil.charting.data.BarData
import com.github.mikephil.charting.data.BarDataSet
import com.github.mikephil.charting.data.BarEntry
import com.github.mikephil.charting.data.CombinedData
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.data.LineData
import com.github.mikephil.charting.data.LineDataSet
import com.github.mikephil.charting.formatter.ValueFormatter
import com.google.android.material.tabs.TabLayout
import com.google.android.material.tabs.TabLayout.OnTabSelectedListener
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.AmountListResp
import com.okla.ops.beans.OrderItem
import com.okla.ops.beans.OrderListResp
import com.okla.ops.beans.PayTypeObject
import com.okla.ops.databinding.ActivitySalesummaryBinding
import com.okla.ops.dialog.DialogSelectDate
import com.okla.ops.dialog.DialogSlectStatisticsData
import com.okla.ops.utils.StringUtils
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.sales.depositrefund.ViewReceiptDialogFragment
import com.lxj.xpopup.XPopup
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit
import java.util.Locale


class SaleSummaryActivity :
    BaseNormalVActivity<SaleSummaryViewModel, ActivitySalesummaryBinding>() {
    private var mAdapter: SingleDataBindingNoPUseAdapter<OrderItem>? = null
    private val orderList: MutableList<OrderListResp> = mutableListOf()
    private val amountList: MutableList<AmountListResp> = mutableListOf()
    private val mTitleDataList = mutableListOf<String>()

    //    private var quantityData: ArrayList<String>? = null
    private var xDateData: ArrayList<String>? = null
    private var lineDataSet: LineDataSet? = null
    private var barDataSet: BarDataSet? = null
    private var combinedData = CombinedData()
    private var mStartDate: String? = null
    private var mEndDate: String? = null
    private var maxAmount = 0f
    private var maxBat = 0f
    private var lineData = LineData()
    private var barData = BarData()
    private var isChooseLine = true
    private var isManager = false
    private val mTitleDataList2 = mutableListOf<String>()
    private var mStatus: Int? = null


    companion object {
        fun startActivity(context: Context) {
            val intent = Intent(context, SaleSummaryActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): SaleSummaryViewModel {
        return ViewModelProvider(this).get(SaleSummaryViewModel::class.java);
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_salesummary
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarDarkMode(this)
        initTabData()
        initIndicator()
        initAdapter()
        initObserver()
        initClick()
        initData()
        initTimerPickerStart(mStartDateLast ?: "")
        initTimerPickerEnd(mEndDateLast ?: "")
        initDialogSelectDate()
        refreshListData()
    }

    private fun initIndicator() {
        //初始化标题列表（可根据需要清空再填充）
        mTitleDataList2.clear()
        mTitleDataList2.add(getString(R.string.transport_all))
        mTitleDataList2.add(getString(R.string.text_cash))
        mTitleDataList2.add(getString(R.string.text_online))
        mTitleDataList2.forEach { title ->
            val tab = mBinding.tablayout2.newTab()
            val customView = LayoutInflater.from(this).inflate(R.layout.layout_custom_tab_2, null)
            customView.findViewById<TextView>(R.id.tabText).text = title
            tab.customView = customView
            mBinding.tablayout2.addTab(tab)
        }
        mBinding.tablayout2.setSelectedTabIndicator(null)
        mBinding.tablayout2.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = true
                val position = tab?.position ?: 0
                mStatus = when (position) {
                    0 -> null
                    1 -> 1
                    2 -> 2
                    else -> mStatus
                }
                pageIndex = 1
                refreshListData()
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = false

            }

            override fun onTabReselected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = true

            }
        })

    }

    private fun initData() {
        isManager = DataStoreUtils.readBooleanData(DataStoreKeyUtils.MANAGER, false)
        if (isManager) {
            mBinding.ivSelect.visibility = View.VISIBLE
            mBinding.tvTitleSaledata.setOnClickListener(this)
            mBinding.ivSelect.setOnClickListener(this)
        } else {
            mBinding.ivSelect.visibility = View.GONE
        }
        val local = LanguageUtils.LanguageUtil.getLocalByLanguage()
        mToday = DateFormatUtils.formatTranslate(DateTimeUtils.getToday(local), local)
//        mDefaultStartDate =
//            DateTimeUtils.getPast29Day(LanguageUtils.LanguageUtil.getLocalByLanguage())
        mCurrentMonthFristDay =
            DateFormatUtils.formatTranslate(DateTimeUtils.getFirstDayOfMonth(local), local)
        mStartDate = mCurrentMonthFristDay
//        mEndDate = mToday
//        mEndDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))
        // 开始日期：29天前（包括今天一共 30 天）
        mEndDate = mToday
//        mStartDate = mDefaultStartDate
        mBinding.tvDate.text = mStartDate.plus("~").plus(mEndDate)
        mStartDateLast = mStartDate
        mEndDateLast = mEndDate
//        mStartDateLast?.let { initTimerPicker(it,1) }
//        mEndDateLast?.let { initTimerPicker(it,2) }
        getViewModel().getSellPageRankData(mStartDate ?: "", mEndDate ?: "")
        getViewModel().get12MonthOrderData()
        mBinding.barChart.setPadding(
            DensityUtil.dp2px(6f),
            0,
            DensityUtil.dp2px(6f),
            DensityUtil.dp2px(12f)
        )
    }

    private fun initTabData() {
        mTitleDataList.clear()
        mTitleDataList.add(getString(R.string.str_sales_amount))
        mTitleDataList.add(getString(R.string.str_transaction_order))
        mTitleDataList.forEach {
            mBinding.tablayout.addTab(mBinding.tablayout.newTab().setText(it))
        }
        mBinding.tablayout.addOnTabSelectedListener(object : OnTabSelectedListener {
            override fun onTabReselected(tab: TabLayout.Tab?) {
            }

            override fun onTabSelected(tab: TabLayout.Tab?) {
                if (tab?.position == 0) {
                    isChooseLine = true
                    showLine()
                } else {
                    isChooseLine = false
                    showBar()
                }
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {

            }
        })
    }

    private fun initObserver() {
        // 12个月统计数据
        getViewModel().sellStaticDateLiveData.observe(this) {
            if (it?.amountList.isNullOrEmpty() && it?.numList.isNullOrEmpty()) {
                return@observe
            }
            if (it?.timeList?.size == it?.numList?.size && it?.timeList?.size == it?.amountList?.size) {
                orderList.clear()
                amountList.clear()
                val local = LanguageUtils.LanguageUtil.getLocalByLanguage()
                mContext?.let { ctx ->
                    lifecycleScope.launch {
                        withContext(Dispatchers.Default) {
                            it?.timeList?.forEachIndexed { index, time ->
                                orderList.add(OrderListResp(time ?: "", it.numList[index]))
                                amountList.add(AmountListResp(time ?: "", it.amountList[index]))
                            }
                            //解决选择当天，不显示日期问题。
                            if (!mStartDate.isNullOrBlank() && !mEndDate.isNullOrBlank() && mStartDate == mEndDate && it?.timeList?.size == 1) {
                                orderList.add(
                                    OrderListResp(
                                        it?.timeList?.get(0),
                                        it?.numList?.get(0)
                                    )
                                )
                                amountList.add(
                                    AmountListResp(
                                        it?.timeList?.get(0),
                                        it?.amountList?.get(0)
                                    )
                                )
                            }
                            updateBarData(orderList, amountList)
                        }
                        withContext(Dispatchers.Main.immediate) {
                            updateBarUI()
                        }
                    }
                }
            }
        }
        // 销售排名等数据
        getViewModel().sellPageRankLiveData.observe(this, {
            it?.let {
                mBinding.tvTotalAmount.text =
                    "$".plus(NumToStrUtil.DoubleToStrWith2(it.orderIncome ?: 0.00))
                mBinding.tvOrderAccount.text = it.orderNum.toString()
                mBinding.tvRank1.text = it.incomeRank.toString()
                mBinding.tvRank2.text = it.numRank.toString() ?: "-"
                mBinding.tvRate.text =
                    NumToStrUtil.DoubleToStrWith2((it.signRate ?: 0.00) * 100).toString().plus("%")
                mBinding.tvPrice.text =
                    "$".plus(NumToStrUtil.DoubleToStrWith2(it.avgOrderAmount ?: 0.00))
            }
        })
        getViewModel().shopSellDataLiveData.observe(this, {
            updateList(it)
        })
        mBinding.swipRefresh.setOnRefreshListener {
            pageIndex = 1
            refreshListData()
        }
        mBinding.swipRefresh.setOnLoadMoreListener {
            pageIndex++
            refreshListData()
        }
    }

    private fun updateBarData(
        list: MutableList<OrderListResp>,
        list2: MutableList<AmountListResp>
    ) {
        generateBarDataSet(list)
        generateLineDataSet(list2)
        //X轴
        xDateData = arrayListOf<String>()
//        quantityData = arrayListOf<String>()
        for (i in list.indices) {
            xDateData?.add(list[i].time.toString())
//            quantityData?.add(list[i].order.toString())
        }
    }

    private fun generateLineDataSet(list2: MutableList<AmountListResp>) {
        lineData.clearValues()
        //折线图
        val amountEntries = mutableListOf<Entry>()
        for (i in list2.indices) {
            val tempAmount = list2[i].amount?.toFloat() ?: 0f
            if (maxAmount < tempAmount) {
                maxAmount = tempAmount
            }
            amountEntries.add(Entry(i * 1f, tempAmount, list2[i].time))
        }
        lineDataSet = LineDataSet(amountEntries, "")
        lineDataSet?.color = Color.parseColor("#FF08983B") // 设置折线图颜色
        lineDataSet?.setDrawCircles(true)
        lineDataSet?.setDrawValues(true)
        lineDataSet?.lineWidth = 1.5f
        lineDataSet?.mode = LineDataSet.Mode.LINEAR
        lineDataSet?.circleHoleRadius = 12f
        // 圆点颜色和半径
        lineDataSet?.setDrawCircleHole(true)
        lineDataSet?.setCircleColor(Color.parseColor("#FF08983B"))     // 圆点颜色
        lineDataSet?.circleRadius = 3f              // 外圈半径
        lineDataSet?.circleHoleRadius = 1f          // 内圈半径（中空）
        lineDataSet?.circleHoleColor = Color.WHITE // 中心孔颜色（可选）
        //设置渐变颜色
        lineDataSet?.setDrawFilled(true)
        val drawable = ContextCompat.getDrawable(mContext, R.drawable.bg_gradient_ffeeeb_ffffff)
        lineDataSet?.fillDrawable = drawable
//        lineDataSet?.axisDependency = YAxis.AxisDependency.RIGHT // 使用右侧 Y 轴
//        lineDataSet?.axisDependency = YAxis.AxisDependency.LEFT // 使用右侧 Y 轴
        lineData.addDataSet(lineDataSet)
    }

    private fun generateBarDataSet(list: MutableList<OrderListResp>) {
        barData.clearValues()
        barData.barWidth = 0.6f
        //柱状图
        maxBat = 0f
        val barEntries = mutableListOf<BarEntry>()
        for (i in list.indices) {
            val tempBat = list[i].order?.toFloat() ?: 0f
            if (maxBat < tempBat) {
                maxBat = tempBat
            }
            //  Log.d("xxx", "bat : $tempBat")
            barEntries.add(BarEntry(i * 1f, tempBat, list[i].time))
        }
        barDataSet = BarDataSet(barEntries, "")
        barDataSet?.color = Color.parseColor("#3FA9FC")
        barDataSet?.setDrawValues(true)
        barDataSet?.highLightColor = Color.parseColor("#3FA9FC")
//        barDataSet?.axisDependency = YAxis.AxisDependency.LEFT
        barData.addDataSet(barDataSet)
    }

    private fun showLine() {
        // 完全清除旧的数据与渲染器
        mBinding.barChart.clear()
        // 新建 CombinedData，并先放一个空的 BarData 避免 NPE
        combinedData = CombinedData()
        combinedData.setData(BarData())   // 空 BarData
        combinedData.setData(lineData)    // 真正的 LineData
        // 赋值、刷新
        mBinding.barChart.data = combinedData
        mBinding.barChart.invalidate()
    }

    private fun showBar() {
        mBinding.barChart.clear()
        combinedData = CombinedData()
        combinedData.setData(barData)     // 真正的 BarData
        combinedData.setData(LineData())  // 空 LineData
        mBinding.barChart.data = combinedData
        mBinding.barChart.invalidate()
    }

    private fun updateBarUI() {
        //X轴
        val xAxis = mBinding.barChart.xAxis
        xAxis.setDrawGridLines(false)      // 隐藏垂直网格线
        xAxis.position = XAxis.XAxisPosition.BOTTOM
        xAxis.valueFormatter = object : ValueFormatter() {
            override fun getFormattedValue(value: Float): String {
                val toInt = value.toInt()
                //开始日期和结束日期一样的时候（选择同一天），只展示一个日期。
                if (mStartDate == mEndDate && !mStartDate.isNullOrBlank() && !mEndDate.isNullOrBlank()) {
                    if (toInt < xDateData?.size!! && toInt > 0) {
                        return xDateData!![toInt]
                    }
                } else {
                    if (toInt < xDateData?.size!! && toInt >= 0) return xDateData!![toInt]
                }
                return ""
            }
        }
        if (xDateData?.size!! > 12) {
            //设置了居中显示会少显示一个，所以要多加一个。
            xAxis.setLabelCount(12, true)
        } else {
            xAxis.setLabelCount(xDateData?.size!!, true)
        }
        xAxis.axisLineColor = Color.parseColor("#FFEDEDED")
        xAxis.axisLineWidth = 0.5f
        xAxis.gridColor = Color.parseColor("#FFEDEDED")
        xAxis.gridLineWidth = 0.5f
        xAxis.labelRotationAngle = 70f; // 斜展示
//        val marker = XYStaticMarkerView(mContext, xAxis.valueFormatter, xAxis);
//        marker.chartView = mBinding.barChart
//        mBinding.barChart.marker = marker
        mBinding.barChart.axisLeft.setDrawGridLines(false)   // 隐藏水平网格线
        mBinding.barChart.axisLeft.setDrawAxisLine(true)     // 显示 Y 轴线
        mBinding.barChart.axisLeft.isEnabled = true // 启用左侧 Y 轴
        mBinding.barChart.axisRight.isEnabled = false // 禁用右侧 Y 轴
        mBinding.barChart.axisLeft.axisLineColor = Color.TRANSPARENT
        mBinding.barChart.axisLeft.axisMinimum = 0f
        mBinding.barChart.axisLeft.mAxisMaximum = 8f
        mBinding.barChart.axisLeft.setGranularity(1f)
        mBinding.barChart.axisLeft.setLabelCount(8, true)
        mBinding.barChart.legend.isEnabled = false
        mBinding.barChart.description.isEnabled = false
        mBinding.barChart.isDoubleTapToZoomEnabled = false
        mBinding.barChart.extraBottomOffset = 12f
        if (isChooseLine) {
            showLine()
        } else {
            showBar()
        }
    }

    private fun initClick() {
        mBinding.ivBackPage.setOnClickListener(this)
        mBinding.tvDate.setOnClickListener(this)
        mBinding.tvTitleTotalAmount.setOnClickListener(this)
        mBinding.tvTitleOrder.setOnClickListener(this)
        mBinding.tvTitleRate.setOnClickListener(this)
        mBinding.tvTitlePrice.setOnClickListener(this)
    }

    private var getDataType = 0
    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.tv_title_saledata, R.id.iv_select -> {
                if (ViewClickUtils.isFastClick()) {
                    return
                }
                XPopup.Builder(mContext)
                    .enableDrag(false)
                    .asCustom(DialogSlectStatisticsData(this, {
                        getDataType = it
                        if (it == 0) {
                            mBinding.tvTitleSaledata.text =
                                mContext.getString(R.string.str_sales_data)
                        } else if (it == 1) {
                            mBinding.tvTitleSaledata.text =
                                mContext.getString(R.string.str_after_sale_data)
                        }
                        pageIndex = 1
                        refreshListData()
                    }))
                    .show()
            }

            R.id.iv_back_page -> {
                finish()
            }
            //时间范围区间最多选择30天。
            R.id.tv_date -> {
                showDialogSelectDate()
            }

            R.id.tv_title_total_amount -> {
                CustomDialog.Builder(this)
                    .setTitle(resources.getString(R.string.str_total_sales_amount))
                    .setMessage(resources.getString(R.string.str_sale_statistics_totalsale_tip))
                    .setIKnowButton(resources.getString(R.string.str_ok)) { dialog, _ ->
                        dialog.dismiss()
                    }.create().show()
            }

            R.id.tv_title_order -> {
                CustomDialog.Builder(this)
                    .setTitle(resources.getString(R.string.str_transaction_order))
                    .setMessage(resources.getString(R.string.str_sale_statistics_order_tip))
                    .setIKnowButton(resources.getString(R.string.str_ok)) { dialog, _ ->
                        dialog.dismiss()
                    }.create().show()
            }

            R.id.tv_title_rate -> {
                val totalStr = resources.getString(R.string.str_order_sining_rate_tip)
                val left = totalStr.indexOf('(')
                val right = totalStr.lastIndexOf(')')
                if (left in 0..<right) {
                    val spannableString = SpannableString(totalStr)
                    spannableString.setSpan(
                        ForegroundColorSpan(resources.getColor(R.color.color_e6000000)),
                        left + 1,
                        right,
                        Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                    CustomDialog.Builder(this)
                        .setTitle(resources.getString(R.string.str_order_signing_rate))
                        .setSpannableMessage(spannableString)
                        .setIKnowButton(resources.getString(R.string.str_ok)) { dialog, _ ->
                            dialog.dismiss()
                        }.create().show()
                }


            }

            R.id.tv_title_price -> {
                val totalStr = resources.getString(R.string.str_average_order_price_tip)
                val spannableString = SpannableString(totalStr)
                spannableString.setSpan(
                    ForegroundColorSpan(resources.getColor(R.color.color_e6000000)),
                    totalStr.indexOf("=") + 1,
                    totalStr.indexOf("÷"),
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                )
                spannableString.setSpan(
                    ForegroundColorSpan(resources.getColor(R.color.color_e6000000)),
                    totalStr.indexOf("÷") + 1,
                    totalStr.length,
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                )
                CustomDialog.Builder(this)
                    .setTitle(resources.getString(R.string.str_average_order_price))
                    .setSpannableMessage(spannableString)
                    .setIKnowButton(resources.getString(R.string.str_ok)) { dialog, _ ->
                        dialog.dismiss()
                    }.create().show()
            }
        }
    }

    private var mToday: String = ""

    //    private var mDefaultStartDate: String = ""
    private var mCurrentMonthFristDay: String = ""
    private var mStartDateLast: String? = null //上一次选中的
    private var mEndDateLast: String? = null;
    private var dialogSelectDate: DialogSelectDate? = null
    private fun initDialogSelectDate() {
        mContext?.let {
            if (dialogSelectDate == null) {
                dialogSelectDate = DialogSelectDate(it) { start, end, isCancel ->
                    if (isCancel) return@DialogSelectDate
                    mStartDate = if (!TextUtils.isEmpty(start)) {
                        start
                    } else {
                        null
                    }
                    mEndDate = if (!TextUtils.isEmpty(end)) {
                        end
                    } else {
                        null
                    }
                    if (mStartDate == null || mEndDate == null) {
                        ToastUtils.showShort(it.getString(R.string.tips_please_select_time))
                        return@DialogSelectDate
                    }
                    if (mStartDate == mStartDateLast && mEndDate == mEndDateLast) {
                        return@DialogSelectDate
                    }
                    if (!mStartDate.isNullOrBlank() && !mEndDate.isNullOrBlank()) {
                        mBinding.tvDate.text = mStartDate.plus("~").plus(mEndDate)
                        getViewModel().getSellPageRankData(mStartDate!!, mEndDate!!)
                        pageIndex = 1
                        refreshListData()
                    }
                    if (!mStartDate.isNullOrBlank()) {
                        mStartDateLast = mStartDate;
                    }
                    if (!mEndDate.isNullOrBlank()) {
                        mEndDateLast = mEndDate;
                    }
                }

            }
            dialogSelectDate?.setDialogDateListener(object :
                DialogSelectDate.OnDialogDateListener {
                override fun onStartClick(s: String) {
                    if (!TextUtils.isEmpty(s)) {
                        showTimerPickerStart(s)
                    } else {
                        showTimerPickerStart(mStartDateLast ?: "")
                    }
                }

                override fun onEndClick(s: String) {
                    if (!TextUtils.isEmpty(s)) {
                        showTimerPickerEnd(s)
                    } else {
                        showTimerPickerEnd(mEndDateLast ?: "")
                    }
                }

            })

        }
    }

    private fun showDialogSelectDate() {
        dialogSelectDate?.let {
            mStartDateLast?.let { it1 -> dialogSelectDate?.setStartDate(it1) }
            mEndDateLast?.let { it1 -> dialogSelectDate?.setEndDate(it1) }
            XPopup.Builder(mContext)
                .enableDrag(false)
                .asCustom(it).show()
        }
    }

    private var mSelectDateType: Int = 1
    private var mTimerPickerStart: CustomDatePicker? = null
    private var mTimerPickerEnd: CustomDatePicker? = null
    private fun initTimerPickerStart(dateTime: String) {
        mContext?.let { context ->
            val beginTime: Long = System.currentTimeMillis() - 1000 * 60 * 60 * 24 * 365L * 1
            val endTime: Long = System.currentTimeMillis()
            if (mTimerPickerStart == null) {
                mTimerPickerStart = CustomDatePicker(
                    context,
                    {
                        if (it > 0) {
                            val selectDate = DateTimeUtils.getTimeString(
                                "yyyy-MM-dd",
                                it,
                                LanguageUtils.LanguageUtil.getLocalByLanguage()
                            )
                            val endDate = dialogSelectDate?.getEndDate()
                            if (!TextUtils.isEmpty(endDate) && isEndTimeLessThanStartTime(
                                    selectDate,
                                    endDate ?: ""
                                )
                            ) {
                                ToastUtils.showShort(context.getString(R.string.tips_end_time_cannot_less_start_time))
                                return@CustomDatePicker
                            }
                            if (!TextUtils.isEmpty(endDate) && !isRangeIn30Days(
                                    selectDate,
                                    endDate ?: ""
                                )
                            ) {
                                ToastUtils.showShort(context.getString(R.string.tips_selecttime_in_30days))
                                return@CustomDatePicker
                            }
                            dialogSelectDate?.setStartDate(selectDate)
                        }

                    },
                    beginTime,
                    endTime,
                    LanguageUtils.LanguageUtil.getLocalByLanguage()
                )
                mTimerPickerStart?.setCancelable(true)
                mTimerPickerStart?.setCanShowPreciseTime(false)
                mTimerPickerStart?.setScrollLoop(true)
                mTimerPickerStart?.setCanShowAnim(true)
                mTimerPickerStart?.setOnlyShowDate(true)
            }
//            // 30 天前的毫秒
//            val thirtyDaysMs = 29L * 24 * 60 * 60 * 1000
//            val defaultStartTs = System.currentTimeMillis() - thirtyDaysMs
//            mTimerPickerStart?.setSelectedTime(defaultStartTs,false)
        }
    }

    private fun initTimerPickerEnd(dateTime: String) {
        mContext?.let { context ->
            val beginTime: Long = System.currentTimeMillis() - 1000 * 60 * 60 * 24 * 365L * 1
            val endTime: Long = System.currentTimeMillis()
            if (mTimerPickerEnd == null) {
                mTimerPickerEnd = CustomDatePicker(
                    context,
                    {
                        if (it > 0) {
                            val selectDate = DateTimeUtils.getTimeString(
                                "yyyy-MM-dd",
                                it,
                                LanguageUtils.LanguageUtil.getLocalByLanguage()
                            )
                            //结束
                            val startDate = dialogSelectDate?.getStartDate()
                            if (!TextUtils.isEmpty(startDate) && isEndTimeLessThanStartTime(
                                    startDate ?: "",
                                    selectDate
                                )
                            ) {
                                ToastUtils.showShort(context.getString(R.string.tips_end_time_cannot_less_start_time))
                                return@CustomDatePicker
                            }
                            if (!TextUtils.isEmpty(startDate) && !isRangeIn30Days(
                                    startDate ?: "", selectDate
                                )
                            ) {
                                ToastUtils.showShort(context.getString(R.string.tips_selecttime_in_30days))
                                return@CustomDatePicker
                            }
                            dialogSelectDate?.setEndDate(selectDate)
                        }

                    },
                    beginTime,
                    endTime,
                    LanguageUtils.LanguageUtil.getLocalByLanguage()
                )
                mTimerPickerEnd?.setCancelable(true)
                mTimerPickerEnd?.setCanShowPreciseTime(false)
                mTimerPickerEnd?.setScrollLoop(true)
                mTimerPickerEnd?.setCanShowAnim(true)
                mTimerPickerEnd?.setOnlyShowDate(true)
            }
//            mTimerPickerEnd?.setSelectedTime(mToday,false)

        }
    }

    private fun showTimerPickerStart(dateTime: String) {
        if (!TextUtils.isEmpty(dateTime)) {
            val localDate = LocalDate.parse(dateTime)  // 默认按 yyyy-MM-dd
            val ts = localDate.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()
            mTimerPickerStart?.show(ts)
        } else {
            mTimerPickerStart?.show(System.currentTimeMillis())
        }
    }


    private fun showTimerPickerEnd(dateTime: String) {
        if (!TextUtils.isEmpty(dateTime)) {
            val localDate = LocalDate.parse(dateTime)  // 默认按 yyyy-MM-dd
            val ts = localDate.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()
            mTimerPickerEnd?.show(ts)
        } else {
            mTimerPickerEnd?.show(System.currentTimeMillis())
        }
    }

    private fun parseDateToMillis(dateStr: String): Long {
        return try {
            val locale = LanguageUtils.LanguageUtil.getLocalByLanguage()
            // 按照 yyyy-MM-dd、并带入 locale 构造 formatter
            val fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd", locale)
            val localDate = LocalDate.parse(dateStr, fmt)
            localDate
                .atStartOfDay(ZoneId.systemDefault())
                .toInstant()
                .toEpochMilli()
        } catch (e: Exception) {
            0L
        }
    }


    //判断结束日期是否早于开始日期
    private fun isEndTimeLessThanStartTime(startDate: String, endDate: String): Boolean {
        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
        val start = LocalDate.parse(startDate, formatter)
        val end = LocalDate.parse(endDate, formatter)
        return end.isBefore(start)
    }

    // 判断区间是否在 30 天（含首尾）内
    private fun isRangeIn30Days(startDate: String, endDate: String): Boolean {
        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
        val start = LocalDate.parse(startDate, formatter)
        val end = LocalDate.parse(endDate, formatter)
        if (end.isBefore(start)) return false
        // 计算包含首尾的总天数
        val days = ChronoUnit.DAYS.between(start, end) + 1
        return days <= 30
    }

    private fun initAdapter() {
        mAdapter = object : SingleDataBindingNoPUseAdapter<OrderItem>(R.layout.item_sale_data) {
            override fun convert(helper: BaseViewHolder, item: OrderItem) {
                super.convert(helper, item)
                item.run {
                    if (helper.adapterPosition == 0) {
                        helper.setGone(R.id.devideline, false)
                    } else {
                        helper.setGone(R.id.devideline, true)
                    }
                    var str1 = ""
                    if (item.payWay == PayTypeObject.TYPE_CASH) {
                        str1 = mContext.getString(R.string.text_cash)
                    } else if (item.payType == PayTypeObject.TYPE_ONLINE) {
                        str1 = mContext.getString(R.string.text_online)
                    }
                    if (null != item.amount) {
                        helper.setText(
                            R.id.tv_price,
                            "$".plus(NumToStrUtil.DoubleToStrWith2(item.amount ?: 0.00))
                        )
                    } else {
                        helper.setText(
                            R.id.tv_price, "-"
                        )
                    }

                    val img = helper.getView<ImageView>(R.id.img_type)
                    if (getDataType == 0) {
                        helper.setGone(R.id.voucher, false)
                        var str2 = ""
                        if (item.payType == 1) {
                            str2 = mContext.getString(R.string.text_full_amount)
                        } else if (item.payType == 2) {
                            str2 = mContext.getString(R.string.str_installment)
                        }
                        var ordrNoStr="-"
                        if(!item.orderNo.isNullOrBlank()){
                            ordrNoStr= item.orderNo?:"-"
                        }
                        if (LanguageUtils.LanguageUtil.getLocalByLanguage() == Locale.US) {
                            helper.setText(
                                R.id.tv_orderno,
                                str1.plus(" ").plus(str2).plus(" | ")
                                    .plus(
                                        mContext.getString(R.string.str_order_no)
                                            .plus(ordrNoStr)
                                    )
                            )
                        } else {
                            helper.setText(
                                R.id.tv_orderno,
                                str1.plus(str2).plus(" | ")
                                    .plus(
                                        mContext.getString(R.string.str_order_no).plus(ordrNoStr)
                                    )
                            )
                        }
                        when (item.orderType) {
                            1 -> {
                                helper.setText(R.id.tv_type, mContext.getString(R.string.sale))
                                img.setImageResource(R.mipmap.icon_sale_bind)
                            }

                            2 -> {
                                helper.setText(R.id.tv_type, mContext.getString(R.string.lease))
                                img.setImageResource(R.mipmap.icon_lease_bind)
                            }

                            3 -> {
                                helper.setText(
                                    R.id.tv_type,
                                    mContext.getString(R.string.str_swap_battery)
                                )
                                img.setImageResource(R.mipmap.icon_swap_bind)
                            }

                            else -> {
                                helper.setText(
                                    R.id.tv_type,"-"
                                )
                                img.setImageResource(0)
                            }
                        }
                    } else if (getDataType == 1) {
                        helper.setText(
                            R.id.tv_orderno,
                            str1.plus(mContext.getString(R.string.str_order_no).plus(item.orderNo))
                        )
                        when (item.orderType) {
                            //保养
                            1 -> {
                                img.setImageResource(R.mipmap.icon_roadside_assistance)
                                helper.setText(
                                    R.id.tv_type,
                                    mContext.getString(R.string.str_maintenance_schedule)
                                )
                            }
                            //道路救援
                            2 -> {
                                img.setImageResource(R.mipmap.icon_schedule_maintenance)
                                helper.setText(
                                    R.id.tv_type,
                                    mContext.getString(R.string.str_road_rescue)
                                )
                            }
                        }
                        if (!item.attachment.isNullOrBlank()) {
                            helper.setGone(R.id.voucher, true)
                            helper.addOnClickListener(R.id.voucher)
                        } else {
                            helper.setGone(R.id.voucher, false)
                        }
                    }

                }
            }
        }
        mAdapter?.setOnItemChildClickListener { adapter, view, position ->
            when (view?.id) {
                R.id.voucher -> {
                    val item = mAdapter?.getItem(position) as OrderItem
                    ViewReceiptDialogFragment(StringUtils.strToList(item.attachment)).show(
                        supportFragmentManager,
                        "salesummary"
                    )
                }
            }
        }
        mBinding.rvdata.adapter = mAdapter
    }

    private fun refreshListData() {
        getViewModel().queryShopSellData(
            mStartDate ?: "",
            mEndDate ?: "",
            mStatus,
            pageIndex,
            pageSize, getDataType
        )
    }

    private var pageIndex = 1
    private var pageSize = 10

    @SuppressLint("NotifyDataSetChanged")
    private fun updateList(items: List<OrderItem>?) {
        if (mAdapter == null) return
        val isDataEmpty = items.isNullOrEmpty()
        if (pageIndex == 1) {
            if (isDataEmpty) {
                mAdapter?.setNewData(mutableListOf())
                mBinding.swipRefresh.finishRefreshWithNoMoreData()
            } else {
                mAdapter?.setNewData(items?.toMutableList())
                mBinding.swipRefresh.finishRefresh(true)
                mBinding.swipRefresh.resetNoMoreData()
                mBinding.swipRefresh.setEnableLoadMore(true)
            }
            if (mAdapter?.data?.isEmpty() == true) {
                mBinding.dataEmptyLayout.dataErrorView.visibility = View.VISIBLE
                mBinding.dataEmptyLayout.dataErrorView.setBackgroundResource(R.drawable.bg_ffffff_bottom_r10_bg)
                mBinding.swipRefresh.visibility = View.GONE
            } else {
                mBinding.dataEmptyLayout.dataErrorView.visibility = View.GONE
                mBinding.swipRefresh.visibility = View.VISIBLE
            }
        } else {
            if (isDataEmpty) {
                mBinding.swipRefresh.finishLoadMoreWithNoMoreData()
            } else {
                items?.let { mAdapter?.addData(it) }
                mBinding.swipRefresh.finishLoadMore(true)
            }
        }
        mAdapter?.notifyDataSetChanged()
    }
}