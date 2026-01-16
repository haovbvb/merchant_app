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

import com.base.common.utils.ToastUtils;
import com.base.common.utils.Utils;
import com.okla.ops.R;
import com.okla.ops.beans.DeviceTypeObject;
import com.okla.ops.utils.ViewClickUtils;
import com.okla.ops.weight.LayoutTextInputView;

public class DialogBatteryInput extends Dialog implements View.OnClickListener {

    private Activity activity;
    private String title;
    private int index;

    private int deviceType;

    public DialogBatteryInput(Context context, String title, int deviceType) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.title = title;
        this.deviceType = deviceType;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public DialogBatteryInput(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    @Override
    public void onClick(View v) {
        dismiss();
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
        Utils.setBackgroundAlpha(activity, 1.0f);
    }

    private LayoutTextInputView batteryInputView;
    private LayoutTextInputView immiInputView;
    private LayoutTextInputView iccidInputView;

    private LayoutTextInputView locDevIdInputView;
    private AppCompatTextView btnConfirm;

    private AppCompatTextView tvTitle;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_battery_input, null);
        tvTitle = view.findViewById(R.id.tvTitle);
        tvTitle.setText(title);
        batteryInputView = view.findViewById(R.id.batteryInputTextView);
        if (deviceType == DeviceTypeObject.TYPE_BATTERY) {
            batteryInputView.setTitle(getContext().getString(R.string.text_battery_sn), true);
            batteryInputView.setHintContent(getContext().getString(R.string.hint_enter_battery_sn));
            batteryInputView.setOnInputListener(content -> btnConfirm.setEnabled(!TextUtils.isEmpty(content)));
        } else if(deviceType == DeviceTypeObject.TYPE_VEHICLE){
            batteryInputView.setTitle(getContext().getString(R.string.text_vehicle_sn), true);
            batteryInputView.setHintContent(getContext().getString(R.string.hint_enter_vehicle_sn));
            batteryInputView.setOnInputListener(content -> btnConfirm.setEnabled(!TextUtils.isEmpty(content) && !TextUtils.isEmpty(immiInputView.getContent())));
        } else if(deviceType== DeviceTypeObject.TYPE_STATION){
            batteryInputView.setTitle(getContext().getString(R.string.text_station_sn), true);
            batteryInputView.setHintContent(getContext().getString(R.string.hint_enter_station_sn));
            batteryInputView.setOnInputListener(content -> btnConfirm.setEnabled(!TextUtils.isEmpty(content)));
        }
        batteryInputView.setFilter();
        batteryInputView.setOnScanListener(() -> {
            if (onInputListener != null) onInputListener.onScan(2);
        });
        // IMEI
        immiInputView = view.findViewById(R.id.immiInputTextView);
        if (deviceType == DeviceTypeObject.TYPE_VEHICLE) {
            immiInputView.setVisibility(View.VISIBLE);
            immiInputView.setTitle(getContext().getString(R.string.text_vin), true);
            immiInputView.setOnInputListener(content -> btnConfirm.setEnabled(!TextUtils.isEmpty(content) && !TextUtils.isEmpty(batteryInputView.getContent())));
            immiInputView.setHintContent(getContext().getString(R.string.hint_enter_vehicle_vin));
        } else if(deviceType== DeviceTypeObject.TYPE_BATTERY){
            immiInputView.setVisibility(View.VISIBLE);
            immiInputView.setTitle(getContext().getString(R.string.text_imei), false);
            immiInputView.setHintContent(getContext().getString(R.string.hint_enter_imei_code));
        }else {
            immiInputView.setVisibility(View.GONE);
        }
        immiInputView.setFilter();
        immiInputView.setOnScanListener(() -> {
            if (onInputListener != null) onInputListener.onScan(3);
        });

        //ICCID
        iccidInputView = view.findViewById(R.id.iccidInputTextView);
        if(deviceType==DeviceTypeObject.TYPE_BATTERY){
            iccidInputView.setVisibility(View.VISIBLE);
            iccidInputView.setTitle(getContext().getString(R.string.text_iccid));
            iccidInputView.setHintContent(getContext().getString(R.string.hint_enter_iccid_code));
        }else if(deviceType==DeviceTypeObject.TYPE_VEHICLE) {
            iccidInputView.setTitle(getContext().getString(R.string.text_vcu));
            iccidInputView.setHintContent(getContext().getString(R.string.hint_enter_vcu));
        }else {
            iccidInputView.setVisibility(View.GONE);
        }
        iccidInputView.setFilter();
        iccidInputView.setOnScanListener(() -> {
            if (onInputListener != null) onInputListener.onScan(4);
        });

        //lockDevId
        locDevIdInputView = view.findViewById(R.id.locDevId);
        locDevIdInputView.setTitle(getContext().getString(R.string.text_lockdevid));
        locDevIdInputView.setHintContent(getContext().getString(R.string.hint_enter_lockdevid));
        locDevIdInputView.setOnScanListener(() -> {
            if (onInputListener != null) onInputListener.onScan(5);
        });
        if(deviceType==DeviceTypeObject.TYPE_STATION) {
            locDevIdInputView.setVisibility(View.VISIBLE);
        }else {
            locDevIdInputView.setVisibility(View.GONE);
        }
        btnConfirm = view.findViewById(R.id.btnConfirm);
        btnConfirm.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
            String batterySn = batteryInputView.getContent();
            if (TextUtils.isEmpty(batterySn)) {
                if (deviceType == DeviceTypeObject.TYPE_VEHICLE) {
                    ToastUtils.showShort(getContext().getString(R.string.hint_enter_vehicle_sn));
                } else {
                    ToastUtils.showShort(getContext().getString(R.string.hint_enter_battery_sn));
                }
                return;
            }
            if (deviceType == DeviceTypeObject.TYPE_VEHICLE) {
                if (immiInputView.getVisibility() == View.VISIBLE && TextUtils.isEmpty(immiInputView.getContent())) {
                    ToastUtils.showShort(getContext().getString(R.string.hint_enter_vehicle_vin));
                    return;
                }
            }
            if (onInputListener != null) {
                onInputListener.onConfirm(index, batteryInputView.getContent(), immiInputView.getContent(), iccidInputView.getContent(),locDevIdInputView.getContent());
            }
            dismiss();
        });
        return view;
    }

    public void updateTitle(String title) {
        this.title = title;
        if (null != tvTitle) {
            tvTitle.setText(title);
        }
    }

    public void setIndex(int index) {
        this.index = index;
    }

    public void updateBatterySn(String sn) {
        batteryInputView.setContent(sn);
    }

    public void updateIMEI(String imei) {
        immiInputView.setContent(imei);
    }
    public void updateLockDevId(String locDevId){
        locDevIdInputView.setContent(locDevId);
    }

    public void updateICCID(String iccid) {
        iccidInputView.setContent(iccid);
    }

    public void hideIMEI() {
        immiInputView.setVisibility(View.GONE);
    }

    public void hideICCID() {
        iccidInputView.setVisibility(View.GONE);
    }

    public interface OnInputListener {
        void onConfirm(int index, String batterSn, String imei, String iccid,String locDevId);

        void onScan(int scanType);
    }

    private OnInputListener onInputListener;

    public void setOnInputListener(OnInputListener listener) {
        onInputListener = listener;
    }

}
