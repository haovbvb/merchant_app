package com.okla.ops.views.workbench;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.view.View;

import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.utils.StatusBarUtil;
import com.base.library.base.mvvm.BaseViewModel;
import com.journeyapps.barcodescanner.CaptureManager;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;
import com.okla.ops.R;
import com.okla.ops.databinding.ActivityQrcodeBinding;


/**
 * @Date: 2021/1/19 15:15
 * @Author: craz
 * @Description:
 * @Version:
 */

public class QRCodeActivity extends BaseNormalVActivity<BaseViewModel, ActivityQrcodeBinding> implements DecoratedBarcodeView.TorchListener {

    private CaptureManager captureManager;
    public static final String QR_TYPE_TARGET = "type";
    public static final int NORMAL = 1;

    public static String SCAN_RESULT = "scanResult";

    public static Intent getIntents(Context context) {
        Intent intent = new Intent(context, QRCodeActivity.class);
        return intent;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_qrcode;
    }

    @Override
    protected BaseViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(BaseViewModel.class);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        StatusBarUtil.transparencyBar(this);
        StatusBarUtil.StatusBarLightMode(this);
        permissionManager = PermissionManager.getInstance(this.getActivityResultRegistry(), this.getClass().getName(), this);
        getLifecycle().addObserver(permissionManager);
//        mImmersionBar.fitsSystemWindows(false).keyboardEnable(false).statusBarDarkFont(false).statusBarColor(android.R.color.transparent).navigationBarColor(android.R.color.transparent).navigationBarDarkIcon(false).init();
        mBinding.setView(this);
        requestPermission();
        //重要代码，初始化捕获
        captureManager = new CaptureManager(this, mBinding.viewFinder);
        mBinding.viewFinder.setStatusText("");
        captureManager.initializeFromIntent(getIntent(), savedInstanceState);
        captureManager.decode();
        mBinding.viewFinder.setTorchListener(this);

        initClick();
    }

    PermissionManager permissionManager;


    private void requestPermission() {
        String[] perms = {Manifest.permission.CAMERA};
        permissionManager.checkPermissions(new PermissionListenerImpl() {
            @Override
            public void passPermission() {
                super.passPermission();
                if (captureManager != null) {
                    captureManager.onResume();
                }
            }

            @Override
            public void showRequestPermissionRationale() {
                super.showRequestPermissionRationale();
                PermissionManager.askForPermission(getActivity(), "");
            }
        }, perms);
    }

    @Override
    protected void onResume() {
        super.onResume();
        captureManager.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        captureManager.onPause();
    }

    @Override
    protected void onDestroy() {
        captureManager.onDestroy();
        super.onDestroy();
    }

    @Override
    public void onSaveInstanceState(Bundle outState, PersistableBundle outPersistentState) {
        super.onSaveInstanceState(outState, outPersistentState);
        captureManager.onSaveInstanceState(outState);
    }

    private void initClick() {
        mBinding.clHead.ivBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mBinding.clHead.tvTitle.setText(getString(R.string.qr_title));
        if (!hasFlash()) {
            mBinding.btnSwitch.setVisibility(View.INVISIBLE);
        }
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.btn_switch:
                if (isLightOn) {
                    mBinding.viewFinder.setTorchOff();
                } else {
                    mBinding.viewFinder.setTorchOn();
                }
                break;
            case R.id.manual_input:
                break;
            default:
                break;
        }
    }

    private boolean hasFlash() {
        return getApplicationContext().getPackageManager()
                .hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
    }

    boolean isLightOn = false;

    @Override
    public void onTorchOn() {
        isLightOn = true;
        mBinding.flashImage.setImageResource(R.mipmap.qr_light);
        mBinding.flashImage.setBackgroundResource(R.drawable.bg_4d6dd9ee_r16);
    }

    @Override
    public void onTorchOff() {
        isLightOn = false;
        mBinding.flashImage.setImageResource(R.mipmap.qr_unlight);
        mBinding.flashImage.setBackgroundResource(R.drawable.bg_80999999_r16);
    }

}