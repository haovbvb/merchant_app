//package com.okla.ops.dialog;
//
//import android.app.Activity;
//import android.app.Dialog;
//import android.content.Context;
//import android.content.DialogInterface;
//import android.graphics.Color;
//import android.graphics.Point;
//import android.os.Build;
//import android.text.TextUtils;
//import android.util.Log;
//import android.view.Display;
//import android.view.Gravity;
//import android.view.LayoutInflater;
//import android.view.View;
//import android.view.ViewGroup;
//import android.view.Window;
//import android.view.WindowManager;
//import android.widget.ImageView;
//import android.widget.TextView;
//
//import androidx.annotation.NonNull;
//import androidx.appcompat.widget.AppCompatTextView;
//import androidx.recyclerview.widget.LinearLayoutManager;
//import androidx.recyclerview.widget.RecyclerView;
//
//import com.base.common.custom.SpaceItemDecoration;
//import com.base.common.utils.DensityUtil;
//import com.base.common.utils.Utils;
//import com.chad.library.adapter.base.BaseViewHolder;
//import com.okla.ops.R;
//import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
//import com.okla.ops.beans.WarehouseBean;
//import com.okla.ops.beans.WarehouseBeanType;
//import com.okla.ops.custom.NoDataView;
//
//import java.util.List;
//
///**
// * Author: Joe
// * Date: 2024/1/25 16:39
// * Description:
// */
//public class SelectWarehouseDialog extends Dialog implements View.OnClickListener {
//
//    private Activity activity;
//    private List<WarehouseBean> mListData;
//
//    private String title;
//    private String mSelectNo;
//
//    public SelectWarehouseDialog(Context context, List<WarehouseBean> list, String title) {
//        super(context, com.base.common.R.style.ShareBottomDialogs);
//        this.activity = (Activity) context;
//        this.mListData = list;
//        this.title = title;
//        this.setCancelable(true);
//        this.setCanceledOnTouchOutside(true);
//        this.setContentView(inflateView());
//        this.setOnShowListener(dialog -> {
//            updateList(this.mListData);
//            updateData();
//        });
//    }
//
//    public OnClickListener mOnClickListener;
//
//    public void setOnClickListener(OnClickListener onClickListener) {
//        this.mOnClickListener = onClickListener;
//    }
//
//    @Override
//    public void onClick(View v) {
//        dismiss();
//    }
//
//    public interface OnClickListener {
//
//        public void onItemClick(WarehouseBean warehouseBean);
//    }
//
//    @Override
//    public void show() {
//        super.show();
//        initWindow();
//        Utils.setBackgroundAlpha(activity, 0.5f);
//    }
//
//    public void initWindow() {
//        Window window = getWindow();
//        if (window != null) {
//            WindowManager.LayoutParams wl = window.getAttributes();
//            wl.height = ViewGroup.LayoutParams.WRAP_CONTENT;
////            wl.height = (int) (DensityUtil.getScreenHeight(getContext()) * 0.7f);
//            wl.width = ViewGroup.LayoutParams.MATCH_PARENT;
//            wl.gravity = Gravity.BOTTOM;
//            window.setAttributes(wl);
//        }
//    }
//
//    @Override
//    public void dismiss() {
//        super.dismiss();
//        Utils.setBackgroundAlpha(activity, 1.0f);
//    }
//
//    public void clear() {
//        mSelectNo = "";
//    }
//
//    public void updateList(List<WarehouseBean> list) {
//        if (TextUtils.isEmpty(mSelectNo)) {
//            this.mListData = list;
//            mSingleDataBindingNoPUseAdapter.setNewData(mListData);
//            if (this.mListData != null && !this.mListData.isEmpty()) {
//                recyclerView.setVisibility(View.VISIBLE);
//                noDataView.setVisibility(View.GONE);
//            } else {
//                recyclerView.setVisibility(View.GONE);
//                noDataView.setVisibility(View.VISIBLE);
//            }
//        } else {
//            recyclerView.setVisibility(View.GONE);
//            noDataView.setVisibility(View.VISIBLE);
//        }
//    }
//
//    private NoDataView noDataView;
//    private RecyclerView recyclerView;
//
//    private SingleDataBindingNoPUseAdapter<WarehouseBean> mSingleDataBindingNoPUseAdapter;
//
//    public View inflateView() {
//        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_select_list, null);
//        view.findViewById(R.id.iv_close).setOnClickListener(this);
//        TextView tvTitle = view.findViewById(R.id.tv_title);
//        tvTitle.setText(title);
//        noDataView = view.findViewById(R.id.noDataView);
//        noDataView.setVisibility(View.VISIBLE);
//        recyclerView = view.findViewById(R.id.recyclerView);
//        recyclerView.setVisibility(View.GONE);
//        ViewGroup.LayoutParams layoutParams = recyclerView.getLayoutParams();
//        if (getWindow() != null) {
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//                layoutParams.height = getWindow().getWindowManager().getCurrentWindowMetrics().getBounds().height() / 2;
//            } else {
//                Display defaultDisplay = getWindow().getWindowManager().getDefaultDisplay();
//                Point p = new Point();
//                defaultDisplay.getSize(p);
//                layoutParams.height = p.y / 2;
//            }
//        }
//        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
//        recyclerView.addItemDecoration(new SpaceItemDecoration(DensityUtil.dp2px(8.0f), 0));
//        mSingleDataBindingNoPUseAdapter = new SingleDataBindingNoPUseAdapter<>(R.layout.item_device_transport_warehouse) {
//            @Override
//            protected void convert(@NonNull BaseViewHolder helper, WarehouseBean item) {
//                super.convert(helper, item);
//                helper.setText(R.id.tv_name, item.getOutWarehouseName());
//                AppCompatTextView tvCity = helper.getView(R.id.tv_address);
//                String cityName = item.getCityName();
//                if (TextUtils.isEmpty(cityName)) {
//                    tvCity.setVisibility(View.GONE);
//                } else {
//                    tvCity.setText(item.getCityName());
//                    tvCity.setVisibility(View.VISIBLE);
//                }
//                AppCompatTextView tvType = helper.getView(R.id.tv_type);
//                Integer warehouseType = item.getWarehouseType();
//                if (warehouseType == null) {
//                    tvType.setVisibility(View.GONE);
//                } else {
//                    tvType.setVisibility(View.VISIBLE);
//                    switch (item.getWarehouseType()) {
//                        case WarehouseBeanType.TYPE_MAIN:
//                            tvType.setTextColor(Color.parseColor("#FFED942F"));
//                            tvType.setText(mContext.getString(R.string.transport_main_warehouse));
//                            break;
//                        case WarehouseBeanType.TYPE_CITY:
//                            tvType.setTextColor(Color.parseColor("#FF1184F7"));
//                            tvType.setText(mContext.getString(R.string.transport_city_warehouse));
//                            break;
//                        case WarehouseBeanType.TYPE_SERVICE:
//                            tvType.setTextColor(Color.parseColor("#FF0ABF83"));
//                            tvType.setText(mContext.getString(R.string.transport_service_warehouse));
//                            break;
//                    }
//                }
//                ImageView ivImg = helper.getView(R.id.ivSelected);
//                String outWarehouseNo = item.getOutWarehouseNo();
//                if (TextUtils.equals(mSelectNo, outWarehouseNo)) {
//                    ivImg.setVisibility(View.VISIBLE);
//                } else {
//                    ivImg.setVisibility(View.GONE);
//                }
//            }
//        };
//        recyclerView.setAdapter(mSingleDataBindingNoPUseAdapter);
//        mSingleDataBindingNoPUseAdapter.setNewData(mListData);
//        mSingleDataBindingNoPUseAdapter.setOnItemClickListener((adapter, v, position) -> {
//            dismiss();
//            WarehouseBean warehouseBean = mListData.get(position);
//            String outWarehouseNo = warehouseBean.getOutWarehouseNo();
//            if (!TextUtils.equals(mSelectNo, outWarehouseNo)) {
//                mSelectNo = outWarehouseNo;
//                mSingleDataBindingNoPUseAdapter.notifyDataSetChanged();
//                if (mOnClickListener != null)
//                    mOnClickListener.onItemClick(warehouseBean);
//            }
//        });
//        return view;
//    }
//
//    public void updateData() {
//        if (mSingleDataBindingNoPUseAdapter != null)
//            mSingleDataBindingNoPUseAdapter.notifyDataSetChanged();
//    }
//
//}
