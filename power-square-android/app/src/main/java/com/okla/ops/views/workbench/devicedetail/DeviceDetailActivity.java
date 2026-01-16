package com.okla.ops.views.workbench.devicedetail;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;

import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.okla.ops.R;
import com.okla.ops.beans.DeviceTypeObject;
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew;
import com.okla.ops.databinding.ActivityDeviceDetailBinding;
import com.okla.ops.views.workbench.equipmentsearch.EquipmentSearchViewModelNew;

import razerdp.widget.QuickPopup;

public class DeviceDetailActivity extends BaseNormalVActivity<EquipmentSearchViewModelNew, ActivityDeviceDetailBinding> {

    private Observer<EquipmentDeviceSearchBeanNew> mEquipmentDeviceSearchObserver;

    public static void startDeviceDetailActivity(Context context, String sn, int type) {
        Intent intent = new Intent(context, DeviceDetailActivity.class);
        intent.putExtra("sn", sn);
        intent.putExtra("type", type);
        context.startActivity(intent);
    }

    public static Intent getIntents(Context context, String sn, int type) {
        Intent intent = new Intent(context, DeviceDetailActivity.class);
        intent.putExtra("sn", sn);
        intent.putExtra("type", type);
        return intent;
    }

    public static Intent getIntents(Context context, String sn) {
        Intent intent = new Intent(context, DeviceDetailActivity.class);
        intent.putExtra("sn", sn);
        return intent;
    }

    @Override
    protected EquipmentSearchViewModelNew onCreateViewModel() {
        return new ViewModelProvider(this).get(EquipmentSearchViewModelNew.class);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_device_detail;
    }

    @Override
    public int title() {
        if (deviceType == DeviceTypeObject.TYPE_BATTERY) {
            return R.string.textBatteryDetail;
        } else if (deviceType == DeviceTypeObject.TYPE_VEHICLE) {
            return R.string.details_of_central_control;
        } else {
            return R.string.str_device;
        }
    }


    private int deviceType;
    private String deviceSn;

    @Override
    protected void getIntentExtras(Intent intent) {
        super.getIntentExtras(intent);
        deviceType = getIntent().getIntExtra("type", 1);
        deviceSn = getIntent().getStringExtra("sn");
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setView(this);
        mBinding.includeTitle.topTitle.setGravity(Gravity.CENTER);
        initObserver();
        if (!TextUtils.isEmpty(deviceSn)) {
            getViewModel().getDeviceListSearchData(deviceSn).observe(this, mEquipmentDeviceSearchObserver);
        } else {
            finish();
        }
    }

    private void initObserver() {
        mEquipmentDeviceSearchObserver = bean -> {
            if (bean != null) {
                /*if (bean.getType() != 1) {
                    return;
                }*/
                mBinding.flContent.setVisibility(View.VISIBLE);
                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.flContent, DeviceDetailFragment.getInstance(bean,0,DeviceWarehouseFragment.OPERATE_TYPE_READ_ONLY))
                        .commit();
                getViewModel().saveSearchHistory(bean.getDeviceInfo().getSn());
                /*Integer hasPermission = bean.getDeviceInfo().getHasPermission();
                List<ManagerInfo> managerList = bean.getDeviceInfo().getManagerList();
                if (hasPermission != null && hasPermission == 0 && managerList != null && managerList.size() > 0) {
                    showSetDisableDialog(bean);
                }*/
            }
        };
    }

    private QuickPopup setDisableDialog;

//    public void showSetDisableDialog(EquipmentDeviceSearchBeanNew beanNew) {
//        setDisableDialog = QuickPopupBuilder.with(this)
//                .contentView(R.layout.dialog_manager_info)
//                .config(new QuickPopupConfig()
//                        .gravity(Gravity.CENTER)
//                        .backpressEnable(false)
//                        .dismissOnOutSideTouch(false)
//                        .outSideTouchable(false)
//                        .withClick(R.id.tvOK, view -> {
//
//                        }, true)
//                ).build();
//        setDisableDialog.setBackPressEnable(false);
////        ((TextView) setDisableDialog.getContentView().findViewById(R.id.tvTip)).setText(getString(R.string.user_activation_buy_combo_suc_tip));
//        setDisableDialog.showPopupWindow();
//        StringBuilder names = new StringBuilder();
//        List<ManagerInfo> managerList = beanNew.getDeviceInfo().getManagerList();
//        if (managerList != null && managerList.size() > 0) {
//            for (int i = 0; i < managerList.size(); i++) {
//                ManagerInfo managerInfo = managerList.get(i);
//                names.append(managerInfo.getShowName());
//                if (i != managerList.size() - 1) {
//                    names.append(",");
//                }
//            }
//        }
//        ((TextView) setDisableDialog.findViewById(R.id.tvManagerValue)).setText(names.toString());
//    }

}
