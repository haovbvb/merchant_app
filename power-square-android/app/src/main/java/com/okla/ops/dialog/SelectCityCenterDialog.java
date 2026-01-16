package com.okla.ops.dialog;

import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;

import androidx.databinding.ViewDataBinding;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.BR;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.CityCode;

import java.util.List;

import razerdp.basepopup.BasePopupWindow;

/**
 * Date: 2019/4/10 14:06
 * Author: Jayden
 * Description:
 * Version:
 */
public class SelectCityCenterDialog extends BasePopupWindow {
    private SingleDataBindingNoPUseAdapter mAdapter;
    private OnSelectClickListener selectClickListener;

    public SelectCityCenterDialog(Context context, final List<CityCode> data) {
        super(context);
        setOutSideTouchable(false);
        setPopupGravity(Gravity.CENTER);
        RecyclerView recyclerView = findViewById(R.id.rcv_content);
        recyclerView.setLayoutManager(new LinearLayoutManager(context));
        recyclerView.setItemAnimator(new DefaultItemAnimator());
        mAdapter = new SingleDataBindingNoPUseAdapter<CityCode>(R.layout.item_select_city_center){
            @Override
            public void convert(BaseViewHolder helper, CityCode item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                viewDataBinding.setVariable(BR.index, mAdapter.getData().indexOf(item));
                if(item.isSelect()) {
                    ((ImageView) helper.getView(R.id.ivHook)).setImageResource(R.mipmap.hook_selected);
                }else {
                    ((ImageView) helper.getView(R.id.ivHook)).setImageResource(R.mipmap.hook_unselected);
                }
            }
        };
        recyclerView.setAdapter(mAdapter);
        data.get(0).setSelect(true);
        mAdapter.addData(data);
        mAdapter.setOnItemClickListener((adapter, view, position) -> {
            if (selectClickListener != null) {
                for (int i = 0; i < data.size(); i++) {
                    if(i == position) {
                        data.get(i).setSelect(true);
                    }else {
                        data.get(i).setSelect(false);
                    }

                }
                selectClickListener.onItemClick(data.get(position));
            }
            dismiss();
        });
    }

    @Override
    public void showPopupWindow(View anchorView) {
        super.showPopupWindow(anchorView);

    }

    @Override
    public View onCreateContentView() {
        return createPopupById(R.layout.view_select_current_and_point_pop);
    }

    public SelectCityCenterDialog setOnSelectClickListener(OnSelectClickListener listener) {
        selectClickListener = listener;
        return this;
    }

    public interface OnSelectClickListener {
        void onItemClick(CityCode data);
    }
}
