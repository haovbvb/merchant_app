package com.okla.ops.views.workbench.warehouse.devicetransport;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.okla.ops.R;

/**
 * Author: Joe
 * Date: 2024/1/25 15:32
 * Description:
 */
public class DeviceReceiveEmptyLayout extends ConstraintLayout {

    public DeviceReceiveEmptyLayout(@NonNull Context context) {
        super(context);
        init(context);
    }

    public DeviceReceiveEmptyLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public DeviceReceiveEmptyLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        LayoutInflater.from(context).inflate(R.layout.layout_transport_receive_empty, this);
    }

}
