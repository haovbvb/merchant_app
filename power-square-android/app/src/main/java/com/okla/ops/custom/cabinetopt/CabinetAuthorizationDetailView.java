package com.okla.ops.custom.cabinetopt;

import android.content.Context;
import android.text.SpannableString;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.okla.ops.R;

public class CabinetAuthorizationDetailView extends LinearLayout {

    private TextView tvTitle;
    private TextView tvValue;

    public CabinetAuthorizationDetailView(Context context) {
        super(context);
        init(context);
    }

    public CabinetAuthorizationDetailView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public CabinetAuthorizationDetailView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_cabinet_authorization_detail, this);
        tvTitle = view.findViewById(R.id.tvTitle);
        tvValue = view.findViewById(R.id.tvValue);
    }

    public void setTitle(String title) {
        tvTitle.setText(title);
    }

    public void setValue(String value) {
        tvValue.setText(value);
    }

    public void setValue(SpannableString spannableString) {
        tvValue.setText(spannableString);
    }

    public void setValue(String value, int color) {
        tvValue.setText(value);
        tvValue.setTextColor(color);
    }

}
