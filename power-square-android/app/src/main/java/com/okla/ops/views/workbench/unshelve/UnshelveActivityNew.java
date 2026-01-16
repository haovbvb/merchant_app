package com.okla.ops.views.workbench.unshelve;

import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.dialog.CustomDialog;
import com.base.common.utils.ToastUtils;
import com.okla.ops.custom.FeedbackReasonsView;
import com.okla.ops.databinding.ActivityUnshelveNewBinding;
import com.okla.ops.utils.ScanUtils;
import com.okla.ops.utils.ViewClickUtils;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.okla.ops.views.PromoteWebActivity;
import com.okla.ops.weight.SnSearchInfoView;
import com.orhanobut.logger.Logger;
import com.okla.ops.R;
import com.okla.ops.beans.NewCabinetBean;
import com.okla.ops.custom.station.StationInfoDetailView;
import com.okla.ops.custom.station.StationInfoView;
import com.okla.ops.utils.EventUtils;
import com.okla.ops.views.workbench.QRCodeActivity;

import java.util.ArrayList;
import java.util.List;

/**
 * @Date: DATE.{TIME}
 * @Author: joe
 * @Description:
 * @Version: 换电柜下架
 */
public class UnshelveActivityNew extends BaseNormalVActivity<UnshelveViewModel, ActivityUnshelveNewBinding> {

    private Observer<Object> unshelveObserver;

    private Observer<String> getSnByPidObserver;
    private String batteryCabinetSn;
    private String feedbackReasons;

//    private String storeStatusStr="";

    public static Intent getIntents(Context context) {
        Intent intent = new Intent(context, UnshelveActivityNew.class);
        return intent;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_unshelve_new;
    }

    @Override
    protected UnshelveViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(UnshelveViewModel.class);
    }

//    @Override
//    public boolean isImmersive() {
//        return false;
//    }

    //    @Override
//    public boolean isInitImmersionBar() {
//        return false;
//    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setView(this);
        mBinding.setVm(viewModel);
        initObserver();
        initListener();
        initData();
    }

    private void initData() {
        mBinding.feedbackReasons.setReasonTitleAndHint(
                getString(R.string.stop_cabinet_unshelve_reasons),
                getString(R.string.stop_cabinet_unshelve_reasons_hint)
        );
        List<String> reasons = new ArrayList<String>();
        reasons.add(getString(R.string.stop_cabinet_unshelve_common_reasons_1));
        reasons.add(getString(R.string.stop_cabinet_unshelve_common_reasons_2));
        reasons.add(getString(R.string.stop_cabinet_unshelve_common_reasons_3));
        mBinding.feedbackReasons.initCommonReasons(reasons);
        mBinding.feedbackReasons.setOnTextInputListener(new FeedbackReasonsView.OnTextInputListener() {
            @Override
            public void onTextInputed(@NonNull String content) {
                enableBtnConfirm();
            }
        });
    }

    private void initListener() {
        mBinding.vStationInfo.setOnStationInfoListener(new StationInfoView.OnStationInfoListener() {
            @Override
            public void onScanClick() {
                batteryScan(QRCodeActivity.NORMAL);
            }

            @Override
            public void onEditTextNotHasFocus(String inputContent) {
                getCabinetNameAndType(inputContent);
            }
        });
        mBinding.vStationInfo.setOnEditTextActionListener(new StationInfoView.OnEditTextActionListener() {
            @Override
            public void onActionDone() {
                getCabinetNameAndType(mBinding.vStationInfo.getBatteryCabinetSn());

            }
        });
        mBinding.vStationInfo.setOnClearInputListener(new SnSearchInfoView.OnClearInputListener() {
            @Override
            public void onCleared() {
                stationSn="";
                mBinding.vStationInfo.removeAllViews();
                mBinding.feedbackReasons.clearFeedbackReason();
                enableBtnConfirm();
            }
        });

    }

    private StationInfoDetailView stationInfoDetailView;

    private String stationSn="";
    private void initObserver() {
        unshelveObserver = s -> {
            EventUtils.INSTANCE.getUnshelveReaderData().setValue(true);
            finish();
        };
        getSnByPidObserver = deviceSn -> {
            if (!TextUtils.isEmpty(deviceSn)) {
                if (!deviceSn.contains("sn=") && deviceSn.contains("http")) {
                    startActivityForResult(PromoteWebActivity.getIntents(mContext, deviceSn, true), PromoteWebActivity.PARSE_REQUEST_CODE);
                } else {
                    getCabinetNameAndType(deviceSn);
                }
            }
        };
        getViewModel().newCabinetBeanMutableLiveData.observe(this, newCabinetBean -> {
            if (newCabinetBean == null) {
                mBinding.vStationInfo.updateData("");
                stationSn="";
                ToastUtils.showShort(getString(R.string.invalid_qr_code));
            } else {
                if (stationInfoDetailView == null)
                    stationInfoDetailView = new StationInfoDetailView(this);
                stationInfoDetailView.setData(newCabinetBean);
                String sn = newCabinetBean.getSn();
                stationSn=sn;
                mBinding.vStationInfo.updateData(sn, stationInfoDetailView);
            }
            enableBtnConfirm();
        });
    }

    public void onClickView(View v) {
        switch (v.getId()) {
            case R.id.ivBack:
                finish();
                break;
            case R.id.tvConfirm:
                if (ViewClickUtils.isFastClick()) {
                    return;
                }
                batteryCabinetSn = mBinding.vStationInfo.getBatteryCabinetSn();
                feedbackReasons = mBinding.feedbackReasons.getFeedbackReason();
                if (TextUtils.isEmpty(batteryCabinetSn)) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_sn_toast_tip));
                    return;
                }
                if (TextUtils.isEmpty(feedbackReasons)) {
                    ToastUtils.showShort(getString(R.string.stop_cabinet_unshelve_reason));
                    return;
                }
