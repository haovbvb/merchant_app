package com.okla.ops.views.workbench.user

import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVFragment
import com.base.common.custom.BottomSpacingColorItemDecoration
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.base.common.utils.LanguageUtils
import com.base.common.utils.NumToStrUtil
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.UserPaymentRecord
import com.okla.ops.databinding.FragmentPaymentRecordBinding
import com.okla.ops.utils.StringUtils
import com.okla.ops.views.workbench.sales.depositrefund.ViewReceiptDialogFragment
import java.util.Locale

class PaymentRecordFragment :
    BaseNormalListVFragment<UserViewModel, FragmentPaymentRecordBinding>() {

    companion object {
        fun getInstance(cardNum: String): PaymentRecordFragment {
            val fragment = PaymentRecordFragment()
            val bundle = Bundle()
            bundle.putString("cardNum", cardNum)
            fragment.arguments = bundle
            return fragment
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_payment_record
    }

    override fun onCreateViewModel(): UserViewModel {
        return ViewModelProvider(this)[UserViewModel::class.java]
    }

    private var mCardNum: String = ""
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mCardNum = arguments?.getString("cardNum") ?: ""
        addObserver()
    }


    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        getStatusView().enableRefresh = true
        getStatusView().enableLoadMore = true
        initEmptyLayout()
        onRefresh()
    }

    private fun initEmptyLayout() {
        mBinding.emptyLayout.dataErrorInfoIv.setImageResource(R.mipmap.icon_empty_payrecord)
        mBinding.emptyLayout.dataErrorInfoTv.text = context?.getString(R.string.str_empty_payrecord)
        mBinding.emptyLayout.dataErrorView.visibility = View.GONE

    }

    private fun addObserver() {
        getViewModel().userPayListLiveData.observe(this) {
            updateListItems(it)
            if (!it.isNullOrEmpty()) {
                mBinding.emptyLayout.dataErrorView.visibility = View.GONE
                mBinding.swipRefresh.visibility = View.VISIBLE
            } else {
                if (pageIndex == 1) {
                    mBinding.emptyLayout.dataErrorView.visibility = View.VISIBLE
                    mBinding.swipRefresh.visibility = View.GONE
                }
            }
        }
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<UserPaymentRecord>
    override fun createAdapter(): RecyclerView.Adapter<*> {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<UserPaymentRecord>(R.layout.item_payment_record) {
            override fun convert(
                helper: BaseViewHolder, item: UserPaymentRecord
            ) {
                super.convert(helper, item)
                helper.setText(R.id.tv_order_no,mContext.getString(R.string.str_order_no).plus(item.orderNo))
                val ivImg = helper.getView<AppCompatImageView>(R.id.ivImg)
                val tvStatus = helper.getView<AppCompatTextView>(R.id.tvStatus)
                val tvDate = helper.getView<AppCompatTextView>(R.id.tvDate)
                val tvAmount = helper.getView<AppCompatTextView>(R.id.tvAmount)
                val tvPeriod = helper.getView<AppCompatTextView>(R.id.tvPeriod)
                val devideLine = helper.getView<View>(R.id.devideline)
                val tvViewVoucher = helper.getView<TextView>(R.id.tv_view_voucher)
                if (helper.adapterPosition == adapter.itemCount - 1) {
                    devideLine.visibility = View.GONE
                } else {
                    devideLine.visibility = View.VISIBLE

                }
                val isHaveVoucher = !item.attachment.isNullOrBlank()
                if (isHaveVoucher) {
                    tvViewVoucher.visibility = View.VISIBLE
                } else {
                    tvViewVoucher.visibility = View.GONE
                }
                helper.addOnClickListener(R.id.tv_view_voucher)
                var str2 = ""
                // 1全款 2分期
                if (item.payType == 1) {
                    str2 = mContext.getString(R.string.text_full_amount)
                    tvPeriod.visibility = View.GONE
                } else if (item.payType == 2) {
                    str2 = mContext.getString(R.string.text_userdetail_installment)
                    tvPeriod.visibility = View.VISIBLE
                    tvPeriod.text = mContext.getString(R.string.text_period_num, item.period)
                }
                context?.let {
                    when (item.payWay) {
                        1 -> {
                            if(LanguageUtils.LanguageUtil.getLocalByLanguage()== Locale.ENGLISH){
                                tvStatus.text = it.getString(R.string.text_cash).plus(" ").plus(str2)
                            }else{
                                tvStatus.text = it.getString(R.string.text_cash).plus(str2)
                            }
                            ivImg.setImageDrawable(
                                ContextCompat.getDrawable(
                                    it, R.mipmap.icon_payrecord_cash
                                )
                            )
                        }

                        2 -> {
                            if(LanguageUtils.LanguageUtil.getLocalByLanguage()== Locale.ENGLISH){
                                tvStatus.text = it.getString(R.string.text_online).plus(" ").plus(str2)
                            }else{
                                tvStatus.text = it.getString(R.string.text_online).plus(str2)
                            }
                            ivImg.setImageDrawable(
                                ContextCompat.getDrawable(
                                    it, R.mipmap.icon_payrecord_online
                                )
                            )
                        }
                    }
                }
                tvDate.text = DateTimeUtils.getTimeString(
                    DateTimeUtils.dateFormatY,
                    item.payTime,
                    LanguageUtils.LanguageUtil.getLocalByLanguage()
                )
                tvAmount.text = "$".plus(NumToStrUtil.DoubleToStrWith2(item.amount ?: 0.00))
            }
        }
        mAdapter.setOnItemChildClickListener { adapter, view, position ->
            val item = adapter.getItem(position) as UserPaymentRecord
            when (view?.id) {
                R.id.tv_view_voucher -> {
                    val voucherList = ArrayList<String>()
                    voucherList.addAll(StringUtils.strToList(item?.attachment))
                    ViewReceiptDialogFragment(voucherList).show(
                        childFragmentManager,
                        "view_receipt"
                    )
                }
            }
        }
        return mAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        val backgroundColor = Color.parseColor("#FFE6E6E6")  // 背景颜色
        val itemDecoration =
            BottomSpacingColorItemDecoration(1, backgroundColor, DensityUtil.dp2px(12f))
        mBinding.rvList.addItemDecoration(itemDecoration)
        mBinding.rvList.setBackgroundResource(R.drawable.bg_ffffff_r8)
        return mBinding.rvList
    }

    override fun initPageData() {
        getViewModel().getUserPayList(mCardNum, pageIndex, pageSize)
    }

}