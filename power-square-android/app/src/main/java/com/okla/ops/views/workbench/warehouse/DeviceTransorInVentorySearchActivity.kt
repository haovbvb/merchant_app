package com.okla.ops.views.workbench.warehouse

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.library.utils.GsonUtils
import com.base.library.utils.StringUtil
import com.chad.library.adapter.base.BaseViewHolder
import com.google.gson.reflect.TypeToken
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.DeviceInventory
import com.okla.ops.beans.DeviceTransport
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.beans.SearchHistory
import com.okla.ops.databinding.ActDeviceTransportInventorySearchBinding
import com.okla.ops.views.workbench.warehouse.deviceinventory.DeviceInventoryDetailActivity
import com.okla.ops.views.workbench.warehouse.devicetransport.DeviceTransportDetailActivity
import com.okla.ops.weight.SearchHistoryView
import com.okla.ops.weight.SearchTitleView

class DeviceTransorInVentorySearchActivity :
    BaseNormalListVActivity<SearchViewModel, ActDeviceTransportInventorySearchBinding>() {

    private var searchType = 0
    private var mKeyword = ""
    private lateinit var deviceIssuesAdapter: SingleDataBindingNoPUseAdapter<DeviceTransport>
    private lateinit var deviceReceiveAdapter: SingleDataBindingNoPUseAdapter<DeviceTransport>
    private lateinit var deviceInventorAdapter: SingleDataBindingNoPUseAdapter<DeviceInventory>

    companion object {
        const val TYPE_DEVICE_ISSUSE = 1; //设备发出
        const val TYPE_DEVICE_RECEIVE = 2;//设备接收
        const val TYPE_DEVICE_INVENTORY = 3; //设备盘点
        fun getIntents(context: Context, searchType: Int) {
            val intent = Intent(context, DeviceTransorInVentorySearchActivity::class.java)
            intent.putExtra("searchType", searchType)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): SearchViewModel {
        return ViewModelProvider(this).get(SearchViewModel::class.java)
    }

    override fun getLayoutId(): Int {
        return R.layout.act_device_transport_inventory_search
    }

    override fun createAdapter(): RecyclerView.Adapter<*> {
        searchType = intent?.getIntExtra("searchType", 0) ?: 0
        when (searchType) {
            TYPE_DEVICE_ISSUSE -> {
                initIssuesAdapter()
                return deviceIssuesAdapter
            }

            TYPE_DEVICE_RECEIVE -> {
                initReceiveAdapter()
                return deviceReceiveAdapter
            }

            TYPE_DEVICE_INVENTORY -> {
                initInventorAdapter()
                return deviceInventorAdapter
            }
        }
        return deviceIssuesAdapter
    }


    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        getStatusView().enableRefresh = true
        getStatusView().enableLoadMore = true
        searchType = intent?.getIntExtra("searchType", 0) ?: 0
        initListener()
        initOberver()
        switchView("")
        initData()


    }

    private fun initOberver() {
        getViewModel().mDeviceIssueRespLiveData.observe(this, {
            if (it?.list.isNullOrEmpty()) {
                mBinding.emptyLayout.dataErrorView.visibility = View.VISIBLE
                mBinding.emptyLayout.dataErrorInfoIv.setImageResource(R.mipmap.icon_empty_search)
                mBinding.emptyLayout.dataErrorInfoTv.text =
                    this.getString(R.string.str_empty_search_tip)
            } else {
                addHistory(mKeyword)
                mBinding.emptyLayout.dataErrorView.visibility = View.GONE
                updateListItems(it?.list)
            }
        })
        getViewModel().mDeviceReceiveRespLiveData.observe(this, {
            if (it?.list.isNullOrEmpty()) {
                mBinding.emptyLayout.dataErrorView.visibility = View.VISIBLE
                mBinding.emptyLayout.dataErrorInfoIv.setImageResource(R.mipmap.icon_empty_search)
                mBinding.emptyLayout.dataErrorInfoTv.text =
                    this.getString(R.string.str_empty_search_tip)
            } else {
                addHistory(mKeyword)
                mBinding.emptyLayout.dataErrorView.visibility = View.GONE
                updateListItems(it?.list)
            }
        })
        getViewModel().mDeviceInventoryRespLiveData.observe(this, {
            if (it?.list.isNullOrEmpty()) {
                mBinding.emptyLayout.dataErrorView.visibility = View.VISIBLE
                mBinding.emptyLayout.dataErrorInfoIv.setImageResource(R.mipmap.icon_empty_search)
                mBinding.emptyLayout.dataErrorInfoTv.text =
                    this.getString(R.string.str_empty_search_tip)
            } else {
                addHistory(mKeyword)
                mBinding.emptyLayout.dataErrorView.visibility = View.GONE
                updateListItems(it?.list)
            }
        })
    }

    private fun initIssuesAdapter() {
        deviceIssuesAdapter = object :
            SingleDataBindingNoPUseAdapter<DeviceTransport>(R.layout.item_device_transport) {

            override fun convert(helper: BaseViewHolder, item: DeviceTransport) {
                super.convert(helper, item)
                item.run {
                    helper.setText(R.id.tvTransferNum, transferNo)
                    val tvDesName = helper.getView<AppCompatTextView>(R.id.tvDesName)
                    if (outWarehouseName.contains("platform")) {
                        tvDesName.text = mContext.getString(R.string.text_platform)
                    } else {
                        tvDesName.text = outWarehouseName
                    }
                    helper.setText(R.id.tvNumValue, StringUtil.isDataNumberEmpty(deviceNum))
                    helper.setText(R.id.tvReceiveValue, StringUtil.isDataNumberEmpty(receivedNum))
                    val recallNum = deviceNum - inTransitNum - receivedNum
                    helper.setText(
                        R.id.tvRecallValue,
                        StringUtil.isDataNumberEmpty(if (recallNum >= 0) recallNum else 0)
                    )
                    val tvStatus = helper.getView<AppCompatTextView>(R.id.tvStatus)
                    when (status) {
                        0 -> {//在途
                            tvStatus.text = getString(R.string.transport_status_on)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_fef7ea_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.color_ed942f
                                )
                            )
                        }

                        1 -> {//已接收
                            tvStatus.text = getString(R.string.transport_status_receive)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_ffeef7e9_r4
                            )

                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.main_color
                                )
                            )
                        }

                        2 -> {//部分接收
                            tvStatus.text = getString(R.string.transport_receive_part)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_f0f7ff_r4
                            )

                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.color_1184f7
                                )
                            )
                        }

                        3 -> {//已撤回
                            tvStatus.text = getString(R.string.str_withdraw_all)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_fff3f2_r4
                            )

                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.color_ffa4332
                                )
                            )
                        }
                    }
                    val tvDeviceType = helper.getView<AppCompatTextView>(R.id.tvDeviceType)
                    when (deviceType) {
                        DeviceTypeObject.TYPE_BATTERY -> {//电池
                            tvDeviceType.text = getString(R.string.transport_battery)
                        }

                        DeviceTypeObject.TYPE_VEHICLE -> {//车辆
                            tvDeviceType.text = getString(R.string.transport_vehicle)
                        }
                    }
                }
            }
        }
        deviceIssuesAdapter.setOnItemClickListener { adapter, _, position ->
            val itemData = adapter.data[position] as DeviceTransport
            DeviceTransportDetailActivity.getIntents(
                this,
                itemData.transferNo,
                DeviceTransportDetailActivity.TRANSPORT_TYPE_ISSUE,
                itemData.status
            )
        }
    }

    private fun initReceiveAdapter() {
        deviceReceiveAdapter = object :
            SingleDataBindingNoPUseAdapter<DeviceTransport>(R.layout.item_device_transport) {

            override fun convert(helper: BaseViewHolder, item: DeviceTransport) {
                super.convert(helper, item)
                item.run {
                    helper.setText(R.id.tvTransferNum, transferNo)
                    val tvDesName = helper.getView<AppCompatTextView>(R.id.tvDesName)
                    if (inWarehouseName.contains("platform")) {
                        tvDesName.text = mContext.getString(R.string.text_platform)
                    } else {
                        tvDesName.text = inWarehouseName
                    }
                    helper.setText(R.id.tvNumValue, StringUtil.isDataNumberEmpty(deviceNum))
                    helper.setText(R.id.tvReceiveValue, StringUtil.isDataNumberEmpty(receivedNum))
                    val recallNum = deviceNum - inTransitNum - receivedNum
                    helper.setText(
                        R.id.tvRecallValue,
                        StringUtil.isDataNumberEmpty(if (recallNum >= 0) recallNum else 0)
                    )
                    val tvStatus = helper.getView<AppCompatTextView>(R.id.tvStatus)
                    when (status) {
                        0 -> {//在途
                            tvStatus.text = getString(R.string.transport_status_on)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_fef7ea_r4
                            )

                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.color_ed942f
                                )
                            )
                        }

                        1 -> {//已接收
                            tvStatus.text = getString(R.string.transport_status_receive)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_ffeef7e9_r4
                            )

                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.main_color
                                )
                            )
                        }

                        2 -> {//部分接收
                            tvStatus.text = getString(R.string.transport_receive_part)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_f0f7ff_r4
                            )

                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.color_1184f7
                                )
                            )
                        }

                        3 -> {//已撤回
                            tvStatus.text = getString(R.string.str_withdraw_all)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_fff3f2_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.color_ffa4332
                                )
                            )
                        }
                    }
                    val tvDeviceType = helper.getView<AppCompatTextView>(R.id.tvDeviceType)
                    when (deviceType) {
                        DeviceTypeObject.TYPE_BATTERY -> {//电池
                            tvDeviceType.text = getString(R.string.transport_battery)
                        }

                        DeviceTypeObject.TYPE_VEHICLE -> {//车辆
                            tvDeviceType.text = getString(R.string.transport_vehicle)
                        }
                    }
                }

            }
        }
        deviceReceiveAdapter.setOnItemClickListener { adapter, _, position ->
            val itemData = adapter.data[position] as DeviceTransport
            DeviceTransportDetailActivity.getIntents(
                this,
                itemData.transferNo,
                DeviceTransportDetailActivity.TRANSPORT_TYPE_RECEPTION,
                itemData.status
            )
        }
    }

    private fun initInventorAdapter() {
        deviceInventorAdapter = object :
            SingleDataBindingNoPUseAdapter<DeviceInventory>(R.layout.item_device_inventory) {

            override fun convert(helper: BaseViewHolder, item: DeviceInventory) {
                super.convert(helper, item)
                item.run {
                    helper.setText(R.id.tvNumber, inventoryNo)
                    helper.setText(R.id.tvDesName, warehouseName)
                    helper.setText(R.id.tvInventoryValue, StringUtil.isDataNumberEmpty(inventory))
                    helper.setText(R.id.tvStockValue, StringUtil.isDataNumberEmpty(stock))
                    val tvDevice = helper.getView<AppCompatTextView>(R.id.tvDeviceValue)
                    when (deviceType) {
                        1 -> {
                            tvDevice.setText(R.string.inventory_battery)
                        }

                        2 -> {
                            tvDevice.setText(R.string.inventory_vehicle)
                        }
                    }
                    val tvStatus = helper.getView<AppCompatTextView>(R.id.tvStatus)
                    when (status) {
                        0 -> {//进行中
                            tvStatus.setText(R.string.str_unfinished)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_fef7ea_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.color_ed942f
                                )
                            )
                        }

                        1 -> {//已完成
                            tvStatus.setText(R.string.inventory_complete)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_ffeef7e9_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.main_color
                                )
                            )
                        }

                        2 -> {//已撤销
                            tvStatus.setText(R.string.str_withdraw_all)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransorInVentorySearchActivity,
                                R.drawable.bg_fff3f2_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransorInVentorySearchActivity,
                                    R.color.color_ffa4332
                                )
                            )
                        }
                    }
                }
            }
        }
        deviceInventorAdapter.setOnItemClickListener { adapter, _, position ->
            val itemData = adapter.data[position] as DeviceInventory
            DeviceInventoryDetailActivity.getIntents(
                this@DeviceTransorInVentorySearchActivity,
                itemData.deviceType ?: 0,
               DeviceInventoryDetailActivity.OPT_QUERY,
                itemData.inventoryNo ?: ""
            )
        }

    }

    private fun initListener() {
        mBinding.searchTitleView.setOnSearchTitleListener(object :
            SearchTitleView.OnSearchTitleListener {
            override fun onSearch(content: String) {
                mKeyword = content
                switchView(content)
                if (!TextUtils.isEmpty(mKeyword)) {
                    onRefresh()
                }
            }

            override fun onBack() {
                finish()
            }

        })
        mBinding.searchHistoryView.setListener(object : SearchHistoryView.OnClickListener {
            override fun onSelectedName(content: String) {
                mBinding.searchTitleView.setSearchText(content)
            }

            override fun onClearSearchName() {
                saveHistoryData("")
            }

        })

    }

    private fun switchView(content: String) {
        if (TextUtils.isEmpty(content)) {
            mBinding.swipRefresh.visibility = View.GONE
            mBinding.emptyLayout.dataErrorView.visibility = View.GONE
            mBinding.searchHistoryView.visibility = View.VISIBLE
            val historyJson = readHistoryData()
            if (historyJson.isNotEmpty()) {
                val type = object : TypeToken<List<SearchHistory>>() {}.type
                mBinding.searchHistoryView.setHistoryData(GsonUtils.fromGson(historyJson, type))
            }
        } else {
            mBinding.swipRefresh.visibility = View.VISIBLE
            mBinding.searchHistoryView.visibility = View.GONE
            mBinding.emptyLayout.dataErrorView.visibility = View.GONE
        }
    }

    private fun addHistory(content: String) {
        if (content.isBlank()) return
        val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")

        // 根据 searchType 决定存储的 key
        val key = when (searchType) {
            TYPE_DEVICE_ISSUSE -> DataStoreKeyUtils.HISTORY_SEARCH_DEVICE_ISSUSE.plus(account)
            TYPE_DEVICE_RECEIVE -> DataStoreKeyUtils.HISTORY_SEARCH_DEVICE_RECEIVE.plus(account)
            TYPE_DEVICE_INVENTORY -> DataStoreKeyUtils.HISTORY_SEARCH_DEVICE_INVENTOR.plus(account)
            else -> return
        }

        // 读取旧的 JSON
        val oldJson = readHistoryData()
        val type = object : TypeToken<MutableList<SearchHistory>>() {}.type
        val historyList: MutableList<SearchHistory> = try {
            if (oldJson.isNotEmpty()) GsonUtils.fromGson(oldJson, type)
            else mutableListOf()
        } catch (e: Exception) {
            mutableListOf()
        }

        // 去重：移除已有相同条目
        historyList.removeAll { it.name == content }

        // 添加到最前
        historyList.add(0, SearchHistory(content, content))

        // 保留最新 5 条
        val limitedList = historyList.take(5).toMutableList()
        // 持久化：转回 JSON 并保存
        val newJson = GsonUtils.toGson(limitedList)
        saveHistoryData(newJson)
    }

    private fun initData() {
//        val historyJson = readHistoryData()
//        if (historyJson.isNotEmpty()) {
//            val type = object : TypeToken<List<SearchHistory>>() {}.type
//            mBinding.searchHistoryView.setHistoryData(GsonUtils.fromGson(historyJson, type))
//        }
        mContext?.let {
            if (searchType == TYPE_DEVICE_INVENTORY) {
                mBinding.searchTitleView.setSearchHint(it.getString(R.string.hint_enter_inventory_number_search))
            } else {
                mBinding.searchTitleView.setSearchHint(it.getString(R.string.hint_device_issue_search_input_tip))
            }
        }
    }

    private fun saveHistoryData(str: String) {
        val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")
        when (searchType) {
            TYPE_DEVICE_ISSUSE -> {
                DataStoreUtils.saveSyncStringData(
                    DataStoreKeyUtils.HISTORY_SEARCH_DEVICE_ISSUSE.plus(account),
                    str
                )
            }

            TYPE_DEVICE_RECEIVE -> {
                DataStoreUtils.saveSyncStringData(
                    DataStoreKeyUtils.HISTORY_SEARCH_DEVICE_RECEIVE.plus(account),
                    str
                )
            }

            TYPE_DEVICE_INVENTORY -> {
                DataStoreUtils.saveSyncStringData(
                    DataStoreKeyUtils.HISTORY_SEARCH_DEVICE_INVENTOR.plus(account),
                    str
                )

            }
        }
    }

    private fun readHistoryData(): String {
        val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")
        when (searchType) {
            TYPE_DEVICE_ISSUSE -> {
                return DataStoreUtils.readStringData(
                    DataStoreKeyUtils.HISTORY_SEARCH_DEVICE_ISSUSE.plus(
                        account
                    )
                )
            }

            TYPE_DEVICE_RECEIVE -> {
                return DataStoreUtils.readStringData(
                    DataStoreKeyUtils.HISTORY_SEARCH_DEVICE_RECEIVE.plus(
                        account
                    )
                )
            }

            TYPE_DEVICE_INVENTORY -> {
                return DataStoreUtils.readStringData(
                    DataStoreKeyUtils.HISTORY_SEARCH_DEVICE_INVENTOR.plus(
                        account
                    )
                )

            }
        }
        return ""
    }

    override fun getRecyclerView(): RecyclerView {
        return mBinding.rvStock
    }

    override fun initPageData() {
        when (searchType) {
            TYPE_DEVICE_ISSUSE -> {
                getViewModel().queryDeviceIssuePage(mKeyword, null, pageIndex, pageSize)

            }

            TYPE_DEVICE_RECEIVE -> {
                getViewModel().queryDeviceReceivePage(mKeyword, null, pageIndex, pageSize)

            }

            TYPE_DEVICE_INVENTORY -> {
                getViewModel().queryDeviceInventoryPage(pageIndex, pageSize, mKeyword)
            }
        }
    }
}