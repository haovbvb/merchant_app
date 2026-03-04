package com.okla.ops.views.workbench.sales.installmentPayment

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.Group
import androidx.core.content.ContextCompat
import com.base.common.utils.NumToStrUtil
import com.bumptech.glide.Glide
import com.okla.ops.R
import com.okla.ops.beans.InstallmentPaymentResponse
import com.okla.ops.utils.TextUtil
import com.okla.ops.views.workbench.user.UserDetailActivity

class InstallmentUserInfoView(context: Context) : ConstraintLayout(context), TextUtil {

    init {
        initView()
    }

    private lateinit var tvUserName: TextView
    private lateinit var ivUserHead: ImageView
    private lateinit var tvOrderCount: TextView
    private lateinit var tvConsumptionCount: TextView
    private lateinit var tvAssetCount: TextView
    private lateinit var tvStatus: TextView
    private lateinit var imgArrowRight: ImageView
    private lateinit var groupNotify: Group
    private lateinit var tvUserOrderStatus: TextView
    private lateinit var tvPaySource: TextView


    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_installment_userinfo, this)
        tvUserName = findViewById(R.id.tv_username)
        ivUserHead = findViewById(R.id.img_header)
        tvOrderCount = findViewById(R.id.tv_order_count)
        tvConsumptionCount = findViewById(R.id.tv_total_consumption)
        tvAssetCount = findViewById(R.id.tv_assets)
        imgArrowRight = findViewById(R.id.img_arrow)
        tvStatus = findViewById(R.id.tv_status)
        groupNotify = findViewById(R.id.groupnotify)
        tvUserOrderStatus = findViewById(R.id.tv_in_installments)
        tvPaySource = findViewById(R.id.tv_cash_installment)
    }

    fun updateData(it: InstallmentPaymentResponse) {
        tvUserName.text = it.username
        Glide.with(context).load(it.personImg).error(R.drawable.icon_def_avator).into(ivUserHead)
        tvOrderCount.text = it.orderNum.toString()
        val totalAmount = it.totalAmount?.let { it1 -> NumToStrUtil.DoubleToStrWith2(it1) }
        tvConsumptionCount.text = "$".plus(totalAmount)
        tvAssetCount.text = it.deviceNum.toString()
        //userOrderStatus  1=全款 2=结清 3=分期中 4=逾期 5=失信
        if (it.userOrderStatus == null) {
            groupNotify.visibility = View.GONE
        } else {
            groupNotify.visibility = View.VISIBLE
        }
        when (it.userOrderStatus) {
            1 -> {
                groupNotify.visibility = View.VISIBLE
                tvStatus.text = context.getString(R.string.str_status_fully_paid)
                tvUserOrderStatus.text = context.getString(R.string.text_full_amount)
                tvUserOrderStatus.setTextColor(ContextCompat.getColor(context,R.color.color_f49300))
                tvUserOrderStatus.background =
                    ContextCompat.getDrawable(context, R.drawable.bg_line_f49300_r4)
            }

            2 -> {
                groupNotify.visibility = View.VISIBLE
                tvStatus.text = context.getString(R.string.str_status_settled)
                tvUserOrderStatus.text = context.getString(R.string.text_paid_up)
                tvUserOrderStatus.setTextColor(ContextCompat.getColor(context,R.color.main_color))
                tvUserOrderStatus.background =
                    ContextCompat.getDrawable(context, R.drawable.bg_line_00b88a_r4)
            }

            3 -> {
                groupNotify.visibility = View.VISIBLE
                tvStatus.text = context.getString(R.string.str_status_in_installments)
                tvUserOrderStatus.text = context.getString(R.string.str_in_installments)
                tvUserOrderStatus.setTextColor(ContextCompat.getColor(context,R.color.color_1184f7))
                tvUserOrderStatus.background =
                    ContextCompat.getDrawable(context, R.drawable.bg_line_1184f7_r4)
            }

            4 -> {
                groupNotify.visibility = View.VISIBLE
                tvStatus.text = context.getString(R.string.str_status_overdue)
                tvUserOrderStatus.text = context.getString(R.string.text_overdue)
                tvUserOrderStatus.setTextColor(ContextCompat.getColor(context,R.color.main_color))
                tvUserOrderStatus.background =
                    ContextCompat.getDrawable(context, R.drawable.bg_line_maincolor_r4)
            }

            5 -> {
                groupNotify.visibility = View.VISIBLE
                tvStatus.text = context.getString(R.string.str_status_defaulted)
                tvUserOrderStatus.setTextColor(ContextCompat.getColor(context,R.color.main_color))
                tvUserOrderStatus.text = context.getString(R.string.text_dishonest)
                tvUserOrderStatus.background =
                    ContextCompat.getDrawable(context, R.drawable.bg_line_maincolor_r4)
            }

            else -> {
                tvUserOrderStatus.text = "-"
                tvUserOrderStatus.setTextColor(ContextCompat.getColor(context,R.color.color_99000000))
                tvUserOrderStatus.background =
                    ContextCompat.getDrawable(context, R.drawable.bg_line_26000000_r4)
                groupNotify.visibility = View.GONE
            }
        }
        val userId = it.cardNum
        imgArrowRight.setOnClickListener {
            userId?.let { it1 -> UserDetailActivity.startUserDetailActivity(context, it1) }
        }
    }
}