package com.okla.ops.views.workbench.warehouse.devicetransport

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.InputFilter
import android.text.TextUtils
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.base.common.utils.ToastUtils
import com.chad.library.adapter.base.BaseViewHolder
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.DeviceTransportDetailPageData
import com.okla.ops.beans.DeviceTypeObject
import com.okla.ops.databinding.ActivityDeviceTransportDetailBinding
import com.okla.ops.dialog.PopContentEdit
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.views.workbench.QRCodeListActivity
import com.lxj.xpopup.XPopup

class DeviceTransportDetailActivity :
    BaseNormalListVActivity<DeviceTransportViewModel, ActivityDeviceTransportDetailBinding>() {

    companion object {

        const val TRANSPORT_TYPE_ISSUE = 1
        const val TRANSPORT_TYPE_RECEPTION = 2

        private const val TRANSFER_NO = "transferNo"
        private const val TRANSPORT_TYPE = "transferType"
        private const val TRANSPORT_STATUS = "transferStatus"

        fun getIntents(context: Context, warehouseNo: String, transferType: Int, status: Int) {
            val intent = Intent(context, DeviceTransportDetailActivity::class.java)
            intent.putExtra(TRANSFER_NO, warehouseNo)
            intent.putExtra(TRANSPORT_TYPE, transferType)
            intent.putExtra(TRANSPORT_STATUS, status)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): DeviceTransportViewModel {
        return ViewModelProvider(this).get(DeviceTransportViewModel::class.java)
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_device_transport_detail
    }

    override fun title(): Int {
        return if (transferType == TRANSPORT_TYPE_ISSUE) {
            R.string.transport_issue_detail
        } else {
            R.string.transport_reception_detail
        }
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        getStatusView().enableRefresh = false
        getStatusView().enableLoadMore = true
        if (transferType == TRANSPORT_TYPE_ISSUE) {
            mBinding.tvPostNumberEdit.visibility =
                if (transferStatus == 1 || transferStatus == 3) View.GONE else View.VISIBLE
            mBinding.GroupScan.visibility = View.GONE
        } else {
            mBinding.tvPostNumberEdit.visibility = View.GONE
            mBinding.GroupScan.visibility = View.VISIBLE
        }
        initObserver()
        initClick()
        onRefresh()
    }

    var mDeviceType: Int = 0
    private fun initObserver() {
        getViewModel().mOutTransportDetailLiveData.observe(this) {
            it?.let {
                updateListItems(it.detailPage?.list)
                mBinding.tvTransportId.text = it.transferNo
                mBinding.tvTransportDate.text =
                    DateTimeUtils.getTimeString(DateTimeUtils.defaultFormat, it.sendTime)
                if (it.outWarehouseName.contains("platform")) {
                    mBinding.tvSendAddress.text = mContext.getString(R.string.text_platform)
                } else {
                    mBinding.tvSendAddress.text = it.outWarehouseName
                }
                mBinding.tvReceiveAddress.text = it.inWarehouseName
                mBinding.tvPostNumber.text = it.trackingNumber
                mDeviceType = it.deviceType
                when (mDeviceType) {
                    DeviceTypeObject.TYPE_BATTERY -> mBinding.tvDeviceType.text =
                        getString(R.string.transport_battery)

                    DeviceTypeObject.TYPE_VEHICLE -> mBinding.tvDeviceType.text =
                        getString(R.string.transport_vehicle)
                    DeviceTypeObject.TYPE_STATION-> mBinding.tvDeviceType.text =
                        getString(R.string.transport_station)
                }
                mBinding.tvDeviceNum.text = "(${it.detailPage?.total})"
                mBinding.tvInTransitValue.text = "${it.inTransitNum}"
                mBinding.tvReceiveValue.text = "${it.receivedNum}"
                mBinding.tvRecallValue.text = "${it.withdrawNum}"
            }
        }
        getViewModel().mEditTrackingNumberLiveData.observe(this) {
            onRefresh()
        }
        getViewModel().mDeviceReceiveLiveData.observe(this) {
            onRefresh()
        }
        getViewModel().mDeviceWithdrawLiveData.observe(this) {
            onRefresh()
        }
    }

    private fun initClick() {
        mBinding.tvPostNumberEdit.setOnClickListener {
            XPopup.Builder(this)
                .enableDrag(false)
                .dismissOnTouchOutside(false)
                .asCustom(
                    PopContentEdit(
                        this, mContext.getString(R.string.text_tracking_number)
                    ) { content ->
                        mBinding.tvPostNumber.text = content
                        mTransportNumber = content
                        getViewModel().editTrackingNumber(transferNo, mTransportNumber)

                    })
                .show()
        }
        mBinding.btnScan.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            startActivityForResult(
                QRCodeListActivity.getIntents(this, mDeviceType, transferNo),
                QRCodeListActivity.REQUEST_CODE
            )
        }
    }

    var transferNo: String = ""
    var transferType: Int? = TRANSPORT_TYPE_ISSUE
    var transferStatus: Int? = 0
    override fun getIntentExtras(intent: Intent?) {
        super.getIntentExtras(intent)
        transferNo = intent?.getStringExtra(TRANSFER_NO) ?: ""
        transferType = intent?.getIntExtra(TRANSPORT_TYPE, 0)
        transferStatus = intent?.getIntExtra(TRANSPORT_STATUS, 0)
    }

    private lateinit var mSingleDataBindingNoPUseAdapter: SingleDataBindingNoPUseAdapter<DeviceTransportDetailPageData>

    override fun createAdapter(): RecyclerView.Adapter<*> {
        mSingleDataBindingNoPUseAdapter = object :
            SingleDataBindingNoPUseAdapter<DeviceTransportDetailPageData>(R.layout.item_device_transport_data) {

            override fun convert(helper: BaseViewHolder, item: DeviceTransportDetailPageData) {
                super.convert(helper, item)
                item.run {
                    helper.setText(R.id.tvSn, item.deviceSn)
                    val tvStatus = helper.getView<AppCompatTextView>(R.id.tvDeviceStatus)
                    val tvReceive = helper.getView<AppCompatTextView>(R.id.tvReceive)
                    val tvRecall = helper.getView<AppCompatTextView>(R.id.tvRecall)
                    val tvDate = helper.getView<AppCompatTextView>(R.id.tvDate)
                    if (!TextUtils.isEmpty(item.opTime)) {
                        tvDate.text =
                            DateTimeUtils.getTimeString(
                                DateTimeUtils.defaultFormat,
                                item.opTime,
                                LanguageUtils.LanguageUtil.getLocalByLanguage()
                            )
                        tvDate.visibility = View.VISIBLE
                    } else {
                        tvDate.visibility = View.GONE
                    }
                    tvReceive.visibility = View.GONE
                    tvRecall.visibility = View.GONE
                    tvReceive.setOnClickListener {
                        getViewModel().receiveDevice(item.deviceSn, transferNo)
                    }
                    tvRecall.setOnClickListener {
                        getViewModel().withdrawDevice(item.deviceSn, transferNo)
                    }
                    // 0=在途 1=已接收 2=部分接收 3 已撤回
                    // 0=在途 1=已接收 2已撤回
                    when (item.status) {
                        0 -> {
                            tvStatus.text = getString(R.string.transport_in_transit)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransportDetailActivity,
                                R.drawable.bg_fef7ea_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransportDetailActivity,
                                    R.color.color_ed942f
                                )
                            )
                            if (transferType == TRANSPORT_TYPE_RECEPTION) {
                                tvReceive.visibility = View.VISIBLE
                                tvRecall.visibility = View.VISIBLE
                            }
                        }

                        1 -> {
                            tvStatus.text = getString(R.string.transport_receive)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransportDetailActivity,
                                R.drawable.bg_ffeef7e9_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransportDetailActivity,
                                    R.color.main_color
                                )
                            )
                        }

                        2 -> {
                            tvStatus.text = getString(R.string.transport_withdraw)
                            tvStatus.background = ContextCompat.getDrawable(
                                this@DeviceTransportDetailActivity,
                                R.drawable.bg_fff3f2_r4
                            )
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    this@DeviceTransportDetailActivity,
                                    R.color.color_ffa4332
                                )
                            )
                        }

                        else -> {
                            tvStatus.visibility = View.GONE
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
        getViewModel().queryOutTransportDetail(transferNo, pageIndex, pageSize)
    }

    private var mTransportNumber: String = ""
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == QRCodeListActivity.REQUEST_CODE) {
            onRefresh()
        }
    }

}