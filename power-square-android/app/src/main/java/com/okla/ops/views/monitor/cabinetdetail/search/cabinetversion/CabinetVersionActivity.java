package com.okla.ops.views.monitor.cabinetdetail.search.cabinetversion;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.okla.ops.R;
import com.okla.ops.beans.CabinetVersionBean;
import com.okla.ops.databinding.ActivityCabinetVersionBinding;

/**
 * @Date: 2021/2/23 10:27
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinetVersionActivity extends BaseNormalVActivity<CabinetVersionViewModel, ActivityCabinetVersionBinding> {

    private String mCabinetPID;
    private Observer<CabinetVersionBean> versionObserver;

    public static Intent getIntents(Context context, String pid) {
        Intent intent = new Intent(context, CabinetVersionActivity.class);
        intent.putExtra("pid",pid);
        return intent;
    }

    @Override
    public int title() {
        return R.string.cabinet_version_title;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_cabinet_version;
    }

    @Override
    protected CabinetVersionViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinetVersionViewModel.class);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mCabinetPID = getIntent().getStringExtra("pid");
        initObserver();
    }

    private void initObserver() {
        getLoading().onStart();
        versionObserver = new Observer<CabinetVersionBean>() {
            @Override
            public void onChanged(CabinetVersionBean cabinetVersionBean) {
                getLoading().onFinish();
                cabinetVersionBean.setPms(TextUtils.isEmpty(cabinetVersionBean.getPms()) ? "" : cabinetVersionBean.getPms().replace(",","\n"));
                cabinetVersionBean.setCharge(TextUtils.isEmpty(cabinetVersionBean.getCharge()) ? "" : cabinetVersionBean.getCharge().replace(",","\n"));
                mBinding.setData(cabinetVersionBean);
            }
        };
        getViewModel().getCabinetVersion(mCabinetPID).observe(this,versionObserver);
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            default:
                break;
        }
    }
}