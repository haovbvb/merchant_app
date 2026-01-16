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
import com.base.library.utils.DensityUtils;
import com.bumptech.glide.Glide;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.Agent;
import com.okla.ops.beans.City;
import com.okla.ops.weight.CircleImageView;
import com.okla.ops.weight.SimpleSearchView;

import java.util.List;

public class DialogAgentList extends Dialog implements View.OnClickListener {

    private Activity activity;
    private List<Agent> mListData;
    private RecyclerView recyclerView;

    public DialogAgentList(Context context, List<Agent> list) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.mListData = list;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(true);
        this.setContentView(inflateView());
    }

    public DialogAgentList(@NonNull Context context, int themeResId) {
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

        public void onItemClick(Agent agent);
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

    private SingleDataBindingNoPUseAdapter<Agent> mSingleDataBindingNoPUseAdapter;
    private AppCompatTextView tvCitySelect;
    private EmptyView emptyView;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_agent_list, null);
        emptyView = view.findViewById(R.id.emptyView);
        SimpleSearchView searchView = view.findViewById(R.id.vSearch);
        searchView.setOnSearchListener(s -> {
            keyword = s;
            if (onAgentSearchListener != null) {
                if (mCity != null) {
                    onAgentSearchListener.onText(mCity.getCode() == null ? "" : mCity.getCode(), s);
                } else {
                    onAgentSearchListener.onText("", s);
                }
            }
            return null;
        });
        searchView.setHint(getContext().getString(R.string.hint_enter_agent_name));
        tvCitySelect = view.findViewById(R.id.tvCitySelect);
        tvCitySelect.setOnClickListener(v -> {
            if (onCitySelectListener != null) {
                onCitySelectListener.onClick();
            }
        });
        AppCompatTextView btnCancel = view.findViewById(R.id.btnCancel);
        btnCancel.setOnClickListener(v -> dismiss());
        recyclerView = view.findViewById(R.id.rvAgent);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        mSingleDataBindingNoPUseAdapter = new SingleDataBindingNoPUseAdapter<Agent>(R.layout.item_agent) {
            @Override
            protected void convert(@NonNull BaseViewHolder helper, Agent item) {
                super.convert(helper, item);
                TextView tvAgentName = helper.getView(R.id.tvAgentName);
                tvAgentName.setText(item.getAgentName());
                AppCompatImageView ivSelect = helper.getView(R.id.ivSelect);
                if (item.getSelect()) {
                    ivSelect.setVisibility(View.VISIBLE);
                } else {
                    ivSelect.setVisibility(View.INVISIBLE);
                }
                CircleImageView headView = helper.getView(R.id.ivAvatar);
                Glide.with(mContext).load(item.getImg())
                        .override(DensityUtils.dp2px(30), DensityUtils.dp2px(30))
                        .placeholder(R.drawable.icon_def_avator)
                        .error(R.drawable.icon_def_avator)
                        .into(headView);
            }
        };
        recyclerView.setAdapter(mSingleDataBindingNoPUseAdapter);
        mSingleDataBindingNoPUseAdapter.setNewData(mListData);
        mSingleDataBindingNoPUseAdapter.setOnItemClickListener((adapter, v, position) -> {
            Agent agent = (Agent) adapter.getData().get(position);
            for (Object item : adapter.getData()) {
                if (item instanceof Agent) {
                    ((Agent) item).setSelect(false);

                }
            }
            for (int i = 0; i < adapter.getData().size(); i++) {
                Object object = adapter.getData().get(i);
                if (object instanceof Agent) {
                    ((Agent) object).setSelect(false);
                    mSingleDataBindingNoPUseAdapter.notifyItemChanged(i);
                }
            }
            agent.setSelect(true);
            mSingleDataBindingNoPUseAdapter.notifyItemChanged(position);
            if (mOnClickListener != null)
                mOnClickListener.onItemClick(agent);
            dismiss();
        });
        return view;
    }

    public void updateData(List<Agent> list) {
        mSingleDataBindingNoPUseAdapter.setNewData(list);
        if (list != null && !list.isEmpty()) {
            emptyView.setVisibility(View.GONE);
        } else {
            emptyView.setVisibility(View.VISIBLE);
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

    public interface OnAgentSearchListener {
        void onText(String cityCode, String key);
    }

    private OnAgentSearchListener onAgentSearchListener;

    public void setOnAgentSearchListener(OnAgentSearchListener listener) {
        this.onAgentSearchListener = listener;
    }

}
