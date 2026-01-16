package com.okla.ops.views.workbench.sales.installmentPayment;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;

import com.base.common.utils.DateTimeUtils;
import com.base.common.utils.LanguageUtils;
import com.base.common.utils.NumToStrUtil;
import com.bumptech.glide.Glide;
import com.okla.ops.R;
import com.okla.ops.beans.PayTypeObject;
import com.okla.ops.beans.PeriodOrder;

import java.util.Locale;

public class PaymentSelectedOrderInfoView extends ConstraintLayout {
    private TextView tvOrderNo;
    private TextView tvTime;
    private ImageView imgDevice;
    private TextView tvDeviceSn;
    private TextView tvModel;
    private TextView tvRemainAmount;
    private TextView tvReaminInstall;
    private TextView tvLatestDueDate;
    private TextView tvMonthlyAmount;

    private TextView tvStatus;

    private TextView tvPaySource;

    private ConstraintLayout rootLayout;

    public PaymentSelectedOrderInfoView(@NonNull Context context) {
        super(context);
        init(context);

    }

    public PaymentSelectedOrderInfoView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);

    }

    public PaymentSelectedOrderInfoView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);

    }

    public PaymentSelectedOrderInfoView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context);

    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_payment_order_info, this);
        tvOrderNo = view.findViewById(R.id.tv_orderno);
        tvTime = view.findViewById(R.id.tv_time);
        imgDevice = view.findViewById(R.id.img_device);
        tvDeviceSn = view.findViewById(R.id.tv_devicesn);
        tvModel = view.findViewById(R.id.tv_model);
        tvRemainAmount = view.findViewById(R.id.tv_remain_amount);
        tvReaminInstall = view.findViewById(R.id.tv_reamin_installment);
        tvLatestDueDate = view.findViewById(R.id.tv_due_date);
        tvMonthlyAmount = view.findViewById(R.id.tv_monthly_amount);
        rootLayout = view.findViewById(R.id.rootlayout);
        tvStatus = view.findViewById(R.id.tv_in_installments);
        tvPaySource = view.findViewById(R.id.tv_cash_installment);
    }

    public void updateInfo(PeriodOrder order) {
        if (order == null) {
            rootLayout.setVisibility(View.GONE);
        } else {
            rootLayout.setVisibility(View.VISIBLE);
            tvOrderNo.setText(order.getOrderNo());
            tvDeviceSn.setText(order.getSn());
            tvModel.setText(order.getModel());
            String remainStr = String.format(
                    Locale.US,
                    "%.2f",
                    order.getRemainPay()
            );
            tvRemainAmount.setText("$" + remainStr);
            tvReaminInstall.setText(String.valueOf(order.getRemainPeriod()));
            if (null != order.getRePaymentDate()) {
                tvLatestDueDate.setText(DateTimeUtils.getTimeString(DateTimeUtils.dateFormatY, order.getRePaymentDate(), LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage()));
            } else {
                tvLatestDueDate.setText("-");
            }
            String monthlyStr = NumToStrUtil.INSTANCE.DoubleToStrWith2(order.getAmount());
            tvMonthlyAmount.setText("$" + monthlyStr);
            tvTime.setText(DateTimeUtils.getTimeString(DateTimeUtils.dateFormatNormal, order.getOrderDate(), LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage()));
            Glide.with(getContext()).load(order.getImg()).into(imgDevice);
            if (order.getPaySource() == PayTypeObject.TYPE_ONLINE) {
                tvPaySource.setText(getContext().getString(R.string.str_online_installment));
            } else if (order.getPaySource() == PayTypeObject.TYPE_CASH) {
                tvPaySource.setText(getContext().getString(R.string.str_cash_installment));
            }
            // 1=全款 2=结清 3=分期中 4=逾期 5=失信
            switch (order.getStatus()) {
                case 1:
                    tvStatus.setText(getContext().getString(R.string.str_status_fully_paid));
                    tvStatus.setTextColor(ContextCompat.getColor(getContext(), R.color.color_f49300));
                    tvStatus.setBackground(
                            ContextCompat.getDrawable(getContext(), R.drawable.bg_line_f49300_r4));
                    break;
                case 2:
                    tvStatus.setText(getContext().getString(R.string.text_paid_up));
                    tvStatus.setTextColor(ContextCompat.getColor(getContext(), R.color.main_color));
                    tvStatus.setBackground(
                            ContextCompat.getDrawable(getContext(), R.drawable.bg_line_maincolor_r4));
                    break;
                case 3:
                    tvStatus.setText(getContext().getString(R.string.str_in_installments));
                    tvStatus.setTextColor(ContextCompat.getColor(getContext(), R.color.color_1184f7));
                    tvStatus.setBackground(
                            ContextCompat.getDrawable(getContext(), R.drawable.bg_line_1184f7_r4));
                    break;
                case 4:
                    tvStatus.setText(getContext().getString(R.string.status_overdue));
                    tvStatus.setTextColor(ContextCompat.getColor(getContext(), R.color.color_ffa4332));
                    tvStatus.setBackground(
                            ContextCompat.getDrawable(getContext(), R.drawable.bg_line_fa4332_r4));
                    break;
                case 5:
                    tvStatus.setText(getContext().getString(R.string.text_dishonest));
                    tvStatus.setTextColor(ContextCompat.getColor(getContext(), R.color.color_ffa4332));
                    tvStatus.setBackground(ContextCompat.getDrawable(getContext(), R.drawable.bg_line_fa4332_r4));
                    break;
                default:
                    break;

            }
        }

    }
}
