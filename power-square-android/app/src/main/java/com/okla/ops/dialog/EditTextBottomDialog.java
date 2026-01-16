package com.okla.ops.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.os.Handler;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.constraintlayout.widget.Group;

import com.base.common.utils.ToastUtils;
import com.okla.ops.R;
import com.okla.ops.utils.ScanUtils;

/**
 * Author: Joe
 * Date: 2024/1/29 11:47
 * Description:
 */
public class EditTextBottomDialog extends Dialog {

    private Activity activity;
    private boolean needShowVinEdt = false;

    public EditTextBottomDialog(Context context, boolean needShowVinEdt) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.needShowVinEdt = needShowVinEdt;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }


    public void setOnClickListener(OnClickListener onClickListener) {
        this.mOnClickListener = onClickListener;
    }

    public OnClickListener mOnClickListener;

    public interface OnClickListener {
        public void onConfirm(String sn, String vin);
    }

    @Override
    public void show() {
        super.show();
        initWindow();
        new Handler().postDelayed(this::showInputKeyword, 500);
        if (editText != null) editText.setText("");
    }

    public void initWindow() {
        Window window = getWindow();
        if (window != null) {
            WindowManager.LayoutParams wl = window.getAttributes();
            wl.height = ViewGroup.LayoutParams.WRAP_CONTENT;
//            wl.height = DensityUtil.dp2px(72);
            wl.width = ViewGroup.LayoutParams.MATCH_PARENT;
            wl.gravity = Gravity.BOTTOM;
            window.setAttributes(wl);
        }
    }

    @Override
    public void dismiss() {
        super.dismiss();
    }

    private String deviceSn;
    private String deviceVin;
    private ImageView ivClear;
    private EditText editText;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.edit_text_bottom_dialog_layout, null);
        view.findViewById(R.id.btn_confirm).setOnClickListener(v -> {
            if (TextUtils.isEmpty(deviceSn)) {
                ToastUtils.showShort(getContext().getString(R.string.scan_input_tip_sn));
                return;
            }
            dismiss();
            if (mOnClickListener != null)
                mOnClickListener.onConfirm(deviceSn, "");
        });
        view.findViewById(R.id.btn_confirm_vehicle).setOnClickListener(v -> {
            if (TextUtils.isEmpty(deviceSn)) {
                ToastUtils.showShort(getContext().getString(R.string.scan_input_tip_sn));
                return;
            }
            if (TextUtils.isEmpty(deviceVin)) {
                ToastUtils.showShort(getContext().getString(R.string.scan_input_tip_vin));
                return;
            }
            dismiss();
            if (mOnClickListener != null)
                mOnClickListener.onConfirm(deviceSn, deviceVin);
        });
        ivClear = view.findViewById(R.id.ivClear);
        ImageView ivClearVin = view.findViewById(R.id.ivClearVin);
        EditText edtVin = view.findViewById(R.id.etEnterVin);
        TextView btnConfirm = view.findViewById(R.id.btn_confirm);
        Group vehicleGroup = view.findViewById(R.id.group_vehicle);
        if (!needShowVinEdt) {
            btnConfirm.setVisibility(View.VISIBLE);
            vehicleGroup.setVisibility(View.GONE);
        } else {
            btnConfirm.setVisibility(View.GONE);
            vehicleGroup.setVisibility(View.VISIBLE);
        }
        ivClear.setOnClickListener(v -> editText.setText(""));
        ivClearVin.setOnClickListener(v -> edtVin.setText(""));
        editText = view.findViewById(R.id.etEnterSn);
        editText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                deviceSn = s.toString();
                if (TextUtils.isEmpty(s)) {
                    ivClear.setVisibility(View.GONE);
                } else {
                    ivClear.setVisibility(View.VISIBLE);
                }
            }
        });
        edtVin.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                deviceVin = s.toString();
                if (TextUtils.isEmpty(s)) {
                    ivClearVin.setVisibility(View.GONE);
                } else {
                    ivClearVin.setVisibility(View.VISIBLE);
                }
            }
        });
        ScanUtils.Companion.setFilter(editText);
        ScanUtils.Companion.setFilter(edtVin);
        return view;
    }

    public void showInputKeyword() {
        editText.setFocusable(true);
        editText.setFocusableInTouchMode(true);
        editText.requestFocus();
        InputMethodManager inputMethodManager = (InputMethodManager) editText.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        inputMethodManager.showSoftInput(editText, 0);
    }
}
