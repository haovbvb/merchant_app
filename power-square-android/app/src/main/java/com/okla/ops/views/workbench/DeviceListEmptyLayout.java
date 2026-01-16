package com.okla.ops.views.workbench;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.okla.ops.R;


/**
 * Author: Joe
 * Date: 2024/1/25 15:32
 * Description:
 */
public class DeviceListEmptyLayout extends ConstraintLayout {

    private ImageView tvIcon;
    private AppCompatTextView textView;

    private ConstraintLayout createLayout;

    public DeviceListEmptyLayout(@NonNull Context context) {
        super(context);
        init(context);
    }

    public DeviceListEmptyLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public DeviceListEmptyLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_transport_send_empty, this);
        tvIcon = view.findViewById(R.id.iv_info);
        textView = view.findViewById(R.id.tv_info);
        createLayout = view.findViewById(R.id.btn_create);
        ConstraintLayout btnCreate = view.findViewById(R.id.btn_create);
        btnCreate.setOnClickListener(v -> {
            if (onCreateListener != null)
                onCreateListener.onCreate();
        });
    }

    public void setIcon(Drawable drawable) {
        tvIcon.setImageDrawable(drawable);
    }

    public void setTextInfo(String textInfo) {
        textView.setText(textInfo);
    }

    public interface OnCreateListener {
        void onCreate();
    }

    private OnCreateListener onCreateListener;

    public void setOnCreateListener(OnCreateListener onCreateListener) {
        this.onCreateListener = onCreateListener;
    }

    public void setBtnCreateGone() {
        createLayout.setVisibility(View.GONE);
    }
}
