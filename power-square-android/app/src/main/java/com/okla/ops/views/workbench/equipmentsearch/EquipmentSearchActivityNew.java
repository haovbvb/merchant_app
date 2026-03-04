package com.okla.ops.views.workbench.equipmentsearch;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.Preferences;
import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.utils.ToastUtils;
import com.base.common.utils.WindowInsetsHelper;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.okla.ops.R;
import com.okla.ops.beans.DeviceTypeObject;
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew;
import com.okla.ops.beans.ManagerInfo;
import com.okla.ops.custom.SearchTitleView;
import com.okla.ops.custom.usersearch.UserSearchHistoryView;
import com.okla.ops.databinding.ActivityEquipmentSearchNewBinding;
import com.okla.ops.utils.ScanUtils;
import com.okla.ops.views.PromoteWebActivity;
import com.okla.ops.views.workbench.QRCodeActivity;
import com.okla.ops.views.workbench.devicedetail.DeviceDetailFragment;
import com.orhanobut.logger.Logger;

import java.util.List;

import razerdp.basepopup.QuickPopupBuilder;
import razerdp.basepopup.QuickPopupConfig;
import razerdp.widget.QuickPopup;

public class EquipmentSearchActivityNew extends BaseNormalVActivity<EquipmentSearchViewModelNew, ActivityEquipmentSearchNewBinding> {

    private Observer<EquipmentDeviceSearchBeanNew> mEquipmentDeviceSearchObserver;
    private Observer<Object> mOpenCabinBackDoorObserver;

    private int tabindex;
    public static final int QUERY_DEVICE = 1;//查询设备
    public static final int OPT_DEVICE = 2;//电柜操作
    public static final int OPT_OPEN_DOOR = 3;//开电柜门

    private int type = -1;//1.查询设备 2.电柜操作

    public static Intent getIntents(Context context, String sn, int tabIndex, int optType, boolean isFromStation) {
        Intent intent = new Intent(context, EquipmentSearchActivityNew.class);
        intent.putExtra("sn", sn);
        intent.putExtra("tabindex", tabIndex);
        intent.putExtra("optType", optType);
        intent.putExtra("isFromStation", isFromStation);
        return intent;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_equipment_search_new;
    }

    @Override
    protected EquipmentSearchViewModelNew onCreateViewModel() {
        return new ViewModelProvider(this).get(EquipmentSearchViewModelNew.class);
    }

    private String inputString;
    private boolean isFromStation;

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setView(this);
        WindowInsetsHelper.applyForToolbar(this,mBinding.llEditScan.getId());
        initObserver();
        initClicks();
        initData();
        String strSn = getIntent().getStringExtra("sn").trim();
        tabindex = getIntent().getIntExtra("tabindex", 0);
        type = getIntent().getIntExtra("optType", 0);
        isFromStation = getIntent().getBooleanExtra("isFromStation", isFromStation);
        if (!TextUtils.isEmpty(strSn)) {
            mBinding.llEditScan.setEditContent(strSn);
            inputString = strSn;
            queryDeviceData();
        } else {
            new Handler().postDelayed(() -> mBinding.llEditScan.showInputKeyword(), 500);
        }
    }

    private void initObserver() {
        mOpenCabinBackDoorObserver = bean -> {
            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_open_success));
        };

        mBinding.vUserSearchHistory.setListener(new UserSearchHistoryView.OnClickListener() {
            @Override
            public void onSelectedName(@NonNull String id) {
                hideSoftInput();
                inputString = id;
                mBinding.llEditScan.setEditContent(id);
                queryDeviceData();
            }

            @Override
            public void onClearSearchName() {
                Preferences.getInstance().setSearchDevice("");
            }
        });

        mEquipmentDeviceSearchObserver = bean -> {
            if (bean != null) {
//                if ((bean.getType() != 3 && type == OPT_DEVICE) || (bean.getType() != 3 && type == OPT_OPEN_DOOR)) {
//                    ToastUtils.showShort(getString(R.string.putaway_cabinet_pid_tip));
//                    return;
//                }
                if(isFromStation){
                    bean.setType(DeviceTypeObject.TYPE_STATION);
                }
                if (type == OPT_DEVICE || type == QUERY_DEVICE) {
                    mBinding.flContent.setVisibility(View.VISIBLE);
                    mBinding.vUserSearchHistory.setVisibility(View.GONE);
                    getSupportFragmentManager().beginTransaction()
                            .replace(R.id.flContent, DeviceDetailFragment.getInstance(bean, 0, type))
                            .commit();
                    getViewModel().saveSearchHistory(bean.getDeviceInfo().getSn());
                    Integer hasPermission = bean.getDeviceInfo().getHasPermission();
                    List<ManagerInfo> managerList = bean.getDeviceInfo().getManagerList();
                    if (hasPermission != null && hasPermission == 0 && type == OPT_DEVICE && managerList != null && managerList.size() > 0) {
                        showSetDisableDialog(bean);
                    }
                }
                if (type == OPT_OPEN_DOOR) {
                    mStationSn = bean.getDeviceInfo().getSn();
                    showTipDialog();
                }
            }else {
                mBinding.flContent.setVisibility(View.GONE);
                mBinding.vUserSearchHistory.setVisibility(View.VISIBLE);
            }
        };

        getViewModel().searchHistoryListMutableLiveData.observe(this, userSearchHistories -> mBinding.vUserSearchHistory.setHistoryNameData(userSearchHistories));
