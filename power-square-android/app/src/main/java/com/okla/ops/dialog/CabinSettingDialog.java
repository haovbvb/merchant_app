package com.okla.ops.dialog;

import android.content.Context;
import android.view.Gravity;
import android.view.View;

import androidx.databinding.ViewDataBinding;
import androidx.databinding.library.baseAdapters.BR;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;

import java.util.List;

import razerdp.basepopup.BasePopupWindow;

/**
 * Date: 2019/4/10 14:06
 * Author: Jayden
 * Description:
 * Version:
 */
public class CabinSettingDialog extends BasePopupWindow {
    private SingleDataBindingNoPUseAdapter mAdapter;
    private OnSelectClickListener selectClickListener;

    public CabinSettingDialog(Context context, final List<String> data) {
        super(context);
        setOutSideTouchable(true);
        setPopupGravity(Gravity.CENTER);
        setBackground(null);
        RecyclerView recyclerView = findViewById(R.id.rcv_content);
        recyclerView.setLayoutManager(new LinearLayoutManager(context));
        recyclerView.setItemAnimator(new DefaultItemAnimator());
        mAdapter = new SingleDataBindingNoPUseAdapter<String>(R.layout.item_cabin_setting){
            @Override
            public void convert(BaseViewHolder helper, String item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                viewDataBinding.setVariable(BR.index,mAdapter.getData().indexOf(item));
            }
        };
        mAdapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
                if (selectClickListener != null) {
                    dismiss();
                    selectClickListener.onItemClick(position);
                }
            }
        });
        recyclerView.setAdapter(mAdapter);
        mAdapter.addData(data);
    }

    @Override
    public void showPopupWindow(View anchorView) {
        super.showPopupWindow(anchorView);
        setPopupGravity(Gravity.BOTTOM|Gravity.LEFT);
    }

    @Override
    public View onCreateContentView() {
        return createPopupById(R.layout.view_cabin_setting_pop);
    }

    public CabinSettingDialog setOnSelectClickListener(OnSelectClickListener listener) {
        selectClickListener = listener;
        return this;
    }

    public interface OnSelectClickListener {
        void onItemClick(int index);
    }
}
