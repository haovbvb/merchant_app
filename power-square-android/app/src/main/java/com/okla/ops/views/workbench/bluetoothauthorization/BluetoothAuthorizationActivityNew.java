package com.okla.ops.views.workbench.bluetoothauthorization;

import android.Manifest;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothGatt;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.Gravity;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.base.mvvm.BaseNormalListVActivity;
import com.base.common.utils.ToastUtils;
import com.chad.library.adapter.base.BaseViewHolder;
import com.clj.fastble.BleManager;
import com.clj.fastble.callback.BleGattCallback;
import com.clj.fastble.callback.BleScanCallback;
import com.clj.fastble.data.BleDevice;
import com.clj.fastble.exception.BleException;
import com.clj.fastble.scan.BleScanRuleConfig;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.databinding.ActivityBluetoothAuthorizationNewBinding;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * @Date: DATE.{TIME}
 * @Author: hong_world
 * @Description:
 * @Version:
 */
public class BluetoothAuthorizationActivityNew extends BaseNormalListVActivity<BluetoothAuthorizationViewModel, ActivityBluetoothAuthorizationNewBinding> implements View.OnClickListener {
    private static final int REQUEST_CODE_OPEN_GPS = 1;
    private static final int REQUEST_CODE_OPEN_BLUETOOTH = 3;
    private static final int REQUEST_CODE_PERMISSION_LOCATION = 2;

    public static Intent getIntents(Context context) {
        Intent intent = new Intent(context, BluetoothAuthorizationActivityNew.class);
        return intent;
    }

    private ProgressDialog progressDialog;

    private SingleDataBindingNoPUseAdapter<BleDevice> mSingleDataBindingNoPUseAdapter;

    @Override
    protected int getLayoutId() {
        return R.layout.activity_bluetooth_authorization_new;
    }

