package com.okla.ops.views.mine;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;

import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.utils.StatusBarUtil;
import com.base.library.base.mvvm.BaseViewModel;
import com.okla.ops.R;
import com.okla.ops.databinding.ActivityAboutAppBinding;

public class AboutAppActivity extends BaseNormalVActivity<BaseViewModel, ActivityAboutAppBinding> {

    public static void startAboutAppActivity(Context context) {
        Intent intent = new Intent(context, AboutAppActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_about_app;
    }

    @Override
    protected BaseViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(BaseViewModel.class);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        StatusBarUtil.transparencyBar(this);
        StatusBarUtil.StatusBarDarkMode(this);
        mBinding.ivBack.setOnClickListener(v -> finish());
        getAppVersion();
    }

    public void getAppVersion() {
        try {
            PackageManager manager = getActivity().getPackageManager();
            PackageInfo info = manager.getPackageInfo(getActivity().getPackageName(), 0);
            String versionName = info.versionName;
            mBinding.tvCurrentVersion.setText("Version " + versionName);
            mBinding.tvNewVersion.setText("V" + versionName);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

