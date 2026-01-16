package com.okla.ops.custom;

import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.okla.ops.R;
import com.okla.ops.utils.ScanUtils;
import com.okla.ops.utils.ViewClickUtils;

public class SearchTitleView extends ConstraintLayout implements View.OnClickListener {

    private ImageView ivClear;
    private EditText etContent;
    private View line;
    private ImageView ivScan;

    private String inputString = "";

    public SearchTitleView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public SearchTitleView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public SearchTitleView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_title_search, this);
        view.findViewById(R.id.topBack).setOnClickListener(this);
        line = view.findViewById(R.id.line);
        ivClear = view.findViewById(R.id.imClear);
        ivClear.setOnClickListener(this);
        ivScan = view.findViewById(R.id.imScan);
        ivScan.setOnClickListener(this);
        etContent = view.findViewById(R.id.etInput);
        ScanUtils.Companion.setFilter(etContent);
        etContent.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!TextUtils.isEmpty(s.toString())) {
                    ivClear.setVisibility(View.VISIBLE);
                } else {
                    ivClear.setVisibility(View.GONE);
                    if (onSearchTitleListener != null)
                        onSearchTitleListener.onContentCLear();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                inputString = s.toString();
                if (onSearchTitleListener != null)
                    onSearchTitleListener.onContentUpdate(inputString);
            }
        });
        etContent.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEARCH ||
                    (event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER)) {
                if (event == null || event.getAction() == KeyEvent.ACTION_UP) {
                    if (onSearchTitleListener != null) {
                        onSearchTitleListener.onSearchContent(inputString);
                    }
                    return true; // 消费事件
                }
                return true; // 消费事件，但不执行操作
            }
            return false; // 未处理的情况，继续传播
        });
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        etContent.addTextChangedListener(null);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.topBack:
                if (ViewClickUtils.isFastClick()) {
                    return;
                }
                if (onSearchTitleListener != null)
                    onSearchTitleListener.onBack();
                break;
            case R.id.imClear:
                if (ViewClickUtils.isFastClick()) {
                    return;
                }
                ivClear.setVisibility(View.GONE);
                etContent.setText("");
                inputString = "";
                break;
            case R.id.imScan:
                if (ViewClickUtils.isFastClick()) {
                    return;
                }
                if (onSearchTitleListener != null)
                    onSearchTitleListener.onScan();
                break;
        }
    }

    public void setEditContent(String content) {
        if (!TextUtils.isEmpty(content)){
            etContent.setText(content);
            etContent.setSelection(content.length());
        }
    }

    public void showInputKeyword() {
        etContent.setFocusable(true);
        etContent.setFocusableInTouchMode(true);
        etContent.requestFocus();
        InputMethodManager inputMethodManager = (InputMethodManager) etContent.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        inputMethodManager.showSoftInput(etContent, 0);
    }

    public void setEditHint(String hint) {
        etContent.setHint(hint);
    }

    public String getEditHint() {
        return etContent.getHint().toString();
    }

    public void hideScan() {
        line.setVisibility(View.GONE);
        ivScan.setVisibility(View.GONE);
    }

    public interface OnSearchTitleListener {
        void onSearchContent(String content);

        void onContentUpdate(String content);

        void onContentCLear();

        void onBack();

        void onScan();
    }

    private OnSearchTitleListener onSearchTitleListener;

    public void setOnSearchTitleListener(OnSearchTitleListener onSearchTitleListener) {
        this.onSearchTitleListener = onSearchTitleListener;
    }
}
