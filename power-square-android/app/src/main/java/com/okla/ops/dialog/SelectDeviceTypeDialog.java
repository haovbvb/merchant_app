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

import androidx.annotation.NonNull;

import com.base.common.utils.DensityUtil;
import com.base.common.utils.Utils;
import com.okla.ops.beans.DeviceType;
import com.okla.ops.R;
import com.okla.ops.weight.MyGridView;
import com.okla.ops.custom.SlideView;
import com.okla.ops.views.workbench.warehouse.devicetransport.DeviceTypeGridViewAdapter;

import java.util.List;


public class SelectDeviceTypeDialog extends Dialog implements View.OnClickListener {

    private Activity activity;
    private List<DeviceType> mListData;

    public SelectDeviceTypeDialog(Context context, List<DeviceType> list) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.mListData = list;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public SelectDeviceTypeDialog(@NonNull Context context, int themeResId) {
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

        public void onItemClick(int type);
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

    private DeviceTypeGridViewAdapter deviceTypeGridViewAdapter;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_select_type, null);
        view.findViewById(R.id.iv_close).setOnClickListener(this);
        SlideView slideView = view.findViewById(R.id.vSlideView);
        slideView.setVisibility(View.GONE);
        MyGridView gridView = view.findViewById(R.id.gvBottom);
        deviceTypeGridViewAdapter = new DeviceTypeGridViewAdapter(activity, mListData);
        gridView.setAdapter(deviceTypeGridViewAdapter);
        gridView.setHorizontalSpacing(DensityUtil.dp2px(activity, 12));
        gridView.setOnItemClickListener((parent, view1, position, id) -> {
            dismiss();
            DeviceType sDeviceType = mListData.get(position);
            if (mOnClickListener != null && sDeviceType != null)
                mOnClickListener.onItemClick(sDeviceType.getDeviceType());
        });
        return view;
    }

    public void updateData() {
        if (deviceTypeGridViewAdapter != null)
            deviceTypeGridViewAdapter.notifyDataSetChanged();
    }

}
