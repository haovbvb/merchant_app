package com.okla.ops.views.workbench.bluetoothauthorization;

import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.Preferences;
import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.utils.ToastUtils;
import com.clj.fastble.BleManager;
import com.clj.fastble.callback.BleNotifyCallback;
import com.clj.fastble.callback.BleWriteCallback;
import com.clj.fastble.data.BleDevice;
import com.clj.fastble.exception.BleException;
import com.clj.fastble.utils.HexUtil;
import com.okla.ops.databinding.ActivityBluetoothOperateBinding;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.okla.ops.utils.ScanUtils;
import com.orhanobut.logger.Logger;
import com.okla.ops.R;
import com.okla.ops.beans.AddAuthorizationEventBusBean;
import com.okla.ops.utils.BluetoothConstants;
import com.okla.ops.utils.CrcUtil;
import com.okla.ops.utils.UrlUtil;
import com.okla.ops.utils.ViewClickUtils;
import com.okla.ops.views.workbench.QRCodeActivity;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;

import razerdp.basepopup.QuickPopupBuilder;
import razerdp.basepopup.QuickPopupConfig;
import razerdp.widget.QuickPopup;

import static com.okla.ops.utils.BluetoothConstants.CLEAR_AUTHORIZATION;
import static com.okla.ops.utils.BluetoothConstants.RESET_AUTHORIZATION;
import static com.okla.ops.utils.BluetoothConstants.bleKeyBlock;
import static com.okla.ops.utils.BluetoothConstants.keyId;
import static com.okla.ops.utils.BluetoothConstants.userPwd;

/**
 * 蓝牙操作 指令
 */
public class BluetoothOperateActivity extends BaseNormalVActivity<BluetoothAuthorizationViewModel, ActivityBluetoothOperateBinding> implements View.OnClickListener {


    public static final String BLE_DEVICE = "bleDevice";
    public static final String BLUETOOTH_GATT = "BluetoothGatt";
    public static final String STATUS = "status";

    private String mDevicesName;
    private BleDevice mBleDevice;

    private BluetoothGattCharacteristic mCharacteristic;

    /**
     * 当前发送的内容
     */
    private String mSendData;
    /**
     * 当前发送的指令
     */
    private String mSendSignal;


    /**
     * 增加授权类型
     */
    public int mType;

    /**
     * sn code 扫码或者手动输入
     */
    private String mStrSN;

    public static final String TAG = "FastBle";

    public static void startBluetoothOperateActivity(Context context, BleDevice bleDevice, BluetoothGatt gatt, int status) {
        Intent intent = new Intent(context, BluetoothOperateActivity.class);
        intent.putExtra(BLE_DEVICE, bleDevice);
//        intent.putExtra(BLUETOOTH_GATT, gatt);
        intent.putExtra(STATUS, status);
        context.startActivity(intent);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_bluetooth_operate;
    }

