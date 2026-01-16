package com.base.common.dialog;

import android.app.Dialog;
import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

public class DialogDownloadLoading {
    private TextView tipTextView;
    private Dialog progressDialog = null;
    private final boolean cancelable;
    public DialogDownloadLoading(@NonNull Context context, boolean cancelable) {
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

    public Dialog createLoadingDialog(Context context, String msg) {
        LayoutInflater inflater = LayoutInflater.from(context);
        View v = inflater.inflate(com.base.common.R.layout.dialog_download_loading, null);// 得到加载view
        LinearLayout layout = (LinearLayout) v.findViewById(com.base.common.R.id.dialog_view);// 加载布局
        // main.xml中的ImageView
        // 提示文字
        tipTextView = (TextView) v.findViewById(com.base.common.R.id.tipTextView);
        if (!TextUtils.isEmpty(msg)) {
            tipTextView.setText(msg);// 设置加载信息
        }
        Dialog loadingDialog = new Dialog(context, com.base.common.R.style.loading_dialog_translucent);// 创建自定义样式dialog

        loadingDialog.setCancelable(false);// 不可以用“返回键”取消
        loadingDialog.setContentView(layout, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT));// 设置布局
        loadingDialog.getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE, WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        return loadingDialog;
    }

    public void stepDialog(Dialog loadingDialog) {
    }

    public void setProcess(String process) {
        tipTextView.setText(process);// 设置下载进度
    }

    public void onStart() {
        if (progressDialog != null && !progressDialog.isShowing())
            progressDialog.show();
    }

    public void onFinish() {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
    }
}
