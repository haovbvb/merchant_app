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
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.utils.Utils;
import com.base.common.weight.EmptyView;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.City;
import com.okla.ops.beans.Shop;
import com.okla.ops.weight.SimpleSearchView;

import java.util.List;

public class DialogShopList extends Dialog implements View.OnClickListener {

    private Activity activity;
    private List<Shop> mListData;
    private RecyclerView recyclerView;

    public DialogShopList(Context context, List<Shop> list) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.mListData = list;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public DialogShopList(@NonNull Context context, int themeResId) {
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

        public void onItemClick(Shop agent);
    }

    @Override
    public void show() {
        super.show();
        initWindow();
        Utils.setBackgroundAlpha(activity, 0.5f);
    }

    public void initWindow() {
        int heightPixels = activity.getResources().getDisplayMetrics().heightPixels;
        Window window = getWindow();
        WindowManager.LayoutParams wl = window.getAttributes();
        wl.height = (int) (heightPixels * 0.8f);
        wl.width = ViewGroup.LayoutParams.MATCH_PARENT;
        wl.gravity = Gravity.BOTTOM;
        window.setAttributes(wl);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        Utils.setBackgroundAlpha(activity, 1.0f);
    }

    private String keyword;

    public String getKeyword() {
        return keyword;
    }

    private SingleDataBindingNoPUseAdapter<Shop> mSingleDataBindingNoPUseAdapter;
    private AppCompatTextView tvCitySelect;
    private EmptyView emptyView;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_shop_list, null);
        emptyView = view.findViewById(R.id.emptyView);
        SimpleSearchView searchView = view.findViewById(R.id.vSearch);
        searchView.setOnSearchListener(s -> {
            keyword = s;
            if (onShopSearchListener != null) {
                if (mCity != null) {
                    onShopSearchListener.onText(mCity.getCode() == null ? "" : mCity.getCode(), s);
                } else {
                    onShopSearchListener.onText("", s);
                }
            }
            return null;
        });
        searchView.setHint(getContext().getString(R.string.hint_enter_shop_name));
        tvCitySelect = view.findViewById(R.id.tvCitySelect);
        tvCitySelect.setOnClickListener(v -> {
            if (onCitySelectListener != null) {
                onCitySelectListener.onClick();
            }
        });
        AppCompatTextView btnCancel = view.findViewById(R.id.btnCancel);
        btnCancel.setOnClickListener(v -> dismiss());
        recyclerView = view.findViewById(R.id.rvShop);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        mSingleDataBindingNoPUseAdapter = new SingleDataBindingNoPUseAdapter<Shop>(R.layout.item_shop) {
            @Override
            protected void convert(@NonNull BaseViewHolder helper, Shop item) {
                super.convert(helper, item);
                TextView tvShopName = helper.getView(R.id.tvShopName);
                tvShopName.setText(item.getShopName());
                AppCompatImageView ivSelect = helper.getView(R.id.ivSelect);
                if (item.getSelect()) {
                    ivSelect.setVisibility(View.VISIBLE);
                } else {
                    ivSelect.setVisibility(View.INVISIBLE);
                }
            }
        };
        recyclerView.setAdapter(mSingleDataBindingNoPUseAdapter);
        mSingleDataBindingNoPUseAdapter.setNewData(mListData);
        mSingleDataBindingNoPUseAdapter.setOnItemClickListener((adapter, v, position) -> {
            Shop shop = (Shop) adapter.getData().get(position);
            for (Object item : adapter.getData()) {
                if (item instanceof Shop) {
                    ((Shop) item).setSelect(false);

                }
            }
            for (int i = 0; i < adapter.getData().size(); i++) {
                Object object = adapter.getData().get(i);
                if (object instanceof Shop) {
                    ((Shop) object).setSelect(false);
                    mSingleDataBindingNoPUseAdapter.notifyItemChanged(i);
                }
            }
            shop.setSelect(true);
            mSingleDataBindingNoPUseAdapter.notifyItemChanged(position);
            if (mOnClickListener != null)
                mOnClickListener.onItemClick(shop);
            dismiss();
        });
        return view;
    }

    public void updateData(List<Shop> list) {
        mSingleDataBindingNoPUseAdapter.setNewData(list);
        if (list.isEmpty()) {
            emptyView.setVisibility(View.VISIBLE);
        } else {
            emptyView.setVisibility(View.GONE);
        }
    }

    private City mCity;

    public void setCity(City city) {
        mCity = city;
        if (city != null) {
            tvCitySelect.setText(city.getName());
        } else {
            tvCitySelect.setText(getContext().getString(R.string.text_all_city));
        }
    }

    public String cityCode() {
        if (mCity == null) return "";
        else return mCity.getCode();
    }

    public interface OnCitySelectListener {
        void onClick();
    }

    private OnCitySelectListener onCitySelectListener;

    public void setOnCitySelectListener(OnCitySelectListener listener) {
        this.onCitySelectListener = listener;
    }

    public interface OnShopSearchListener {
        void onText(String cityCode, String key);
    }

    private OnShopSearchListener onShopSearchListener;

    public void setOnShopSearchListener(OnShopSearchListener listener) {
        this.onShopSearchListener = listener;
    }

}
