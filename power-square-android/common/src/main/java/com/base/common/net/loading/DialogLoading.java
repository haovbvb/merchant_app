package com.base.common.net.loading;

import android.app.Dialog;
import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.base.common.R;
import com.base.library.base.OnCancelListener;

public class DialogLoading extends SimpleLoading {

    private Dialog progressDialog = null;
    private final boolean cancelable;

    public DialogLoading(@NonNull Context context, boolean cancelable) {
        this.cancelable = cancelable;
        initProgressDialog(context);
        stepDialog(progressDialog);
    }

    public void initProgressDialog(Context context) {
        if (progressDialog == null) {
            progressDialog = createLoadingDialog(context, null);   // new ProgressDialog(context)
            progressDialog.setCancelable(cancelable);
        }
    }

    public static Dialog createLoadingDialog(Context context, String msg) {
        LayoutInflater inflater = LayoutInflater.from(context);
        View v = inflater.inflate(R.layout.loading_dialog_layout, null);// 得到加载view
        LinearLayout layout = (LinearLayout) v.findViewById(R.id.dialog_view);// 加载布局
        // main.xml中的ImageView
        TextView tipTextView = (TextView) v.findViewById(R.id.tipTextView);// 提示文字
        if (!TextUtils.isEmpty(msg)) {
            tipTextView.setText(msg);// 设置加载信息
        }
        Dialog loadingDialog = new Dialog(context, R.style.loading_dialog_translucent);// 创建自定义样式dialog

        loadingDialog.setCancelable(false);// 不可以用“返回键”取消
        loadingDialog.setContentView(layout, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT));// 设置布局
        loadingDialog.getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE, WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        return loadingDialog;
    }

    public void stepDialog(Dialog loadingDialog) {
    }

    public Dialog getDialog() {
        return progressDialog;
    }

    @Override
    public void setOnCancelListener(@Nullable OnCancelListener listener) {
        if (listener != null)
            progressDialog.setOnCancelListener(dialog -> listener.onCancel());
    }

    @Override
    public void onStart() {
        super.onStart();
        if (progressDialog != null && !progressDialog.isShowing())
            progressDialog.show();
    }

    @Override
    public void onFinish() {
        super.onFinish();
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
    }

    @Override
    public void onError(Throwable e) {
        super.onError(e);
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
    }
}