package com.okla.ops.dialog;

import android.content.Context;
import android.view.Gravity;
import android.view.View;

import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.OpsAndMaintenaceBean;

import java.util.List;

import razerdp.basepopup.BasePopupWindow;

/**
 * Date: 2019/4/10 14:06
 * Author: Jayden
 * Description:
 * Version:
 */
public class SelectPersonLiableDialog extends BasePopupWindow {
    private SingleDataBindingNoPUseAdapter mAdapter;
    private OnSelectClickListener selectClickListener;

    public SelectPersonLiableDialog(Context context, final List<OpsAndMaintenaceBean.ListBean> data) {
        super(context);
        setOutSideTouchable(false);
        setAlignBackground(true);
        setAlignBackgroundGravity(Gravity.BOTTOM);
        setPopupGravity(Gravity.TOP);
        RecyclerView recyclerView = findViewById(R.id.rcv_content);
        recyclerView.setLayoutManager(new LinearLayoutManager(context));
        recyclerView.setItemAnimator(new DefaultItemAnimator());
        mAdapter = new SingleDataBindingNoPUseAdapter<OpsAndMaintenaceBean.ListBean>(R.layout.item_delete_selected_responsible_person){
            @Override
            protected void convert(BaseViewHolder helper, OpsAndMaintenaceBean.ListBean item) {
                super.convert(helper, item);
                helper.getView(R.id.ivDeleteSelected).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (selectClickListener != null) {
                            selectClickListener.onItemClick(item);
                            mAdapter.remove(getData().indexOf(item));
                        }
                    }
                });
            }
        };
        recyclerView.setAdapter(mAdapter);
        mAdapter.addData(data);
    }

    @Override
    public void showPopupWindow(View anchorView) {
        super.showPopupWindow(anchorView);

    }

    @Override
    public View onCreateContentView() {
        return createPopupById(R.layout.view_select_person_liable_pop);
    }

    public SelectPersonLiableDialog setOnSelectClickListener(OnSelectClickListener listener) {
        selectClickListener = listener;
        return this;
    }

    public interface OnSelectClickListener {
        void onItemClick(OpsAndMaintenaceBean.ListBean data);
    }
}
