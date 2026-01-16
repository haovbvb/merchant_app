package com.okla.ops.weight;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.appcompat.widget.LinearLayoutCompat;

import com.okla.ops.R;

public class BatteryDataView extends LinearLayoutCompat {

    private BatteryCapacityView batteryCapacityView;
    private AppCompatTextView tvBatterPercent;

    public BatteryDataView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public BatteryDataView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public BatteryDataView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_battery_data, this);
        batteryCapacityView = view.findViewById(R.id.vPowerImg);
        tvBatterPercent = view.findViewById(R.id.tvPower);
    }

    /**
     * 设置数据
     *
     * @param soc     剩余电量
     * @param lowFlag 低电量标志 1低电量
     */
    public void setData(Integer soc, int lowFlag) {
        batteryCapacityView.setCurrentPower(soc == null ? 0 : soc, lowFlag);
        tvBatterPercent.setText(soc == null ? "-" : soc + "%");
    }

}
