package com.okla.ops.views.mine;

import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.View;

import com.base.common.BuildConfig;
import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.library.base.mvvm.BaseViewModel;
import com.okla.ops.R;
import com.okla.ops.databinding.ActivityServiceAgreementBinding;
import com.okla.ops.views.PromoteWebActivity;

public class ServiceAgreementActivity extends BaseNormalVActivity<BaseViewModel, ActivityServiceAgreementBinding>
        implements View.OnClickListener {

    public static void startServiceAgreementActivity(Context context) {
        Intent intent = new Intent(context, ServiceAgreementActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_service_agreement;
    }

    @Override
    protected BaseViewModel onCreateViewModel() {
        return new BaseViewModel();
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setViewModel(viewModel);
        mBinding.includeTitle.topTitle.setText(R.string.text_user_agreement);
        mBinding.includeTitle.topTitle.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
        initClicks();
    }

    private void initClicks() {
        mBinding.tvUserAgreement.setOnClickListener(this);
        mBinding.tvPrivacy.setOnClickListener(this);
    }

    @Override
    public void onNoDoubleClick(View v) {
        super.onNoDoubleClick(v);
        if (v.getId() == R.id.tvPrivacy) {
            startActivity(PromoteWebActivity.getIntents(mContext, BuildConfig.PRIVACY_POLICY, "", "", false));
        }
        if (v.getId() == R.id.tvUserAgreement) {
            startActivity(PromoteWebActivity.getIntents(mContext, BuildConfig.USER_AGREEMENT, "", "", false));
        }
    }

}
