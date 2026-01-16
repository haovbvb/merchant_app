package com.okla.ops.utils;

import android.Manifest;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.utils.Crc16Utils;
import com.base.common.utils.MD5Util;
import com.clj.fastble.BleManager;
import com.clj.fastble.callback.BleGattCallback;
import com.clj.fastble.callback.BleNotifyCallback;
import com.clj.fastble.callback.BleScanCallback;
import com.clj.fastble.callback.BleWriteCallback;
import com.clj.fastble.data.BleDevice;
import com.clj.fastble.exception.BleException;
import com.clj.fastble.scan.BleScanRuleConfig;
import com.clj.fastble.utils.HexUtil;
import com.orhanobut.logger.Logger;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

public class BluetoothBleUtil {

    private BluetoothBleUtil() {
    }

    private static class Holder {
        private static final BluetoothBleUtil INSTANCE = new BluetoothBleUtil();
    }

    public static BluetoothBleUtil getInstance() {
        return Holder.INSTANCE;
    }

    private Context mContext;

    public void init(Context context) {
        mContext = context;
    }

    public void destroy() {
        mContext = null;
        dataCallbacks.clear();
        mBluetoothBleCallback = null;
        bluetoothHandler.removeCallbacksAndMessages(null);
        BleManager.getInstance().disconnectAllDevice();
        BleManager.getInstance().destroy();
    }

    private boolean mStartScan;
    private String mDeviceSn;

    public boolean isEnableBluetooth() {
        return BleManager.getInstance().isBlueEnable();
    }

    public boolean isConnected() {
        return BleManager.getInstance().isConnected(mBleDevice);
    }

    public void disconnect() {
        BleManager.getInstance().disconnect(mBleDevice);
    }

    public void askBluetoothPermission(String deviceSn) {
        if (TextUtils.isEmpty(deviceSn)) return;
        this.mDeviceSn = deviceSn;
        BluetoothAdapter defaultAdapter = BluetoothAdapter.getDefaultAdapter();
        if (defaultAdapter == null) return;
        if (!defaultAdapter.isEnabled()) {
            return;
        }
        String[] strings = getPermissions().toArray(new String[0]);
        PermissionManager.checkPermission((FragmentActivity) mContext, permissionListener, strings);
    }

