package com.okla.ops.views.workbench;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;

import androidx.annotation.RequiresApi;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.beans.RxEvent;
import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.utils.StatusBarUtil;
import com.base.common.utils.ToastUtils;
import com.base.common.utils.WindowInsetsHelper;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.ResultPoint;
import com.google.zxing.client.android.BeepManager;
import com.journeyapps.barcodescanner.BarcodeCallback;
import com.journeyapps.barcodescanner.BarcodeResult;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;
import com.journeyapps.barcodescanner.DefaultDecoderFactory;
import com.okla.ops.R;
import com.okla.ops.beans.Battery;
import com.okla.ops.beans.DeviceTypeObject;
import com.okla.ops.beans.ScanDeviceBean;
import com.okla.ops.databinding.ActivityQrcodeListBinding;
import com.okla.ops.dialog.EditTextBottomDialog;
import com.okla.ops.utils.ScanUtils;

import org.greenrobot.eventbus.EventBus;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

public class QRCodeListActivity extends BaseNormalVActivity<QRCodeListViewModel, ActivityQrcodeListBinding> implements DecoratedBarcodeView.TorchListener {

    public static final int REQUEST_CODE = 1;
    public static final int RESULT_CODE = 2;
    public static final String SN_LIST = "snList";

    private DecoratedBarcodeView barcodeView;
    private BeepManager beepManager;
    private String lastText;
    private final ArrayList<ScanDeviceBean> snList = new ArrayList<>();
    private int deviceType, snSize, snMaxSize = Integer.MAX_VALUE;
    private String transferNo, warehouseNo, inventoryNo;
    private PermissionManager permissionManager;
    private final ArrayList<ScanDeviceBean> mExistSnList = new ArrayList<>();
    private final ArrayList<Battery> mBatteryList = new ArrayList<>();
    public static String BATTERY_LIST = "batteryList";
    public static String VERIFY = "verify";

    private boolean isFirstScan = true;

    private boolean verify = false;
    private ArrayList<ScanDeviceBean> intentSnList;

    public static Intent getIntents(Context context, int type, String warehouseNo, int size, int maxSize) {
        Intent intent = new Intent(context, QRCodeListActivity.class);
        intent.putExtra("deviceType", type);
        intent.putExtra("warehouseNo", warehouseNo);
        intent.putExtra("snSize", size);
        intent.putExtra("snMaxSize", maxSize);
        return intent;
    }

    public static Intent getIntents(Context context, int type, String transferNo) {
        Intent intent = new Intent(context, QRCodeListActivity.class);
        intent.putExtra("deviceType", type);
        intent.putExtra("transferNo", transferNo);
        return intent;
    }

    public static Intent getIntents(Context context, String inventoryNo,int deviceType) {
        Intent intent = new Intent(context, QRCodeListActivity.class);
        intent.putExtra("inventoryNo", inventoryNo);
        intent.putExtra("deviceType", deviceType);
        return intent;
    }

    public static Intent getIntents(Context context, Boolean verify, ArrayList<ScanDeviceBean> snList, boolean needShowVinEdt, boolean isEntry,int deviceType) {
        Intent intent = new Intent(context, QRCodeListActivity.class);
        intent.putExtra(VERIFY, verify);
        intent.putExtra("needShowVinEdt", needShowVinEdt);
        intent.putExtra("isEntry", isEntry);
        intent.putExtra("deviceType",deviceType);
        intent.putExtra(SN_LIST, snList);
        return intent;
    }

    private boolean needShowVinEdt = false;
    private boolean isEntry = false;

    @Override
    protected int getLayoutId() {
        return R.layout.activity_qrcode_list;
    }

