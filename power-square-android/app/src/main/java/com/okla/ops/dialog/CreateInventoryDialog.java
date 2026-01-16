package com.okla.ops.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.constraintlayout.widget.Group;
import androidx.core.content.ContextCompat;

import com.base.common.utils.Utils;
import com.okla.ops.R;
import com.okla.ops.beans.WarehouseBeanType;

public class CreateInventoryDialog extends Dialog implements View.OnClickListener {

    private Activity activity;

    private String warehouseNo;
    private int deviceType;

    public CreateInventoryDialog(Context context) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public CreateInventoryDialog(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    public OnClickListener mOnClickListener;

    public void setOnClickListener(OnClickListener onClickListener) {
        this.mOnClickListener = onClickListener;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.iv_close:
                if (mOnClickListener != null)
                    mOnClickListener.onCancel();
                dismiss();
                break;
            case R.id.tvSelectInventory:
                if (mOnClickListener != null) mOnClickListener.onSelectWarehouse();
                break;
            case R.id.tvStation:
                resetSelectStatus();
                tvStation.setBackground(getContext().getDrawable(R.drawable.bg_fff_line_00b39b_r8));
                tvStation.setCompoundDrawablesRelativeWithIntrinsicBounds(null, ContextCompat.getDrawable(getContext(), R.drawable.icon_station_select), null, null);
                tvStation.setTextColor(getContext().getColor(R.color.color_00b39b));
                deviceType = 2;
                enableStartButton();
                break;
            case R.id.tvBattery:
                resetSelectStatus();
                tvBattery.setBackground(getContext().getDrawable(R.drawable.bg_fff_line_00b39b_r8));
                tvBattery.setCompoundDrawablesRelativeWithIntrinsicBounds(null, ContextCompat.getDrawable(getContext(), R.drawable.icon_battery_select), null, null);
                tvBattery.setTextColor(getContext().getColor(R.color.color_00b39b));
                deviceType = 1;
                enableStartButton();
                break;
            case R.id.tvVehicle:
                resetSelectStatus();
                tvVehicle.setBackground(getContext().getDrawable(R.drawable.bg_fff_line_00b39b_r8));
                tvVehicle.setCompoundDrawablesRelativeWithIntrinsicBounds(null, ContextCompat.getDrawable(getContext(), R.drawable.icon_vehicle_select), null, null);
                tvVehicle.setTextColor(getContext().getColor(R.color.color_00b39b));
                deviceType = 3;
                enableStartButton();
                break;
            case R.id.btnConfirm:
                /*if (TextUtils.isEmpty(warehouseNo)) {
                    ToastUtils.showShort(getContext().getString(R.string.inventory_select_inventory));
                } else if (deviceType == 0) {
                    ToastUtils.showShort(getContext().getString(R.string.inventory_select_device_type));
                }*/
                if (!TextUtils.isEmpty(warehouseNo) && deviceType != 0) {
                    if (mOnClickListener != null)
                        mOnClickListener.onConfirmClick(warehouseNo, deviceType);
                    dismiss();
                }
                break;
        }
    }

    private void resetSelectStatus() {
        tvStation.setBackground(getContext().getDrawable(R.drawable.bg_f5f8fb_r8));
        tvStation.setCompoundDrawablesRelativeWithIntrinsicBounds(null, ContextCompat.getDrawable(getContext(), R.drawable.icon_station_unselect), null, null);
        tvStation.setTextColor(getContext().getColor(R.color.color_800c0c0d));
        tvBattery.setBackground(getContext().getDrawable(R.drawable.bg_f5f8fb_r8));
        tvBattery.setCompoundDrawablesRelativeWithIntrinsicBounds(null, ContextCompat.getDrawable(getContext(), R.drawable.icon_battery_unselect), null, null);
        tvBattery.setTextColor(getContext().getColor(R.color.color_800c0c0d));
        tvVehicle.setBackground(getContext().getDrawable(R.drawable.bg_f5f8fb_r8));
        tvVehicle.setCompoundDrawablesRelativeWithIntrinsicBounds(null, ContextCompat.getDrawable(getContext(), R.drawable.icon_vehicle_unselect), null, null);
        tvVehicle.setTextColor(getContext().getColor(R.color.color_800c0c0d));
    }

    private void enableStartButton() {
        if (!TextUtils.isEmpty(warehouseNo) && deviceType != 0) {
            btnStart.setBackground(getContext().getDrawable(com.base.common.R.drawable.bg_maincolor_r8));
        } else {
            btnStart.setBackground(getContext().getDrawable(R.drawable.bg_7accc1_r8));
        }
    }

    public interface OnClickListener {

        void onConfirmClick(String warehouseNo, int type);

        void onCancel();

        void onSelectWarehouse();
    }

    @Override
    public void show() {
        super.show();
        initWindow();
        Utils.setBackgroundAlpha(activity, 0.5f);
    }

    public void initWindow() {
        Window window = getWindow();
        if (window != null) {
            WindowManager.LayoutParams wl = window.getAttributes();
            wl.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            wl.width = ViewGroup.LayoutParams.MATCH_PARENT;
            wl.gravity = Gravity.BOTTOM;
            window.setAttributes(wl);
        }
    }

    @Override
    public void dismiss() {
        super.dismiss();
        warehouseNo = "";
        deviceType = 0;
        tvSelectInventory.setText("");
        groupPosition.setVisibility(View.GONE);
        tvPositionValue.setVisibility(View.GONE);
        resetSelectStatus();
        enableStartButton();
        Utils.setBackgroundAlpha(activity, 1.0f);
    }

    private AppCompatTextView tvSelectInventory, tvPositionValue, tvStation, tvBattery, tvVehicle, btnStart;
    private Group groupPosition;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_create_inventory, null);
        view.findViewById(R.id.iv_close).setOnClickListener(this);
        tvSelectInventory = view.findViewById(R.id.tvSelectInventory);
        tvSelectInventory.setOnClickListener(this);
        tvPositionValue = view.findViewById(R.id.tvPositionValue);
        tvPositionValue.setVisibility(View.GONE);
        groupPosition = view.findViewById(R.id.group_position);
        groupPosition.setVisibility(View.GONE);
        tvStation = view.findViewById(R.id.tvStation);
        tvStation.setOnClickListener(this);
        tvBattery = view.findViewById(R.id.tvBattery);
        tvBattery.setOnClickListener(this);
        tvVehicle = view.findViewById(R.id.tvVehicle);
        tvVehicle.setOnClickListener(this);
        btnStart = view.findViewById(R.id.btnConfirm);
        btnStart.setOnClickListener(this);
        return view;
    }

    public void updateData(String warehouseName, String warehouseNo, Integer type) {
        this.warehouseNo = warehouseNo;
        tvSelectInventory.setText(warehouseName);
        groupPosition.setVisibility(View.VISIBLE);
        tvPositionValue.setVisibility(View.VISIBLE);
        switch (type) {
            case WarehouseBeanType.TYPE_MAIN:
                tvPositionValue.setText(getContext().getString(R.string.transport_main_warehouse));
                break;
            case WarehouseBeanType.TYPE_CITY:
                tvPositionValue.setText(getContext().getString(R.string.transport_city_warehouse));
                break;
            case WarehouseBeanType.TYPE_SERVICE:
                tvPositionValue.setText(getContext().getString(R.string.transport_service_warehouse));
                break;
        }
        enableStartButton();
    }

}
