package com.base.common.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.base.common.R;
import com.base.common.utils.Utils;

import java.util.List;

public class BaseBottomDialog extends Dialog implements View.OnClickListener {


    private Activity activity;
    private List<String> mListData;

    public BaseBottomDialog(Context context, List<String> list) {
        super(context, R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.mListData = list;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public BaseBottomDialog(Context context, int themeResId) {
        super(context, themeResId);
    }


    public void setOnClickListener(OnClickListener onClickListener) {
        this.mOnClickListener = onClickListener;
    }

    public OnClickListener mOnClickListener;


    @Override
    public void onClick(View v) {

        int id = v.getId();
        if (mOnClickListener != null) {
            mOnClickListener.onItemClick(id);
        }

        dismiss();
    }


    public interface OnClickListener {

        public void onCancelListener();

        public void onItemClick(int id);
    }


    @Override
    public void show() {
        super.show();
        initWindow();
        Utils.setBackgroundAlpha(activity, 0.5f);

    }

    public void initWindow() {
        Window window = getWindow();
        WindowManager.LayoutParams wl = window.getAttributes();
        wl.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        wl.width = ViewGroup.LayoutParams.MATCH_PARENT;
        wl.gravity = Gravity.BOTTOM;
        window.setAttributes(wl);
    }


    @Override
    public void dismiss() {
        super.dismiss();
        Utils.setBackgroundAlpha(activity, 1.0f);
    }

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.base_bottom_dialog_layout, null);
        view.findViewById(R.id.tv_cancel).setOnClickListener(this);
        TextView tvAction1 = view.findViewById(R.id.tv_action_1);

        TextView tvAction2 = view.findViewById(R.id.tv_action_2);

        TextView tvAction3 = view.findViewById(R.id.tv_action_3);

        LinearLayout llAction1 = view.findViewById(R.id.ll_action_1);
        LinearLayout llAction2 = view.findViewById(R.id.ll_action_2);
        LinearLayout llAction3 = view.findViewById(R.id.ll_action_3);
        llAction1.setOnClickListener(this);
        llAction2.setOnClickListener(this);
        llAction3.setOnClickListener(this);

        if (mListData.size() == 3) {
            llAction1.setVisibility(View.VISIBLE);
            llAction2.setVisibility(View.VISIBLE);
            llAction3.setVisibility(View.VISIBLE);
            tvAction1.setText(mListData.get(0));
            tvAction2.setText(mListData.get(1));
            tvAction3.setText(mListData.get(2));
        } else if (mListData.size() == 2) {
            llAction1.setVisibility(View.VISIBLE);
            llAction2.setVisibility(View.VISIBLE);
            llAction3.setVisibility(View.GONE);
            tvAction1.setText(mListData.get(0));
            tvAction2.setText(mListData.get(1));
            view.findViewById(R.id.tvLine2).setVisibility(View.GONE);
        } else if (mListData.size() == 1) {
            llAction1.setVisibility(View.VISIBLE);
            llAction2.setVisibility(View.GONE);
            llAction3.setVisibility(View.GONE);
            view.findViewById(R.id.tvLine2).setVisibility(View.GONE);
            tvAction1.setText(mListData.get(0));
        }


        return view;
    }


}
