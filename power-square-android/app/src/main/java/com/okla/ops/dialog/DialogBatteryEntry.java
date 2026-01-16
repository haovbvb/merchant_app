package com.okla.ops.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.custom.SpaceItemDecoration;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.Utils;
import com.bumptech.glide.Glide;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.BatteryType;
import com.okla.ops.beans.CarType;
import com.okla.ops.beans.StationType;

import java.util.List;

public class DialogBatteryEntry extends Dialog implements View.OnClickListener {

    private Activity activity;
    private RecyclerView recyclerView;

    public DialogBatteryEntry(Context context) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public DialogBatteryEntry(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    public OnClickListener mOnClickListener;

    public void setOnClickListener(OnClickListener onClickListener) {
        this.mOnClickListener = onClickListener;
    }

    @Override
    public void onClick(View v) {
        dismiss();
    }

    public interface OnClickListener {
        public void onItemClick(BatteryType batteryType, CarType carType,StationType stationType);
    }

    @Override
    public void show() {
        super.show();
        initWindow();
        Utils.setBackgroundAlpha(activity, 0.5f);
    }

    public void initWindow() {
        Window window = getWindow();
        WindowManager.LayoutParams wl = window.getAttributes();
        wl.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        wl.width = ViewGroup.LayoutParams.MATCH_PARENT;
        wl.gravity = Gravity.BOTTOM;
        window.setAttributes(wl);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        View line1 = this.findViewById(R.id.line1);
        View line2 = this.findViewById(R.id.line2);
        View line3 = this.findViewById(R.id.line3);
        line1.setVisibility(View.VISIBLE);
        line2.setVisibility(View.INVISIBLE);
        line3.setVisibility(View.INVISIBLE);
        TextView tvVehicle = this.findViewById(R.id.tv_vehicle);
        TextView tvBattery = this.findViewById(R.id.tv_battery);
        TextView tvStation = this.findViewById(R.id.tv_station);
        tvVehicle.setTextColor(ContextCompat.getColor(activity, R.color.color_e6000000));
        tvBattery.setTextColor(ContextCompat.getColor(activity, R.color.color_66000000));
        tvStation.setTextColor(ContextCompat.getColor(activity, R.color.color_66000000));
        recyclerView.setAdapter(carAdapter);
        Utils.setBackgroundAlpha(activity, 1.0f);
    }

    private SingleDataBindingNoPUseAdapter<BatteryType> batteryAdapter;
    private SingleDataBindingNoPUseAdapter<CarType> carAdapter;

    private SingleDataBindingNoPUseAdapter<StationType> stationAdapter;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_battery_entry, null);
        TextView tvVehicle = view.findViewById(R.id.tv_vehicle);
        TextView tvBattery = view.findViewById(R.id.tv_battery);
        TextView tvStation = view.findViewById(R.id.tv_station);
        View line1 = view.findViewById(R.id.line1);
        View line2 = view.findViewById(R.id.line2);
        View line3 = view.findViewById(R.id.line3);
        recyclerView = view.findViewById(R.id.rvBatteryType);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        recyclerView.addItemDecoration(new SpaceItemDecoration(DensityUtil.dp2px(8.0f), 0));
        batteryAdapter = new SingleDataBindingNoPUseAdapter<BatteryType>(R.layout.item_battery_type) {
            @Override
            protected void convert(@NonNull BaseViewHolder helper, BatteryType item) {
                super.convert(helper, item);
                TextView tvModel = helper.getView(R.id.tvModel);
                TextView tvModelName = helper.getView(R.id.tvModelName);
                ImageView ivImg = helper.getView(R.id.ivBattery);
                tvModel.setText(item.getModel());
                tvModelName.setText(item.getModelName());
                Glide.with(getContext()).load(item.getImg())
                        .into(ivImg);
            }
        };
        carAdapter = new SingleDataBindingNoPUseAdapter<CarType>(R.layout.item_battery_type) {
            @Override
            protected void convert(@NonNull BaseViewHolder helper, CarType item) {
                super.convert(helper, item);
                TextView tvModel = helper.getView(R.id.tvModel);
                TextView tvModelName = helper.getView(R.id.tvModelName);
                ImageView ivImg = helper.getView(R.id.ivBattery);
                tvModel.setText(item.getModel());
                tvModelName.setText(item.getModelName());
                Glide.with(getContext()).load(item.getImg())
                        .into(ivImg);
            }
        };
        stationAdapter = new SingleDataBindingNoPUseAdapter<StationType>(R.layout.item_battery_type) {
            @Override
            protected void convert(@NonNull BaseViewHolder helper, StationType item) {
                super.convert(helper, item);
                TextView tvModel = helper.getView(R.id.tvModel);
                TextView tvModelName = helper.getView(R.id.tvModelName);
                ImageView ivImg = helper.getView(R.id.ivBattery);
                tvModel.setText(item.getModel());
                tvModelName.setText(item.getModelName());
                Glide.with(getContext()).load(item.getImg())
                        .into(ivImg);
            }
        };
        batteryAdapter.setOnItemClickListener((adapter, v, position) -> {
            BatteryType batteryType = (BatteryType) adapter.getData().get(position);
            if (mOnClickListener != null)
                mOnClickListener.onItemClick(batteryType, null,null);
            dismiss();
        });
        carAdapter.setOnItemClickListener((adapter, v, position) -> {
            CarType carType = (CarType) adapter.getData().get(position);
            if (mOnClickListener != null)
                mOnClickListener.onItemClick(null, carType,null);
            dismiss();
        });
        stationAdapter.setOnItemClickListener((adapter, v, position) -> {
            StationType stationType = (StationType) adapter.getData().get(position);
            if (mOnClickListener != null)
                mOnClickListener.onItemClick(null, null,stationType);
            dismiss();
        });
        recyclerView.setAdapter(carAdapter);
        tvVehicle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                line1.setVisibility(View.VISIBLE);
                line2.setVisibility(View.INVISIBLE);
                line3.setVisibility(View.INVISIBLE);
                tvVehicle.setTextColor(ContextCompat.getColor(activity, R.color.color_e6000000));
                tvBattery.setTextColor(ContextCompat.getColor(activity, R.color.color_66000000));
                tvStation.setTextColor(ContextCompat.getColor(activity, R.color.color_66000000));
                recyclerView.setAdapter(carAdapter);
            }
        });
        tvBattery.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                line1.setVisibility(View.INVISIBLE);
                line2.setVisibility(View.VISIBLE);
                line3.setVisibility(View.INVISIBLE);
                tvVehicle.setTextColor(ContextCompat.getColor(activity, R.color.color_66000000));
                tvBattery.setTextColor(ContextCompat.getColor(activity, R.color.color_e6000000));
                tvStation.setTextColor(ContextCompat.getColor(activity, R.color.color_66000000));
                recyclerView.setAdapter(batteryAdapter);
            }
        });
        tvStation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                line1.setVisibility(View.INVISIBLE);
                line2.setVisibility(View.INVISIBLE);
                line3.setVisibility(View.VISIBLE);
                tvStation.setTextColor(ContextCompat.getColor(activity, R.color.color_66000000));
                tvBattery.setTextColor(ContextCompat.getColor(activity, R.color.color_e6000000));
                tvVehicle.setTextColor(ContextCompat.getColor(activity, R.color.color_66000000));
                recyclerView.setAdapter(stationAdapter);

            }
        });
        return view;
    }

    public void updateCarData(List<CarType> list) {
        carAdapter.setNewData(list);
    }

    public void updateBatteryData(List<BatteryType> list) {
        batteryAdapter.setNewData(list);
    }
    public void updateStationData(List<StationType> list){
        stationAdapter.setNewData(list);
    }
}
