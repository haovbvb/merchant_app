package com.okla.ops.weight;

import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.okla.ops.R;
import com.okla.ops.utils.ScanUtils;
import com.okla.ops.utils.ViewClickUtils;

import java.util.concurrent.TimeUnit;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;
import io.reactivex.subjects.PublishSubject;

public class SnSearchInfoView extends ConstraintLayout implements View.OnFocusChangeListener, View.OnClickListener {

    private EditText editSN;
    private TextView tvNoInfo, tvTitle;
    private FrameLayout flSnInfo;
    private final PublishSubject<String> inputSubject = PublishSubject.create();
    private Disposable inputDispose = null;


    public SnSearchInfoView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public SnSearchInfoView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public SnSearchInfoView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_sn_search_info, this);
        view.findViewById(R.id.ivScan).setOnClickListener(this);
        tvTitle = view.findViewById(R.id.tvTitle);
        flSnInfo = view.findViewById(R.id.flSnInfo);
        tvNoInfo = view.findViewById(R.id.tvNoInfo);
        editSN = view.findViewById(R.id.etSN);
        editSN.setOnFocusChangeListener(this);
        ScanUtils.Companion.setFilter(editSN);
        editSN.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                // 将输入变化推送给 PublishSubject
                inputSubject.onNext(s.toString());
                if (TextUtils.isEmpty(s.toString())) {
                    if (null != onClearInputListener) {
                        onClearInputListener.onCleared();
                    }
                }
            }
        });
        editSN.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                editSN.clearFocus();
                if (onEditTextActionListener != null)
                    onEditTextActionListener.onActionDone(editSN.getText().toString());
            }
            return false;
        });
        // 设置订阅，防抖处理
        inputDispose = inputSubject
                .debounce(1500, TimeUnit.MILLISECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .distinctUntilChanged() // 去重
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<String>() {
                    @Override
                    public void accept(String inputText) throws Exception {
                        // 处理输入框数据
                        if (onEditTextChangedListener != null) {
                            onEditTextChangedListener.onTextChange(inputText);
                        }
                    }
                });

    }

    public String getSn() {
        return editSN.getText().toString();
    }

    public void updateData(String sn, View batteryInfoView) {
        flSnInfo.removeAllViews();
        if (!TextUtils.isEmpty(sn)) {
            flSnInfo.addView(batteryInfoView);
            editSN.setText(sn);
            editSN.setSelection(sn.length());
        } else {
            editSN.setText("");
        }
    }

    public void updateData(String sn) {
        editSN.setText(sn);
        if(!TextUtils.isEmpty(sn)){
            editSN.setSelection(sn.length());
        }
    }

    public void removeSnInfo() {
        ViewParent parent = tvNoInfo.getParent();
        if (parent instanceof ViewGroup) {
            ((ViewGroup) parent).removeView(tvNoInfo);
        }
        flSnInfo.removeAllViews();
        flSnInfo.addView(tvNoInfo);
        tvNoInfo.setVisibility(View.VISIBLE);
    }

    public void setTitle(String title) {
        tvTitle.setText(title);
    }

    public void setNoDataTips(String tips) {
        tvNoInfo.setText(tips);
    }

    public void setEditTextAction(int imeOptions) {
        editSN.setImeOptions(imeOptions);
    }

    public void clearEditText() {
        editSN.setText("");
    }

    public void setEditTextHint(String tips) {
        editSN.setHint(tips);
    }

    public void clearEditTextForces() {
        editSN.clearFocus();
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
            String inputContent = ((EditText) v).getText().toString();
            if (onSnSearchInfoListener != null)
                onSnSearchInfoListener.onEditTextNotHasFocus(inputContent);
        } else {
            onSnSearchInfoListener.onEditTextHasFocus();
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.ivScan) {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
            if (onSnSearchInfoListener != null)
                onSnSearchInfoListener.onScanClick();
        }
    }

    public interface OnSnSearchInfoListener {
        void onScanClick();

        void onEditTextNotHasFocus(String inputContent);

        void onEditTextHasFocus();
    }

    private OnSnSearchInfoListener onSnSearchInfoListener;

    public void setOnSnSearchInfoListener(OnSnSearchInfoListener listener) {
        this.onSnSearchInfoListener = listener;
    }

    public interface OnEditTextActionListener {
        void onActionDone(String inputContent);
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

    private OnClearInputListener onClearInputListener;

    public interface OnClearInputListener {
        void onCleared();
    }

    public void setOnClearInputListener(OnClearInputListener onClearListener) {
        this.onClearInputListener = onClearListener;
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (inputDispose != null && !inputDispose.isDisposed()) {
            inputDispose.dispose();
        }
    }
}
