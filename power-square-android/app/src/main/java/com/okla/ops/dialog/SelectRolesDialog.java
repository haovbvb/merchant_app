package com.okla.ops.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.custom.SpaceItemDecoration;
import com.base.common.db.entity.RoleEntity;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.Utils;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.custom.SlideView;

import java.util.List;


public class SelectRolesDialog extends Dialog implements View.OnClickListener {

    private Activity activity;
    private List<RoleEntity> mListData;
    private RecyclerView recyclerView;
    private SlideView slideView;

    public SelectRolesDialog(Context context, List<RoleEntity> list) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.mListData = list;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public SelectRolesDialog(@NonNull Context context, int themeResId) {
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

        public void onItemClick(String str);
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

    public void destroy() {
        if (recyclerView != null)
            recyclerView.removeOnScrollListener(scrollListener);
    }

    private SingleDataBindingNoPUseAdapter<RoleEntity> mSingleDataBindingNoPUseAdapter;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_select_type, null);
        view.findViewById(R.id.iv_close).setOnClickListener(this);
        slideView = view.findViewById(R.id.vSlideView);
        if (mListData.size() < 4) slideView.setVisibility(View.GONE);
        TextView tvTitle = view.findViewById(R.id.tv_title);
        tvTitle.setText(getContext().getString(R.string.workbench_choose_role));
        recyclerView = view.findViewById(R.id.recyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        recyclerView.addItemDecoration(new SpaceItemDecoration(DensityUtil.dp2px(6.0f), 0));
        mSingleDataBindingNoPUseAdapter = new SingleDataBindingNoPUseAdapter<RoleEntity>(R.layout.item_roles) {
            @Override
            protected void convert(BaseViewHolder helper, RoleEntity item) {
                super.convert(helper, item);
                TextView tvNameItem = helper.getView(R.id.tv_name);
                ImageView ivImg = helper.getView(R.id.iv_icon);
                String role = item.getRole();
                if (TextUtils.equals(role, "app_role_op")) {
                    tvNameItem.setText(getContext().getString(R.string.workbench_role_om));
                    ivImg.setImageDrawable(ContextCompat.getDrawable(getContext(), R.mipmap.icon_onm));
                } else if (TextUtils.equals(role, "app_role_store_man")) {
                    tvNameItem.setText(getContext().getString(R.string.workbench_role_warehouse));
                    ivImg.setImageDrawable(ContextCompat.getDrawable(getContext(), R.mipmap.icon_warehouse));
                } else if (TextUtils.equals(role, "app_role_sales")) {
                    tvNameItem.setText(getContext().getString(R.string.workbench_role_Sales));
                    ivImg.setImageDrawable(ContextCompat.getDrawable(getContext(), R.mipmap.img_sales_summary));
                }
            }
        };
        recyclerView.setAdapter(mSingleDataBindingNoPUseAdapter);
        mSingleDataBindingNoPUseAdapter.setNewData(mListData);
        mSingleDataBindingNoPUseAdapter.setOnItemClickListener((adapter, v, position) -> {
            RoleEntity role = mListData.get(position);
            if (!role.getSelected()) {
                for (RoleEntity roleEntity : mListData) {
                    roleEntity.setSelected(false);
                }
                role.setSelected(true);
                if (mOnClickListener != null)
                    mOnClickListener.onItemClick(mListData.get(position).getRole());
            }
            dismiss();
        });
        recyclerView.addOnScrollListener(scrollListener);
        return view;
    }

    public void updateData() {
        if (mSingleDataBindingNoPUseAdapter != null)
            mSingleDataBindingNoPUseAdapter.notifyDataSetChanged();
    }

    private final RecyclerView.OnScrollListener scrollListener = new RecyclerView.OnScrollListener() {

        @Override
        public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
            super.onScrollStateChanged(recyclerView, newState);
        }

        @Override
        public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
            super.onScrolled(recyclerView, dx, dy);
            int extent = recyclerView.computeHorizontalScrollExtent();
            int range = recyclerView.computeHorizontalScrollRange();
            int offset = recyclerView.computeHorizontalScrollOffset();
            float percent = (offset / (float) (range - extent));
            if (slideView != null)
                slideView.move(percent);
        }
    };

}
