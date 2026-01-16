package com.okla.ops.views.workbench.cabinetopt;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.text.TextUtils;
import android.view.View;

import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.utils.StatusBarUtil;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.okla.ops.R;
import com.okla.ops.databinding.ActivityCabinetScanQrcodeBinding;
import com.okla.ops.dialog.EditTextBottomDialog;
import com.journeyapps.barcodescanner.CaptureManager;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;

public class CabinetScanQrcodeActivity extends BaseNormalVActivity<BaseViewModel, ActivityCabinetScanQrcodeBinding> implements DecoratedBarcodeView.TorchListener {

    private CaptureManager captureManager;
    public static final String QR_TYPE_TARGET = "type";
    public static final int NORMAL = 1;
    public static final int RESULT_CODE = 2;

    public static Intent getIntents(Context context) {
        Intent intent = new Intent(context, CabinetScanQrcodeActivity.class);
        return intent;
    }

    @Override
    protected BaseViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(BaseViewModel.class);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_cabinet_scan_qrcode;
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        StatusBarUtil.transparencyBar(this);
        StatusBarUtil.StatusBarLightMode(this);
        mBinding.setView(this);
        requestPermission();
        //重要代码，初始化捕获
        captureManager = new CaptureManager(this, mBinding.viewFinder);
        captureManager.initializeFromIntent(getIntent(), savedInstanceState);
        captureManager.decode();
        mBinding.viewFinder.setTorchListener(this);

        initClick();
    }

    private void requestPermission() {
        String[] perms = {Manifest.permission.CAMERA};
        PermissionManager.checkPermission(this, new PermissionListenerImpl() {
            @Override
            public void passPermission() {
                if (captureManager != null) {
                    captureManager.onResume();
                }
            }

            @Override
            public void showRequestPermissionRationale() {
                super.showRequestPermissionRationale();
                PermissionManager.askForPermission(getActivity(), "");
            }

            @Override
            public void deniedPermission() {
                super.deniedPermission();
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
        mBinding.clHead.ivBack.setOnClickListener(v -> finish());
        mBinding.clHead.tvTitle.setText(getString(R.string.qr_title));
        if (!hasFlash()) {
            mBinding.btnSwitch.setVisibility(View.INVISIBLE);
        }
        mBinding.tvEnterSn.setOnClickListener(v -> showEditTextBottomDialog());
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
    }

    @Override
    public void onTorchOff() {
        isLightOn = false;
        mBinding.flashImage.setImageResource(R.mipmap.qr_unlight);
    }

    private EditTextBottomDialog editTextBottomDialog;

    private void showEditTextBottomDialog() {
        if (editTextBottomDialog == null) {
            editTextBottomDialog = new EditTextBottomDialog(mContext,false);
            editTextBottomDialog.setOnClickListener(new EditTextBottomDialog.OnClickListener() {
                @Override
                public void onConfirm(String sn, String vin) {
                    if (TextUtils.isEmpty(sn)) {
                        ToastUtils.showShort(getString(R.string.transport_enter_device_sn));
                        return;
                    }
                    Intent intent = new Intent();
                    intent.putExtra("SN", sn);
                    setResult(RESULT_CODE, intent);
                    finish();
                }
            });
            editTextBottomDialog.setOnDismissListener(dialog -> mBinding.clEnterSn.setVisibility(View.VISIBLE));
        }
        editTextBottomDialog.show();
        mBinding.clEnterSn.setVisibility(View.GONE);
    }
}