    @Override
    protected BluetoothAuthorizationViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(BluetoothAuthorizationViewModel.class);
    }


    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setViewModel(viewModel);
        mBinding.includeTitle.topTitle.setText(R.string.bluetooth_authorization);

        mBinding.resetAuthorization.tvLeft.setText(getString(R.string.reset_authorization));
        mBinding.factoryAuthorizedEntrance.tvLeft.setText(getString(R.string.factory_authorized_entrance));
        mBinding.clearAuthorization.tvLeft.setText(getString(R.string.clear_authorization));

        mBinding.resetAuthorization.clContent.setOnClickListener(v -> {
            //重置有效期

            showTipDialog(RESET_AUTHORIZATION);
        });

        mBinding.clearAuthorization.clContent.setOnClickListener(v -> {
            //清空授权
            showTipDialog(CLEAR_AUTHORIZATION);
        });

        mBinding.tvAddAuthorize.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }

            mStrSN = mBinding.etSn.getText().toString();
            if (TextUtils.isEmpty(mStrSN)) {
                ToastUtils.showShort(getString(R.string.sn_not_null));
                return;
            }
            getLoading().onStart();
            hideSoftInput();
            getViewModel().getUidByPhone(Preferences.getInstance().getPhone());
        });

        mBinding.clScan.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
            new IntentIntegrator(this)
                    .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                    .setOrientationLocked(false)
                    .setCaptureActivity(QRCodeActivity.class) // 设置自定义的activity是CustomActivity
                    .initiateScan(); //  初始化扫描
        });

        mBinding.factoryAuthorizedEntrance.clContent.setOnClickListener(v -> {

            Intent intent = new Intent(mContext, BluetoothOperateFactoryTimeActivity.class);
            startActivity(intent);
        });

        mBinding.tvDeviceName.setText(mDevicesName);

        initClicks();

        readDevicesData();

        addObserver();
    }

    /**
     * 读取设备信息
     */
    private void readDevicesData() {
        BluetoothGatt gatt = BleManager.getInstance().getBluetoothGatt(mBleDevice);
        for (BluetoothGattService service : gatt.getServices()) {
            for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                mCharacteristic = characteristic;
                Logger.d(" readDevicesData  getService:" + mCharacteristic.getService().getUuid().toString());
                Logger.d(" readDevicesData ====:" + mCharacteristic.getUuid().toString());
            }
        }


        BleManager.getInstance().notify(mBleDevice, mCharacteristic.getService().getUuid().toString(),
                BluetoothConstants.READ_UUID, new BleNotifyCallback() {
                    @Override
                    public void onNotifySuccess() {
                        Logger.d("READ_UUID notify onNotifySuccess :");
                        getKeyId();
                    }

                    @Override
                    public void onNotifyFailure(BleException exception) {
                        Logger.d("READ_UUID notify onNotifyFailure :" + exception.toString());
                    }

                    @Override
                    public void onCharacteristicChanged(byte[] data) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                BluetoothConstants.commandBack += HexUtil.formatHexString(data, false);
                                Logger.d("READ_UUID notify onCharacteristicChanged :" + HexUtil.formatHexString(data, false) + ",back:" + BluetoothConstants.commandBack);
                                if (BluetoothConstants.commandBack.contains(BluetoothConstants.command_end.toLowerCase())) {
                                    //
                                    Logger.d("设备返回数据:" + BluetoothConstants.commandBack);
                                    String signalBack = getBackSignal(BluetoothConstants.commandBack);
                                    Logger.d("设备返回指令:" + signalBack.toUpperCase());
                                    Logger.d("设备返回指令:" + BluetoothConstants.command_signal.toUpperCase());
                                    if (!signalBack.toUpperCase().equals(BluetoothConstants.command_signal.toUpperCase())) {
                                        BluetoothConstants.commandBack = "";
                                        if (signalBack.equals("010d")) {
                                            getLoading().onFinish();
                                            ToastUtils.showShort(getString(R.string.repeat_authorization));
                                        }
                                        return;
                                    }
                                    // 解密前，需要先把数据中的转义符转回正常字符
                                    BluetoothConstants.commandBack = BluetoothConstants.commandBack.replace("7d5d", "7d");
                                    BluetoothConstants.commandBack = BluetoothConstants.commandBack.replace("7d5e", "7e");
                                    // 取出要解密部分
                                    String decryptStr = getDecryptStr(BluetoothConstants.commandBack);
                                    Logger.d("--解密数据--", decryptStr);
                                    decryptData(decryptStr, false);
                                }
                            }
                        });
                    }
                });


    }

    private QuickPopup mTipDialog;

    /**
     * 操作提示
     */
    private void showTipDialog(int type) {
        mTipDialog = QuickPopupBuilder.with(mContext).contentView(R.layout.dialog_base_layout)
                .config(new QuickPopupConfig()
                        .gravity(Gravity.CENTER)
                        .outSideTouchable(false)
                        .outSideDismiss(false)
                        .backpressEnable(false)
                        .withClick(R.id.tv_cancel, v -> mTipDialog.dismiss())
                        .withClick(R.id.tv_sure, v -> {
                            if (type == RESET_AUTHORIZATION) {
                                resetAuthorizationTime();
                                getLoading().onStart();
                            } else if (type == CLEAR_AUTHORIZATION) {
                                clearAuthorization();
                                getLoading().onStart();
                            }
                            mTipDialog.dismiss();
                        })).build();
        mTipDialog.showPopupWindow();
        mTipDialog.getContentView().post(() -> {
            TextView tvTitle = mTipDialog.findViewById(R.id.tvTitle);
            tvTitle.setText(getString(R.string.notifyTitle));
            TextView tvContent = mTipDialog.findViewById(R.id.tvContent);
            String strTip = "";
            if (type == RESET_AUTHORIZATION) {
                strTip = getString(R.string.reset_authorization_tip);
            } else if (type == CLEAR_AUTHORIZATION) {
                strTip = getString(R.string.clear_authorization_tip);
            }
            tvContent.setText(strTip);
                });
    }

    /**
     * 后台加密
     *
     * @param signal 信号值
     * @
     */
    public void decryptData(String signal, boolean isEncrypt) {
        HashMap<String, Object> hashMap = new HashMap<>();
        hashMap.put("str", signal);
        hashMap.put("isEncrypt", isEncrypt);
        getViewModel().blueToothEnOrDecrypt(hashMap);
    }


    /**
     * 初始化 读取钥匙
     */
    public void getKeyId() {
        mSendData = userPwd; // "12345678";
        mSendSignal = "0031";
        Logger.d("读取钥匙ID--" + mSendData + ",发送指令:" + mSendSignal);
        decryptData(mSendData, true);
    }

    /**
     * 清除授权
     */
    public void clearAuthorization() {
        mSendData = userPwd + keyId + bleKeyBlock;
        mSendSignal = "000c";
        Logger.d("清除授权--:" + mSendData + ",发送指令:" + mSendSignal);
        decryptData(mSendData, true);
    }


    private String getSetKeyTime() { // 有效期天数转bcd
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.YEAR, 10);
        String setKeyTime = getBCD(cal);
        return setKeyTime;
    }


    private String getBCD(Calendar cal) {

//        Date datetime = cal.getTime();
        int year = cal.get(Calendar.YEAR) - 2000; // 获取年份,从2000年开始计算
        if (year < 0) {
            year = 0; // 不允许小于2000年的年份出现
        }
        int month = cal.get(Calendar.MONTH) + 1; // 获取月份 0-11 所以需要加1
        int day = cal.get(Calendar.DAY_OF_MONTH); // 获取日
        int hour = cal.get(Calendar.HOUR_OF_DAY); // 小时
        int minute = cal.get(Calendar.MINUTE); // 分

        return formatNumber(year) + formatNumber(month) + formatNumber(day) + formatNumber(hour) + formatNumber(minute); // 得到BCD码的时间字符串
    }

    private String formatNumber(int n) {
        if (String.valueOf(n).length() > 1) {
            return String.valueOf(n);
        }
        return "0" + n;
    }

    public String mSetKeyTime;

    /**
     * 重置设备有效期
     */
    public void resetAuthorizationTime() {
        mSetKeyTime = getSetKeyTime();
        mSendData = userPwd + mSetKeyTime + bleKeyBlock;
        mSendSignal = "0087";
        Logger.d("设置有效期--:" + mSendData + ",发送指令:" + mSendSignal);
        decryptData(mSendData, true);
    }


    @Override
    protected boolean isBindEventBusHere() {
        return true;
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void addAuthorizationEventBusBean(AddAuthorizationEventBusBean authorizationEventBusBean) {

        if (authorizationEventBusBean.state == 0 && authorizationEventBusBean.day > 0) {
            addAuthorizationTime(authorizationEventBusBean.day);
        }
    }

    /**
     * 开始授权 工厂授权
     */
    public void addAuthorizationTime(int day) {
        mType = BluetoothConstants.ADD_FACTORY_AUTHORIZATION;
        addDataBuilder(day);
        mSendSignal = "000D";
        Logger.d("开始授权--:" + mSendData + ",发送指令:" + mSendSignal);
        decryptData(mSendData, true);
    }

    /**
     * 增加换电授权 默认一天
     */
    public void addAuthorizationTime() {
        mType = BluetoothConstants.ADD_AUTHORIZATION;
        addDataBuilder();
        mSendSignal = "000D";
        Logger.d("开始授权--:" + mSendData + ",发送指令:" + mSendSignal);
        decryptData(mSendData, true);
    }

    private Date curDate;
    private Date nextDate;

    /**
     * 组装增加授权参数 取的全局变量数据
     */
    public void addDataBuilder() {
        // 有效时间 默认1天
        int setTime = 24 * 60 * 60 * 1000;
        // 误差提前值1小时
        int aheadTime = 60 * 60 * 1000;
        // 当前时间
        curDate = new Date();
        // 一天后
        nextDate = new Date(curDate.getTime() + setTime);
        // 当前时间提前1小时
        curDate = new Date(curDate.getTime() - aheadTime);
        Calendar current = Calendar.getInstance();
        current.setTime(curDate);
        String startTime = getBCD(current);
        Calendar nextDateTime = Calendar.getInstance();
        nextDateTime.setTime(nextDate);
        String endTime = getBCD(nextDateTime);
        BluetoothConstants.userChar = getUserChar();
        mSendData = BluetoothConstants.userChar + BluetoothConstants.lockId + BluetoothConstants.rights +
                startTime + endTime + BluetoothConstants.userNum +
                BluetoothConstants.lockPwd + BluetoothConstants.lockBlock;
    }

    /**
     * 组装增加授权参数 取的全局变量数据
     */
    public void addDataBuilder(int day) {
        // 有效时间 默认1天
        int setTime = 24 * 60 * 60 * 1000 * day;
        // 误差提前值1小时
        int aheadTime = 60 * 60 * 1000;
        // 当前时间
        curDate = new Date();
        // n天后
        nextDate = new Date(curDate.getTime() + setTime);
        // 当前时间提前1小时
        curDate = new Date(curDate.getTime() - aheadTime);
        Calendar current = Calendar.getInstance();
        current.setTime(curDate);
        String startTime = getBCD(current);
        Calendar nextDateTime = Calendar.getInstance();
        nextDateTime.setTime(nextDate);
        String endTime = getBCD(nextDateTime);
        BluetoothConstants.userChar = getUserChar();
        String facLockId = "0a000000";
        String facRight = "06";
        String facUserNum = "00000000";
        mSendData = BluetoothConstants.userChar + facLockId + facRight + startTime + endTime + facUserNum + BluetoothConstants.lockPwd + BluetoothConstants.lockBlock;

    }

    /**
     * 获取用户特征值
     * return 2位16进制字符串
     */
    private String getUserChar() {

        int[] _userPwd = toArray(userPwd);
        int[] _keyId = toArray(keyId);
        int result = _userPwd[0];
        result = result ^ _userPwd[1];
        result = result ^ _userPwd[2];
        result = result ^ _userPwd[3];
        result = result ^ _keyId[0];
        result = result ^ _keyId[1];
        result = result ^ _keyId[2];
        result = result ^ _keyId[3];
        String resultData = Integer.toHexString(result);
        if (resultData.length() < 2) {
            resultData = "0" + resultData;
        }
        return resultData;
    }

    private int[] toArray(String hexStr) {
        int count = hexStr.length() / 2;
        int[] array = new int[count];
        for (int i = 0; i < count; i++) {
            int item = Integer.valueOf(hexStr.substring(i * 2, 2 * (i + 1)), 16);
            array[i] = item;
        }
        return array;
    }

    private void addObserver() {
        getViewModel().mBluetoothEnOrDecrypt.observeForever(result -> {

            Logger.d("addObserver:" + result.data);
            boolean isEncrypt = (boolean) result.map.get("isEncrypt");

            if (isEncrypt) {
                Logger.d("加密成功===== 发送指令:" + mSendSignal + ",发送内容:" + mSendData);
                BluetoothConstants.command_data = result.data;
                dataBuilder(mSendSignal, mSendData, result.data);
            } else {
                Logger.d("解密成功-------");
                BluetoothConstants.commandBack = "";
                if (mSendSignal.equals("0031")) {
                    //获取钥匙id
                    Logger.d("获取钥匙id-------");
                    getKeyID(result.data);
                    return;
                }
                if (mSendSignal.equals("000c")) {
                    String backKeyId = result.data.substring(0, 8);
                    Logger.d("清空授权=====");
                    getLoading().onFinish();
                    if (backKeyId.equals(keyId)) {
                        ToastUtils.showShort(getString(R.string.authorization_success));
                    } else {
                        ToastUtils.showShort(getString(R.string.authorization_fail));
                    }
                } else if (mSendSignal.equals("0087")) {
                    getLoading().onFinish();
                    String backKeyId = result.data.substring(0, 10);
                    Logger.d("设置有效期:" + backKeyId);
                    if (mSetKeyTime.equals(backKeyId)) {
                        ToastUtils.showShort(getString(R.string.reset_authorization_time_success));
                    } else {
                        ToastUtils.showShort(getString(R.string.reset_authorization_time_fail));
                    }
                } else if (mSendSignal.equals("000D")) {
                    Logger.d("授权入口:");
                    String backKeyId = result.data.substring(0, 8);
                    if (backKeyId.equals(keyId)) {

                        HashMap<String, Object> hashMap = new HashMap<>();
                        hashMap.put("phone", Preferences.getInstance().getPhone());
                        hashMap.put("lockIcId", 0);
                        hashMap.put("keyId", keyId);
                        hashMap.put("authBegtime", curDate.getTime());
                        hashMap.put("authEndtime", nextDate.getTime());
                        if (mType == BluetoothConstants.ADD_FACTORY_AUTHORIZATION) {
                            Logger.d("工厂授权入口:");
//                            ToastUtils.showShort(getString(R.string.factory_authorized_success));
                            hashMap.put("lockDevId", 0);
                            hashMap.put("sn", 0);

                        } else if (mType == BluetoothConstants.ADD_AUTHORIZATION) {
                            Logger.d("新增换电授权===:");
//                            ToastUtils.showShort(getString(R.string.add_authorized_success));
                            hashMap.put("lockDevId", BluetoothConstants.lockDevId);
                            hashMap.put("sn", mStrSN);
                        }
                        getViewModel().authAdd(hashMap);
                    } else {
                        getLoading().onFinish();
                        ToastUtils.showShort(getString(mType == BluetoothConstants.ADD_FACTORY_AUTHORIZATION ? R.string.factory_authorized_fail : R.string.add_authorized_fail));
                        AddAuthorizationEventBusBean event = new AddAuthorizationEventBusBean(-1);
                        EventBus.getDefault().post(event);
                        //reset
                        mType = 0;
                    }

                }

            }

        });
        //get uid
        getViewModel().mUidLiveData.observe(this, s -> {
            Logger.d("获取uid:" + s);
            String str = String.format("%08d", s);
            Logger.d("获取uid===:" + str);
            BluetoothConstants.userNum = str;
            getViewModel().getLockIdBySn(mStrSN);
        });

        //get sn
        getViewModel().mSnLiveData.observe(this, sn -> {
            Logger.d("获取sn:" + sn.toString());
            if (TextUtils.isEmpty(sn.getLockDevId())) {
                getLoading().onFinish();
                ToastUtils.showShort(getString(R.string.str_not_match_lock_id));
                return;
            }
            BluetoothConstants.lockDevId = sn.getLockDevId();
            BluetoothConstants.lockId = sn.getLockDevId();
            BluetoothConstants.lockIcId = sn.getLockIcId();
            addAuthorizationTime();
        });


        //增加授权成功后，上传本次授权数据
        getViewModel().mAddAuthLiveData.observeForever(o -> {
            getLoading().onFinish();
            if(o!=null){
                Logger.d("上传本次授权数据:" + getString(mType == BluetoothConstants.ADD_FACTORY_AUTHORIZATION ? R.string.factory_authorized_success : R.string.add_authorized_success));
                ToastUtils.showShort(getString(mType == BluetoothConstants.ADD_FACTORY_AUTHORIZATION ? R.string.factory_authorized_success : R.string.add_authorized_success));
                AddAuthorizationEventBusBean event = new AddAuthorizationEventBusBean(1);
                EventBus.getDefault().post(event);
                //reset
                mType = 0;
            }

        });

    }


    public String getBackSignal(String str) {
        if (str.length() < 18) {
            return str;
        }
        return str.substring(14, 18);
    }

    /**
     * 蓝牙返回的数据中取出加密部分，固定长度
     *
     * @param str 整段数据
     *            return 返回加密部分
     */
    public String getDecryptStr(String str) {
        if (str.length() < 18) {
            return str;
        }
        return str.substring(18, str.length() - 8);
    }

    /**
     * 蓝牙返回的数据中已解密后，取出前8位，为钥匙id
     *
     * @param str 已解密数据
     */
    public void getKeyID(String str) {
        // 取下标0到8 不包换8
        keyId = str.substring(0, 8);
        Logger.d("--钥匙ID--：" + keyId);

    }


    /**
     * 组装数据 16进制字符串
     * 组装完成后发送
     *
     * @param signal
     * @param strHex        未加密的消息参数
     * @param strHexDecrypt 加密后消息参数
     */
    public void dataBuilder(String signal, String strHex, String strHexDecrypt) {
        // 报文消息为消息参数长度+2字节signal长度
        BluetoothConstants.command_len = "00" + Integer.toHexString(strHex.length() / 2 + 2);
        if (BluetoothConstants.command_len.length() < 4) {
            BluetoothConstants.command_len = "0" + BluetoothConstants.command_len;
        }
        BluetoothConstants.command_signal = signal;
        BluetoothConstants.command_data = strHexDecrypt;
        String crcStr = BluetoothConstants.command_1 + BluetoothConstants.command_2 + BluetoothConstants.command_3 + BluetoothConstants.command_4
                + BluetoothConstants.command_len + BluetoothConstants.command_signal + BluetoothConstants.command_data;
        Logger.d("--crc--加密前:" + crcStr);
        BluetoothConstants.command_crc = CrcUtil.getCRC(crcStr);
        Logger.d("--校验码crc--" + BluetoothConstants.command_crc);
        String command_body = crcStr + BluetoothConstants.command_crc;
        // 发送数据前若有需要转义的数据，先转义
        command_body = command_body.toLowerCase();
        String strNew = "";
        Logger.d("before command_body :" + command_body);
        for (int i = 0; i < command_body.length() / 2; i++) {
            String subStr = command_body.substring(i * 2, (i + 1) * 2);
            subStr = subStr.replace("7d", "7d5d");
            subStr = subStr.replace("7e", "7d5e");
            strNew = strNew + subStr;
        }
        command_body = strNew;
        Logger.d("after command_body :" + command_body);
        String finalCommand = (BluetoothConstants.command_head + command_body + BluetoothConstants.command_end).toLowerCase();
        Logger.d("发送到蓝牙设备:" + finalCommand);
        sendCmd(finalCommand, 0);
    }

    /**
     * 发送数据到设备
     *
     * @param command
     */
    public void sendCmd(String command, int index) {

        BleManager.getInstance().write(mBleDevice, mCharacteristic.getService().getUuid().toString(), BluetoothConstants.WRITE_UUID, HexUtil.hexStringToBytes(command), new BleWriteCallback() {
            @Override
            public void onWriteSuccess(int current, int total, byte[] justWrite) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                        Logger.d("onWriteSuccess:" + "write success, current 执行指令: " + current
                                + " total: " + total
                                + " justWrite: " + HexUtil.formatHexString(justWrite, false));
                    }
                });
            }

            @Override
            public void onWriteFailure(BleException exception) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
