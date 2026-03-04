package com.okla.ops.views.workbench.cabinetopt;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.utils.MD5Util;
import com.base.common.utils.ToastUtils;
import com.okla.ops.R;
import com.okla.ops.databinding.ActivityCabinetOperateBinding;
import com.okla.ops.utils.ScanUtils;
import com.okla.ops.views.workbench.bluetoothauthorization.BluetoothAuthorizationActivityNew;
import com.okla.ops.views.workbench.equipmentsearch.EquipmentSearchActivityNew;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

public class CabinetOperateActivity extends BaseNormalVActivity<CabinetOperateViewModel, ActivityCabinetOperateBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.activity_cabinet_operate;
    }

    @Override
    protected CabinetOperateViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinetOperateViewModel.class);
    }

    @Override
    public int title() {
        return R.string.cabinet_opt_title;
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        TextView topTitle = findViewById(com.base.common.R.id.topTitle);
        topTitle.setGravity(Gravity.CENTER);
        Drawable drawable = ContextCompat.getDrawable(this, R.drawable.icon_bluetooth_item);
        int size = (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP,
                24f,
                getResources().getDisplayMetrics()
        );

        if (drawable != null) {
            drawable.setBounds(0, 0, size, size);
        }

        mBinding.btnBluetooth.setCompoundDrawables(
                drawable,
                null,
                null,
                null
        );
        initObserver();
        initClick();
    }

    private void initClick() {
        mBinding.btnCabinetOpt.setOnClickListener(v -> {
            startActivity(EquipmentSearchActivityNew.getIntents(this, "",0,EquipmentSearchActivityNew.OPT_DEVICE,true));
        });
        mBinding.btnBluetooth.setOnClickListener(v -> {
            startActivity(BluetoothAuthorizationActivityNew.getIntents(this));
        });
        mBinding.btnCabinetAuthorization.setOnClickListener(v -> {
            startActivity(new Intent(this, CabinetAuthorizationOperateActivity.class));
        });
        mBinding.btnCabinetOpenDoor.setOnClickListener(v -> {
            startActivity(EquipmentSearchActivityNew.getIntents(this,"",0, EquipmentSearchActivityNew.OPT_OPEN_DOOR,true));
        });
        mBinding.btnCabinetOffline.setOnClickListener(v -> {
            new IntentIntegrator(this)
                    .addExtra(CabinetScanQrcodeActivity.QR_TYPE_TARGET, CabinetScanQrcodeActivity.NORMAL)
                    .setOrientationLocked(false)
                    .setCaptureActivity(CabinetScanQrcodeActivity.class) // 设置自定义的activity是CustomActivity
                    .initiateScan(); //  初始化扫描
        });
    }

    private void initObserver() {

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            String mScanedMessage = null;
            IntentResult intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
            if (intentResult != null && intentResult.getContents() != null) {
                mScanedMessage = intentResult.getContents();
            }
            if (!TextUtils.isEmpty(mScanedMessage)) {
                String sn = ScanUtils.Companion.parseStationQr(mContext,mScanedMessage).getSn();
                CabinetOfflineDetailActivity.startCabinetOfflineDetailActivity(this, sn);
            }
        }
        if (resultCode == CabinetScanQrcodeActivity.RESULT_CODE) {
            if (data != null) {
                String mScanedMessage = data.getStringExtra("SN");
                if (mScanedMessage != null) {
                    if (!TextUtils.isEmpty(mScanedMessage)) {
                        CabinetOfflineDetailActivity.startCabinetOfflineDetailActivity(this, mScanedMessage);
                    }
                }
            }
        }
    }

}
