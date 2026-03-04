package com.okla.ops.views.workbench.cabinetopt;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.viewpager2.widget.ViewPager2;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.ToastUtils;
import com.base.library.utils.GsonUtils;
import com.bumptech.glide.Glide;
import com.google.android.material.snackbar.Snackbar;
import com.okla.ops.R;
import com.okla.ops.adapter.ViewPager2FragmentAdapter;
import com.okla.ops.databinding.ActivityCabinetOfflineDetailBinding;
import com.okla.ops.utils.BluetoothBleUtil;
import com.okla.ops.utils.CabinetData;
import com.okla.ops.utils.CabinetDataResult;
import com.okla.ops.utils.CabinetDataType;
import com.okla.ops.utils.CabinetParam;
import com.okla.ops.utils.CabinetParamName;
import com.okla.ops.utils.CabinetSignal;
import com.okla.ops.utils.ResultInfo;

import net.lucode.hackware.magicindicator.FragmentContainerHelper;
import net.lucode.hackware.magicindicator.buildins.UIUtil;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.CommonNavigator;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.CommonNavigatorAdapter;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerIndicator;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerTitleView;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.indicators.LinePagerIndicator;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.titles.ColorTransitionPagerTitleView;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.titles.SimplePagerTitleView;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import razerdp.basepopup.QuickPopupBuilder;
import razerdp.basepopup.QuickPopupConfig;
import razerdp.widget.QuickPopup;

public class CabinetOfflineDetailActivity extends BaseNormalVActivity<CabinetOfflineViewModel, ActivityCabinetOfflineDetailBinding> {

    public static void startCabinetOfflineDetailActivity(Context context, String sn) {
        Intent intent = new Intent(context, CabinetOfflineDetailActivity.class);
        intent.putExtra("SN", sn);
        context.startActivity(intent);
    }

    @Override
    public int title() {
        return R.string.cabinet_detail_title;
    }