//        getSnByPidObserver = deviceSn -> {
//            if (!TextUtils.isEmpty(deviceSn)) {
//                if (!deviceSn.contains("sn=") && deviceSn.contains("http")) {
//                    startActivityForResult(PromoteWebActivity.getIntents(mContext, deviceSn, true), PromoteWebActivity.PARSE_REQUEST_CODE);
//                } else {
//                    inputString = deviceSn;
//                    mBinding.llEditScan.setEditContent(inputString);
//                    queryDeviceData();
//                }
//            }
//        };
    }

    private String mStationSn;
    private QuickPopup mTipDialog;

    /**
     * 操作提示
     */
    private void showTipDialog() {
        mTipDialog = QuickPopupBuilder.with(this).contentView(R.layout.dialog_warning)
                .config(new QuickPopupConfig()
                        .gravity(Gravity.CENTER)
                        .outSideTouchable(false)
                        .outSideDismiss(false)
                        .backpressEnable(false)
                        .withClick(R.id.btn_cancel, v -> mTipDialog.dismiss())
                        .withClick(R.id.btn_ok, v -> {
                            mTipDialog.dismiss();
                            if (!TextUtils.isEmpty(mStationSn))
                                getViewModel().openCabinBackDoor(mStationSn).observe(this, mOpenCabinBackDoorObserver);
                        })).build();
        mTipDialog.showPopupWindow();
        mTipDialog.getContentView().post(() -> {
            TextView tvContent = mTipDialog.findViewById(R.id.tvContent);
            if (tvContent != null) {
                tvContent.setText(getString(R.string.cabinet_opt_cabinet_open_confirm_tips));
            }
        });
    }

    private void initClicks() {
        mBinding.llEditScan.setEditHint(getString(R.string.device_search_input_tip));
        mBinding.llEditScan.findViewById(R.id.imScan).setVisibility(View.VISIBLE);
        mBinding.llEditScan.setOnSearchTitleListener(new SearchTitleView.OnSearchTitleListener() {
            @Override
            public void onSearchContent(String content) {
                hideSoftInput();
                if (TextUtils.isEmpty(content)) {
                    ToastUtils.showShort(mBinding.llEditScan.getEditHint());
                    return;
                }
                inputString = content;
                queryDeviceData();
            }

            @Override
            public void onContentUpdate(String content) {
                inputString = content;
            }

            @Override
            public void onContentCLear() {
                mBinding.flContent.setVisibility(View.GONE);
                mBinding.vUserSearchHistory.setVisibility(View.VISIBLE);
            }

            @Override
            public void onBack() {
                finish();
            }

            @Override
            public void onScan() {
                new IntentIntegrator(EquipmentSearchActivityNew.this)
                        .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                        .setOrientationLocked(false)
                        .setCaptureActivity(QRCodeActivity.class) // 设置自定义的activity是CustomActivity
                        .initiateScan(); //  初始化扫描
            }
        });
    }

    private void initData() {
        getViewModel().readSearchHistory();
    }

    private void queryDeviceData() {
        if(isFromStation){
           getViewModel().getStationDetail(inputString.trim()).observe(this, mEquipmentDeviceSearchObserver);
        }else {
            getViewModel().getDeviceListSearchData(inputString.trim()).observe(this, mEquipmentDeviceSearchObserver);
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
                if (!TextUtils.isEmpty(scanMessage)) {
//                    if (isFromStation) {
//                        //只能扫码电柜
//                        if (scanMessage.contains("sn=") && scanMessage.contains("tenantId=")) {
//                            String stationSn = ScanUtils.Companion.parseStationQr(mContext, scanMessage).getSn();
//                            if (!TextUtils.isEmpty(stationSn)) {
//                                inputString = stationSn;
//                                mBinding.llEditScan.setEditContent(inputString);
//                                queryDeviceData();
//                            }
//                        } else {
//                            ToastUtils.showShort(getString(R.string.invalid_station_qr_code));
//                            return;
//                        }
//                    } else {
                        String deviceSn = ScanUtils.Companion.getDeviceSn(mContext, scanMessage);
                        if (!TextUtils.isEmpty(deviceSn)) {
                            inputString = deviceSn;
                            mBinding.llEditScan.setEditContent(inputString);
                            queryDeviceData();
                        }
//                    }
                } else {
                    ToastUtils.showShort(getString(R.string.invalid_qr_code));
                }
            }
        } else if (requestCode == PromoteWebActivity.PARSE_REQUEST_CODE) {
            if (data != null) {
                String parseResult = data.getStringExtra("parse_result");
                inputString = ScanUtils.Companion.getDeviceSn(mContext, parseResult);
                mBinding.llEditScan.setEditContent(inputString);
                if (!TextUtils.isEmpty(inputString)) {
                    queryDeviceData();
                } else {
                    ToastUtils.showShort(getString(R.string.invalid_qr_code));
                }
            }
        }
    }

    private QuickPopup setDisableDialog;

    public void showSetDisableDialog(EquipmentDeviceSearchBeanNew beanNew) {
        setDisableDialog = QuickPopupBuilder.with(this)
                .contentView(R.layout.dialog_manager_info)
                .config(new QuickPopupConfig()
                        .gravity(Gravity.CENTER)
                        .backpressEnable(false)
                        .dismissOnOutSideTouch(false)
                        .outSideTouchable(false)
                        .withClick(R.id.tvOK, view -> {

                        }, true)
                ).build();
        setDisableDialog.setBackPressEnable(false);
//        ((TextView) setDisableDialog.getContentView().findViewById(R.id.tvTip)).setText(getString(R.string.user_activation_buy_combo_suc_tip));
        setDisableDialog.showPopupWindow();
        String name = "";
        String phone = "";
        List<ManagerInfo> managerList = beanNew.getDeviceInfo().getManagerList();
        if (managerList != null && managerList.size() > 0) {
            ManagerInfo managerInfo = managerList.get(0);
            name = managerInfo.getShowName();
            phone = managerInfo.getPhone();
            String areaCode = Preferences.getInstance().getAreaCode();
            if (!TextUtils.isEmpty(areaCode))
                phone = areaCode + " " + phone;
        }
        ((TextView) setDisableDialog.findViewById(R.id.tvManagerValue)).setText(name);
        ((TextView) setDisableDialog.findViewById(R.id.tvPhoneValue)).setText(phone);
    }


}