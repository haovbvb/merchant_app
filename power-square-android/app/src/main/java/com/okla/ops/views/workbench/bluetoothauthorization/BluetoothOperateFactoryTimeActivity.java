package com.okla.ops.views.workbench.bluetoothauthorization;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.utils.ToastUtils;
import com.okla.ops.R;
import com.okla.ops.beans.AddAuthorizationEventBusBean;
import com.okla.ops.databinding.ActivityOperateFactoryTimeBinding;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

/**
 * 工厂授权时间
 */
public class BluetoothOperateFactoryTimeActivity extends BaseNormalVActivity<BluetoothAuthorizationViewModel, ActivityOperateFactoryTimeBinding> implements View.OnClickListener {


    @Override
    protected int getLayoutId() {
        return R.layout.activity_operate_factory_time;
    }

    @Override
    protected BluetoothAuthorizationViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(BluetoothAuthorizationViewModel.class);
    }

    @Override
    protected boolean isBindEventBusHere() {
        return true;
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void addAuthorizationEventBusBean(AddAuthorizationEventBusBean authorizationEventBusBean) {

        if (authorizationEventBusBean.state == 0) {
            return;
        }

        if (authorizationEventBusBean.state == 1) {
            finish();
        }
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setViewModel(viewModel);
        mBinding.includeTitle.topTitle.setText(R.string.factory_authorized);


        initClicks();

        mBinding.tvSure.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String strDay = mBinding.etSn.getText().toString().trim();
                if (TextUtils.isEmpty(strDay)) {
                    return;
                }

                AddAuthorizationEventBusBean event = new AddAuthorizationEventBusBean(0);
                int day = Integer.parseInt(strDay);
                if (day > 365) {
                    ToastUtils.showShort(getString(R.string.add_authorization_days_tip));
                    return;
                }
                event.day = day;
                EventBus.getDefault().post(event);
            }
        });


    }

    private void initClicks() {

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            default:
                break;
        }
    }
}