    @NonNull
    private static List<String> getPermissions() {
        List<String> permissions = new ArrayList<>();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions.add(Manifest.permission.BLUETOOTH_SCAN);
            permissions.add(Manifest.permission.BLUETOOTH_ADVERTISE);
            permissions.add(Manifest.permission.BLUETOOTH_CONNECT);
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION);
        } else {
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION);
            permissions.add(Manifest.permission.BLUETOOTH);
            permissions.add(Manifest.permission.BLUETOOTH_ADMIN);
        }
        return permissions;
    }

    private final PermissionListenerImpl permissionListener = new PermissionListenerImpl() {
        @Override
        public void passPermission() {
            super.passPermission();
            BleManager.getInstance().enableBluetooth();
            startScan();
        }

        @Override
        public void showRequestPermissionRationale() {
            super.showRequestPermissionRationale();
            PermissionManager.askForPermission((Activity) mContext, "");
        }
    };

    private synchronized void startScan() {
        if (mStartScan) return;
        mStartScan = true;
        if (mBluetoothBleCallback != null) mBluetoothBleCallback.onScanning();
        BleManager.getInstance().enableBluetooth();
        BleScanRuleConfig scanRuleConfig = new BleScanRuleConfig.Builder()
                //.setServiceUuids(serviceUuids)      // 只扫描指定的服务的设备，可选
                .setDeviceName(true, mDeviceSn)   // 只扫描指定广播名的设备，可选
                // .setDeviceMac(mac)                  // 只扫描指定mac的设备，可选
                //  .setAutoConnect(isAutoConnect)      // 连接时的autoConnect参数，可选，默认false
                .setScanTimeOut(60000)              // 扫描超时时间，可选，默认10秒
                .build();
        BleManager.getInstance().initScanRule(scanRuleConfig);
        BleManager.getInstance().scan(new BleScanCallback() {
            @Override
            public void onScanStarted(boolean success) {
                if (!success) {
                    if (mBluetoothBleCallback != null)
                        mBluetoothBleCallback.onDisconnect("scan failed!");
                }
            }

            @Override
            public void onLeScan(BleDevice bleDevice) {
                super.onLeScan(bleDevice);
                if (TextUtils.equals(mDeviceSn, bleDevice.getName())) {
                    BleManager.getInstance().cancelScan();
                }
            }

            @Override
            public void onScanning(BleDevice bleDevice) {
                if (TextUtils.equals(mDeviceSn, bleDevice.getName())) {
                    BleManager.getInstance().cancelScan();
                }
            }

            @Override
            public void onScanFinished(List<BleDevice> scanResultList) {
                mStartScan = false;
                BleDevice tempBleDevice = null;
                if (scanResultList != null) {
                    for (BleDevice bleDevice : scanResultList) {
                        if (TextUtils.equals(mDeviceSn, bleDevice.getName())) {
                            tempBleDevice = bleDevice;
                            break;
                        }
                    }
                }
                if (tempBleDevice != null) {
                    BleManager.getInstance().connect(tempBleDevice, bleGattCallback);
                } else {
                    if (mBluetoothBleCallback != null) mBluetoothBleCallback.onScanTimeout();
                }
            }
        });
    }

    private final BleGattCallback bleGattCallback = new BleGattCallback() {
        @Override
        public void onStartConnect() {
            if (mBluetoothBleCallback != null) mBluetoothBleCallback.onConnecting();
        }

        @Override
        public void onConnectFail(BleDevice bleDevice, BleException exception) {
            if (mBluetoothBleCallback != null)
                mBluetoothBleCallback.onDisconnect(exception.toString());
        }

        @Override
        public void onConnectSuccess(BleDevice bleDevice, BluetoothGatt gatt, int status) {
            if (mBluetoothBleCallback != null) mBluetoothBleCallback.onConnected();
            connectSuccess(bleDevice);
        }

        @Override
        public void onDisConnected(boolean isActiveDisConnected, BleDevice device, BluetoothGatt gatt, int status) {
            Log.d("BleManager", "disconnected status: " + status + ",isActiveDisConnected: " + isActiveDisConnected);
            if (mBluetoothBleCallback != null)
                mBluetoothBleCallback.onDisconnect("disconnected status: " + status);
            for (BluetoothBleDataCallback callback : dataCallbacks) {
                callback.onDisconnect();
            }
        }
    };

    public interface BluetoothBleCallback {

        void onScanning();

        void onScanTimeout();

        void onConnecting();

        void onConnected();

        void onDisconnect(String msg);

        void onReadFailure(String msg);

        void onWriteFailure(String msg);

    }

    private BluetoothBleCallback mBluetoothBleCallback;

    public void setBluetoothBleCallback(BluetoothBleCallback bluetoothBleCallback) {
        mBluetoothBleCallback = bluetoothBleCallback;
    }

    public interface BluetoothBleDataCallback {

        void onAuthorization();

        void onReceiveData(String data);

        void onDisconnect();

    }

    private final List<BluetoothBleDataCallback> dataCallbacks = new ArrayList<>();

    public void addDataCallback(BluetoothBleDataCallback callback) {
        dataCallbacks.add(callback);
    }

    public void removeDataCallback(BluetoothBleDataCallback callback) {
        dataCallbacks.remove(callback);
    }

    private BleDevice mBleDevice;
    private String mServiceUuid;
    private static final String READ_UUID = "0000ffe4-0000-1000-8000-00805f9b34fb";
    private static final String WRITE_UUID = "0000ffe9-0000-1000-8000-00805f9b34fb";
    private String mSecretKey;
    public static final String key_authorization = "E9?t>MM21G7K2HWVM6FNgr81HI90XK=s==";
    public static final String key_data = "AG;B:;I`Mu3yNv3DIdB|C@4?D75>4Y9A==";

    public void setSecretKey(String secretKey) {
        mSecretKey = secretKey;
    }

    private void connectSuccess(BleDevice bleDevice) {
        mBleDevice = bleDevice;
        mServiceUuid = "";
        List<BluetoothGattService> bluetoothGattServices = BleManager.getInstance().getBluetoothGattServices(bleDevice);
        if (bluetoothGattServices != null) {
            for (BluetoothGattService service : bluetoothGattServices) {
                List<BluetoothGattCharacteristic> bluetoothGattCharacteristics = BleManager.getInstance().getBluetoothGattCharacteristics(service);
                for (BluetoothGattCharacteristic bluetoothGattCharacteristic : bluetoothGattCharacteristics) {
                    String serviceUUID = bluetoothGattCharacteristic.getService().getUuid().toString();
                    // 盾创UUID服务：0x8910
                    if (serviceUUID.contains("8910")) {
                        mServiceUuid = serviceUUID;
                        break;
                    }
                }
                if (!TextUtils.isEmpty(mServiceUuid)) {
                    break;
                }
            }
        }
        if (TextUtils.isEmpty(mServiceUuid)) {
            if (mBluetoothBleCallback != null)
                mBluetoothBleCallback.onReadFailure("serviceUUID is null");
        } else {
            BleManager.getInstance().notify(bleDevice, mServiceUuid, READ_UUID, new BleNotifyCallback() {
                @Override
                public void onNotifySuccess() {
                    sendAuthorizationData();
                }

                @Override
                public void onNotifyFailure(BleException exception) {
                    if (mBluetoothBleCallback != null)
                        mBluetoothBleCallback.onReadFailure(exception.toString());
                }

                @Override
                public void onCharacteristicChanged(byte[] data) {
                    decodePackage(data);
                }
            });
        }
    }

    private void sendAuthorizationData() {
        BleManager.getInstance().write(mBleDevice, mServiceUuid, WRITE_UUID, buildAuthorizationPackage(), new BleWriteCallback() {
            @Override
            public void onWriteSuccess(int current, int total, byte[] justWrite) {
                Log.d("BleManager", "onWriteSuccess:" + "write success, current 执行指令: " + current
                        + " total: " + total
                        + " justWrite: " + HexUtil.formatHexString(justWrite, false));
            }

            @Override
            public void onWriteFailure(BleException exception) {
                if (mBluetoothBleCallback != null)
                    mBluetoothBleCallback.onWriteFailure(exception.toString());
            }
        });
    }

    private byte[] buildAuthorizationPackage() {
        byte[] head = new byte[2];
        head[0] = (byte) (0xbb & 0xff);
        head[1] = 0x66;
        byte[] command = new byte[1];
        command[0] = 0x01;
        String time = String.valueOf(System.currentTimeMillis());
        String authorizationData = time + MD5Util.encrypt2(mDeviceSn + key_authorization + time);
        byte[] data = authorizationData.getBytes();
        byte[] length = intTo2Bytes(data.length);
        byte[] crcParam = new byte[head.length + command.length + length.length + data.length];
        System.arraycopy(head, 0, crcParam, 0, head.length);
        System.arraycopy(command, 0, crcParam, head.length, command.length);
        System.arraycopy(length, 0, crcParam, head.length + command.length, length.length);
        System.arraycopy(data, 0, crcParam, head.length + command.length + length.length, data.length);
        char crc = Crc16Utils.calculateCRC16(crcParam);
        byte[] crc16 = charToBytes(crc);
        byte[] authorizationPackage = new byte[crcParam.length + crc16.length];
        System.arraycopy(crcParam, 0, authorizationPackage, 0, crcParam.length);
        System.arraycopy(crc16, 0, authorizationPackage, crcParam.length, crc16.length);
        return authorizationPackage;
    }

    private final Handler bluetoothHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(@NonNull android.os.Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case 1:
                    sendData(queue.poll());
                    break;
            }
        }
    };

    private final Queue<String> queue = new LinkedList<>();

    public void addDataToQueue(String jsonData) {
        if (isSending) {
            queue.offer(jsonData);
        } else {
            sendData(jsonData);
        }
    }

    private boolean isSending = false;

    private void sendData(String jsonData) {
        Log.d("BleManager", "send jsonData:" + jsonData);
        isSending = true;
        if (BleManager.getInstance().isConnected(mBleDevice)) {
            BleManager.getInstance().write(mBleDevice, mServiceUuid, WRITE_UUID, buildDataPackage(jsonData), new BleWriteCallback() {
                @Override
                public void onWriteSuccess(int current, int total, byte[] justWrite) {
                    Log.d("BleManager", "onWriteSuccess:" + "write success, current 执行指令: " + current
                            + " total: " + total
                            + " justWrite: " + HexUtil.formatHexString(justWrite, false));
                    if (current == total) {
                        if (!queue.isEmpty()) {
                            bluetoothHandler.sendEmptyMessageDelayed(1, 5000);
                        } else {
                            isSending = false;
                            Log.d("BleManager", "发送队列为空");
                        }
                    }
                }

                @Override
                public void onWriteFailure(BleException exception) {
                    isSending = false;
                    queue.clear();
                    if (mBluetoothBleCallback != null)
                        mBluetoothBleCallback.onWriteFailure(exception.toString());
                }
            });
        } else {
            isSending = false;
            queue.clear();
        }
    }

    private byte[] buildDataPackage(String jsonData) {
        byte[] head = new byte[2];
        head[0] = (byte) (0xbb & 0xff);
        head[1] = 0x66;
        byte[] command = new byte[1];
        command[0] = 0x03;
        String md5 = MD5Util.encrypt2(jsonData + key_data + mSecretKey);
        byte[] data = jsonData.getBytes();
        byte[] md5Bytes = md5.getBytes();
        byte[] totalData = new byte[data.length + md5Bytes.length];
        byte[] length = intTo2Bytes(totalData.length);
        System.arraycopy(data, 0, totalData, 0, data.length);
        System.arraycopy(md5Bytes, 0, totalData, data.length, md5Bytes.length);
        byte[] crcParam = new byte[head.length + command.length + length.length + totalData.length];
        System.arraycopy(head, 0, crcParam, 0, head.length);
        System.arraycopy(command, 0, crcParam, head.length, command.length);
        System.arraycopy(length, 0, crcParam, head.length + command.length, length.length);
        System.arraycopy(totalData, 0, crcParam, head.length + command.length + length.length, totalData.length);
        char crc = Crc16Utils.calculateCRC16(crcParam);
        byte[] crc16 = charToBytes(crc);
        byte[] dataPackage = new byte[crcParam.length + crc16.length];
        System.arraycopy(crcParam, 0, dataPackage, 0, crcParam.length);
        System.arraycopy(crc16, 0, dataPackage, crcParam.length, crc16.length);
        return dataPackage;
    }

    private byte[] intTo2Bytes(int value) {
        byte[] result = new byte[2];
        // 高位字节在前
        result[0] = (byte) ((value >> 8) & 0xFF); // 取高位
        result[1] = (byte) (value & 0xFF);        // 取低位
        return result;
    }

    private byte[] charToBytes(char ch) {
        byte[] result = new byte[2];
        result[0] = (byte) ((ch >> 8) & 0xFF); // 高位字节
        result[1] = (byte) (ch & 0xFF);        // 低位字节
        return result;
    }

    private boolean existPackageHead(byte[] data) {
        if (data.length < 2) return false;
        return (data[0] & 0xFF) == 0xBB && (data[1] & 0xFF) == 0x66;
    }

    private byte[] mMultiPackage;
    private int mMultiIndex;

    private void decodePackage(byte[] data) {
        if (existPackageHead(data)) {
            if (data.length < 3) return;
            int command = data[2] & 0xFF;
            if (data.length < 5) return;
            int dataLen = (data[3] & 0xFF) << 8 | (data[4] & 0xFF);//长度
            if (data.length > dataLen) {//判断是否需要分包
                byte[] content = new byte[dataLen];
                System.arraycopy(data, 5, content, 0, dataLen);
                if (command == 0x02) {//鉴权结果
                    int result = content[0] & 0xFF;
                    if (result == 1) {//成功
                        for (BluetoothBleDataCallback callback : dataCallbacks) {
                            callback.onAuthorization();
                        }
                    } else if (result == 2) {//超时失败
                        if (mBluetoothBleCallback != null)
                            mBluetoothBleCallback.onDisconnect("鉴权失败");
                    } else {//未知状态
                        if (mBluetoothBleCallback != null)
                            mBluetoothBleCallback.onDisconnect("鉴权异常： " + command);
                    }
                }
                if (command == 0x03) {//交互数据
                    String result = new String(content, StandardCharsets.UTF_8);
                    if (result.length() < 32) return;
                    String json = result.substring(0, result.length() - 32);
//                    Logger.d("json: " + json);
                    Log.d("BleManager", "receive json:" + json);
                    filterData(json);
                }
            } else {//分包
                if (command == 0x03) {//交互数据
                    mMultiPackage = new byte[dataLen + 7];
                    System.arraycopy(data, 0, mMultiPackage, 0, data.length);
                    mMultiIndex = data.length;
                }
            }
        } else {//分包
            if (mMultiIndex == 0) return;
            System.arraycopy(data, 0, mMultiPackage, mMultiIndex, data.length);
            mMultiIndex += data.length;
            if (mMultiIndex == mMultiPackage.length) {
                mMultiIndex = 0;
                int dataLen = (mMultiPackage[3] & 0xFF) << 8 | (mMultiPackage[4] & 0xFF);//长度
                byte[] content = new byte[dataLen];
                System.arraycopy(mMultiPackage, 5, content, 0, dataLen);
                String result = new String(content, StandardCharsets.UTF_8);
                if (result.length() < 32) return;
                String json = result.substring(0, result.length() - 32);
//                Logger.d("receive json: " + json);
                Log.d("BleManager", "receive json:" + json);
                filterData(json);
            }
        }
    }

    private void filterData(String data) {
        for (BluetoothBleDataCallback callback : dataCallbacks) {
            callback.onReceiveData(data);
        }
        /*StationDataBean stationDataBean = GsonUtils.fromGson(data, StationDataBean.class);
        if (stationDataBean != null && stationDataBean.getMsgType() != null) {
            //现阶段不需要上传至服务器
            if (stationDataBean.getMsgType() == 310) {
                Message obtain = Message.obtain();
                obtain.what = IBluetoothSwap.SEND_DATA_TO_SERVER_OTHER;
                obtain.obj = data;
                bluetoothHandler.sendMessage(obtain);
            } else {
                List<AlarmBean> alarmList = stationDataBean.getAlarmList();
                String userId = stationDataBean.getUserId();
                if (alarmList != null && !alarmList.isEmpty()) {
                    AlarmBean alarmBean = alarmList.get(0);
                    if (TextUtils.equals(alarmBean.getUserId(), String.valueOf(bluetoothRentId))) {
                        Message obtain = Message.obtain();
                        obtain.what = IBluetoothSwap.SEND_DATA_TO_SERVER;
                        obtain.obj = data;
                        bluetoothHandler.sendMessage(obtain);
                    }
                } else if (!TextUtils.isEmpty(userId) && TextUtils.equals(userId, String.valueOf(bluetoothRentId))) {
                    Message obtain = Message.obtain();
                    obtain.what = IBluetoothSwap.SEND_DATA_TO_SERVER;
                    obtain.obj = data;
                    bluetoothHandler.sendMessage(obtain);
                }
            }
        }*/
    }

}
