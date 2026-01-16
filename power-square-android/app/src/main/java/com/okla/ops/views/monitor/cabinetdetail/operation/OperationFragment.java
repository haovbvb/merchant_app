package com.okla.ops.views.monitor.cabinetdetail.operation;

import android.os.Bundle;
import android.view.View;

import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.dialog.CustomDialog;
import com.base.common.utils.ToastUtils;
import com.okla.ops.R;
import com.okla.ops.beans.TemporyPSWbean;
import com.okla.ops.databinding.FragmentOperationBinding;
import com.okla.ops.views.monitor.cabinetdetail.operation.settings.SettingsActivity;

/**
 * @Date: 2021/1/26 14:24
 * @Author: craz
 * @Description:
 * @Version:
 */

public class OperationFragment extends BaseNormalVFragment<OperationViewModel, FragmentOperationBinding> {

    private CustomDialog.Builder builder;
    private String mCabinetPID;
    private Observer<String> openElectronicLock,restartAndShutDownObserver,shutDownObserver;
    private Observer<TemporyPSWbean> temporyPSWObser;
    private TemporyPSWbean temporyPSWbean;
    private boolean isNoRemotePerssion=true;
    private boolean isNoTempPSWPermission=true;

    public static OperationFragment getInstance(String pid,boolean isNoRemotePerssion,boolean isNoTempPSWPermission) {
        OperationFragment fragment = new OperationFragment();
        Bundle bundle = new Bundle();
        bundle.putString("pid", pid);
        bundle.putBoolean("isNoRemotePerssion", isNoRemotePerssion);
        bundle.putBoolean("isNoTempPSWPermission", isNoTempPSWPermission);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_operation;
    }

    @Override
    protected OperationViewModel onCreateViewModel() {
        return new ViewModelProvider(getActivity()).get(OperationViewModel.class);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        mBinding.setView(this);
        mCabinetPID = getArguments().getString("pid");
        isNoRemotePerssion = getArguments().getBoolean("isNoRemotePerssion");
        isNoTempPSWPermission = getArguments().getBoolean("isNoTempPSWPermission");
        initObserver();
    }

    private void initObserver() {
        openElectronicLock = s -> {

        };
        restartAndShutDownObserver = s -> {

        };
        shutDownObserver = s -> {

        };
        temporyPSWObser = bean -> {
            if(bean != null){
                temporyPSWbean = bean;
                showTemporyPSWDialog();
            }
        };

    }

    String strMsg;
    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.tvOpenElectronlicLock:
                if(isNoRemotePerssion){
                    ToastUtils.showShort(getString(com.base.common.R.string.text_no_permission));
                    return;
                }
                strMsg = getString(R.string.operation_is_confirm_open_electronic_lock);
                showLockDialog();
                break;
            case R.id.tvShutdownCompleteMmachine:
                if(isNoRemotePerssion){
                    ToastUtils.showShort(getString(com.base.common.R.string.text_no_permission));
                    return;
                }
                strMsg = getString(R.string.operation_shutdown_complete_machine_tip);
                shutDownMachineMethod(1);
                break;
            case R.id.tvRestartCompleteMmachine:
                if(isNoRemotePerssion){
                    ToastUtils.showShort(getString(com.base.common.R.string.text_no_permission));
                    return;
                }
                strMsg = getString(R.string.operation_restart_complete_machine_tip);
                restartAndShutDownMethod(0,3);
                break;
            case R.id.tvRestartAndroidMmachine:
                if(isNoRemotePerssion){
                    ToastUtils.showShort(getString(com.base.common.R.string.text_no_permission));
                    return;
                }
                strMsg = getString(R.string.operation_restart_android_machine_tip);
                restartAndShutDownMethod(0,1);
                break;
            case R.id.tvRestartChargerPowerSuply:
                if(isNoRemotePerssion){
                    ToastUtils.showShort(getString(com.base.common.R.string.text_no_permission));
                    return;
                }
                strMsg = getString(R.string.operation_restart_charger_power_supply_tip);
                restartAndShutDownMethod(0,2);
                break;
            case R.id.tvUndo:
                if(isNoRemotePerssion){
                    ToastUtils.showShort(getString(com.base.common.R.string.text_no_permission));
                    return;
                }
                break;
            case R.id.tvSet:
                if(isNoRemotePerssion){
                    ToastUtils.showShort(getString(com.base.common.R.string.text_no_permission));
                    return;
                }
                startActivity(SettingsActivity.getIntents(getContext(),mCabinetPID));
                break;
            case R.id.tvTemporyPSW:
                if(isNoTempPSWPermission){
                    ToastUtils.showShort(getString(com.base.common.R.string.text_no_permission));
                    return;
                }
                getViewModel().getTemporyPSW(mCabinetPID).observe(this,temporyPSWObser);
                break;
            default:
                break;
        }
    }

    private void shutDownMachineMethod(int sleep) {
        //shutDown : 1 关机  其他重启
        //type : 1-安卓机  2-充电器   3-整机
        builder = new CustomDialog.Builder(getActivity())
                .setMessage(strMsg)
                .setNegativeButton((dialog, which) -> {
                    dialog.dismiss();
                })
                .setPositiveButton((dialog, which) -> {
                    getViewModel().shutDaownMachine(mCabinetPID,sleep).observe(this,shutDownObserver);
                    dialog.dismiss();
                });
        builder.create().show();
    }
    private void restartAndShutDownMethod(int shutDown,int type) {
        //shutDown : 1 关机  其他重启
        //type : 1-安卓机  2-充电器   3-整机
        builder = new CustomDialog.Builder(getActivity())
                .setMessage(strMsg)
                .setNegativeButton((dialog, which) -> {
                    dialog.dismiss();
                })
                .setPositiveButton((dialog, which) -> {
                    getViewModel().restartCompleteMachine(mCabinetPID,shutDown,type).observe(this,restartAndShutDownObserver);
                    dialog.dismiss();
                });
        builder.create().show();
    }
    private void showLockDialog() {
        builder = new CustomDialog.Builder(getActivity())
                .setMessage(strMsg)
                .setNegativeButton((dialog, which) -> {
                    dialog.dismiss();
                })
                .setPositiveButton((dialog, which) -> {
                    getViewModel().openElectronicLock(mCabinetPID, nID).observe(this,openElectronicLock);
                    dialog.dismiss();
                });
        builder.create().show();
    }
    private void showTemporyPSWDialog() {
        builder = new CustomDialog.Builder(getActivity())
                .setMessage(String.format(getString(R.string.operation_tempory_user_name), temporyPSWbean.getName(), temporyPSWbean.getNewPassword()))
                .setIKnowButton((dialog, which) -> {
                    dialog.dismiss();
                });
        builder.create().show();
    }

    private int nID = 1;
    public void reFreshSn(String mCabinetPID,int nID){
        this.mCabinetPID = mCabinetPID;
        this.nID = nID;
    }
}