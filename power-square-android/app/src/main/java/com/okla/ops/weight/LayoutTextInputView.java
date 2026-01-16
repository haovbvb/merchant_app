package com.okla.ops.weight;

import android.content.Context;
import android.graphics.Color;
import android.text.Editable;
import android.text.InputFilter;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.ForegroundColorSpan;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatEditText;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.okla.ops.R;
import com.okla.ops.utils.ViewClickUtils;

public class LayoutTextInputView extends ConstraintLayout {
    public LayoutTextInputView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public LayoutTextInputView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public LayoutTextInputView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private AppCompatTextView tvTitle;
    private AppCompatEditText etContent;
    private ImageView ivClear;

    private ImageView ivScan;

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_text_input, this);
        tvTitle = view.findViewById(R.id.tvTitle);
        etContent = view.findViewById(R.id.etContent);
        ivClear = view.findViewById(R.id.imClear);
        ivClear.setOnClickListener(v -> {
            etContent.setText("");
        });
        ivScan = view.findViewById(R.id.imScan);
        ivScan.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
            if (onScanListener != null) onScanListener.onScan();
        });
        etContent.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (TextUtils.isEmpty(s.toString())) {
                    ivClear.setVisibility(View.GONE);
                } else {
                    ivClear.setVisibility(View.VISIBLE);
                }
                if (onInputListener != null) onInputListener.onTextChange(s.toString());
            }
        });
    }

    public void setTitle(String title) {
        setTitle(title, false);
    }

    public void setTitle(String title, boolean hasStart) {
        if (hasStart) {
            String newTitle = title + "*";
            SpannableString spannableString = new SpannableString(newTitle);
            int color = Color.parseColor("#FF0000");
            spannableString.setSpan(
                    new ForegroundColorSpan(color),
                    spannableString.length() - 1,
                    spannableString.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            );
            tvTitle.setText(spannableString);
        } else {
            tvTitle.setText(title);
        }
    }

    public void setContent(String content) {
        if (etContent != null) {
            // 限制最大长度50
            if (!TextUtils.isEmpty(content) && content.length() > 50) {
                content = content.substring(0, 50);
            }
            etContent.setText(content);
            if (!TextUtils.isEmpty(content)) {
                // 光标移到文本末尾
                etContent.setSelection(content.length());
            }
        }
    }

    public String getContent() {
        Editable text = etContent.getText();
        if (text == null) return "";
        return text.toString();
    }

    public void setHintContent(String hintContent) {
        etContent.setHint(hintContent);
    }

    public void setFilter() {
        InputFilter filter = (source, start, end, dest, dstart, dend) -> {
            // 禁止输入中文字符
            if (source != null && source.toString().matches(".*[\\u4e00-\\u9fa5]+.*")) {
                return "";
            } else {
                return source;
            }
        };
        InputFilter filter1 = new InputFilter.LengthFilter(50);
        etContent.setFilters(new InputFilter[]{filter, filter1});
    }

    public interface OnInputListener {

        void onTextChange(String content);
    }

    private OnInputListener onInputListener;

    public void setOnInputListener(OnInputListener onInputListener) {
        this.onInputListener = onInputListener;
    }

    public interface OnScanListener {
        void onScan();
    }

    private OnScanListener onScanListener;

    public void setOnScanListener(OnScanListener onScanListener) {
        this.onScanListener = onScanListener;
    }

    public void hideScan(){
        ivScan.setVisibility(View.GONE);
    }
}
