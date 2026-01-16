package com.okla.ops.views.workbench.warehouse.devicetransport;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.okla.ops.R;


public class DeviceTransportSnLayout extends ConstraintLayout {

    private AppCompatTextView tvSn;

    public DeviceTransportSnLayout(@NonNull Context context) {
        super(context);
        init(context);
    }

    public DeviceTransportSnLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public DeviceTransportSnLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_transport_device_sn, this);
        tvSn = view.findViewById(R.id.tvSn);
        AppCompatImageView ivDelete = view.findViewById(R.id.ivDelete);
        ivDelete.setOnClickListener(v -> {
            if (onDeleteListener != null)
                onDeleteListener.onDelete(this);
        });
    }

    public void setTvSn(String sn) {
        tvSn.setText(sn);
    }

    public String getTvSn() {
        return tvSn.getText().toString();
    }

    public interface OnDeleteListener {
        void onDelete(DeviceTransportSnLayout deviceTransportSnLayout);
    }

    private OnDeleteListener onDeleteListener;

    public void setOnDeleteListener(OnDeleteListener onDeleteListener) {
        this.onDeleteListener = onDeleteListener;
    }
}
