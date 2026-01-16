package com.okla.ops.custom.station;

import android.content.Context;
import android.content.res.TypedArray;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatEditText;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.okla.ops.R;
import com.okla.ops.weight.SnSearchInfoView;


public class StationInfoView extends ConstraintLayout implements View.OnFocusChangeListener, View.OnClickListener {

    private EditText etBatteryCabinetSN;
    private TextView tvBatteryCabinetInfo, tvBatteryCabinetSNDesc;
    private FrameLayout ctBatteryCabinetInfo;
    private String type;

    public StationInfoView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public StationInfoView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        if (attrs != null) {
            TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.StationInfoView);
            type = typedArray.getString(R.styleable.StationInfoView_type);
            typedArray.recycle();
        }
        init(context);
    }

    public StationInfoView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_station_info, this);
        view.findViewById(R.id.ivScanSN).setOnClickListener(this);
        tvBatteryCabinetSNDesc = view.findViewById(R.id.tvBatteryCabinetSNDesc);
        ctBatteryCabinetInfo = view.findViewById(R.id.ctStationInfo);
        tvBatteryCabinetInfo = view.findViewById(R.id.tvStationNoInfo);
        etBatteryCabinetSN = view.findViewById(R.id.etBatteryCabinetSN);
        etBatteryCabinetSN.setOnFocusChangeListener(this);
        etBatteryCabinetSN.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (onEditTextChangedListener != null)
                    onEditTextChangedListener.onTextChange(s.toString());
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (TextUtils.isEmpty(s.toString())) {
                    if (null != onClearInputListener) {
                        onClearInputListener.onCleared();
                    }
                }

            }
        });
        etBatteryCabinetSN.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                if (onEditTextActionListener != null)
                    onEditTextActionListener.onActionDone();
            }
            return false;
        });
        if ("vehicle".equals(type)) {
            tvBatteryCabinetSNDesc.setText(context.getString(R.string.vehicle_sn));
            etBatteryCabinetSN.setHint(context.getString(R.string.vehicle_sn_hint));
            tvBatteryCabinetInfo.setText(context.getString(R.string.vehicle_info_tips));
        }
    }

    public String getBatteryCabinetSn() {
        return etBatteryCabinetSN.getText().toString();
    }

    public void updateData(String sn, View stationInfoView) {
        ctBatteryCabinetInfo.removeAllViews();
        if (!TextUtils.isEmpty(sn)) {
            etBatteryCabinetSN.setText(sn);
            tvBatteryCabinetInfo.setVisibility(View.GONE);
            ctBatteryCabinetInfo.addView(stationInfoView);
        } else {
            etBatteryCabinetSN.setText("");
            tvBatteryCabinetInfo.setVisibility(View.VISIBLE);
        }
    }

    public void updateData(String sn) {
        ctBatteryCabinetInfo.removeAllViews();
        etBatteryCabinetSN.setText(sn);
        ctBatteryCabinetInfo.addView(tvBatteryCabinetInfo);
        tvBatteryCabinetInfo.setVisibility(View.VISIBLE);
    }

    public void removeAllViews(){
        ctBatteryCabinetInfo.removeAllViews();
    }

    public void setTitle(String title) {
        tvBatteryCabinetSNDesc.setText(title);
    }

    public void setNoDataTips(String tips) {
        tvBatteryCabinetInfo.setText(tips);
    }

    public void setEditTextAction(int imeOptions) {
        etBatteryCabinetSN.setImeOptions(imeOptions);
    }

    public void setEditTextHint(String tips) {
        etBatteryCabinetSN.setHint(tips);
    }

    public void clearEditTextForces() {
        etBatteryCabinetSN.clearFocus();
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
            String inputContent = ((EditText) v).getText().toString();
            if (onStationInfoListener != null)
                onStationInfoListener.onEditTextNotHasFocus(inputContent);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.ivScanSN:
                if (onStationInfoListener != null)
                    onStationInfoListener.onScanClick();
                break;
        }
    }

    public interface OnStationInfoListener {
        void onScanClick();

        void onEditTextNotHasFocus(String inputContent);
    }

    private OnStationInfoListener onStationInfoListener;

    public void setOnStationInfoListener(OnStationInfoListener onStationInfoListener) {
        this.onStationInfoListener = onStationInfoListener;
    }

    public interface OnEditTextActionListener {
        void onActionDone();
    }

    private OnEditTextActionListener onEditTextActionListener;

    public void setOnEditTextActionListener(OnEditTextActionListener onEditTextActionListener) {
        this.onEditTextActionListener = onEditTextActionListener;
    }

    public interface OnEditTextChangedListener {
        void onTextChange(String data);
    }

    private OnEditTextChangedListener onEditTextChangedListener;

    public void setOnEditTextChangedListener(OnEditTextChangedListener onEditTextChangedListener) {
        this.onEditTextChangedListener = onEditTextChangedListener;
    }

    private SnSearchInfoView.OnClearInputListener onClearInputListener;

    public interface OnClearInputListener {
        void onCleared();
    }

    public void setOnClearInputListener(SnSearchInfoView.OnClearInputListener onClearListener) {
        this.onClearInputListener = onClearListener;
    }
}

