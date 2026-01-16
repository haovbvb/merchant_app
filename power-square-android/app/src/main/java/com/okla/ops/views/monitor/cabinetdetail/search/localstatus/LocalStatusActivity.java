package com.okla.ops.views.monitor.cabinetdetail.search.localstatus;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.okla.ops.R;
import com.okla.ops.databinding.ActivityLocalStatusBinding;

/**
 * @Date: 2021/2/23 10:24
 * @Author: craz
 * @Description:
 * @Version:
 */

public class LocalStatusActivity extends BaseNormalVActivity<LocalStatusViewModel, ActivityLocalStatusBinding> {

    private Observer<String> statusObserver;
    private String mCabinetPID;

    public static Intent getIntents(Context context,String pid) {
        Intent intent = new Intent(context, LocalStatusActivity.class);
        intent.putExtra("pid",pid);
        return intent;
    }

    @Override
    public int title() {
        return R.string.local_status_title;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_local_status;
    }

    @Override
    protected LocalStatusViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(LocalStatusViewModel.class);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mCabinetPID = getIntent().getStringExtra("pid");
        initObserver();
    }

    private void initObserver() {
        getLoading().onStart();
        statusObserver = s -> {
            getLoading().onFinish();
            mBinding.setData(s);
        };
        getViewModel().getLocalStatus(mCabinetPID).observe(this, statusObserver);
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            default:
                break;
        }
    }
}