    @Override
    protected BluetoothAuthorizationViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(BluetoothAuthorizationViewModel.class);
    }

    @Override
    protected RecyclerView.Adapter createAdapter() {
        mSingleDataBindingNoPUseAdapter = new SingleDataBindingNoPUseAdapter<BleDevice>(R.layout.item_bluetooth_devices) {
            @Override
            protected void convert(BaseViewHolder helper, BleDevice item) {
                super.convert(helper, item);
                helper.setText(R.id.tv_bluetooth_name, item.getName());
                helper.getView(R.id.line).setVisibility(helper.getAdapterPosition() == getData().size() - 1 ? View.GONE : View.VISIBLE);
            }
        };
        return mSingleDataBindingNoPUseAdapter;
    }

    @Override
    public int title() {
        return R.string.cabinet_opt_bluetooth_find;
    }

    @Override
    protected RecyclerView getRecyclerView() {
        return mBinding.rvBluetooth;
    }

    @Override
    protected void initPageData() {
        BleManager.getInstance().init(getApplication());
        BleManager.getInstance()
                .enableLog(true)
                .setReConnectCount(10, 10000)
            .setConnectOverTime(30000)
                .setOperateTimeout(20000);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setViewModel(viewModel);
        getStatusView().setEnableRefresh(false);
        progressDialog = new ProgressDialog(this);
        mBinding.includeTitle.topTitle.setGravity(Gravity.CENTER);
        initClicks();
        mBinding.tvBluetoothConnectableDevices.setText(getString(R.string.bluetooth_devices_not_find));

        mSingleDataBindingNoPUseAdapter.setOnItemClickListener((adapter, view, position) -> {
            BleDevice bleDevice = mSingleDataBindingNoPUseAdapter.getData().get(position);
            if (!BleManager.getInstance().isConnected(bleDevice)) {
                BleManager.getInstance().cancelScan();
                connect(bleDevice);
            } else {
                BluetoothOperateActivityNew.startBluetoothOperateActivityNew(mContext, bleDevice, null, -1);
            }

        });
        mBinding.sbBluetoothState.setCheckedImmediatelyNoEvent(BluetoothAdapter.getDefaultAdapter().isEnabled());
        mBinding.sbBluetoothState.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    int permissionCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT);
                    if (permissionCheck == PackageManager.PERMISSION_GRANTED) {
                        BleManager.getInstance().enableBluetooth();
                    }
                } else {
                    BleManager.getInstance().enableBluetooth();
                }
                mBinding.sbBluetoothState.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        onRefresh();
                        checkPermissions();
                    }
                }, 2000);
            } else {
                BleManager.getInstance().disableBluetooth();
                mSingleDataBindingNoPUseAdapter.getData().clear();
                mSingleDataBindingNoPUseAdapter.notifyDataSetChanged();
                mBinding.tvBluetoothConnectableDevices.setText(getString(R.string.bluetooth_devices_not_find));
            }
        });
        onRefresh();
        checkPermissions();
    }

    private void connect(final BleDevice bleDevice) {
        BleManager.getInstance().connect(bleDevice, new BleGattCallback() {
            @Override
            public void onStartConnect() {
                progressDialog.show();
            }

            @Override
            public void onConnectFail(BleDevice bleDevice, BleException exception) {

                progressDialog.dismiss();
                ToastUtils.showShort(getString(R.string.connect_fail));

            }

            @Override
            public void onConnectSuccess(BleDevice bleDevice, BluetoothGatt gatt, int status) {
                progressDialog.dismiss();
                String name = bleDevice.getDevice().getName();
//                if (name != null && (name.contains("HWK") || name.contains("HNT"))) {
//                    mSingleDataBindingNoPUseAdapter.addData(bleDevice);
//                }
                BluetoothOperateActivityNew.startBluetoothOperateActivityNew(mContext, bleDevice, gatt, status);

            }

            @Override
            public void onDisConnected(boolean isActiveDisConnected, BleDevice bleDevice, BluetoothGatt gatt, int status) {
                progressDialog.dismiss();

                mSingleDataBindingNoPUseAdapter.getData().clear();
                mSingleDataBindingNoPUseAdapter.notifyDataSetChanged();
                mBinding.tvBluetoothConnectableDevices.setText(getString(R.string.bluetooth_devices_not_find));
                if (isActiveDisConnected) {
                    //ToastUtils.showShort(getString(R.string.active_disconnected));
                } else {
                    //ToastUtils.showShort(getString(R.string.disconnected));
                    // ObserverManager.getInstance().notifyObserver(bleDevice);
                }

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

    @Override
    public final void onRequestPermissionsResult(int requestCode,
                                                 @NonNull String[] permissions,
                                                 @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case REQUEST_CODE_PERMISSION_LOCATION:
                if (grantResults.length > 0) {
                    boolean isReject = false;
                    for (int i = 0; i < grantResults.length; i++) {
                        if (grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                            onPermissionGranted(permissions[i]);
                        } else {
                            isReject = true;
                        }
                    }
                    if (grantResults.length > 1 && isReject) {
                        new AlertDialog.Builder(this)
                                .setTitle(R.string.notifyTitle)
                                .setMessage(R.string.nearbyNotifyMsg)
                                .setNegativeButton(R.string.cancel,
                                        new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                finish();
                                            }
                                        })
                                .setPositiveButton(R.string.setting,
                                        new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                                                Uri uri = Uri.fromParts("package", getPackageName(), null);
                                                intent.setData(uri);
                                                startActivityForResult(intent, REQUEST_CODE_OPEN_BLUETOOTH);
                                            }
                                        })

                                .setCancelable(false)
                                .show();
                    }
                }
                break;
        }
    }

    private void checkPermissions() {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!bluetoothAdapter.isEnabled()) {
            ToastUtils.showShort(getString(R.string.please_open_blue));
            return;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            checkBluetoothPermission();
        } else {
            String[] permissions = {Manifest.permission.ACCESS_FINE_LOCATION};
            List<String> permissionDeniedList = new ArrayList<>();
            for (String permission : permissions) {
                int permissionCheck = ContextCompat.checkSelfPermission(this, permission);
                if (permissionCheck == PackageManager.PERMISSION_GRANTED) {
                    onPermissionGranted(permission);
                } else {
                    permissionDeniedList.add(permission);
                }
            }
            if (!permissionDeniedList.isEmpty()) {
                String[] deniedPermissions = permissionDeniedList.toArray(new String[permissionDeniedList.size()]);
                ActivityCompat.requestPermissions(this, deniedPermissions, REQUEST_CODE_PERMISSION_LOCATION);
            }
        }
    }

    private void onPermissionGranted(String permission) {
        switch (permission) {
            case Manifest.permission.BLUETOOTH_SCAN:
            case Manifest.permission.BLUETOOTH_ADVERTISE:
            case Manifest.permission.BLUETOOTH_CONNECT:
            case Manifest.permission.ACCESS_FINE_LOCATION:
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !checkGPSIsOpen()) {
                    new AlertDialog.Builder(this)
                            .setTitle(R.string.notifyTitle)
                            .setMessage(R.string.gpsNotifyMsg)
                            .setNegativeButton(R.string.cancel,
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            finish();
                                        }
                                    })
                            .setPositiveButton(R.string.setting,
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                                            startActivityForResult(intent, REQUEST_CODE_OPEN_GPS);
                                        }
                                    })

                            .setCancelable(false)
                            .show();
                } else {
                    setScanRule();
                    startScan();
                }
                break;
        }
    }

    private boolean checkGPSIsOpen() {
        LocationManager locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
        if (locationManager == null)
            return false;
        return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_OPEN_GPS) {
            if (checkGPSIsOpen()) {
                setScanRule();
                startScan();
            }
        }
        if (requestCode == REQUEST_CODE_OPEN_BLUETOOTH) {
            checkBluetoothPermission();
        }
    }

    private void checkBluetoothPermission() {
        String[] permissions = {Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_ADVERTISE, Manifest.permission.BLUETOOTH_CONNECT};
        List<String> permissionDeniedList = new ArrayList<>();
        for (String permission : permissions) {
            int permissionCheck = ContextCompat.checkSelfPermission(this, permission);
            if (permissionCheck == PackageManager.PERMISSION_GRANTED) {
                onPermissionGranted(permission);
            } else {
                permissionDeniedList.add(permission);
            }
        }
        if (!permissionDeniedList.isEmpty()) {
            String[] deniedPermissions = permissionDeniedList.toArray(new String[permissionDeniedList.size()]);
            ActivityCompat.requestPermissions(this, deniedPermissions, REQUEST_CODE_PERMISSION_LOCATION);
        }
    }

    private void setScanRule() {
//        String[] uuids = null;
//        String str_uuid = null;

        UUID[] serviceUuids = null;
//        if (uuids != null && uuids.length > 0) {
//            serviceUuids = new UUID[uuids.length];
//            for (int i = 0; i < uuids.length; i++) {
//                String name = uuids[i];
//                String[] components = name.split("-");
//                if (components.length != 5) {
//                    serviceUuids[i] = null;
//                } else {
//                    serviceUuids[i] = UUID.fromString(uuids[i]);
//                }
//            }
//        }

        String[] names = null;


        String mac = "";

        boolean isAutoConnect = false;

        BleScanRuleConfig scanRuleConfig = new BleScanRuleConfig.Builder()
                //.setServiceUuids(serviceUuids)      // 只扫描指定的服务的设备，可选
                // .setDeviceName(true, names)   // 只扫描指定广播名的设备，可选
                // .setDeviceMac(mac)                  // 只扫描指定mac的设备，可选
                //  .setAutoConnect(isAutoConnect)      // 连接时的autoConnect参数，可选，默认false
                .setScanTimeOut(10000)              // 扫描超时时间，可选，默认10秒
                .build();
        BleManager.getInstance().initScanRule(scanRuleConfig);
    }

    private void startScan() {
        BleManager.getInstance().scan(new BleScanCallback() {
            @Override
            public void onScanStarted(boolean success) {
                Log.d("startScan", "startScan:" + success);
            }

            @Override
            public void onLeScan(BleDevice bleDevice) {
                super.onLeScan(bleDevice);
                Log.d("startScan", "onLeScan:" + bleDevice);
            }

            @Override
            public void onScanning(BleDevice bleDevice) {
                String name = bleDevice.getDevice().getName();
                if (name != null && (name.contains("HWK") || name.contains("HNT"))) {
                    mSingleDataBindingNoPUseAdapter.addData(bleDevice);
                    mBinding.tvBluetoothConnectableDevices.setText(getString(R.string.bluetooth_authorization_connectable_devices_desc));
                }
                Log.d("startScan", "onScanning:====name = " + name);
            }

            @Override
            public void onScanFinished(List<BleDevice> scanResultList) {
                Log.d("startScan", "onScanFinished:====" + scanResultList);
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        BleManager.getInstance().disconnectAllDevice();
        BleManager.getInstance().destroy();
    }
}