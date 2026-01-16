package com.okla.ops.views.workbench.cabinetopt;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.library.utils.GsonUtils;
import com.okla.ops.R;
import com.okla.ops.databinding.FragmentCabinetOfflineRealTimeBinding;
import com.okla.ops.utils.AlarmInfo;
import com.okla.ops.utils.Attr;
import com.okla.ops.utils.BluetoothBleUtil;
import com.okla.ops.utils.CabinetData;
import com.okla.ops.utils.CabinetDataType;
import com.okla.ops.utils.CabinetInfo;
import com.okla.ops.utils.CabinetParam;
import com.okla.ops.utils.CabinetParamName;
import com.okla.ops.utils.CabinetSignal;
import com.okla.ops.utils.ResultInfo;

import java.util.List;

public class CabinetOfflineRealTimeFragment extends BaseNormalVFragment<CabinetOfflineViewModel, FragmentCabinetOfflineRealTimeBinding> {

    public static CabinetOfflineRealTimeFragment getInstance(String sn) {
        CabinetOfflineRealTimeFragment fragment = new CabinetOfflineRealTimeFragment();
        Bundle bundle = new Bundle();
        bundle.putString("sn", sn);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_cabinet_offline_real_time;
    }

    @Override
    protected CabinetOfflineViewModel onCreateViewModel() {
        return new ViewModelProvider(requireActivity()).get(CabinetOfflineViewModel.class);
    }

    @Override
    public void onResume() {
        super.onResume();
        BluetoothBleUtil.getInstance().addDataCallback(callback);
        parseAllData(getViewModel().getAllData());
    }

    @Override
    public void onPause() {
        super.onPause();
        BluetoothBleUtil.getInstance().removeDataCallback(callback);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        initClick();
        initData();
    }

    private String deviceSn;

    private void initData() {
        Bundle arguments = getArguments();
        if (arguments != null) {
            deviceSn = arguments.getString("sn");
        }
        getViewModel().getCabinetBaseInfo(deviceSn);
        if (BluetoothBleUtil.getInstance().isConnected()) {
            initAlarmStatus();
        }
    }

    private void initClick() {
    }

