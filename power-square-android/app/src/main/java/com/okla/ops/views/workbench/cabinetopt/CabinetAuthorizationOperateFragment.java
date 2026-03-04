package com.okla.ops.views.workbench.cabinetopt;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.SavedStateHandle;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavBackStackEntry;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.fragment.NavHostFragment;

import com.base.common.Preferences;
import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.timepicker.CustomDatePicker;
import com.base.common.timepicker.DateFormatUtils;
import com.base.common.utils.DateTimeUtils;
import com.base.common.utils.ToastUtils;
import com.base.common.utils.WindowInsetsHelper;
import com.base.library.utils.GsonUtils;
import com.okla.ops.R;
import com.okla.ops.beans.UserAuthorizationBean;
import com.okla.ops.databinding.FragmentCabinetAuthorizationOptBinding;

import java.util.Locale;

public class CabinetAuthorizationOperateFragment extends BaseNormalVFragment<CabinetAuthorizationOperateViewModel, FragmentCabinetAuthorizationOptBinding> {
    @Override
    protected int getLayoutId() {
        return R.layout.fragment_cabinet_authorization_opt;
    }

    @Override
    protected CabinetAuthorizationOperateViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinetAuthorizationOperateViewModel.class);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        initObserver();
        initClicks();
        initData();
    }

    private void initObserver() {
        NavBackStackEntry currentBackStackEntry = NavHostFragment.findNavController(this).getCurrentBackStackEntry();
        if (currentBackStackEntry != null) {
            SavedStateHandle savedStateHandle = currentBackStackEntry.getSavedStateHandle();
            MutableLiveData<String> userGson = savedStateHandle.getLiveData("USER");
            userGson.observe(getViewLifecycleOwner(), u -> {
                if (!TextUtils.isEmpty(u)) {
                    UserAuthorizationBean userAuthorizationBean = GsonUtils.fromGson(u, UserAuthorizationBean.class);
                    if (userAuthorizationBean != null) {
                        accountNo = userAuthorizationBean.getAccountNo();
                        mBinding.vSelectAuthorization.setValue(userAuthorizationBean.getUsername() + " (" + userAuthorizationBean.getPhone() + ")");
                    }
                }
            });
            MutableLiveData<String> sn = savedStateHandle.getLiveData("SN");
            sn.observe(getViewLifecycleOwner(), s -> {
                if (!TextUtils.isEmpty(s)) {
                    boolean isUpdate = !TextUtils.equals(stationSn, s);
                    stationSn = s;
                    mBinding.vSelectCabinet.setValue(stationSn);
                    if (isUpdate) {
                        accountNo = "";
                        mBinding.vSelectAuthorization.setValue("");
                    }
                }
            });
        }
        getViewModel().mPermissionData.observe(this, o -> {
            if (o != null) {
                ToastUtils.showShort(getString(R.string.sucess));
                Locale locale = DateTimeUtils.getLocaleByLanguage(Preferences.getInstance().getLanguage());
                stationSn = "";
                mBinding.vSelectCabinet.setValue("");
                accountNo = "";
                mBinding.vSelectAuthorization.setValue("");
                mBinding.tvAuthorizationBegin.setText(DateFormatUtils.long2Str1(mBeginTime, true, locale));
                mBinding.tvAuthorizationEnd.setText(DateFormatUtils.long2Str1(mBeginTime + 1000 * 60 * 60 * 24, true, locale));
                NavBackStackEntry navBackStackEntry = NavHostFragment.findNavController(this).getCurrentBackStackEntry();
                if (navBackStackEntry != null) {
                    SavedStateHandle savedStateHandle = navBackStackEntry.getSavedStateHandle();
                    savedStateHandle.remove("USER");
                    savedStateHandle.remove("SN");
                }
                getViewModel().mPermissionData.setValue(null);
            }
        });
    }

    private String stationSn = "";
    private String accountNo = "";

    private void initClicks() {
        mBinding.vSelectCabinet.setOnClickListener(v -> {
            NavController navController = Navigation.findNavController(v);
            Bundle bundle = new Bundle();
            bundle.putString("sn", stationSn);
            navController.navigate(R.id.action_one_to_two, bundle);
        });
        mBinding.vSelectAuthorization.setOnClickListener(v -> {
            if (TextUtils.isEmpty(stationSn)) {
                ToastUtils.showShort(getString(R.string.cabinet_opt_select_cabinet));
                return;
            }
            NavController navController = Navigation.findNavController(v);
            Bundle bundle = new Bundle();
            bundle.putString("sn", stationSn);
            bundle.putString("accountNo", accountNo);
            navController.navigate(R.id.action_one_to_three, bundle);
        });
        mBinding.includeTitle.topBack.setOnClickListener(v -> {
            if (!Navigation.findNavController(v).popBackStack()) {
                mActivity.finish();
            }
        });
        mBinding.tvAuthorizationBegin.setOnClickListener(v -> {
            selectTimeType = BEGIN_TIME_SELECT;
            initTimerPicker();
        });
        mBinding.tvAuthorizationEnd.setOnClickListener(v -> {
            selectTimeType = END_TIME_SELECT;
            initTimerPicker();
        });
        mBinding.btnConfirm.setOnClickListener(v -> {
            if (TextUtils.isEmpty(stationSn)) {
                ToastUtils.showShort(getString(R.string.cabinet_opt_select_cabinet));
                return;
            }
            if (TextUtils.isEmpty(accountNo)) {
                ToastUtils.showShort(getString(R.string.cabinet_opt_select_authorization));
                return;
            }
            String beginTime = mBinding.tvAuthorizationBegin.getText().toString();
            String endTime = mBinding.tvAuthorizationEnd.getText().toString();
            beginTime = DateTimeUtils.changeDateFormatYH(beginTime);
            endTime = DateTimeUtils.changeDateFormatYH(endTime);
            getViewModel().stationPermission(stationSn, accountNo, beginTime, endTime);
        });
        mBinding.btnRecord.setOnClickListener(v -> {
            Navigation.findNavController(v).navigate(R.id.action_one_to_four);
        });
    }

    private void initData() {
        Locale locale = DateTimeUtils.getLocaleByLanguage(Preferences.getInstance().getLanguage());
        mBeginTime = System.currentTimeMillis();
        mBinding.includeTitle.topTitle.setText(getString(R.string.cabinet_opt_cabinet_authorization_title));
        mBinding.includeTitle.topTitle.setGravity(Gravity.CENTER);
        mBinding.tvAuthorizationBegin.setText(DateFormatUtils.long2Str1(mBeginTime, true, locale));
        mBinding.tvAuthorizationEnd.setText(DateFormatUtils.long2Str1(mBeginTime + 1000 * 60 * 60 * 24, true, locale));
    }

    private static final long DAY = 30L;
    private static final int BEGIN_TIME_SELECT = 0;
    private static final int END_TIME_SELECT = 1;
    private int selectTimeType = BEGIN_TIME_SELECT;
    private long mBeginTime = 0;

    private void initTimerPicker() {
        String beginTime = mBinding.tvAuthorizationBegin.getText().toString();
        beginTime = DateTimeUtils.changeDateFormatYH(beginTime);
        long bt = DateFormatUtils.str2Long(beginTime, true);
        String endTime = DateFormatUtils.long2Str(bt + 1000 * 60 * 60 * 24 * DAY, true);
        // 通过日期字符串初始化日期，格式请用：yyyy-MM-dd HH:mm
        CustomDatePicker mTimerPicker = new CustomDatePicker(getContext(), new CustomDatePicker.Callback() {
            @Override
            public void onTimeSelected(long timestamp) {
                if(timestamp<=0){
                    return;
                }
                Locale locale = DateTimeUtils.getLocaleByLanguage(Preferences.getInstance().getLanguage());
                switch (selectTimeType) {
                    case BEGIN_TIME_SELECT:
                        mBeginTime = timestamp;
                        mBinding.tvAuthorizationBegin.setText(DateFormatUtils.long2Str1(timestamp, true, locale));
                        break;
                    case END_TIME_SELECT:
                        if (mBeginTime > timestamp) {
                            ToastUtils.showShort(getString(R.string.cabinet_opt_end_time_error));
                            break;
                        }
                        mBinding.tvAuthorizationEnd.setText(DateFormatUtils.long2Str1(timestamp, true, locale));
                        break;
                }
            }
        }, beginTime, endTime);
        // 允许点击屏幕或物理返回键关闭
        mTimerPicker.setCancelable(true);
        // 显示时和分
        mTimerPicker.setCanShowPreciseTime(true);
        // 允许循环滚动
        mTimerPicker.setScrollLoop(true);
        // 允许滚动动画
        mTimerPicker.setCanShowAnim(true);

        mTimerPicker.show(beginTime);
    }

}
