package com.okla.ops.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.custom.SpaceItemDecoration;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.Utils;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.DeviceFixResult;
import com.okla.ops.custom.NoDataView;

import java.util.List;


public class SelectFixResultDialog extends Dialog implements View.OnClickListener {

    private Activity activity;
    private List<DeviceFixResult> mListData;
    private String title;

    public SelectFixResultDialog(Context context, List<DeviceFixResult> list, String title) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.mListData = list;
        this.title = title;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public SelectFixResultDialog(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    public OnClickListener mOnClickListener;

    public void setOnClickListener(OnClickListener onClickListener) {
        this.mOnClickListener = onClickListener;
    }

    @Override
    public void onClick(View v) {
        dismiss();
    }

    public interface OnClickListener {

        public void onItemClick(DeviceFixResult deviceFixResult);
    }

    @Override
    public void show() {
        super.show();
        initWindow();
        Utils.setBackgroundAlpha(activity, 0.5f);
    }

    public void initWindow() {
        Window window = getWindow();
        if (window != null) {
            WindowManager.LayoutParams wl = window.getAttributes();
            wl.height = DensityUtil.dp2px(342f);
            wl.width = ViewGroup.LayoutParams.MATCH_PARENT;
            wl.gravity = Gravity.BOTTOM;
            window.setAttributes(wl);
        }
    }

    @Override
    public void dismiss() {
        super.dismiss();
        Utils.setBackgroundAlpha(activity, 1.0f);
    }

    private NoDataView noDataView;
    private RecyclerView recyclerView;

    private TextView tvCancel;
    private SingleDataBindingNoPUseAdapter<DeviceFixResult> mSingleDataBindingNoPUseAdapter;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_select_list, null);
        view.findViewById(R.id.iv_close).setOnClickListener(this);
        TextView tvTitle = view.findViewById(R.id.tv_title);
        tvTitle.setText(title);
        noDataView = view.findViewById(R.id.noDataView);
        recyclerView = view.findViewById(R.id.recyclerView);
        tvCancel = view.findViewById(R.id.tv_cancel);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerView.addItemDecoration(new SpaceItemDecoration(DensityUtil.dp2px(8.0f), 0));
        mSingleDataBindingNoPUseAdapter = new SingleDataBindingNoPUseAdapter<DeviceFixResult>(R.layout.item_device_fix) {
            @Override
            protected void convert(@NonNull BaseViewHolder helper, DeviceFixResult item) {
                super.convert(helper, item);
                if (helper.getAdapterPosition() == mListData.size() - 1) {
                    helper.setGone(R.id.devideline, false);
                } else {
                    helper.setGone(R.id.devideline, true);
                }
                TextView tvNameItem = helper.getView(R.id.tv_name);
                ImageView ivImg = helper.getView(R.id.ivSelected);
                if (item.isSelect()) {
                    ivImg.setImageResource(R.mipmap.icon_green_checked);
                } else {
                    ivImg.setImageResource(R.mipmap.icon_grey_unchecked);
                }
                tvNameItem.setText(item.getResult());
            }
        };
        recyclerView.setAdapter(mSingleDataBindingNoPUseAdapter);
        mSingleDataBindingNoPUseAdapter.setNewData(mListData);
        mSingleDataBindingNoPUseAdapter.setOnItemClickListener((adapter, v, position) -> {
            DeviceFixResult deviceFixResult = mListData.get(position);
            if (!deviceFixResult.isSelect()) {
                for (int i = 0; i < mListData.size(); i++) {
                    if (mListData.get(i).isSelect()) {
                        mListData.get(i).setSelect(false);
                        mSingleDataBindingNoPUseAdapter.notifyItemChanged(i);
                        break;
                    }
                }
                deviceFixResult.setSelect(true);
                mSingleDataBindingNoPUseAdapter.notifyItemChanged(position);
                recyclerView.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        if (mOnClickListener != null) mOnClickListener.onItemClick(deviceFixResult);
                        dismiss();
                    }
                }, 500);
            }
        });
        if (this.mListData != null && !this.mListData.isEmpty()) {
            recyclerView.setVisibility(View.VISIBLE);
            noDataView.setVisibility(View.GONE);
        } else {
            recyclerView.setVisibility(View.GONE);
            noDataView.setVisibility(View.VISIBLE);
        }
        tvCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
        return view;
    }

    public void updateData(List<DeviceFixResult> list) {
        if (mSingleDataBindingNoPUseAdapter != null)
            mListData= list;
            mSingleDataBindingNoPUseAdapter.setNewData(mListData);
            mSingleDataBindingNoPUseAdapter.notifyDataSetChanged();
    }
}