    @Override
    protected QRCodeListViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(QRCodeListViewModel.class);
    }

    @Override
    protected void getIntentExtras(Intent intent) {
        super.getIntentExtras(intent);
        deviceType = intent.getIntExtra("deviceType", -1);
        snSize = intent.getIntExtra("snSize", 0);
        snMaxSize = intent.getIntExtra("snMaxSize", Integer.MAX_VALUE);
        transferNo = intent.getStringExtra("transferNo");
        warehouseNo = intent.getStringExtra("warehouseNo");
        inventoryNo = intent.getStringExtra("inventoryNo");
        needShowVinEdt = intent.getBooleanExtra("needShowVinEdt", false);
        isEntry = intent.getBooleanExtra("isEntry", false);
        verify = intent != null && intent.getBooleanExtra(VERIFY, false);
        intentSnList = intent != null ? intent.getParcelableArrayListExtra(SN_LIST) : null;
        if (intentSnList != null) {
            mExistSnList.addAll(intentSnList);
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.P)
    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        WindowInsetsHelper.applyForBottom(mBinding.clEnterSn);

        StatusBarUtil.transparencyBar(this);
        StatusBarUtil.StatusBarLightMode(this);
        mBinding.setView(this);
        requestPermission();

        barcodeView = findViewById(R.id.barcode_scanner);
        barcodeView.setStatusText(""); // 清空提示文字
        Collection<BarcodeFormat> formats = Arrays.asList(BarcodeFormat.QR_CODE, BarcodeFormat.CODE_39);
        barcodeView.setOutlineSpotShadowColor(Color.parseColor("#FF50F000"));
        barcodeView.getBarcodeView().setDecoderFactory(new DefaultDecoderFactory(formats));
        barcodeView.initializeFromIntent(getIntent());
        barcodeView.decodeContinuous(callback);
        barcodeView.setTorchListener(this);

        beepManager = new BeepManager(this);

        initObserver();
        initClick();
    }

    private void initObserver() {
        getViewModel().getMCheckDeviceSn().observe(this, s -> {
            if (!TextUtils.isEmpty(warehouseNo)) {
                ToastUtils.showShort(mContext.getString(R.string.cc_str_success));
                snSize++;
                if (snList.isEmpty()) {
                    snList.add(new ScanDeviceBean(s, "",""));
                } else {
                    if (!snList.contains(s)) {
                        snList.add(new ScanDeviceBean(s, "",""));
                    }
                }
            }
        });
        getViewModel().getMScanInventoryLiveData().observe(this, s -> {
            if (!TextUtils.isEmpty(inventoryNo)) {
                ToastUtils.showShort(mContext.getString(R.string.cc_str_success));
                snSize++;
                if (snList.isEmpty()) {
                    snList.add(new ScanDeviceBean(s, "",""));
                } else {
                    if (!snList.contains(s)) {
                        snList.add(new ScanDeviceBean(s, "",""));
                    }
                }
            }
        });
        getViewModel().getMDeviceReceiveLiveData().observe(this, s -> {
            if (s != null) {
                finish();
            }
        });
//        getViewModel().getQueryBatteryLiveData().observe(this, battery ->
//        {
//            if (battery != null) {
//                if (isScannedBattery(battery.getSn())) {
//                    snList.add(new ScanDeviceBean(battery.getSn(),""));
//                    mBatteryList.add(battery);
//                }
//            }
//
//        });
    }

    private boolean isScannedBattery(ScanDeviceBean scanDeviceBean) {
        if (mExistSnList.isEmpty()) {
            ToastUtils.showShort(getString(com.base.common.R.string.cc_str_success));
            snList.add(scanDeviceBean);
            mExistSnList.add(scanDeviceBean);
            return true;
        } else {
            if (mExistSnList.contains(scanDeviceBean) || snList.contains(scanDeviceBean)) {
                ToastUtils.showShort(getString(R.string.tips_device_exist));
                mExistSnList.remove(scanDeviceBean);
                mExistSnList.add(0, scanDeviceBean);
                if (snList.contains(scanDeviceBean)) {
                    snList.remove(scanDeviceBean);
                    snList.add(0, scanDeviceBean);
                }
                return true;
            } else {
                ToastUtils.showShort(getString(com.base.common.R.string.cc_str_success));
                mExistSnList.add(0, scanDeviceBean);
                snList.add(0, scanDeviceBean);
                return true;
            }
        }
    }
    private final Handler handler = new Handler(Looper.getMainLooper());
    private boolean haveShownSameToast = false;
    private final BarcodeCallback callback = new BarcodeCallback() {
        @Override
        public void barcodeResult(BarcodeResult result) {
            if (result.getText() == null) return;
            if (result.getText().equals(lastText)) {
                if (!haveShownSameToast) {
                    haveShownSameToast = true;
                    handler.postDelayed(() -> {
                        if (!isFinishing() && !isDestroyed()) {
                            ToastUtils.showShort(getString(R.string.tips_qrcode_same_as_preone));
                        }
                        haveShownSameToast = false;
                    }, 3200);
                }
                return;
            }
            lastText = result.getText();
            haveShownSameToast = false;

            if (snSize >= snMaxSize) {
                runOnUiThread(() -> {
                    ToastUtils.showShort(getString(R.string.transport_max_device, snMaxSize));
                });
                return;
            }

            lastText = result.getText();
            barcodeView.setStatusText(result.getText());
            beepManager.playBeepSoundAndVibrate();
            String sn = ScanUtils.Companion.getDeviceSn(mContext, lastText);
            String vin = "";
            String vcu = "";
            if (lastText.toLowerCase().contains("vin:")||lastText.toLowerCase().contains("vin=")) {
                vin = ScanUtils.Companion.getDeviceSn(mContext, lastText);
                sn = vin;
            } else {
                sn = ScanUtils.Companion.getDeviceSn(mContext, lastText);
            }
                if (needShowVinEdt) {
                    ScanUtils.QrCodeVehicle qrCodeVehicle = ScanUtils.Companion.parseVehicleQr(mContext, lastText,0);
                    sn = qrCodeVehicle.getSn();
                    vin = qrCodeVehicle.getVin();
                    vcu = qrCodeVehicle.getVcu();
                } else {
                    if(deviceType== DeviceTypeObject.TYPE_BATTERY){
                        ScanUtils.QrCodeBattery qrCodeBattery = ScanUtils.Companion.parseBatteryQr(mContext, lastText,0);
                        sn = qrCodeBattery.getSn();
                        vin = qrCodeBattery.getImei();
                        vcu = qrCodeBattery.getIccid();
                    }else  if(deviceType== DeviceTypeObject.TYPE_STATION){
                        ScanUtils.QrCodeStation qrcodeStation = ScanUtils.Companion.parseStationQr(mContext, lastText);
                        sn = qrcodeStation.getSn();
                        vin = qrcodeStation.getLockDevId();
                        vcu="";
                    }

                }
            if (!TextUtils.isEmpty(sn)) {
                if (!TextUtils.isEmpty(warehouseNo)) {
                    getViewModel().checkDeviceSn(deviceType, sn, warehouseNo);
                } else if (!TextUtils.isEmpty(transferNo)) {
                    getViewModel().receiveDevice(sn, transferNo);
                } else if (!TextUtils.isEmpty(inventoryNo)) {
                    getViewModel().scanInventory(sn, inventoryNo);
                } else if (intentSnList != null) {
//                if (verify) {
//                    getViewModel().queryShipBatteryBySn(sn);
//                } else {
                    ScanDeviceBean deviceBean = new ScanDeviceBean(sn, vin, vcu);
                    if (isScannedBattery(deviceBean)) {
                        snList.add(deviceBean);
                        Battery battery = new Battery(sn, "", "", "", "");
                        mBatteryList.add(battery);
//                        successSetResultAndFinish();
                    }
                }
//                }
            }
        }

        @Override
        public void possibleResultPoints(List<ResultPoint> resultPoints) {
        }
    };

    private void requestPermission() {
        permissionManager = PermissionManager.getInstance(this.getActivityResultRegistry(), this.getClass().getName(), this);
        getLifecycle().addObserver(permissionManager);
        String[] perms = {Manifest.permission.CAMERA};
        permissionManager.checkPermissions(new PermissionListenerImpl() {
            @Override
            public void passPermission() {
                super.passPermission();
                if (barcodeView != null) {
                    barcodeView.resume();
                }
            }

            @Override
            public void showRequestPermissionRationale() {
                super.showRequestPermissionRationale();
            }
        }, perms);
    }

    @Override
    protected void onResume() {
        super.onResume();
        barcodeView.resume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        barcodeView.pause();
    }

    @Override
    protected void onDestroy() {
        handler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            successSetResult();
        }
        return barcodeView.onKeyDown(keyCode, event) || super.onKeyDown(keyCode, event);
    }

    private void successSetResult() {
        Intent intent = new Intent();
        if (!mBatteryList.isEmpty()) {
            intent.putParcelableArrayListExtra(BATTERY_LIST, mBatteryList);
        }
        intent.putParcelableArrayListExtra(SN_LIST, snList);
        setResult(RESULT_CODE, intent);
    }

    private void successSetResultAndFinish() {
        successSetResult();
        finish();
    }

    private void initClick() {
        mBinding.clHead.ivBack.setOnClickListener(v -> {
                EventBus.getDefault().post(new RxEvent.QrcodeListPageBackEvent());
            successSetResultAndFinish();
        });
        mBinding.clHead.tvTitle.setText(getString(R.string.qr_title));
        if (!hasFlash()) {
            mBinding.btnSwitch.setVisibility(View.INVISIBLE);
        }
        mBinding.tvEnterSn.setOnClickListener(v -> showEditTextBottomDialog(needShowVinEdt));
    }


    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.btn_switch:
                if (isLightOn) {
                    barcodeView.setTorchOff();
                    mBinding.flashImage.setImageResource(R.mipmap.qr_unlight);
                    mBinding.flashImage.setBackgroundResource(R.drawable.bg_80999999_r16);
                } else {
                    barcodeView.setTorchOn();
                    mBinding.flashImage.setImageResource(R.mipmap.qr_light);
                    mBinding.flashImage.setBackgroundResource(R.drawable.bg_4d6dd9ee_r16);
                }
                break;
