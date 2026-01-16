package com.okla.ops.views.workbench.cabinetopt;

import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.okla.ops.R;
import com.okla.ops.databinding.ActivityCabinetAuthorizationOperateBinding;

public class CabinetAuthorizationOperateActivity extends BaseNormalVActivity<CabinetAuthorizationOperateViewModel, ActivityCabinetAuthorizationOperateBinding> {
    @Override
    protected CabinetAuthorizationOperateViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinetAuthorizationOperateViewModel.class);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_cabinet_authorization_operate;
    }

}
