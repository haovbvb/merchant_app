package com.okla.ops.views.workbench.sales;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.Group;

import com.base.common.utils.NumToStrUtil;
import com.okla.ops.R;
import com.okla.ops.beans.ServicePlanBean;
import com.okla.ops.views.workbench.sales.rentbind.Pack;

import java.util.Locale;

public class BindPackageInfoView extends ConstraintLayout {
    public BindPackageInfoView(@NonNull Context context) {
        super(context);
        init(context);

    }

    public BindPackageInfoView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);

    }

    public BindPackageInfoView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);

    }

    public BindPackageInfoView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context);

    }

    private TextView tvDeviceTypeModel;
    private TextView tvTitle;
    private TextView tvPrice;

    private Group groupSellBind;
    private Group groupRentBind;

    private Group groupSwapBind;
    private TextView tvServicePeriod;
    private TextView tvSwapPeriod;
    private TextView tvDeposit;

    private ConstraintLayout rootLayout;

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_bindpackage_info, this);
        rootLayout = findViewById(R.id.rootlayout);
        tvTitle = findViewById(R.id.tv_title);
        groupSellBind = findViewById(R.id.group_sellbind);
        tvPrice = findViewById(R.id.tv_price);
        tvDeviceTypeModel = findViewById(R.id.tv_device_type_model);
        groupRentBind = findViewById(R.id.group_rentbind);
        tvServicePeriod = findViewById(R.id.tv_service_period);
        tvDeposit = findViewById(R.id.tv_deposit);
        groupSwapBind = findViewById(R.id.group_swap);
        tvSwapPeriod = findViewById(R.id.tv_swap_period);
    }

    //销售绑定
    public void updateSellData(ServicePlanBean bean) {
        if (bean == null) {
            rootLayout.setVisibility(View.GONE);
        } else {
            rootLayout.setVisibility(View.VISIBLE);
            groupSellBind.setVisibility(View.VISIBLE);
            groupRentBind.setVisibility(View.GONE);
            groupSwapBind.setVisibility(View.GONE);
            tvTitle.setText(bean.getInfoName());
            tvPrice.setText("$" + NumToStrUtil.INSTANCE.DoubleToStrWith2(bean.getPackageAmount()));
            if (!TextUtils.isEmpty(bean.getCarType().trim())) {
                tvDeviceTypeModel.setText(getContext().getString(R.string.text_vehicle) + " • " + bean.getCarType());
            }else if (!TextUtils.isEmpty(bean.getBatteryType().trim())) {
                tvDeviceTypeModel.setText(getContext().getString(R.string.text_battery) + " • " + bean.getBatteryType());
            }
        }

    }

    //租赁绑定
    public void updateRentData(Pack pack) {
        if (pack == null) {
            rootLayout.setVisibility(View.GONE);
        } else {
            rootLayout.setVisibility(View.VISIBLE);
            groupRentBind.setVisibility(View.VISIBLE);
            groupSellBind.setVisibility(View.GONE);
            groupSwapBind.setVisibility(View.GONE);
            tvTitle.setText(pack.getInfoName());
            tvPrice.setText("$" + NumToStrUtil.INSTANCE.DoubleToStrWith2(pack.getPackageAmount()));
            if (pack.getDepositAmount() != null) {
                tvDeposit.setText("$" + NumToStrUtil.INSTANCE.DoubleToStrWith2(pack.getDepositAmount()));
            } else {
                tvDeposit.setText("$" + "-");
            }
            //infotype 0包自然月 1固定周期
            //havedeposit 0否 1是
            String durationStr = "-";
            if (pack.getDuration() != null) {
                durationStr = pack.getDuration().toString();
            }
            //infotype 0包自然月 1固定周期
            if (pack.getInfoType() != null) {
                if (pack.getInfoType() == 0) {
                    tvServicePeriod.setText(getResources().getString(R.string.full_calendar_month));
                } else {
                    tvServicePeriod.setText(getResources().getString(R.string.fixed_cycle) + " • " + durationStr + getContext().getString(R.string.str_days));
                }
            } else {
                tvServicePeriod.setText("-");
            }
        }
    }

    //换电绑定
    private TextView tvAvailableBattery;
    private TextView tvAvailableVehicles;
    private TextView tvPeriod;
    private TextView tvSwapTime;

    public void updateSwapBindData(Pack pack) {
        if (pack == null) {
            rootLayout.setVisibility(View.GONE);
        } else {
            rootLayout.setVisibility(View.VISIBLE);
            groupSwapBind.setVisibility(View.VISIBLE);
            groupSellBind.setVisibility(View.GONE);
            groupRentBind.setVisibility(View.GONE);
            tvTitle.setText(pack.getInfoName());
            tvPrice.setText("$" + NumToStrUtil.INSTANCE.DoubleToStrWith2(pack.getPackageAmount()));
            tvAvailableBattery = findViewById(R.id.tv_battery_available);
            tvAvailableVehicles = findViewById(R.id.tv_vehicle_available);
            tvSwapTime = findViewById(R.id.tv_swaptime);
            if (pack.getBatteryType() != null) {
                tvAvailableBattery.setText(pack.getBatteryType() + " • " + pack.getBatteryNum().toString() + "pac");
            } else {
                tvAvailableBattery.setText("-" + " • " + pack.getBatteryNum().toString() + "pac");
            }
            tvAvailableVehicles.setText(pack.getCarType());
            String str1 = "";
            String str2 = "";
            if (pack.getInfoType() != null) {
                if (pack.getInfoType() == 1) {
                    str1 = getResources().getString(R.string.fixed_cycle);
                    if (pack.getDuration() != null) {
                        str2 = " • " + pack.getDuration().toString() + getContext().getString(R.string.str_days);
                    } else {
                        str2 = " • " + "-" + getContext().getString(R.string.str_days);
                    }
                } else {
                    str1 = getResources().getString(R.string.full_calendar_month);
                }
                tvSwapPeriod.setText(str1 + str2);
            } else {
                tvSwapPeriod.setText("-");
            }
            if (pack.getTimes() != null) {
                tvSwapTime.setText(pack.getTimes().toString());
            } else {
                tvSwapTime.setText("-");
            }
        }

    }

}