//                if(TextUtils.isEmpty(storeStatusStr)){
//                    ToastUtils.showShort(getString(R.string.tip_please_select_storage_status));
//                    return;
//                }
                showTipDialog();
                break;
            default:
                break;
        }
    }

    private void enableBtnConfirm() {
        if (!TextUtils.isEmpty(stationSn)&& !TextUtils.isEmpty(mBinding.feedbackReasons.getFeedbackReason())) {
            mBinding.tvConfirm.setEnabled(true);
        } else {
            mBinding.tvConfirm.setEnabled(false);
        }
    }

    private String getCabinetSn() {
        NewCabinetBean value = viewModel.newCabinetBeanMutableLiveData.getValue();
        if (value == null || value.getSn() == null) {
            return "";
        }
        return value.getSn();
    }

    private void batteryScan(int type) {
        new IntentIntegrator(this)
                .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
                .setOrientationLocked(false)
                .setCaptureActivity(QRCodeActivity.class) // 设置自定义的activity是CustomActivity
                .initiateScan(); //  初始化扫描
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            String mScanedMessage = null;
            IntentResult intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
            if (intentResult != null && intentResult.getContents() != null) {
                mScanedMessage = intentResult.getContents();
                Logger.i("onActivityResult mScanedMessage = " + mScanedMessage);
                if(mScanedMessage.contains("http")||mScanedMessage.contains("https")){
                    if(mScanedMessage.contains("?")){
                        mScanedMessage= mScanedMessage.substring(mScanedMessage.indexOf("?")+1,mScanedMessage.length());
                    }else if(mScanedMessage.contains("？")){
                        mScanedMessage= mScanedMessage.substring(mScanedMessage.indexOf("？")+1,mScanedMessage.length());
                    }
                }
                getCabinetNameAndType(mScanedMessage);
//                if (mScanedMessage.contains("sn=")) {
//                    //正常扫描换电
//                    int index = mScanedMessage.indexOf("sn=");
//                    if (index > -1) {
//                        mScanedMessage = mScanedMessage.substring(index + 3);
//                    }
//                    getCabinetNameAndType(mScanedMessage);
//                } else if (!TextUtils.isEmpty(mScanedMessage)) {
//                    getViewModel().getDeviceSn(mScanedMessage).observe(this, getSnByPidObserver);
//                }
            }
        } else if (requestCode == PromoteWebActivity.PARSE_REQUEST_CODE) {
            if (data != null) {
                String parseResult = data.getStringExtra("parse_result");
                if(!TextUtils.isEmpty(parseResult)){
                    if(parseResult.contains("http")||parseResult.contains("https")){
                        if(parseResult.contains("?")){
                            parseResult= parseResult.substring(parseResult.indexOf("?")+1,parseResult.length());
                        }else if(parseResult.contains("？")){
                            parseResult= parseResult.substring(parseResult.indexOf("？")+1,parseResult.length());
                        }
                    }
                    getCabinetNameAndType(parseResult);
                }
//                if (!TextUtils.isEmpty(parseResult) && parseResult.contains("sn=")) {
//                    //正常扫描换电
//                    int index = parseResult.indexOf("sn=");
//                    if (index > -1) {
//                        parseResult = parseResult.substring(index + 3);
//                    }
//                }
//                getCabinetNameAndType(parseResult);
            }
        }
    }

    private void getCabinetNameAndType(String cabinetId) {
        if (TextUtils.isEmpty(cabinetId)) {
            return;
        }
        getViewModel().getStationType("2", cabinetId);
    }

    private CustomDialog tipDialog;
    private CustomDialog.Builder builder;

    public void showTipDialog() {
        builder = new CustomDialog.Builder(getActivity())
                .setTitle(getString(R.string.title_confirm_retire))
                .setMessage(getString(R.string.stop_cabinet_submit_tips))
                .setPositiveButton((dialog, which) -> {
                    getViewModel().unshelve(batteryCabinetSn, feedbackReasons).observe(this, unshelveObserver);
                    dialog.dismiss();
                })
                .setNegativeButton((dialog, which) -> {
                    dialog.dismiss();
                });
        tipDialog = builder.create();
        tipDialog.show();
    }


    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            // 无论是在 Fragment 还是 Activity 布局里的 EditText，都能拿到当前焦点
            View v = getCurrentFocus();
            if (v instanceof EditText) {
                // 计算点击区域是否在 EditText 之外
                Rect outRect = new Rect();
                v.getGlobalVisibleRect(outRect);
                if (!outRect.contains((int) ev.getRawX(), (int) ev.getRawY())) {
                    // 清除焦点并隐藏键盘
                    v.clearFocus();
                    InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                    if (imm != null) {
                        imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                    }
                }
            }
        }
        return super.dispatchTouchEvent(ev);
    }
}