//                        ToastUtils.showShort("失败");
                        Logger.d("onWriteFailure:" + exception.toString());
                    }
                });
            }
        });


    }

    private void initClicks() {

    }

    @Override
    protected void getIntentExtras(Intent intent) {
        super.getIntentExtras(intent);
        mBleDevice = intent.getParcelableExtra(BLE_DEVICE);
        if (mBleDevice != null) {
            mDevicesName = mBleDevice.getName();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        BluetoothConstants.commandBack = "";
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            default:
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            String scanMessage = null;
            IntentResult intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
            if (intentResult != null && intentResult.getContents() != null) {
                //二维码扫码
                scanMessage = intentResult.getContents();
                Logger.d("onActivityResult :" + scanMessage);
//                if (scanMessage.contains("sn")) {
//                    UrlUtil.UrlEntity entity = UrlUtil.parse(scanMessage);
//                    if (entity != null) {
//                        scanMessage = entity.params.get("sn");
//                    }
//                }
                scanMessage= ScanUtils.Companion.parseStationQr(mContext,scanMessage).getSn();
                Logger.d("onActivityResult:" + scanMessage);
                if (!TextUtils.isEmpty(scanMessage)) {
                    mStrSN = scanMessage;
                    mBinding.etSn.setText(mStrSN);
//                    hideSoftInput();
//                    getViewModel().getUidByPhone(Preferences.getInstance().getPhone());
                } else {
                    ToastUtils.showShort(getString(R.string.sn_not_null));
                }
            }

        }
    }
}