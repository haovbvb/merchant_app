package com.okla.ops.views.workbench.warehouse.deviceinventory

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.beans.RxEvent
import com.base.common.beans.RxEvent.RoadSideNotPayEvent
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.base.common.utils.LanguageUtils.LanguageUtil.getLocalByLanguage
import com.base.library.utils.StringUtil
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.DeviceInventoryData
import com.okla.ops.beans.DeviceInventoryDetail
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.beans.ScanDeviceBean
import com.okla.ops.databinding.ActivityDeviceInventoryDetailBinding
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.QRCodeListActivity
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import razerdp.basepopup.QuickPopupBuilder
import razerdp.basepopup.QuickPopupConfig
import razerdp.widget.QuickPopup

/**
 * Author: Joe
 * Date: 2024/2/19 10:38
 * Description:
 */
class DeviceInventoryDetailActivity :
    BaseNormalListVActivity<DeviceInventoryViewModel, ActivityDeviceInventoryDetailBinding>() {

    companion object {
        private const val INVENTORY_NO = "inventoryNo"
        private const val DEVICE_TYPE = "deviceType"
        const val OPT_CREATE = 1
        const val OPT_QUERY = 2
        private const val OPT_TYPE = "optType"

        fun getIntents(context: Context, deviceType: Int, optType: Int) {
            val intent = Intent(context, DeviceInventoryDetailActivity::class.java)
            intent.putExtra(DEVICE_TYPE, deviceType)
            intent.putExtra(OPT_TYPE, optType)
            context.startActivity(intent)
        }

        fun getIntents(context: Context, deviceType: Int, optType: Int, inventoryNo: String) {
            val intent = Intent(context, DeviceInventoryDetailActivity::class.java)
            intent.putExtra(DEVICE_TYPE, deviceType)
            intent.putExtra(INVENTORY_NO, inventoryNo)
            intent.putExtra(OPT_TYPE, optType)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): DeviceInventoryViewModel {
        return ViewModelProvider(this).get(DeviceInventoryViewModel::class.java)
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_device_inventory_detail
    }

    override fun title(): Int {
        return R.string.inventory_detail
    }

    var deviceType: Int = 0
    var optType: Int = 0
    override fun getIntentExtras(intent: Intent) {
        super.getIntentExtras(intent)
        deviceType = intent.getIntExtra(DEVICE_TYPE, 0)
        optType = intent.getIntExtra(OPT_TYPE, 0)
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        getStatusView().enableRefresh = true
        getStatusView().enableLoadMore = true
        initObserver()
        initClick()
        if (optType == OPT_CREATE) {
            mBinding.btnScan.visibility = View.VISIBLE
            mBinding.tvScan.visibility = View.VISIBLE
            mBinding.groupDetail.visibility = View.GONE
            val layoutParams =
                mBinding.bgWarehouseAddress.layoutParams as ViewGroup.MarginLayoutParams
            layoutParams.topMargin = DensityUtil.dp2px(16f)
            mBinding.includeTitle.topTitle.text =
                mContext.getString(R.string.title_create_inventory)
        } else {
            mBinding.btnScan.visibility = View.GONE
            mBinding.tvScan.visibility = View.GONE
            mBinding.groupDetail.visibility = View.VISIBLE
            val layoutParams =
                mBinding.bgWarehouseAddress.layoutParams as ViewGroup.MarginLayoutParams
            layoutParams.topMargin = DensityUtil.dp2px(38f)
            mBinding.bgWarehouseAddress.layoutParams = layoutParams
            inventoryNo = intent?.getStringExtra(INVENTORY_NO) ?: ""
            mBinding.tvInventoryNo.text = inventoryNo
            mBinding.includeTitle.topTitle.text =
                mContext.getString(R.string.title_inventory_detail)
            onRefresh()
        }
        getViewModel().queryMyWarehouseInfo()
    }

    private fun initClick() {
        mBinding.btnScan.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            startActivityForResult(
                QRCodeListActivity.getIntents(this, inventoryNo,deviceType),
                QRCodeListActivity.REQUEST_CODE
            )
        }
        mBinding.btnCancel.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            showTipDialog()
        }
        mBinding.btnConfirm.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            getViewModel().completeInventory(inventoryNo)
        }
    }

    private var inventoryNo: String = ""
    private var wareHouseNo: String = ""
    private var list = ArrayList<DeviceInventoryData>()
    private fun initObserver() {
        getViewModel().mStartInventoryFailureLiveData.observe(this) {
            finish()
        }
        getViewModel().myWarehouseBeanLiveData.observe(this, {
            wareHouseNo = it?.warehouseNo ?: "-"
            if (it?.warehouseType == 1) {
                mBinding.tvWarehouseName.text =
                    mContext.getString(R.string.text_platform)
                mBinding.tvAddress.text = (it?.cityName ?: "-").plus(" | ")
                    .plus(mContext.getString(R.string.text_platform))
            } else if (it?.warehouseType == 2) {
                mBinding.tvAddress.text =
                    (it?.cityName ?: "-").plus(" | ").plus(mContext.getString(R.string.text_agent))
                mBinding.tvWarehouseName.text = it?.warehouseName
            } else if (it?.warehouseType == 3) {
                mBinding.tvWarehouseName.text = it?.warehouseName
                mBinding.tvAddress.text =
                    (it?.cityName ?: "-").plus(" | ")
                        .plus(mContext.getString(R.string.text_shop))
            }
            mBinding.tvInventoryDate.text =
                DateTimeUtils.getTimeString(
                    DateTimeUtils.defaultFormat, System.currentTimeMillis(),
                    getLocalByLanguage()
                )
            if (optType == OPT_CREATE) {
                getViewModel().startInventory(deviceType, wareHouseNo)
            }
        })
        getViewModel().mStartInventoryLiveData.observe(this) {
            inventoryNo = it?.inventoryNo ?: ""
            onRefresh()
        }
        getViewModel().mQueryInventoryLiveData.observe(this) {
            it?.let {
                if (it.status == 0) {
                    mBinding.groupBottom.visibility = View.VISIBLE
                    mBinding.btnScan.visibility = View.VISIBLE
                    mBinding.tvScan.visibility = View.VISIBLE
                } else {
                    mBinding.groupBottom.visibility = View.GONE
                    mBinding.btnScan.visibility = View.GONE
                    mBinding.tvScan.visibility = View.GONE
                }
                updateData(it)

            }

        }
        getViewModel().mRevokeInventoryLiveData.observe(this) {
            finish()
        }
        getViewModel().mCompleteInventoryLiveData.observe(this) {
            finish()
        }
    }

    private fun updateData(detail: DeviceInventoryDetail) {
        detail.detailPage?.let {
            if (pageIndex == defaultStartPageIndex) {
                getViewModel().clearTempDeviceInventoryList()
            }
            updateListItems(it.list)
        }
        when (detail.deviceType) {
            DeviceTypeObject.TYPE_BATTERY -> mBinding.tvInventoryType.text = getString(R.string.inventory_battery)
            DeviceTypeObject.TYPE_VEHICLE -> mBinding.tvInventoryType.text = getString(R.string.inventory_vehicle)
            DeviceTypeObject.TYPE_STATION -> mBinding.tvInventoryType.text = getString(R.string.inventory_station)
        }
        mBinding.tvStockValue.text = StringUtil.isDataNumberEmpty(detail.stock)
        mBinding.tvInventoryValue.text = StringUtil.isDataNumberEmpty(detail.inventory)
        inventoryCount = detail.inventory
        stockCount = detail.stock;
    }

    private var inventoryCount = 0
    private var stockCount = 0

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == QRCodeListActivity.REQUEST_CODE
            && resultCode == QRCodeListActivity.RESULT_CODE
        ) {
//            val snList = data?.getParcelableArrayListExtra<ScanDeviceBean>(
//                QRCodeListActivity.SN_LIST
//            ).orEmpty()
//            if (snList.isEmpty()) return
//
//            //调用 ViewModel 处理数据
//            val result = viewModel.handleScan(snList)
//
//            //如果有更新位置，且这些位置在当前页范围内，就通知 Adapter 刷新
//            result.updatedPositions.forEach { globalPos ->
//                val pageStart = (pageIndex - 1) * pageSize
//                val pageEnd = pageStart + mSingleDataBindingNoPUseAdapter.data.size - 1
//                if (globalPos in pageStart..pageEnd) {
//                    val localIdx = globalPos - pageStart
//                    mSingleDataBindingNoPUseAdapter.notifyItemChanged(localIdx)
//                }
//            }
//            // 插入新条目到第一页
//            if (result.newItems.isNotEmpty()) {
//                mSingleDataBindingNoPUseAdapter.addData(0, result.newItems)
//            }
//            val statusUpateCount = snList.count { bean ->
//                val (_, statusStr) = bean.sn.split(",")
//                statusStr.toInt() == 1
//            }
//            //更新 UI 显示总盘点数
//            mBinding.tvInventoryValue.text =
//                StringUtil.isDataNumberEmpty(inventoryCount + viewModel.addedCount + statusUpateCount)
//            //更新库存
//            mBinding.tvStockValue.text =
//                StringUtil.isDataNumberEmpty(stockCount + viewModel.addedCount)
        }
    }


    private lateinit var mSingleDataBindingNoPUseAdapter: SingleDataBindingNoPUseAdapter<DeviceInventoryData>

    override fun createAdapter(): RecyclerView.Adapter<*> {
        mSingleDataBindingNoPUseAdapter = object :
            SingleDataBindingNoPUseAdapter<DeviceInventoryData>(R.layout.item_device_inventory_data) {

            override fun convert(helper: BaseViewHolder, item: DeviceInventoryData) {
                super.convert(helper, item)
                item.run {
                    val tvSn = helper.getView<AppCompatTextView>(R.id.tvSn)
                    tvSn.text = deviceSn
                    val tvStatus = helper.getView<AppCompatTextView>(R.id.tvStatus)
                    when (status) {
                        0 -> {//未盘点
                            tvStatus.text = mContext.getString(R.string.inventory_not_counted)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceInventoryDetailActivity,
                                R.drawable.bg_f2f4f7_r6
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceInventoryDetailActivity,
                                    R.color.color_800c0c0d
                                )
                            )
                        }

                        1 -> {//已盘点
                            tvStatus.text = mContext.getString(R.string.inventory_iventoried)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceInventoryDetailActivity,
                                R.drawable.bg_ffeef7e9_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceInventoryDetailActivity,
                                    R.color.main_color
                                )
                            )
                        }

                        2 -> {//盘盈
                            tvStatus.text = getString(R.string.inventory_in_stock)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceInventoryDetailActivity,
                                R.drawable.bg_fdf5eb_r6
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceInventoryDetailActivity,
                                    R.color.color_ed942f
                                )
                            )
                        }

                    }
                }
            }
        }
        return mSingleDataBindingNoPUseAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        return mBinding.recyclerView
    }

    override fun initPageData() {
        getViewModel().queryInventory(inventoryNo, pageIndex, pageSize)
    }

    private var mTipDialog: QuickPopup? = null

    /**showTipDialog
     * 操作提示
     */
    private fun showTipDialog() {
        mTipDialog = QuickPopupBuilder.with(this).contentView(R.layout.dialog_warning)
            .config(QuickPopupConfig()
                .gravity(Gravity.CENTER)
                .outSideTouchable(false)
                .outSideDismiss(false)
                .backpressEnable(false)
                .withClick(R.id.btn_cancel) { mTipDialog?.dismiss() }
                .withClick(R.id.btn_ok) {
                    mTipDialog?.dismiss()
                    getViewModel().revokeInventory(inventoryNo)
                }).build()
        mTipDialog?.showPopupWindow()
        val tvContent = mTipDialog?.findViewById<TextView>(R.id.tvContent)
        tvContent?.text = getString(R.string.inventory_cancel_tips)
        mTipDialog?.showPopupWindow()
    }


    /**
     * 从一个 List<T> 中，按 pageIndex（从 1 开始）和 pageSize，大致返回该页应包含的元素子集。
     * @param list 要分页的原始列表
     * @param pageIndex 要查询的页码（从 1 开始）
     * @param pageSize  每页多少条，默认 10
     * @return 返回当前页对应的子列表；如果 pageIndex 超出范围，则返回空列表
     */
    private fun <T> paginate(
        list: List<T>,
        pageIndex: Int,
        pageSize: Int = 10
    ): List<T> {
        if (pageIndex < 1 || pageSize < 1) return emptyList()

        // 计算当前页在 list 中的起始下标（0-based）
        val start = (pageIndex - 1) * pageSize
        if (start >= list.size) {
            // 起始下标已经越界，说明没有更多数据，直接返回空列表
            return emptyList()
        }
        // 计算结束下标（注意不超过 list.size）
        val end = minOf(start + pageSize, list.size)
        return list.subList(start, end)
    }

    override fun isBindEventBusHere(): Boolean {
        return true
    }
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun backFromQrcodeList(event: RxEvent.QrcodeListPageBackEvent?) {
        onRefresh()
    }
}