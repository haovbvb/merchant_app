package com.okla.ops.views.monitor.cabinetdetail.layoutrecord;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.base.mvvm.BaseNormalListVActivity;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.LayoutCabinetInfoBean;
import com.okla.ops.databinding.ActivityLayoutRecordBinding;

/**
 * @Date: 2021/1/28 10:39
 * @Author: craz
 * @Description:
 * @Version:
 */

public class LayoutRecordActivity extends BaseNormalListVActivity<LayoutRecordViewModel, ActivityLayoutRecordBinding> {

    private Observer<LayoutCabinetInfoBean> observer;
    private String strSN;

    public static Intent getIntents(Context context,String sn) {
        Intent intent = new Intent(context, LayoutRecordActivity.class);
        intent.putExtra("sn",sn);
        return intent;
    }

    @Override
    public int title() {
        return R.string.layout_cabinet_info_titile;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_layout_record;
    }

    @Override
    protected LayoutRecordViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(LayoutRecordViewModel.class);
    }

    @Override
    protected RecyclerView.Adapter createAdapter() {
        return new SingleDataBindingNoPUseAdapter<LayoutCabinetInfoBean>(R.layout.item_layout_cabinet_info);
    }

    @Override
    protected RecyclerView getRecyclerView() {
        return mBinding.rvLayoutRecord;
    }

    @Override
    protected void initPageData() {
        getViewModel().getLayouCabinetInfo(strSN,pageIndex,pageSize).observe(this,observer);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        getStatusView().setEnableLoadMore(true);
        getStatusView().setEnableRefresh(true);
        mBinding.setView(this);
        strSN = getIntent().getStringExtra("sn");
        initObserver();
        onRefresh();
    }

    private void initObserver() {
        observer = new Observer<LayoutCabinetInfoBean>() {
            @Override
            public void onChanged(LayoutCabinetInfoBean layoutCabinetInfoBean) {
                updateListItems(layoutCabinetInfoBean.getList());
            }
        };
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            default:
                break;
        }
    }
}