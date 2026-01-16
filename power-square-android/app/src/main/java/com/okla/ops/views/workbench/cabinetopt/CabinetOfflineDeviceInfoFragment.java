package com.okla.ops.views.workbench.cabinetopt;

import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.InputType;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.StatusBarUtil;
import com.base.common.utils.ToastUtils;
import com.base.library.utils.GsonUtils;
import com.okla.ops.R;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.databinding.FragmentCabinetOfflineDeviceInfoBinding;
import com.okla.ops.utils.AlarmInfo;
import com.okla.ops.utils.Attr;
import com.okla.ops.utils.BluetoothBleUtil;
import com.okla.ops.utils.CabinetData;
import com.okla.ops.utils.CabinetDataType;
import com.okla.ops.utils.CabinetFormat;
import com.okla.ops.utils.CabinetInfo;
import com.okla.ops.utils.CabinetParam;
import com.okla.ops.utils.CabinetParamName;
import com.okla.ops.utils.CabinetSignal;
import com.okla.ops.utils.EventUtils;
import com.okla.ops.utils.ResultInfo;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.snackbar.Snackbar;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.listener.OnRefreshListener;

import java.util.ArrayList;
import java.util.List;

public class CabinetOfflineDeviceInfoFragment extends BaseNormalVFragment<CabinetOfflineViewModel, FragmentCabinetOfflineDeviceInfoBinding> {

    public static CabinetOfflineDeviceInfoFragment getInstance(String sn) {
        CabinetOfflineDeviceInfoFragment fragment = new CabinetOfflineDeviceInfoFragment();
        Bundle bundle = new Bundle();
        bundle.putString("sn", sn);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_cabinet_offline_device_info;
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
        initObserver();
        initClick();
        initData();
    }

    private int maxChargeSoc = 100;

    private void initObserver() {
        getViewModel().baseInfoDataLiveData.observe(this, cabinetDetailBaseInfoBean -> {
            if (cabinetDetailBaseInfoBean != null) {
                mBinding.invSlot.setValue(cabinetDetailBaseInfoBean.getStationModelName());
                if (cabinetDetailBaseInfoBean.getMaxChargeSoc() != null) {
                    maxChargeSoc = cabinetDetailBaseInfoBean.getMaxChargeSoc();
                }
            }
        });
    }

    private void initClick() {
        mBinding.invSwapThreshold.setOnClickListener(v -> {
            mType = TYPE_SWAP_THRESHOLD;
            initBottomSheet();
        });
        mBinding.invAPN.setOnClickListener(v -> {
            mType = TYPE_APN;
            initBottomSheet();
        });
        mBinding.invVolume.setOnClickListener(v -> {
            mType = TYPE_VOLUME;
            initBottomVolumeDialog();
        });
        mBinding.invPlatformURL.setOnClickListener(v -> {
            mType = TYPE_PLATFORM_URL;
            initBottomSheet();
        });
    }

    private String deviceSn;

    private void initData() {
        Bundle arguments = getArguments();
        if (arguments != null) {
            deviceSn = arguments.getString("sn");
        }
        getViewModel().getCabinetBaseInfo(deviceSn);
    }

