package com.okla.ops.custom.cabinetopt;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.okla.ops.R;

public class SelectCabinetAndAuthorizationView extends ConstraintLayout {

    private String title, hint;
    private boolean isShowLine;
    private TextView tvValue;

    public SelectCabinetAndAuthorizationView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public SelectCabinetAndAuthorizationView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.SelectCabinetAndAuthorizationView);
        isShowLine = typedArray.getBoolean(R.styleable.SelectCabinetAndAuthorizationView_SelectCabinetAndAuthorizationIsShowLine, false);
        title = typedArray.getString(R.styleable.SelectCabinetAndAuthorizationView_SelectCabinetAndAuthorizationTitle);
        hint = typedArray.getString(R.styleable.SelectCabinetAndAuthorizationView_SelectCabinetAndAuthorizationHint);
        typedArray.recycle();
        init(context);
    }

    public SelectCabinetAndAuthorizationView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_select_cabinet_authorization, this);
        TextView tvTitle = view.findViewById(R.id.tvTitle);
        tvTitle.setText(title);
        tvValue = view.findViewById(R.id.tvValue);
        tvValue.setHint(hint);
        view.findViewById(R.id.vLine).setVisibility(isShowLine ? View.VISIBLE : View.GONE);
    }

    public void setValue(String data) {
        tvValue.setText(data);
    }
}
