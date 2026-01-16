package com.okla.ops.dialog;

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

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.custom.SpaceItemDecoration;
import com.base.common.image.preview.ImagePreviewDialog;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.Utils;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.beans.VehicleRepair;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.weight.CircleImageView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class RepairRecordDetailDialog extends Dialog implements View.OnClickListener {

    private AppCompatActivity activity;
    private RecyclerView recyclerView;

    public RepairRecordDetailDialog(Context context) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (AppCompatActivity) context;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public RepairRecordDetailDialog(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_close) {
            dismiss();
        }
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
            wl.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            wl.width = ViewGroup.LayoutParams.MATCH_PARENT;
            wl.gravity = Gravity.BOTTOM;
            window.setAttributes(wl);
            window.setWindowAnimations(0);
        }
    }

    @Override
    public void dismiss() {
        super.dismiss();
        Utils.setBackgroundAlpha(activity, 1.0f);
    }

    private AppCompatTextView tvTitle, tvContent, tvOperatorName;
    private CircleImageView ivOperator;
    private final List<String> mImageUrlList = new ArrayList<>();
    private SingleDataBindingNoPUseAdapter imgAdapter;

    public View inflateView() {
        View view = LayoutInflater.from(activity).inflate(R.layout.dialog_repair_record_detail, null);
        view.findViewById(R.id.iv_close).setOnClickListener(this);
        tvTitle = view.findViewById(R.id.tvTitle);
        tvContent = view.findViewById(R.id.tvContent);
        tvOperatorName = view.findViewById(R.id.tvOperatorName);
        ivOperator = view.findViewById(R.id.ivAvator);
        recyclerView = view.findViewById(R.id.rvPhotos);
//        recyclerView.setLayoutManager(new GridLayoutManager(this.getContext(), 3));
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        recyclerView.addItemDecoration(new SpaceItemDecoration(DensityUtil.dp2px(8.0f), 0));
        imgAdapter = new SingleDataBindingNoPUseAdapter<String>(R.layout.item_photo) {
            @Override
            protected void convert(@NonNull BaseViewHolder helper, String item) {
                super.convert(helper, item);
                helper.getView(R.id.ivDeletePhoto).setVisibility(View.GONE);
                ImageView imageView = helper.getView(R.id.ivPhoto);
                Glide.with(activity).load(item).apply(RequestOptions.bitmapTransform(new RoundedCorners(DensityUtil.dp2px(4))).centerCrop()).into(imageView);
            }
        };
        imgAdapter.setOnItemClickListener((adapter, v, position) -> {
            ImagePreviewDialog.getInstance(mImageUrlList, position).showNow(activity.getSupportFragmentManager(), "");
        });
        recyclerView.setAdapter(imgAdapter);
        return view;
    }

    public void updateData(VehicleRepair data) {
        tvTitle.setText(data.getItemName());
        tvContent.setText(data.getRemark());
        Glide.with(activity).load(data.getFixManAvatar())
                .error(R.mipmap.icon_def_avatar)
                .placeholder(R.mipmap.icon_def_avatar)
                .into(ivOperator);
        tvOperatorName.setText(data.getFixMan());
        mImageUrlList.clear();
        recyclerView.setVisibility(View.GONE);
        String imgList = data.getImgList();
        if (!TextUtils.isEmpty(imgList)) {
            String[] split = imgList.split(",");
            mImageUrlList.addAll(Arrays.asList(split));
            recyclerView.setVisibility(View.VISIBLE);
        }
        imgAdapter.setNewData(mImageUrlList);
    }

}