//            case R.id.manual_input:
//                break;
//            default:
//                break;
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

    private EditTextBottomDialog editTextBottomDialog;

    private void showEditTextBottomDialog(boolean needShowVinEdt) {
        if (editTextBottomDialog == null) {
            editTextBottomDialog = new EditTextBottomDialog(this, needShowVinEdt);
            editTextBottomDialog.setOnClickListener(new EditTextBottomDialog.OnClickListener() {
                @Override
                public void onConfirm(String sn, String vin) {
                    if (TextUtils.isEmpty(sn)) {
                        ToastUtils.showShort(getString(R.string.transport_enter_device_sn));
                        return;
                    }
                    if (!TextUtils.isEmpty(warehouseNo)) {
                        if (snSize >= snMaxSize) {
                            ToastUtils.showShort(getString(R.string.transport_max_device, snMaxSize));
                            return;
                        }
                        getViewModel().checkDeviceSn(deviceType, sn, warehouseNo);
                    } else if (!TextUtils.isEmpty(transferNo)) {
                        getViewModel().receiveDevice(sn, transferNo);
                    } else if (!TextUtils.isEmpty(inventoryNo)) {
                        getViewModel().scanInventory(sn, inventoryNo);
                    } else if (intentSnList != null) {
//                        if (verify) {
//                            getViewModel().queryShipBatteryBySn(sn);
//                        } else {
                        snList.add(new ScanDeviceBean(sn, vin,""));
                        successSetResultAndFinish();
//                        }
                    }
                }
            });

            editTextBottomDialog.setOnDismissListener(dialog -> mBinding.clEnterSn.setVisibility(View.VISIBLE));
        }
        editTextBottomDialog.show();
        mBinding.clEnterSn.setVisibility(View.GONE);
    }

    @Override
    public void onPointerCaptureChanged(boolean hasCapture) {
        super.onPointerCaptureChanged(hasCapture);
    }

    @Override
    public int title() {
        return super.title();
    }
}