    private void getCabinetDetail() {
        if (BluetoothBleUtil.getInstance().isConnected()) {
            String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.QUERY_REQUEST, deviceSn, getViewModel().buildParam(
                    CabinetParamName.SOFT_VERSION, CabinetParamName.CAB_VOLUME, CabinetParamName.CAB_SOC, CabinetParamName.CAB_TCP_PORT, CabinetParamName.APN
            )));
            BluetoothBleUtil.getInstance().addDataToQueue(gson);
            List<CabinetParam> params = getViewModel().buildParamSetting(CabinetSignal.ALL_DATA, "0");
            String gson2 = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.QUERY_REQUEST, deviceSn, params));
            BluetoothBleUtil.getInstance().addDataToQueue(gson2);
            getLoading().onStart();
        }
    }

    private final BluetoothBleUtil.BluetoothBleDataCallback callback = new BluetoothBleUtil.BluetoothBleDataCallback() {
        @Override
        public void onAuthorization() {
            mBinding.invBackupPowerStatus.setValue(getString(R.string.text_no));
            getCabinetDetail();
        }

        @Override
        public void onReceiveData(String data) {
            CabinetData cabinetData = GsonUtils.fromGson(data, CabinetData.class);
            if (cabinetData != null) {
                if (cabinetData.isFull() != null && cabinetData.isFull() == 1) {
                    parseAllData(data);
                    getLoading().onFinish();
                }
                if (cabinetData.getMsgType() == CabinetDataType.QUERY_RESPONSE) {
                    List<ResultInfo> resultList = cabinetData.getResultList();
                    if (resultList != null && !resultList.isEmpty()) {
                        for (ResultInfo resultInfo : resultList) {
                            if (CabinetParamName.SOFT_VERSION.equals(resultInfo.getId())) {
                                mBinding.invSoftwareVersion.setValue(resultInfo.getValue());
                            }
                            if (CabinetParamName.CAB_SOC.equals(resultInfo.getId())) {
                                mBinding.invSwapThreshold.setValue(resultInfo.getValue());
                            }
                            if (CabinetParamName.CAB_VOLUME.equals(resultInfo.getId())) {
                                mBinding.invVolume.setValue(resultInfo.getValue());
                            }
                            if (CabinetParamName.CAB_TCP_PORT.equals(resultInfo.getId())) {
                                mBinding.invPlatformURL.setValue(resultInfo.getValue().replace(",",":"));
                            }
                            if (CabinetParamName.APN.equals(resultInfo.getId())) {
                                mBinding.invAPN.setValue(resultInfo.getValue());
                            }
                        }
                    }
                }
                if (cabinetData.getMsgType() == CabinetDataType.ALARM_REQUEST) {
                    List<AlarmInfo> alarmList = cabinetData.getAlarmList();
                    if (alarmList != null && !alarmList.isEmpty()) {
                        for (AlarmInfo alarmInfo : alarmList) {
                            if (CabinetSignal.BACKUP_BATTERY_STATUS.equals(alarmInfo.getId())) {
                                if (alarmInfo.getAlarmFlag() == 1) {
                                    mBinding.invBackupPowerStatus.setValue(getString(R.string.text_yes));
                                } else if (alarmInfo.getAlarmFlag() == 0) {
                                    mBinding.invBackupPowerStatus.setValue(getString(R.string.text_no));
                                } else {
                                    mBinding.invBackupPowerStatus.setValue(getString(R.string.text_unknown));
                                }
                            }
                        }
                    }
                }
                if (cabinetData.getMsgType() == CabinetDataType.CONTROL_RESPONSE) {
                    if (cabinetData.getResult() != null && cabinetData.getResult() == 1) {//成功
                        switch (mType) {
                            case TYPE_SWAP_THRESHOLD:
                                mBinding.invSwapThreshold.setValue(swapThreshold);
                                try {
                                    configCabinet(1, Integer.parseInt(swapThreshold));
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                                break;
                            case TYPE_APN:
                                mBinding.invAPN.setValue(apn);
                                break;
                            case TYPE_VOLUME:
                                mBinding.invVolume.setValue(String.valueOf(mVolume));
                                configCabinet(2, mVolume);
                                break;
                            case TYPE_PLATFORM_URL:
                                String url = platformUrl.replace(",", ":");
                                mBinding.invPlatformURL.setValue(url);
                                break;
                        }
                        mType = 0;
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
        if(data==null){
            return;
        }
        CabinetData cabinetData = GsonUtils.fromGson(data, CabinetData.class);
        if (cabinetData != null) {
            if (cabinetData.getMsgType() == CabinetDataType.ATTRIBUTE_REQUEST) {
                List<Attr> attrList = cabinetData.getAttrList();
                if (attrList != null && !attrList.isEmpty()) {
                    int batInSlot = 0;
                    for (Attr attr : attrList) {
                        if (CabinetSignal.CABINET_BATTERY_SWAP_STATUS.equals(attr.getId())) {
                            int i1 = Integer.parseInt(attr.getValue());
                            if (i1 != 0) {
                                batInSlot++;
                            }
                        }
                    }
                    mBinding.invBatteryInSlot.setValue(String.valueOf(batInSlot));
                }
            }
        }
    }

    private void configCabinet(int type, int value) {
        getViewModel().configCabinet("", "", deviceSn, type, value);
    }


    private static final int TYPE_SWAP_THRESHOLD = 1;
    private static final int TYPE_APN = 2;
    private static final int TYPE_VOLUME = 3;
    private static final int TYPE_PLATFORM_URL = 4;

    private BottomSheetDialog mBottomSheetDialog;
    private EditText editText;
    private TextView tvTitle;
    private String swapThreshold, apn, platformUrl;
    private int mType;

    public void initBottomSheet() {
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = new BottomSheetDialog(getContext());
            View view = LayoutInflater.from(getContext()).inflate(R.layout.dialog_edit_text1, null, false);
            tvTitle = (TextView) view.findViewById(R.id.tvTitle);
            editText = (EditText) view.findViewById(R.id.etInput);
            ImageView imgClear = view.findViewById(R.id.imClear);
            imgClear.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    editText.setText("");
                }
            });
            TextView btnConfirm = (TextView) view.findViewById(R.id.btnConfirm);
            TextView btnCancel = (TextView) view.findViewById(R.id.btnCancel);
            editText.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {

                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {

                }

                @Override
                public void afterTextChanged(Editable s) {
                    switch (mType) {
                        case TYPE_SWAP_THRESHOLD:
                            swapThreshold = s.toString();
                            break;
                        case TYPE_APN:
                            apn = s.toString();
                            break;
                        case TYPE_PLATFORM_URL:
                            platformUrl = s.toString();
                            break;
                    }
                }
            });
            btnConfirm.setOnClickListener(v -> {
                switch (mType) {
                    case TYPE_SWAP_THRESHOLD://阈值
                        if (TextUtils.isEmpty(swapThreshold)) {
                            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_offline_enter_swap_threshold));
                            return;
                        }
                        if (Integer.parseInt(swapThreshold) > maxChargeSoc) {
                            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_offline_enter_swap_threshold_error_d, maxChargeSoc));
                            return;
                        }
                        if (BluetoothBleUtil.getInstance().isConnected()) {
                            String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.CONTROL_REQUEST, deviceSn, getViewModel().buildParamSetting(CabinetParamName.CAB_SOC, swapThreshold)));
                            BluetoothBleUtil.getInstance().addDataToQueue(gson);
                        } else {
                            ToastUtils.showShort(getString(R.string.please_connect_device));
                        }
                        break;
                    case TYPE_APN://APN
                        if (TextUtils.isEmpty(apn)) {
                            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_offline_enter_apn));
                            return;
                        }
                        if (apn.length() > 200) {
                            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_offline_enter_max_len_d, 200));
                            return;
                        }
                        if (BluetoothBleUtil.getInstance().isConnected()) {
                            String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.CONTROL_REQUEST, deviceSn, getViewModel().buildParamSetting(CabinetParamName.APN, apn)));
                            BluetoothBleUtil.getInstance().addDataToQueue(gson);
                        } else {
                            ToastUtils.showShort(getString(R.string.please_connect_device));
                        }
                        break;
                    case TYPE_PLATFORM_URL://URL
                        if (TextUtils.isEmpty(platformUrl)) {
                            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_offline_enter_url));
                            return;
                        }
                        if (!platformUrl.contains(":")) {
                            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_offline_enter_url_error));
                            return;
                        }
                        if (platformUrl.split(":").length > 2) {
                            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_offline_enter_format_error));
                            return;
                        }
                        if (platformUrl.length() > 200) {
                            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_offline_enter_max_len_d, 200));
                            return;
                        }
                        if (BluetoothBleUtil.getInstance().isConnected()) {
                            String url = platformUrl.replace(":", ",");
                            String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.CONTROL_REQUEST, deviceSn, getViewModel().buildParamSetting(CabinetParamName.CAB_TCP_PORT, url)));
                            BluetoothBleUtil.getInstance().addDataToQueue(gson);
                        } else {
                            ToastUtils.showShort(getString(R.string.please_connect_device));
                        }
                        break;
                }
                mBottomSheetDialog.dismiss();
            });
            btnCancel.setOnClickListener(v -> mBottomSheetDialog.dismiss());
            mBottomSheetDialog.setContentView(view);
        }
        switch (mType) {
            case TYPE_SWAP_THRESHOLD:
                tvTitle.setText(getString(R.string.cabinet_opt_cabinet_offline_swap_threshold));
                editText.setHint(getString(R.string.cabinet_opt_cabinet_offline_enter_swap_threshold));
                editText.setText(mBinding.invSwapThreshold.getValue());
                editText.setInputType(InputType.TYPE_CLASS_NUMBER);
                swapThreshold = mBinding.invSwapThreshold.getValue();
                break;
            case TYPE_APN:
                tvTitle.setText(getString(R.string.cabinet_opt_cabinet_offline_apn));
                editText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_NORMAL);
                // 设置输入过滤器，限制只输入字母和数字
                InputFilter filter = (source, start, end, dest, dstart, dend) -> {
                    // 正则表达式：只允许字母和数字
                    if (source.toString().matches("[a-zA-Z0-9]*")) {
                        return null;  // 返回 null 表示输入合法
                    } else {
                        return "";  // 返回空字符串表示输入非法
                    }
                };
                editText.setFilters(new InputFilter[]{filter});
                editText.setText(mBinding.invAPN.getValue());
                editText.setHint(getString(R.string.cabinet_opt_cabinet_offline_enter_apn));
                apn = mBinding.invAPN.getValue();
                break;
            case TYPE_PLATFORM_URL:
                tvTitle.setText(getString(R.string.cabinet_opt_cabinet_offline_platform_url));
                editText.setFilters(new InputFilter[]{});
                editText.setInputType(InputType.TYPE_CLASS_TEXT);
                editText.setText(mBinding.invPlatformURL.getValue());
                editText.setHint(getString(R.string.cabinet_opt_cabinet_offline_enter_url));
                platformUrl = mBinding.invPlatformURL.getValue();
                break;
        }
        if (mBottomSheetDialog.getWindow() != null)
            mBottomSheetDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        if (getActivity() != null && getActivity().getWindow() != null) {
            getActivity().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        }
        mBottomSheetDialog.show();
    }

    private BottomSheetDialog mBottomVolumeDialog;
    private TextView tvVolume;
    private SeekBar seekBar;
    private int mVolume;

    public void initBottomVolumeDialog() {
        if (mBottomVolumeDialog == null) {
            mBottomVolumeDialog = new BottomSheetDialog(getContext());
            View view = LayoutInflater.from(getContext()).inflate(R.layout.dialog_edit_volume, null, false);
            tvVolume = (TextView) view.findViewById(R.id.tvVolume);
            seekBar = (SeekBar) view.findViewById(R.id.seekBar);
            seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    mVolume = progress;
                    tvVolume.setText(String.valueOf(progress));
                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {

                }
            });
            TextView btnConfirm = (TextView) view.findViewById(R.id.btnConfirm);
            TextView btnCancel = (TextView) view.findViewById(R.id.btnCancel);
            btnConfirm.setOnClickListener(v -> {
                mBottomVolumeDialog.dismiss();
                if (BluetoothBleUtil.getInstance().isConnected()) {
                    String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.CONTROL_REQUEST, deviceSn, getViewModel().buildParamSetting(CabinetParamName.CAB_VOLUME, String.valueOf(mVolume))));
                    BluetoothBleUtil.getInstance().addDataToQueue(gson);
                } else {
                    ToastUtils.showShort(getString(R.string.please_connect_device));
                }
            });
            btnCancel.setOnClickListener(v -> mBottomVolumeDialog.dismiss());
            mBottomVolumeDialog.setContentView(view);
        }
        String value = mBinding.invVolume.getValue();
        if (TextUtils.isEmpty(value)) {
            tvVolume.setText("0");
        } else {
            tvVolume.setText(value);
        }
        try {
            mVolume = Integer.parseInt(value);
        } catch (Exception e) {
            mVolume = 0;
        }
        seekBar.setProgress(mVolume);
        mBottomVolumeDialog.show();
    }
}
