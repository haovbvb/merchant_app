package com.okla.ops.views.monitor.cabinetdetail.operation.settings;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.SeekBar;
import android.widget.TimePicker;

import androidx.databinding.library.baseAdapters.BR;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.okla.ops.databinding.ActivitySettingsBinding;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.okla.ops.R;
import com.okla.ops.beans.SettingInfoBean;

import java.util.Calendar;

/**
 * @Date: 2021/2/24 14:58
 * @Author: craz
 * @Description:
 * @Version:
 */

public class SettingsActivity extends BaseNormalVActivity<SettingsViewModel, ActivitySettingsBinding> {

    private Observer<SettingInfoBean> getCabinetSettingInfoObserver;
    private Observer<String> updateCabinetSettingInfoObserver;
    private SettingInfoBean mSettingInfoBean;
    private String pidStr;
    private BottomSheetDialog mTimeSheetDialog;
    private View mTimeDialogView;
    private TimePicker timePicker;

    public static Intent getIntents(Context context,String pid) {
        Intent intent = new Intent(context, SettingsActivity.class);
        intent.putExtra("pid",pid);
        return intent;
    }

    @Override
    public int title() {
        return R.string.operation_setting_title;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_settings;
    }

    @Override
    protected SettingsViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(SettingsViewModel.class);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        pidStr = getIntent().getStringExtra("pid");
        mBinding.setView(this);
        initObserver();
        initListen();
    }

    private void initListen() {
        mBinding.sbEmptyCabinCheck.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mSettingInfoBean.getEmptySpaceDetection().setCount(seekBar.getProgress());
                updateSettingInfo();
            }
        });
        mBinding.sbHeatingAuto.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mSettingInfoBean.getHeating().getApkControl().setPermit(seekBar.getProgress());
                updateSettingInfo();
            }
        });
        mBinding.sbHeatingForbidden.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mSettingInfoBean.getHeating().getApkControl().setProhibit(seekBar.getProgress());
                updateSettingInfo();
            }
        });
        mBinding.sbPresetPower.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mSettingInfoBean.getChargingStrategy().setLevel(seekBar.getProgress());
                updateSettingInfo();
            }
        });
        mBinding.sbCanBeBorrowed.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mSettingInfoBean.getMinimumElectricityBorrowed().setLevel(seekBar.getProgress());
                updateSettingInfo();
            }
        });
    }

    private void initObserver() {
        getCabinetSettingInfoObserver = settingInfoBean -> {
            if(settingInfoBean != null) {
                mSettingInfoBean = settingInfoBean;
                mBinding.setVariable(BR.data, settingInfoBean);
                mBinding.sbEmptyCabinCheck.setProgress(mSettingInfoBean.getEmptySpaceDetection().getCount());
                mBinding.tvEmptyCabinCheckTip.setText(Html.fromHtml(getString(R.string.operation_setting_empty_cabin_check_tip_prefix)
                        + " <font color='#FB6800'>" + mSettingInfoBean.getEmptySpaceDetection().getCount()+ " </font>"
                        + getString(R.string.operation_setting_empty_cabin_check_tip_suffix)
                ));
            }else {
                finish();
            }
        };
        getViewModel().getCabinetSettingInfo(pidStr).observe(this,getCabinetSettingInfoObserver);

        updateCabinetSettingInfoObserver = str -> {

        };
    }

    private void updateSettingInfo() {
        getViewModel().updateCabinetSettingInfo(pidStr,mSettingInfoBean).observe(this,updateCabinetSettingInfoObserver);
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.tvPowerOutageTimeValue:
                isblackoutTimeClick = true;
                initBlackoutTimeBottomSheet();
                break;
            case R.id.tvChargingTimeValue:
                ischargingTimeClick = true;
                initBlackoutTimeBottomSheet();
            case R.id.ivRestartSwitch:
                if(mBinding.ivRestartSwitch.isSelected()){
                    mSettingInfoBean.getRestartTheChargerRegularly().setOpen(0);
                }else {
                    mSettingInfoBean.getRestartTheChargerRegularly().setOpen(1);
                }
                updateSettingInfo();
                break;
            case R.id.tvRestartTimeValue:
                isRestartTimeClick = true;
                initBlackoutTimeBottomSheet();
                break;
            case R.id.tvHeatingAuto:
                if(mBinding.ivHeatingAutoSwitch.isSelected()){
                    mSettingInfoBean.getHeating().getApkControl().setOpen(0);
                }else {
                    mSettingInfoBean.getHeating().getApkControl().setOpen(1);
                }
                updateSettingInfo();
                break;
            case R.id.tvPMSHeatingAuto:
                if(mBinding.ivPMSHeatingAuto.isSelected()){
                    mSettingInfoBean.getHeating().setPmsAutoControl(0);
                }else {
                    mSettingInfoBean.getHeating().setPmsAutoControl(1);
                }
                updateSettingInfo();
                break;
            case R.id.ivHomeDetailSwitch:
                if(mBinding.ivHomeDetailSwitch.isSelected()){
                    mSettingInfoBean.getHomePageDetails().setShow(0);
                }else {
                    mSettingInfoBean.getHomePageDetails().setShow(1);
                }
                updateSettingInfo();
                break;
            case R.id.ivMicroSwith:
                if(mBinding.ivMicroSwith.isSelected()){
                    mSettingInfoBean.getMicroSwitch().setOpen(0);
                }else {
                    mSettingInfoBean.getMicroSwitch().setOpen(1);
                }
                updateSettingInfo();
                break;
            case R.id.ivBatteryConnetorSwith:
                if(mBinding.ivBatteryConnetorSwith.isSelected()){
                    mSettingInfoBean.getBatteryConnector().setOpen(0);
                }else {
                    mSettingInfoBean.getBatteryConnector().setOpen(1);
                }
                updateSettingInfo();
                break;
            case R.id.tvLowBatteryPreferred:
                if(mBinding.ivLowBatteryPreferredSwitch.isSelected()){
                    mSettingInfoBean.getChargingStrategy().setType(0);
                }else {
                    mSettingInfoBean.getChargingStrategy().setType(1);
                }
                updateSettingInfo();
                break;
            case R.id.tvPresetPowerValue:
                if(mBinding.ivPresetPowerSwitch.isSelected()){
                    mSettingInfoBean.getChargingStrategy().setType(0);
                }else {
                    mSettingInfoBean.getChargingStrategy().setType(2);
                }
                updateSettingInfo();
                break;
            default:
                break;
        }
    }

    int mTimeHour,mTimeMinute;
    Calendar calendar;
    boolean isblackoutTimeClick,ischargingTimeClick,isRestartTimeClick;
    StringBuilder stringBuilder ;
    public void initBlackoutTimeBottomSheet() {
        stringBuilder = new StringBuilder();
        calendar = Calendar.getInstance();
        mTimeHour = calendar.get(Calendar.HOUR_OF_DAY);
        mTimeMinute = calendar.get(Calendar.MINUTE);
        mTimeSheetDialog = new BottomSheetDialog(this);
        mTimeDialogView = LayoutInflater.from(this).inflate(R.layout.datepicker_sheet, null, false);

        timePicker = (TimePicker) mTimeDialogView.findViewById(R.id.timePicker);
        timePicker.setDescendantFocusability(TimePicker.FOCUS_BLOCK_DESCENDANTS);  //设置点击事件不弹键盘
        timePicker.setIs24HourView(true);   //设置时间显示为24小时
//        timePicker.setHour(8);  //设置当前小时
//        timePicker.setMinute(10); //设置当前分（0-59）
        timePicker.setOnTimeChangedListener(new TimePicker.OnTimeChangedListener() {
            @Override
            public void onTimeChanged(TimePicker view, int hourOfDay, int minute) {
                mTimeHour = hourOfDay;
                mTimeMinute = minute;
            }
        });
        (mTimeDialogView.findViewById(R.id.tvCancel)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTimeSheetDialog.dismiss();
            }
        });
        (mTimeDialogView.findViewById(R.id.tvConfirm)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTimeSheetDialog.dismiss();
//                if(mTimeHour < 10){
//                    stringBuilder.append("0");
//                }
                stringBuilder.append(mTimeHour);
                stringBuilder.append(":");
//                if(mTimeMinute < 10) {
//                    stringBuilder.append("0");
//                }
                stringBuilder.append(mTimeMinute);
                if(isblackoutTimeClick){
                    mSettingInfoBean.getNoCharging().setBlackoutTime(stringBuilder.toString());
                }else if(ischargingTimeClick){
                    mSettingInfoBean.getNoCharging().setChargingTime(stringBuilder.toString());
                }else if(isRestartTimeClick){
                    mSettingInfoBean.getRestartTheChargerRegularly().setOpen(1);
                    mSettingInfoBean.getRestartTheChargerRegularly().setTime(stringBuilder.toString());
                }
                updateSettingInfo();
                isblackoutTimeClick = false;
                ischargingTimeClick = false;
                isRestartTimeClick = false;
            }
        });
        mTimeSheetDialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                isblackoutTimeClick = false;
                ischargingTimeClick = false;
            }
        });
        mTimeSheetDialog.setContentView(mTimeDialogView);
        mTimeSheetDialog.show();
    }
}