    @Override
    public void onRightImage() {
        super.onRightImage();
        if (BluetoothBleUtil.getInstance().isConnected()) {
            List<CabinetParam> params = getViewModel().buildParamSetting(CabinetSignal.ALL_DATA, "0");
            String gson2 = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.QUERY_REQUEST, deviceSn, params));
            BluetoothBleUtil.getInstance().addDataToQueue(gson2);
            getLoading().onStart();
            addDisposable(Observable.timer(10, TimeUnit.SECONDS) // 10 秒后触发
                    .observeOn(AndroidSchedulers.mainThread()) // 切换到主线程
                    .subscribe(aLong -> getLoading().onFinish()));
        }
    }

    @Override
    protected CabinetOfflineViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinetOfflineViewModel.class);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_cabinet_offline_detail;
    }

    private String deviceSn = "";

    @Override
    protected void getIntentExtras(Intent intent) {
        super.getIntentExtras(intent);
        deviceSn = intent.getStringExtra("SN");
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initBluetooth();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        BluetoothBleUtil.getInstance().destroy();
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.includeTitle.topRightImage.setVisibility(View.VISIBLE);
        mBinding.includeTitle.topRightImage.setImageDrawable(ContextCompat.getDrawable(this, R.mipmap.icon_flash));
        initView();
        initObserver();
        initClick();
        initData();
    }

    private void initObserver() {
        getViewModel().secretKeyLiveData.observe(this, new Observer<String>() {
            @Override
            public void onChanged(String s) {
                if (TextUtils.isEmpty(s)) {
                    finish();
                } else {
                    BluetoothBleUtil.getInstance().setSecretKey(s);
                    startConnectDevice();
                }
            }
        });
        getViewModel().baseInfoDataLiveData.observe(this, cabinetBean -> {
            if (cabinetBean != null) {
                Integer permission = cabinetBean.getHasPermission();
                if (permission != 1) {
                    ToastUtils.showShort(getString(com.base.common.R.string.text_no_permission));
                    finish();
                    return;
                }
                Glide.with(getActivity()).load(cabinetBean.getImg()).into(mBinding.imDevice);
                mBinding.tvDeviceInfo.setText(cabinetBean.getStandardName());
                String status = "";
                if (cabinetBean.getOnlineStatus() == 0) {
                    status = getString(R.string.offline);
                    mBinding.tvStatus.setTextColor(ContextCompat.getColor(this, R.color.color_fa4b51));
                    mBinding.tvStatus.setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(this, R.drawable.icon_wifi_us), null, null, null);
                    mBinding.tvStatus.setBackground(ContextCompat.getDrawable(this, R.drawable.bg_line_fa4b51_r4));
                } else {
                    status = getString(R.string.online);
                    mBinding.tvStatus.setTextColor(ContextCompat.getColor(this, R.color.main_color));
                    mBinding.tvStatus.setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(this, R.drawable.icon_wifi_s), null, null, null);
                    mBinding.tvStatus.setBackground(ContextCompat.getDrawable(this, R.drawable.bg_line_maincolor_r4));
                }
                mBinding.tvStatus.setText(status);
            } else {
                finish();
            }
        });
    }

    private void initData() {
        if (TextUtils.isEmpty(deviceSn)) {
            finish();
            return;
        }
        getViewModel().getStationSecretKey(deviceSn);
        getViewModel().getCabinetBaseInfo(deviceSn);
    }

    private void initBluetooth() {
//        BleManager.getInstance().init(getApplication());
        BluetoothBleUtil.getInstance().init(this);
        BluetoothBleUtil.getInstance().setBluetoothBleCallback(new BluetoothBleUtil.BluetoothBleCallback() {
            @Override
            public void onScanning() {
                getLoading().onStart();
//                ToastUtils.showShort("开始扫描");
            }

            @Override
            public void onScanTimeout() {
                getLoading().onFinish();
//                ToastUtils.showShort("扫描超时");
                reconnectDevice();//连接超时
            }

            @Override
            public void onConnecting() {
                getLoading().onStart();
//                ToastUtils.showShort("开始连接");
            }

            @Override
            public void onConnected() {
                getLoading().onFinish();
//                ToastUtils.showShort("连接成功");
                mBinding.tvBluetoothStatus.setText(getString(R.string.cabinet_opt_cabinet_offline_ble_connected));
                mBinding.tvBluetoothStatus.setTextColor(ContextCompat.getColor(CabinetOfflineDetailActivity.this, R.color.color_0b61d9));
            }

            @Override
            public void onDisconnect(String msg) {
                getLoading().onFinish();
                mBinding.tvBluetoothStatus.setText(getString(R.string.cabinet_opt_cabinet_offline_ble_disconnect));
                mBinding.tvBluetoothStatus.setTextColor(ContextCompat.getColor(CabinetOfflineDetailActivity.this, R.color.color_6c7180));
//                ToastUtils.showShort("连接断开: " + msg);
                reconnectDevice();//连接断开
            }

            @Override
            public void onReadFailure(String msg) {
                getLoading().onFinish();
                Log.e("BleManager", "msg: " + msg);
//                ToastUtils.showShort("读取数据失败: " + msg);
            }

            @Override
            public void onWriteFailure(String msg) {
                getLoading().onFinish();
                showTipsDialog(2);
            }
        });
        BluetoothBleUtil.getInstance().addDataCallback(callback);
    }

    private boolean isReconnecting = false;

    private void reconnectDevice() {
        if (!isReconnecting) {
            isReconnecting = true;
            addDisposable(Observable.timer(10, TimeUnit.SECONDS) // 10 秒后触发
                    .observeOn(AndroidSchedulers.mainThread()) // 切换到主线程
                    .subscribe(aLong -> {
                        isReconnecting = false;
                        startConnectDevice();
                    }));
        }
    }

    private void startConnectDevice() {
        if (BluetoothBleUtil.getInstance().isEnableBluetooth() && !BluetoothBleUtil.getInstance().isConnected()) {
            BluetoothBleUtil.getInstance().askBluetoothPermission(deviceSn);
        } else {
            reconnectDevice();//没有开启蓝牙或已连接蓝牙
        }
    }

    private String swapThreshold;

    private final BluetoothBleUtil.BluetoothBleDataCallback callback = new BluetoothBleUtil.BluetoothBleDataCallback() {
        @Override
        public void onAuthorization() {

        }

        @Override
        public void onReceiveData(String data) {
            getLoading().onFinish();
            CabinetData cabinetData = GsonUtils.fromGson(data, CabinetData.class);
            if (cabinetData != null) {
                if (cabinetData.isFull() != null && cabinetData.isFull() == 1) {
                    getLoading().onFinish();
                    getViewModel().saveAllData(data);
                }
                if (cabinetData.getMsgType() == CabinetDataType.CONTROL_RESPONSE) {
                    showTipsDialog(cabinetData.getResult() == null ? 0 : cabinetData.getResult());
                }
                if (cabinetData.getMsgType() == CabinetDataType.ATTRIBUTE_REQUEST) {

                }
                if (cabinetData.getMsgType() == CabinetDataType.QUERY_RESPONSE) {
                    Integer result = cabinetData.getResult();
                    if (result != null && result == 0) {
                        showTipsDialog(result);
                    }
                    List<ResultInfo> resultList = cabinetData.getResultList();
                    if (resultList != null && !resultList.isEmpty()) {
                        for (ResultInfo resultInfo : resultList) {
                            if (CabinetParamName.CAB_SOC.equals(resultInfo.getId())) {
                                swapThreshold = resultInfo.getValue();
                                break;
                            }
                        }
                    }
                }
            } else {
                CabinetDataResult cabinetDataResult = GsonUtils.fromGson(data, CabinetDataResult.class);
                if (cabinetDataResult != null) {
                    Integer result = cabinetDataResult.getResult();
                    if (result != null) {
                        showTipsDialog(result);
                    }
                }
            }
        }

        @Override
        public void onDisconnect() {
            getLoading().onFinish();
        }

    };

    private void initClick() {
        mBinding.btnRestart.setOnClickListener(v -> showRestartDialog());
        mBinding.btnOpenTheDoor.setOnClickListener(v -> showTipDialog());
    }

    private void showTipsDialog(int result) {
        Snackbar make = Snackbar.make(mBinding.root, "", Snackbar.LENGTH_LONG);
        Snackbar.SnackbarLayout snackbarLayout = (Snackbar.SnackbarLayout) make.getView();
        View inflate = LayoutInflater.from(CabinetOfflineDetailActivity.this).inflate(R.layout.snackbar_notice, null);
        AppCompatImageView ivIcon = inflate.findViewById(R.id.iv_icon);
        AppCompatTextView tvContent = inflate.findViewById(R.id.tv_content);
        if (result == 1) {//成功
            ivIcon.setImageDrawable(ContextCompat.getDrawable(CabinetOfflineDetailActivity.this, R.drawable.icon_success));
            tvContent.setText(getString(R.string.text_success));
        } else {
            ivIcon.setImageDrawable(ContextCompat.getDrawable(CabinetOfflineDetailActivity.this, R.drawable.icon_failure));
            tvContent.setText(getString(R.string.text_failure));
        }
        snackbarLayout.removeAllViews();
        snackbarLayout.addView(inflate);
        ViewGroup.LayoutParams layoutParams = snackbarLayout.getLayoutParams();
        FrameLayout.LayoutParams param = new FrameLayout.LayoutParams(layoutParams.width, layoutParams.height);
        param.gravity = Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL;
        param.leftMargin = DensityUtil.dp2px(20f);
        param.rightMargin = DensityUtil.dp2px(20f);
        snackbarLayout.setLayoutParams(param);
        make.show();
    }

    private final FragmentContainerHelper mFragmentContainerHelper = new FragmentContainerHelper();
    private final ArrayList<String> mTitleDataList = new ArrayList<>();

    private void initView() {
        mTitleDataList.add(getResources().getString(R.string.cabinet_opt_cabinet_offline_device_info));
        mTitleDataList.add(getResources().getString(R.string.device_detail_storehouse_info));
        mTitleDataList.add(getResources().getString(R.string.cabinet_opt_cabinet_offline_real_time));
        CommonNavigator commonNavigator = getCommonNavigator();
        mBinding.magicIndicator.setNavigator(commonNavigator);
        mFragmentContainerHelper.attachMagicIndicator(mBinding.magicIndicator);
        mBinding.viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                super.onPageSelected(position);
                mFragmentContainerHelper.handlePageSelected(position);
                mBinding.magicIndicator.onPageSelected(position);
            }
        });
        mBinding.viewPager.setNestedScrollingEnabled(false);
        mBinding.viewPager.setUserInputEnabled(false);
        mBinding.viewPager.setAdapter(new ViewPager2FragmentAdapter(this, mTitleDataList.size(), position -> {
            if (position == 0) {
                return CabinetOfflineDeviceInfoFragment.getInstance(deviceSn);
            } else if (position == 1) {
                return CabinetOfflineWarehouseFragment.getInstance(deviceSn, swapThreshold);
            } else if (position == 2) {
                return CabinetOfflineRealTimeFragment.getInstance(deviceSn);
            } else {
                return CabinetOfflineDeviceInfoFragment.getInstance(deviceSn);
            }
        }));
    }

    @NonNull
    private CommonNavigator getCommonNavigator() {
        CommonNavigator commonNavigator = new CommonNavigator(this);
        commonNavigator.setAdjustMode(true);
        commonNavigator.setAdapter(new CommonNavigatorAdapter() {

            @Override
            public int getCount() {
                return mTitleDataList.size();
            }

            @Override
            public IPagerTitleView getTitleView(Context context, final int index) {
                SimplePagerTitleView simplePagerTitleView = new ColorTransitionPagerTitleView(context);
                simplePagerTitleView.setText(mTitleDataList.get(index));
                simplePagerTitleView.setNormalColor(Color.parseColor("#800C0C0D"));
                simplePagerTitleView.setSelectedColor(Color.parseColor("#E60C0C0D"));
                simplePagerTitleView.setTextSize(14);
                simplePagerTitleView.setOnClickListener(v -> {
                    mFragmentContainerHelper.handlePageSelected(index);
                    mBinding.viewPager.setCurrentItem(index);
                });
                return simplePagerTitleView;
            }

            @Override
            public IPagerIndicator getIndicator(Context context) {
                LinePagerIndicator indicator = new LinePagerIndicator(context);
                indicator.setMode(LinePagerIndicator.MODE_EXACTLY);
                indicator.setLineWidth(UIUtil.dip2px(context, 30));
                indicator.setColors(Color.parseColor("#FF08983B"));
                return indicator;
            }
        });
        return commonNavigator;
    }

    private QuickPopup mTipDialog;

    /**
     * 开柜门
     */
    private void showTipDialog() {
        mTipDialog = QuickPopupBuilder.with(this)
                .contentView(R.layout.dialog_warning)
                .config(new QuickPopupConfig().gravity(Gravity.CENTER)
                        .outSideTouchable(false)
                        .outSideDismiss(false)
                        .backpressEnable(false)
                        .withClick(R.id.btn_cancel, v -> mTipDialog.dismiss())
                        .withClick(R.id.btn_ok, v -> {
                            mTipDialog.dismiss();
                            if (BluetoothBleUtil.getInstance().isConnected()) {
                                String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.CONTROL_REQUEST, deviceSn, getViewModel().buildParamSetting(CabinetParamName.CONTROL, "14")));
                                BluetoothBleUtil.getInstance().addDataToQueue(gson);
                            } else {
                                ToastUtils.showShort(getString(R.string.please_connect_device));
                            }
                        })).build();
        mTipDialog.showPopupWindow();
        mTipDialog.getContentView().post(() -> {
            TextView tvContent = mTipDialog.findViewById(R.id.tvContent);
            tvContent.setText(getString(R.string.cabinet_opt_cabinet_offline_open_door_tips));
        });
    }

    private QuickPopup mRestartDialog;

    /**
     * 重启
     */
    private void showRestartDialog() {
        mRestartDialog = QuickPopupBuilder.with(this)
                .contentView(R.layout.dialog_warning)
                .config(new QuickPopupConfig().gravity(Gravity.CENTER)
                        .outSideTouchable(false)
                        .outSideDismiss(false)
                        .backpressEnable(false)
                        .withClick(R.id.btn_cancel, v -> mRestartDialog.dismiss())
                        .withClick(R.id.btn_ok, v -> {
                            mRestartDialog.dismiss();
                            if (BluetoothBleUtil.getInstance().isConnected()) {
                                String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.CONTROL_REQUEST, deviceSn, getViewModel().buildParam(CabinetParamName.RESET)));
                                BluetoothBleUtil.getInstance().addDataToQueue(gson);
                            } else {
                                ToastUtils.showShort(getString(R.string.please_connect_device));
                            }
                        })).build();
        mRestartDialog.showPopupWindow();
        mRestartDialog.getContentView().post(() -> {
            TextView tvContent = mRestartDialog.findViewById(R.id.tvContent);
            tvContent.setText(getString(R.string.cabinet_opt_cabinet_offline_restart_tips));

        });
    }

}
