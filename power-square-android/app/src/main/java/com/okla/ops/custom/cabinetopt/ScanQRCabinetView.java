package com.okla.ops.custom.cabinetopt;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;

import com.okla.ops.R;

public class ScanQRCabinetView extends ConstraintLayout {

    private int icon;
    private String title;

    public ScanQRCabinetView(Context context) {
        super(context);
        init(context);
    }

    public ScanQRCabinetView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.ScanQRCabinetView);
        icon = typedArray.getResourceId(R.styleable.ScanQRCabinetView_icon, -1);
        title = typedArray.getString(R.styleable.ScanQRCabinetView_title);
        typedArray.recycle();
        init(context);
    }

    public ScanQRCabinetView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_scan_qr_cabinet, this);
        TextView textView = view.findViewById(R.id.tvTitle);
        textView.setText(title);
        textView.setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(context, icon), null, null, null);
        view.findViewById(R.id.btnInput).setOnClickListener(v -> {
            if (onScanClickListener != null)
                onScanClickListener.onInput(this);
        });
        view.findViewById(R.id.btnScan).setOnClickListener(v -> {
            if (onScanClickListener != null)
                onScanClickListener.onScan(this);
        });
    }

    public interface OnScanClickListener {
        void onInput(View view);

        void onScan(View view);
    }

    private OnScanClickListener onScanClickListener;

    public void setOnScanClickListener(OnScanClickListener onScanClickListener) {
        this.onScanClickListener = onScanClickListener;
    }
}