    private void getCabinetDetail() {
        //310上报数据
        if (BluetoothBleUtil.getInstance().isConnected()) {
            List<CabinetParam> params = getViewModel().buildParamSetting(CabinetSignal.ALL_DATA, "0");
            String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.QUERY_REQUEST, deviceSn, params));
            BluetoothBleUtil.getInstance().addDataToQueue(gson);
            getLoading().onStart();
        }
    }

    private void initAlarmStatus() {
        mBinding.invSmokeDetectorAlarm.setValue(getString(R.string.text_no_alarm));
        mBinding.invWaterLeakageAlarm.setValue(getString(R.string.text_no_alarm));
        mBinding.invCharger.setValue(getString(R.string.text_yes));
    }

    private final BluetoothBleUtil.BluetoothBleDataCallback callback = new BluetoothBleUtil.BluetoothBleDataCallback() {
        @Override
        public void onAuthorization() {
            getCabinetDetail();
            initAlarmStatus();
        }

        @Override
        public void onReceiveData(String data) {
            CabinetData cabinetData = GsonUtils.fromGson(data, CabinetData.class);
            if (cabinetData != null) {
                if (cabinetData.isFull() != null && cabinetData.isFull() == 1) {
                    getLoading().onFinish();
                    parseAllData(data);
                }
                if (cabinetData.getMsgType() == CabinetDataType.ALARM_REQUEST) {
                    List<AlarmInfo> alarmList = cabinetData.getAlarmList();
                    if (alarmList != null && !alarmList.isEmpty()) {
                        boolean isChargerAlarm = false;
                        for (AlarmInfo alarmInfo : alarmList) {
                            if (CabinetSignal.ALARM_SMOKE.equals(alarmInfo.getId())) {
                                if (alarmInfo.getAlarmFlag() == 1) {
                                    mBinding.invSmokeDetectorAlarm.setValue(getString(R.string.text_alarm));
                                } else if (alarmInfo.getAlarmFlag() == 0) {
                                    mBinding.invSmokeDetectorAlarm.setValue(getString(R.string.text_no_alarm));
                                } else {
                                    mBinding.invSmokeDetectorAlarm.setValue(getString(R.string.text_unknown));
                                }
                            }
                            if (CabinetSignal.ALARM_WATER.equals(alarmInfo.getId())) {
                                if (alarmInfo.getAlarmFlag() == 1) {
                                    mBinding.invWaterLeakageAlarm.setValue(getString(R.string.text_alarm));
                                } else if (alarmInfo.getAlarmFlag() == 0) {
                                    mBinding.invWaterLeakageAlarm.setValue(getString(R.string.text_no_alarm));
                                } else {
                                    mBinding.invWaterLeakageAlarm.setValue(getString(R.string.text_unknown));
                                }
                            }
                            if (!TextUtils.isEmpty(alarmInfo.getId()) && alarmInfo.getId().contains(CabinetSignal.CTRL_CHARGER)) {
                                if (alarmInfo.getAlarmFlag() == 1) {
                                    isChargerAlarm = true;
                                }
                            }
                        }
                        if (isChargerAlarm) {
                            mBinding.invCharger.setValue(getString(R.string.text_no));
                        } else {
                            mBinding.invCharger.setValue(getString(R.string.text_yes));
                        }
                    }
                }
                if (cabinetData.getMsgType() == CabinetDataType.QUERY_RESPONSE) {
                    List<ResultInfo> resultList = cabinetData.getResultList();
                    if (resultList != null && !resultList.isEmpty()) {
                        for (ResultInfo resultInfo : resultList) {
                            if (CabinetParamName.SWITCH_CONTROL.equals(resultInfo.getId())) {

                            }
                        }
                    }
                }
            }
        }

        @Override
        public void onDisconnect() {
            getLoading().onFinish();
        }

    };

    private void parseAllData(String data) {
        if(TextUtils.isEmpty(data)){
            return;
        }
        CabinetData cabinetData = GsonUtils.fromGson(data, CabinetData.class);
        if (cabinetData != null) {
            if (cabinetData.getMsgType() == CabinetDataType.ATTRIBUTE_REQUEST) {
                List<CabinetInfo> cabList = cabinetData.getCabList();
                if (cabList != null && !cabList.isEmpty()) {
                    CabinetInfo cabinetInfo = cabList.get(0);
                    mBinding.invGSMSignal.setValue(cabinetInfo.getDBM() + " dbm");
                    mBinding.invTotalVoltage.setValue(cabinetInfo.getCabVol() + " V");
                    mBinding.invTotalCurrent.setValue(cabinetInfo.getCabCur() + " A");
                    mBinding.invTemperature.setValue(cabinetInfo.getCabT() + " ℃");
                    List<String> cabAlarm = cabinetInfo.getCabAlarm();
                    if (!cabAlarm.isEmpty()) {
                        for (String s : cabAlarm) {
                            if ("03".equals(s)) {
                                mBinding.invWaterLeakageAlarm.setValue(getString(R.string.text_alarm));
                                break;
                            }
                            if ("04".equals(s)) {
                                mBinding.invSmokeDetectorAlarm.setValue(getString(R.string.text_alarm));
                                break;
                            }
                        }
                    }
                }
                List<Attr> attrList = cabinetData.getAttrList();
                if (attrList != null && !attrList.isEmpty()) {
                    boolean isConnectCtrl = true;
                    for (Attr attr : attrList) {
                        if (CabinetSignal.GSM.equals(attr.getId())) {
                            mBinding.invGSMSignal.setValue(attr.getValue() + " dbm");
                        }
                        if (CabinetSignal.CABINET_MAINTENANCE_DOOR.equals(attr.getId())) {
                            try {
                                int i = Integer.parseInt(attr.getValue());
                                if (i == 0) {
                                    mBinding.invOMDoor.setValue(getString(R.string.text_close));
                                } else if (i == 1) {
                                    mBinding.invOMDoor.setValue(getString(R.string.text_open));
                                } else {
                                    mBinding.invOMDoor.setValue(getString(R.string.text_unknown));
                                }
                            } catch (Exception e) {
                                mBinding.invOMDoor.setValue(getString(R.string.text_unknown));
                            }
                        }
                        if (CabinetSignal.CABINET_VOLTAGE.equals(attr.getId())) {
                            mBinding.invTotalVoltage.setValue(attr.getValue() + " V");
                        }
                        if (CabinetSignal.CABINET_CURRENT.equals(attr.getId())) {
                            mBinding.invTotalCurrent.setValue(attr.getValue() + " A");
                        }
                        if (CabinetSignal.CABINET_TEMPERATURE.equals(attr.getId())) {
                            mBinding.invTemperature.setValue(attr.getValue() + " ℃");
                        }
                        if (CabinetSignal.ELECTRIC_METER.equals(attr.getId())) {
                            mBinding.invElectricityMeter.setValue(attr.getValue() + " kWh");
                        }
                        if (CabinetSignal.CTRL_SYSTEM.equals(attr.getId())) {
                            try {
                                int i = Integer.parseInt(attr.getValue());
                                if (i == 0) {
                                    isConnectCtrl = false;
                                    mBinding.invCtrlSystem.setValue(getString(R.string.text_exception));
                                } else if (i == 1) {
                                    mBinding.invCtrlSystem.setValue(getString(R.string.text_yes));
                                } else {
                                    isConnectCtrl = false;
                                    mBinding.invCtrlSystem.setValue(getString(R.string.text_unknown));
                                }
                            } catch (Exception e) {
                                isConnectCtrl = false;
                                mBinding.invCtrlSystem.setValue(getString(R.string.text_unknown));
                            }
                        }
                        if (CabinetSignal.CABINET_FAN_STATUS.equals(attr.getId())) {
                            try {
                                int i = Integer.parseInt(attr.getValue());
                                if (i == 0) {
                                    mBinding.invFanStatus.setValue(getString(R.string.text_close));
                                } else if (i == 1) {
                                    mBinding.invFanStatus.setValue(getString(R.string.text_running));
                                } else if (i == 2) {
                                    mBinding.invFanStatus.setValue(getString(R.string.text_exception));
                                } else {
                                    mBinding.invFanStatus.setValue(getString(R.string.text_unknown));
                                }
                            } catch (Exception e) {
                                mBinding.invFanStatus.setValue(getString(R.string.text_unknown));
                            }
                        }
                    }
                    if (isConnectCtrl) {
                        mBinding.invCtrlSystem.setValue(getString(R.string.text_yes));
                    }
                }
            }
        }
    }

}
