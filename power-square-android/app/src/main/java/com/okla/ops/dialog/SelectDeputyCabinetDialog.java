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
import com.okla.ops.beans.DeputyCabinetBean;

import java.util.List;

import razerdp.basepopup.BasePopupWindow;

/**
 * Date: 2019/4/10 14:06
 * Author: Jayden
 * Description:
 * Version:
 */
public class SelectDeputyCabinetDialog extends BasePopupWindow {
    private SingleDataBindingNoPUseAdapter mAdapter;
    private OnSelectClickListener selectClickListener;

    public SelectDeputyCabinetDialog(Context context, final List<DeputyCabinetBean> data) {
        super(context);
        setOutSideTouchable(true);
        setPopupGravity(Gravity.CENTER);
        setBackground(null);
        RecyclerView recyclerView = findViewById(R.id.rcv_content);
        recyclerView.setLayoutManager(new LinearLayoutManager(context));
        recyclerView.setItemAnimator(new DefaultItemAnimator());
        mAdapter = new SingleDataBindingNoPUseAdapter<DeputyCabinetBean>(R.layout.item_cabinet_seselect){
            @Override
            public void convert(BaseViewHolder helper, DeputyCabinetBean item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                viewDataBinding.setVariable(BR.index,mAdapter.getData().indexOf(item));
                viewDataBinding.setVariable(BR.data,item);
            }
        };
        mAdapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
                if (selectClickListener != null) {
                    dismiss();
                    selectClickListener.onItemClick((DeputyCabinetBean) adapter.getData().get(position));
                }
            }
        });
        recyclerView.setAdapter(mAdapter);
        mAdapter.addData(data);
    }

    @Override
    public void showPopupWindow(View anchorView) {
        super.showPopupWindow(anchorView);
        setPopupGravityMode(GravityMode.ALIGN_TO_ANCHOR_SIDE,GravityMode.RELATIVE_TO_ANCHOR);
        setPopupGravity(Gravity.BOTTOM| Gravity.RIGHT);
    }

    @Override
    public View onCreateContentView() {
        return createPopupById(R.layout.view_cabin_setting_pop);
    }

    public SelectDeputyCabinetDialog setOnSelectClickListener(OnSelectClickListener listener) {
        selectClickListener = listener;
        return this;
    }

    public interface OnSelectClickListener {
        void onItemClick(DeputyCabinetBean bean);
    }
}
