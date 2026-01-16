package com.okla.ops.views.workbench.user

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.base.common.utils.LanguageUtils
import com.base.common.utils.NumToStrUtil
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.PayTypeObject
import com.okla.ops.databinding.FragmentRefreshListBinding
import com.okla.ops.dialog.RoadSidePaymentDialog
import com.okla.ops.utils.StringUtils
import com.okla.ops.views.workbench.sales.depositrefund.ViewReceiptDialogFragment
import java.util.Locale

class UserSaleOrderRecordListFragment :
    BaseNormalVFragment<UserViewModel, FragmentRefreshListBinding>() {

    companion object {
        fun getInstance(cardNum: String): UserSaleOrderRecordListFragment {
            val fragment = UserSaleOrderRecordListFragment()
            val bundle = Bundle()
            bundle.putString("cardNum", cardNum)
            fragment.arguments = bundle
            return fragment
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_refresh_list
    }

    override fun onCreateViewModel(): UserViewModel {
        return ViewModelProvider(this)[UserViewModel::class.java]
    }

    private var mCardNum: String = ""
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mCardNum = arguments?.getString("cardNum") ?: ""
    }


    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        mBinding.swipRefresh.setEnableRefresh(true)
        mBinding.swipRefresh.setEnableLoadMore(true)
        initEmptyLayout()
        initAdapter()
        addObserver()
        refreshData()
    }

    private fun initEmptyLayout() {
        mBinding.emptyLayout.dataErrorInfoIv.setImageResource(R.mipmap.empty_user_orderrecord)
        mBinding.emptyLayout.dataErrorInfoTv.text = context?.getString(R.string.str_no_order_yet)
        mBinding.emptyLayout.dataErrorView.visibility = View.GONE
    }

    private fun addObserver() {
        mBinding.swipRefresh.setOnRefreshListener {
            pageIndex = 1
            refreshData()
        }
        mBinding.swipRefresh.setOnLoadMoreListener {
            pageIndex++
            refreshData()
        }
        getViewModel().userSaleOrderListLiveData.observe(this) {
            updateList(it)
        }
    }

    @SuppressLint("NotifyDataSetChanged")
    private fun updateList(items: List<SaleOrder>?) {
        if (mAdapter == null) return
        val isDataEmpty = items.isNullOrEmpty()
        if (pageIndex == 1) {
            if (isDataEmpty) {
                mAdapter.setNewData(mutableListOf())
                mBinding.swipRefresh.finishRefreshWithNoMoreData()
            } else {
                mAdapter.setNewData(items?.toMutableList())
                mBinding.swipRefresh.finishRefresh(true)
                mBinding.swipRefresh.resetNoMoreData()
            }
            if (mAdapter.data.isEmpty()) {
                mBinding.emptyLayout.dataErrorView.visibility = View.VISIBLE
                mBinding.swipRefresh.visibility = View.GONE
            } else {
                mBinding.emptyLayout.dataErrorView.visibility = View.GONE
                mBinding.swipRefresh.visibility = View.VISIBLE
            }
        } else {
            if (isDataEmpty) {
                mBinding.swipRefresh.finishLoadMoreWithNoMoreData()
            } else {
                items?.let { mAdapter.addData(it) }
                mBinding.swipRefresh.finishLoadMore(true)
            }
        }
        mAdapter.notifyDataSetChanged()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<SaleOrder>
    private fun initAdapter() {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<SaleOrder>(R.layout.item_userdetail_saleorder) {
            override fun convert(
                helper: BaseViewHolder, item: SaleOrder
            ) {
                super.convert(helper, item)
                item?.let {
                    if (null != item.orderNo) {
                        helper.setText(R.id.tv_order_no, item.orderNo)
                    }
                    val imgDevice = helper.getView<ImageView>(R.id.img_device)
                    Glide.with(mContext).load(item.deviceImg).into(imgDevice)
                    helper.setText(
                        R.id.tv_order_time,
                        DateTimeUtils.getTimeString(
                            DateTimeUtils.dateFormat3,
                            item.createTime ?: 0,
                            LanguageUtils.LanguageUtil.getLocalByLanguage()
                        )
                    )
                    if (item.deviceSn != null) {
                        helper.setText(R.id.tv_device_sn, item.deviceSn.toString())
                    }
                    if (null != item.deviceModel) {
                        helper.setText(R.id.tv_model, item.deviceModel)
                    }
                    helper.setText(
                        R.id.tv_price,
                        "$".plus(NumToStrUtil.DoubleToStrWith2(item.orderAmount ?: 0.00))
                    )
                    val tvStatus = helper.getView<TextView>(R.id.tv_pay_status)
                    val tvPayType = helper.getView<TextView>(R.id.tv_pay_type)
                    var str1 = ""
                    var str2 = ""
                    if (item.payWay == PayTypeObject.TYPE_CASH) {
                        //现金
                        str1 = mContext.getString(R.string.text_cash)
                    } else if (item.payWay == PayTypeObject.TYPE_ONLINE) {
                        //线上
                        str1 = mContext.getString(R.string.text_online)
                    }
                    if (item.payType == 1) {
                        //全款
                        str2 = mContext.getString(R.string.text_full_amount)
                        helper.setGone(R.id.group_installment, false)
                    } else if (item.payType == 2) {
                        //分期
                        str2 = mContext.getString(R.string.str_installment)
                        helper.setGone(R.id.group_installment, true)
                        helper.setText(R.id.tv_term, item.period.toString())
                        helper.setText(R.id.tv_rate, "${item.rate?.times(100)}%")
                        helper.setText(
                            R.id.tv_monthly,
                            "$".plus(NumToStrUtil.DoubleToStrWith2(item.perAmount ?: 0.00))
                        )
                    }
                    if (LanguageUtils.LanguageUtil.getLocalByLanguage() == Locale.US) {
                        tvPayType.text = str1.plus(" ").plus(str2)
                    } else {
                        tvPayType.text = str1.plus(str2)
                    }
                    //订单状态：-1 已关闭 0=待支付 1=全款 2=结清 3=分期中 4=逾期 5=失信 7=使用中 8=已结束
                    when (item.status) {
                        -1->{
                            tvStatus.text=mContext.getString(R.string.str_have_closed)
                            tvStatus.setTextColor(ContextCompat.getColor(mContext,R.color.color_99000000))
                            tvStatus.setBackgroundResource(R.drawable.bg_line_26000000_r4)
                        }
                        0 -> {
                            tvStatus.text = mContext.getString(R.string.str_payment_pending)
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    mContext,
                                    R.color.color_f49300
                                )
                            )
                            tvStatus.setBackgroundResource(R.drawable.bg_line_f49300_r4)
                        }

                        1 -> {
                            tvStatus.text = mContext.getString(R.string.str_full_payment)
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    mContext,
                                    R.color.main_color
                                )
                            )
                            tvStatus.setBackgroundResource(R.drawable.bg_line_00b88a_r4)
                        }

                        2 -> {
                            tvStatus.text = mContext.getString(R.string.text_paid_up)
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    mContext,
                                    R.color.main_color
                                )
                            )
                            tvStatus.setBackgroundResource(R.drawable.bg_line_00b88a_r4)
                        }

                        3 ,7-> {
                            tvStatus.text = mContext.getString(R.string.str_in_installments)
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    mContext,
                                    R.color.color_1184f7
                                )
                            )
                            tvStatus.setBackgroundResource(R.drawable.bg_line_1184f7_r4)
                        }

                        4 -> {
                            tvStatus.text = mContext.getString(R.string.text_overdue)
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    mContext,
                                    R.color.color_ffa4332
                                )
                            )
                            tvStatus.setBackgroundResource(R.drawable.bg_fff3f2_r4)
                        }

                        5 -> {
                            tvStatus.text = mContext.getString(R.string.text_dishonest)
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    mContext,
                                    R.color.main_color
                                )
                            )
                            tvStatus.setBackgroundResource(R.drawable.bg_line_maincolor_r4)
                        }
                        8->{
                            tvStatus.text = mContext.getString(R.string.str_ended)
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    mContext,
                                    R.color.main_color
                                )
                            )
                            tvStatus.setBackgroundResource(R.drawable.bg_line_maincolor_r4)
                        }

                        else -> {
                            tvStatus.text = "-"
                            tvStatus.setTextColor(
                                ContextCompat.getColor(
                                    mContext,
                                    R.color.color_99000000
                                )
                            )
                            tvStatus.setBackgroundResource(R.drawable.bg_line_26000000_r4)
                        }
                    }
                    val tvVoucher = helper.getView<TextView>(R.id.tv_view_voucher)
                    val voucherLayout = helper.getView<ConstraintLayout>(R.id.voucherlayout)
                    //现金待支付
                    if (item.status == 0 && item.payWay == PayTypeObject.TYPE_CASH) {
                        voucherLayout.visibility = View.VISIBLE
                        tvVoucher.text = mContext.getString(R.string.str_upload_voucher)
                        val drawable =
                            ContextCompat.getDrawable(mContext, R.mipmap.icon_upload_voucher)
                        drawable?.setBounds(0, 0, DensityUtil.dp2px(22f), DensityUtil.dp2px(22f))
                        tvVoucher.setCompoundDrawables(
                            drawable, null, null, null
                        )
                    } else {
                        if (item.attachment.isNullOrBlank()) {
                            voucherLayout.visibility = View.GONE
                        } else {
                            voucherLayout.visibility = View.VISIBLE
                            tvVoucher.text = mContext.getString(R.string.str_view_voucher)
                            val drawable =
                                ContextCompat.getDrawable(mContext, R.mipmap.icon_view_voucher)
                            drawable?.setBounds(
                                0,
                                0,
                                DensityUtil.dp2px(22f),
                                DensityUtil.dp2px(22f)
                            )
                            tvVoucher.setCompoundDrawables(
                                drawable, null, null, null
                            )
                        }
                    }
                    helper.addOnClickListener(R.id.voucherlayout)
                }

            }
        }
        mAdapter.setOnItemChildClickListener { adapter, view, position ->
            val item = mAdapter.getItem(position)
            when (view.id) {
                R.id.voucherlayout -> {
                    if (item?.status == 0) {
                        val dialog =
                            RoadSidePaymentDialog.Companion.getInstance(
                                mCardNum,
                                item?.orderNo ?: "",
                                RoadSidePaymentDialog.TYPE_JUST_UPLOAD_VOUCHER
                            )
                        dialog.show(childFragmentManager, "roadsidepaymentdialog")
                        dialog.setUploadCallBack(object :
                            RoadSidePaymentDialog.OnUploadAttachmentCallBack {
                            override fun onUploadAttachmentCallBack(list: ArrayList<String>) {
                                if (!list.isNullOrEmpty()) {
                                    val item = mAdapter.getItem(position)
                                    //全款
                                    if (item?.payType == 1) {
                                        mAdapter.getItem(position)?.status = 1
                                    } else if (item?.payType == 2) {
                                        mAdapter.getItem(position)?.status = 3
                                    }
                                    mAdapter.getItem(position)?.attachment =
                                        StringUtils.listToStr(list)
                                    mAdapter.notifyItemChanged(position)
                                }
                            }
                        })

                    } else {
                        if (!item?.attachment.isNullOrBlank()) {
                            val voucherList = ArrayList<String>()
                            voucherList.addAll(StringUtils.strToList(item?.attachment))
                            ViewReceiptDialogFragment(voucherList).show(
                                childFragmentManager,
                                "view_receipt"
                            )
                        }
                    }
                }
            }
        }
        mBinding.rvList.adapter = mAdapter
    }


    private var pageIndex = 1
    private var pageSize = 10;

    private fun refreshData() {
        getViewModel().getUserOrderList(0, mCardNum, pageIndex, pageSize)
    }

}