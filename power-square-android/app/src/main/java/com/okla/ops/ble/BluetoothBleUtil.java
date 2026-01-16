package com.okla.ops.ble;

import android.Manifest;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;
import java.util.UUID;

public class BluetoothBleUtil {

    private static final String TAG = "BluetoothBleUtil";

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
        mHandlerThread = new HandlerThread("ble-thread");
        mHandlerThread.start();
        mDelayHandler = new Handler(mHandlerThread.getLooper());
    }

    public void destroy() {
        if (bluetoothGatt != null) {
            bluetoothGatt.disconnect();
            bluetoothGatt.close();
            bluetoothGatt = null;
        }
        mContext = null;
        mBluetoothBleCallback = null;
        bluetoothHandler.removeCallbacksAndMessages(null);
        if (mDelayHandler != null) {
            mDelayHandler.removeCallbacksAndMessages(null);
            mDelayHandler = null;
        }
        if (mHandlerThread != null) {
            mHandlerThread.quitSafely();
            mHandlerThread = null;
        }
//        BleManager.getInstance().disconnectAllDevice();
//        BleManager.getInstance().destroy();
    }

    public void askBluetoothPermission(String vehicleCtrlId) {
        if (TextUtils.isEmpty(vehicleCtrlId)) return;
        this.mVehicleCtrlId = vehicleCtrlId;
        Log.e(TAG, "开始连接");
        BluetoothAdapter defaultAdapter = BluetoothAdapter.getDefaultAdapter();
        if (defaultAdapter == null) return;
        if (!defaultAdapter.isEnabled()) {
            return;
        }
        Log.e(TAG, "开始检查权限");
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
            Log.d(TAG, "权限通过");
            initAdapter();
            startScan();
        }

        @Override
        public void showRequestPermissionRationale() {
            super.showRequestPermissionRationale();
            Log.d(TAG, "权限不通过");
            PermissionManager.askForPermission((Activity) mContext, "");
        }
    };

    private HandlerThread mHandlerThread;
    private BluetoothAdapter bluetoothAdapter;

    private void initAdapter() {
        // 检查设备是否支持 BLE
        if (bluetoothAdapter == null)
            bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            Log.e(TAG, "Bluetooth is not enabled");
        }
    }

    private String mVehicleCtrlId;

    public boolean isConnected() {
        return isConnected;
    }

    public void disconnect() {
        if (bluetoothGatt != null) {
            Log.d(TAG, "disconnect!");
            isConnected = false;
            bluetoothGatt.disconnect();
            bluetoothGatt.close();
            bluetoothGatt = null;
        }
    }

    private static final int BLUETOOTH_CONNECT = 1;
    private static final int BLUETOOTH_DISCONNECT = 2;
    private static final int BLUETOOTH_CONNECTED = 3;
    private static final int BLUETOOTH_SERVICES_DISCOVER = 4;
    private static final int BLUETOOTH_STOP_DISCOVER = 5;
    private static final int BLUETOOTH_SEND_DATA = 6;
    private static final int BLUETOOTH_RECEIVE_DATA = 7;
    private static final int BLUETOOTH_READ_FAILURE = 8;
    private static final int BLUETOOTH_WRITE_FAILURE = 9;
    private static final int BLUETOOTH_WRITE_SUCCESS = 10;
    private static final int BLUETOOTH_SET_MTU_TIMEOUT = 11;


    private final Handler bluetoothHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case BLUETOOTH_DISCONNECT:
                    disconnectFromDevice();
                    break;
                case BLUETOOTH_SERVICES_DISCOVER:
                    discoverServices();
                    break;
                case BLUETOOTH_STOP_DISCOVER:
                    stopScan(msg.obj != null ? (String) msg.obj : "");
                    break;
                case BLUETOOTH_CONNECT:
                    connectToDevice((BluetoothDevice) msg.obj);
                    break;
                case BLUETOOTH_CONNECTED:
                    connected();
                    break;
                case BLUETOOTH_SEND_DATA:
                    writeCharacteristic((String) msg.obj);
                    break;
                case BLUETOOTH_RECEIVE_DATA:
                    receiveData((String) msg.obj);
                    break;
                case BLUETOOTH_WRITE_FAILURE:
                    writeDataFailure((String) msg.obj);
                    break;
                case BLUETOOTH_READ_FAILURE:
                    readDataFailure((String) msg.obj);
                    break;
                case BLUETOOTH_WRITE_SUCCESS:
                    writeDateSuccess((String) msg.obj);
                    break;
                case BLUETOOTH_SET_MTU_TIMEOUT:
                    discoveredGatt();
                    break;
            }
        }
    };

    private final ScanCallback scanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            super.onScanResult(callbackType, result);
            BluetoothDevice device = result.getDevice();
            Log.e(TAG, "device name: " + device.getName());
            if (mVehicleCtrlId.equals(device.getName())) {
                bluetoothHandler.removeMessages(BLUETOOTH_STOP_DISCOVER);
                bluetoothHandler.sendEmptyMessage(BLUETOOTH_STOP_DISCOVER);
                Message obtain = Message.obtain();
                obtain.what = BLUETOOTH_CONNECT;
                obtain.obj = device;
                bluetoothHandler.sendMessageDelayed(obtain, 1000);
            }
        }
    };

    private Handler mDelayHandler;

    private boolean isScanning = false;
    private long mLastScanStartTime = 0;

    private synchronized void startScan() {
        Log.d(TAG, "isScanning: " + isScanning);
        if (!isScanning) {
            isScanning = true;
            if (mDelayHandler != null) {
                mDelayHandler.removeCallbacksAndMessages(null);
            }
            if (mBluetoothBleCallback != null) {
                mBluetoothBleCallback.onScanning();
            }
            long scanDelay = 0;
            long scanSpacing = 5 * 1000;
            long currentTime = System.currentTimeMillis();
            if (currentTime - mLastScanStartTime < scanSpacing) {
                scanDelay = scanSpacing - (currentTime - mLastScanStartTime);
                if (scanDelay > scanSpacing) scanDelay = scanSpacing;
            }
            mLastScanStartTime = currentTime;
            startScanningTask(scanDelay);
        }
    }

    private void startScanningTask(long delay) {
        if (mDelayHandler != null) {
            mDelayHandler.removeCallbacks(scanningStartTask);
            mDelayHandler.postDelayed(scanningStartTask, delay);
        }
    }

    private BluetoothLeScanner bluetoothLeScanner;
    private final Runnable scanningStartTask = new Runnable() {
        @Override
        public void run() {
            ScanSettings scanSettings = getScanSettings();
            List<ScanFilter> scanFilters = new ArrayList<>();
            ScanFilter.Builder scanFilterBuilder = new ScanFilter.Builder();
            scanFilterBuilder.setDeviceName(mVehicleCtrlId);
            scanFilters.add(scanFilterBuilder.build());
            bluetoothLeScanner = bluetoothAdapter.getBluetoothLeScanner();
            bluetoothLeScanner.startScan(scanFilters, scanSettings, scanCallback);
            // 停止扫描任务 (30秒后停止)
            Message message = Message.obtain();
            message.what = BLUETOOTH_STOP_DISCOVER;
            message.obj = "scan time out";
            bluetoothHandler.sendMessageDelayed(message, 30 * 1000);
        }
    };

    private static ScanSettings getScanSettings() {
        ScanSettings.Builder builder = new ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .setReportDelay(0);
        if (Build.VERSION.SDK_INT >= 23) {
            builder.setCallbackType(ScanSettings.CALLBACK_TYPE_ALL_MATCHES);
            builder.setMatchMode(ScanSettings.MATCH_MODE_AGGRESSIVE);
            builder.setNumOfMatches(ScanSettings.MATCH_NUM_MAX_ADVERTISEMENT);
        }
        if (Build.VERSION.SDK_INT >= 26) {
            builder.setLegacy(true);
            builder.setPhy(ScanSettings.PHY_LE_ALL_SUPPORTED);
        }
        return builder.build();
    }

    public void stopScan(String msg) {
        isScanning = false;
        Log.d(TAG, "stopScan");
        bluetoothHandler.removeMessages(BLUETOOTH_STOP_DISCOVER);
        if (mDelayHandler != null) {
            mDelayHandler.removeCallbacks(scanningStartTask);
        }
        if (bluetoothLeScanner != null) {
            bluetoothLeScanner.stopScan(scanCallback);
        }
        if (!TextUtils.isEmpty(msg) && mBluetoothBleCallback != null) {
            mBluetoothBleCallback.onScanTimeout();
        }
    }

    private BluetoothGatt bluetoothGatt;
    private boolean isConnected;

    private void connectToDevice(BluetoothDevice device) {
        if (mBluetoothBleCallback != null) {
            mBluetoothBleCallback.onConnecting();
        }
        isConnected = false;
        bluetoothGatt = device.connectGatt(mContext, false, gattCallback);
    }

    private void connected() {
        isConnected = true;
        if (mBluetoothBleCallback != null) {
            mBluetoothBleCallback.onConnected();
        }
        for (BluetoothBleStateCallback callback : stateCallbacks) {
            callback.onConnected();
        }
    }

    private void disconnectFromDevice() {
        isConnected = false;
        if (mBluetoothBleCallback != null)
            mBluetoothBleCallback.onDisconnect("");
        for (BluetoothBleStateCallback callback : stateCallbacks) {
            callback.onDisconnect();
        }
    }

    private void discoverServices() {
        if (mBluetoothBleCallback != null)
            mBluetoothBleCallback.onDiscoverServices();
    }

    private static final UUID SERVICE_UUID = UUID.fromString("00001802-0000-1000-8000-00805f9b34fb"); // 示例服务 UUID
    private static final UUID READ_CHARACTERISTIC_UUID = UUID.fromString("00002a06-0000-1000-8000-00805f9b34fb"); // 示例特征 UUID
    private static final UUID WRITE_CHARACTERISTIC_UUID = UUID.fromString("00002a06-0000-1000-8000-00805f9b34fb"); // 示例特征 UUID

    private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {

        @Override
        public void onMtuChanged(BluetoothGatt gatt, int mtu, int status) {
            super.onMtuChanged(gatt, mtu, status);
            bluetoothHandler.removeMessages(BLUETOOTH_SET_MTU_TIMEOUT);
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "MTU 已更改: " + mtu);
            } else {
                Log.e(TAG, "MTU 更改失败，状态: " + status);
            }
            discoveredGatt();
        }

        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            super.onConnectionStateChange(gatt, status, newState);
            if (newState == BluetoothGatt.STATE_CONNECTED) {
                Log.d(TAG, "Connected to GATT server. Discovering services...");
                bluetoothHandler.sendEmptyMessage(BLUETOOTH_CONNECTED);
                boolean b = bluetoothGatt.requestMtu(512);
                Log.d(TAG, "request mtu: " + b);
                bluetoothHandler.sendEmptyMessageDelayed(BLUETOOTH_SET_MTU_TIMEOUT, 5 * 1000);
            } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
                Log.d(TAG, "Disconnected from GATT server.");
                if (!TextUtils.isEmpty(mVehicleCtrlId) && TextUtils.equals(gatt.getDevice().getName(), mVehicleCtrlId)) {
                    bluetoothHandler.sendEmptyMessage(BLUETOOTH_DISCONNECT);
                }
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            super.onServicesDiscovered(gatt, status);
            if (status == BluetoothGatt.GATT_SUCCESS) {
                List<BluetoothGattService> services = gatt.getServices();
                Log.e(TAG, "services : " + services);
                if (services != null && !services.isEmpty()) {
                    for (BluetoothGattService service : services) {
                        Log.e(TAG, "service uuid : " + service.getUuid().toString());
                        List<BluetoothGattCharacteristic> characteristics = service.getCharacteristics();
                        Log.e(TAG, "characteristics : " + characteristics);
                        for (BluetoothGattCharacteristic characteristic : characteristics) {
                            Log.e(TAG, "characteristic uuid : " + characteristic.getUuid().toString());
                        }
                    }
                }
                BluetoothGattService service = gatt.getService(SERVICE_UUID);
                if (service != null) {
                    BluetoothGattCharacteristic notifyCharacteristic = service.getCharacteristic(READ_CHARACTERISTIC_UUID);
                    Log.e(TAG, "notifyCharacteristic : " + notifyCharacteristic);
                    if (notifyCharacteristic != null) {
                        boolean b = gatt.setCharacteristicNotification(notifyCharacteristic, true);// 启用通知
                        Log.e(TAG, "b : " + b);
                        if (b) {
                            List<BluetoothGattDescriptor> descriptors = notifyCharacteristic.getDescriptors();
                            Log.e(TAG, "descriptors : " + descriptors);
                            bluetoothHandler.sendEmptyMessage(BLUETOOTH_SERVICES_DISCOVER);
                        } else {
                            Message message = Message.obtain();
                            message.what = BLUETOOTH_READ_FAILURE;
                            message.obj = "set notification failure";
                            bluetoothHandler.sendMessage(message);
                        }
                    }
                }
            }
        }

        @Override
        public void onCharacteristicChanged(@NonNull BluetoothGatt gatt, @NonNull BluetoothGattCharacteristic characteristic, @NonNull byte[] value) {
            super.onCharacteristicChanged(gatt, characteristic, value);
            Log.d(TAG, "onCharacteristicChanged value len: " + value.length);
            Log.d(TAG, "onCharacteristicChanged uuid: " + characteristic.getUuid());
            if (READ_CHARACTERISTIC_UUID.equals(characteristic.getUuid())) {
                byte[] value1 = characteristic.getValue();
                try {
                    String data = new String(value1);
                    Message message = Message.obtain();
                    message.what = BLUETOOTH_RECEIVE_DATA;
                    message.obj = data;
                    bluetoothHandler.sendMessage(message);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            super.onCharacteristicRead(gatt, characteristic, status);
            if (status == BluetoothGatt.GATT_SUCCESS) {
                String value = new String(characteristic.getValue());
                Log.d(TAG, "Characteristic read: " + value);
            } else {
                Log.d(TAG, "Characteristic read failure!status: " + status);
            }
        }

        @Override
        public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            super.onCharacteristicWrite(gatt, characteristic, status);
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "Characteristic written successfully");
                if (!queue.isEmpty()) {
                    Message message = Message.obtain();
                    message.what = BLUETOOTH_SEND_DATA;
                    message.obj = queue.poll();
                    bluetoothHandler.sendMessageDelayed(message, 1000);
                } else {
                    isSending = false;
                }
                String value = new String(characteristic.getValue());
                Message message = Message.obtain();
                message.what = BLUETOOTH_WRITE_SUCCESS;
                message.obj = value;
                bluetoothHandler.sendMessage(message);
            } else {
                Log.d(TAG, "Characteristic written failure!status: " + status);
                Message message = Message.obtain();
                message.what = BLUETOOTH_WRITE_FAILURE;
                message.obj = "Characteristic written failure!status: " + status;
                bluetoothHandler.sendMessage(message);
            }
        }
    };

    private void discoveredGatt() {
        if (bluetoothGatt != null) {
            boolean b1 = bluetoothGatt.discoverServices();
            Log.d(TAG, "discoverServices: " + b1);
        }
    }

    private boolean isSending = false;
    private final Queue<String> queue = new LinkedList<>();

    public void addDataToQueue(String jsonData) {
        if (isSending) {
            queue.offer(jsonData);
        } else {
            writeCharacteristic(jsonData);
        }
    }

    private void writeCharacteristic(String jsonData) {
        if (bluetoothGatt != null) {
            BluetoothGattService service = bluetoothGatt.getService(SERVICE_UUID);
            if (service != null) {
                BluetoothGattCharacteristic writeCharacteristic = service.getCharacteristic(WRITE_CHARACTERISTIC_UUID);
                if (writeCharacteristic != null) {
                    writeCharacteristic.setValue(jsonData.getBytes());
                    Log.d(TAG, "Writing characteristic...: " + jsonData);
                    isSending = bluetoothGatt.writeCharacteristic(writeCharacteristic);
                    Log.d(TAG, "Services writeCharacteristic: " + isSending);
                } else {
                    isSending = false;
                    queue.clear();
                    Log.e(TAG, "Write Characteristic not found.");
                    Message message = Message.obtain();
                    message.what = BLUETOOTH_WRITE_FAILURE;
                    message.obj = "Write Characteristic not found.";
                    bluetoothHandler.sendMessage(message);
                }
            } else {
                Message message = Message.obtain();
                message.what = BLUETOOTH_WRITE_FAILURE;
                message.obj = "BluetoothGattService not found.";
                bluetoothHandler.sendMessage(message);
            }
        }
    }

    private void receiveData(String data) {
        Log.d(TAG, "result:" + data);
        if (mBluetoothBleCallback != null)
            mBluetoothBleCallback.onReceiveData(data);
    }

    private void writeDateSuccess(String data) {
        if (mBluetoothBleCallback != null)
            mBluetoothBleCallback.onWriteSuccess(data);
    }

    private void writeDataFailure(String data) {
        if (mBluetoothBleCallback != null)
            mBluetoothBleCallback.onWriteFailure(data);
    }

    private void readDataFailure(String data) {
        if (mBluetoothBleCallback != null)
            mBluetoothBleCallback.onReadFailure(data);
    }

    public interface BluetoothBleCallback {

        void onScanning();

        void onScanTimeout();

        void onConnecting();

        void onConnected();

        void onDiscoverServices();

        void onDisconnect(String msg);

        void onReadFailure(String msg);

        void onWriteSuccess(String data);

        void onWriteFailure(String msg);

        void onReceiveData(String data);

    }

    private BluetoothBleCallback mBluetoothBleCallback;

    public void setBluetoothBleCallback(BluetoothBleCallback bluetoothBleCallback) {
        mBluetoothBleCallback = bluetoothBleCallback;
    }

    public interface BluetoothBleStateCallback {

        void onConnected();

        void onDisconnect();

    }

    private final List<BluetoothBleStateCallback> stateCallbacks = new ArrayList<>();

    public void addStateCallback(BluetoothBleStateCallback callback) {
        stateCallbacks.add(callback);
    }

    public void removeStateCallback(BluetoothBleStateCallback callback) {
        stateCallbacks.remove(callback);
    }

}
