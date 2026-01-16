package com.okla.ops.views.monitor.cabinetdetail.cabin.faultlist;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.databinding.ViewDataBinding;
import androidx.databinding.library.baseAdapters.BR;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.base.mvvm.BaseNormalListVActivity;
import com.base.common.utils.DensityUtil;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.CabinFaultBean;
import com.okla.ops.beans.CabinToolbarBean;
import com.okla.ops.beans.DeputyCabinetBean;
import com.okla.ops.databinding.ActivityCabinFaultListBinding;
import com.okla.ops.dialog.SelectDeputyCabinetDialog;

import java.util.ArrayList;
import java.util.List;

import razerdp.basepopup.BasePopupWindow;

/**
 * @Date: 2021/2/13 11:14
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinFaultListActivity extends BaseNormalListVActivity<CabinFaultListViewModel, ActivityCabinFaultListBinding> {

    private SingleDataBindingNoPUseAdapter<CabinToolbarBean> mToolbarAdapter;
    private ArrayList<Integer> portList;//仓位列表
    private int port;//第几个仓位
    private String mCabinetSN;//sn
    private String mCabinetPID;//pid
    private Observer<CabinFaultBean> mFaultObserver;

    public static Intent getIntents(Context context,ArrayList<Integer> portList,int port,String mCabinetSN,String mCabinetPID) {
        Intent intent = new Intent(context, CabinFaultListActivity.class);
        intent.putIntegerArrayListExtra("portList",portList);
        intent.putExtra("port",port);
        intent.putExtra("mCabinetSN",mCabinetSN);
        intent.putExtra("mCabinetPID",mCabinetPID);
        return intent;
    }

    @Override
    public int title() {
        return R.string.cabin_fault_list_title;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_cabin_fault_list;
    }

    @Override
    protected CabinFaultListViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinFaultListViewModel.class);
    }

    @Override
    protected RecyclerView.Adapter createAdapter() {
        return new SingleDataBindingNoPUseAdapter<CabinFaultBean>(R.layout.item_fault_list);
    }

    @Override
    protected RecyclerView getRecyclerView() {
        return mBinding.rvFaultList;
    }

    @Override
    protected void initPageData() {
        getViewModel().getFaultList(pageIndex,pageSize,mCabinetSN,port,nID).observe(this,mFaultObserver);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        getStatusView().setEnableRefresh(true);
        getStatusView().setEnableLoadMore(true);
        mBinding.setView(this);
        Intent intent = getIntent();
        portList = intent.getIntegerArrayListExtra("portList");
        port = intent.getIntExtra("port",1);
        mCabinetSN = intent.getStringExtra("mCabinetSN");
        mCabinetPID = intent.getStringExtra("mCabinetPID");
        initTablebarAdapter();
        initObserver();
        onRefresh();
    }

    private void initTablebarAdapter() {
        getToolbarData();
        mToolbarAdapter = new SingleDataBindingNoPUseAdapter<CabinToolbarBean>(R.layout.item_fault_list_toolbar){
            @Override
            public void convert(BaseViewHolder helper, CabinToolbarBean item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                viewDataBinding.setVariable(BR.index, mToolbarAdapter.getData().indexOf(item));
            }
        };
        mToolbarAdapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
                for (int i = 0; i < adapter.getData().size(); i++) {
                    if(i == position){
                        ((CabinToolbarBean)adapter.getData().get(i)).setSelect(true);
                        port = ((CabinToolbarBean)adapter.getData().get(i)).getSize();
                        onRefresh();
                    }else {
                        ((CabinToolbarBean)adapter.getData().get(i)).setSelect(false);
                    }
                }
            }
        });
        mBinding.rvBox.setLayoutManager(new LinearLayoutManager(getActivity(),LinearLayoutManager.HORIZONTAL,false));
        mBinding.rvBox.setAdapter(mToolbarAdapter);
        mToolbarAdapter.addData(mToolbarList);
    }

    private Observer<List<DeputyCabinetBean>> mDeputyCabinetBeanObserver;
    List<DeputyCabinetBean> mDeputyCabinetList;
    private void initObserver() {
        mFaultObserver = mCabinFaultBean -> {
            updateListItems(mCabinFaultBean.getList());
        };

        mDeputyCabinetBeanObserver = deputyCabinetBeanList -> {
            if(deputyCabinetBeanList != null && deputyCabinetBeanList.size() > 1){
                if(mDeputyCabinetList == null){
                    mDeputyCabinetList = new ArrayList<>();
                }
                mDeputyCabinetList.addAll(deputyCabinetBeanList);
                mBinding.includeTitle.topRight.setVisibility(View.VISIBLE);
                mBinding.includeTitle.topRight.setPadding(0,0, DensityUtil.dp2px(this,20),0);
                mBinding.includeTitle.topRight.setCompoundDrawablesWithIntrinsicBounds(0,0,R.mipmap.detail_down,0);
                mBinding.includeTitle.topRight.setCompoundDrawablePadding(4);
                mBinding.includeTitle.topRight.setText(String.format(getString(R.string.device_detail_mainframe),1));
            }
        };
        getViewModel().getDeputyCabinetData(mCabinetPID).observe(this,mDeputyCabinetBeanObserver);
        mBinding.includeTitle.topRight.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                initSelectDeputyCabinetDialog();
            }
        });
    }

    List<CabinToolbarBean> mToolbarList = new ArrayList<>();
    private void getToolbarData() {
        for (int i = 0; i < portList.size(); i++) {
            if(portList.get(i) == port){
                mToolbarList.add(new CabinToolbarBean(String.format(getString(R.string.cabin_cabin_serial),portList.get(i)),portList.get(i),true));
            }else {
                mToolbarList.add(new CabinToolbarBean(String.format(getString(R.string.cabin_cabin_serial),portList.get(i)),portList.get(i),false));
            }
        }
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            default:
                break;
        }
    }


    SelectDeputyCabinetDialog mSelectDeputyCabinetDialog;
    int nID = 1;
    private void initSelectDeputyCabinetDialog() {
        if (mDeputyCabinetList == null || mDeputyCabinetList.size() <= 0) {
            return;
        }
        if (mSelectDeputyCabinetDialog == null) {
            mSelectDeputyCabinetDialog = new SelectDeputyCabinetDialog(this, mDeputyCabinetList)
                    .setOnSelectClickListener(bean -> {
                        nID = bean.getNodeId();
                        if(1 == nID) {
                            mBinding.includeTitle.topRight.setText(String.format(getString(R.string.device_detail_mainframe),bean.getNodeId()));
                        }else {
                            mBinding.includeTitle.topRight.setText(String.format(getString(R.string.device_detail_deputy_ark),bean.getNodeId()));
                        }
                        onRefresh();
                    });
            mSelectDeputyCabinetDialog.setOnDismissListener(new BasePopupWindow.OnDismissListener() {
                @Override
                public void onDismiss() {
                    mBinding.includeTitle.topRight.setCompoundDrawablesWithIntrinsicBounds(0,0,R.mipmap.detail_down,0);
                }
            });
        }
        if (!mSelectDeputyCabinetDialog.isShowing()) {
            mSelectDeputyCabinetDialog.showPopupWindow(mBinding.includeTitle.topRight);
            mBinding.includeTitle.topRight.setCompoundDrawablesWithIntrinsicBounds(0,0,R.mipmap.detail_up,0);
        }
    }
}