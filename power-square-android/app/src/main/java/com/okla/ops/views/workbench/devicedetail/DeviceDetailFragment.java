package com.okla.ops.views.workbench.devicedetail;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.utils.ToastUtils;
import com.bumptech.glide.Glide;
import com.google.android.material.tabs.TabLayoutMediator;
import com.okla.ops.R;
import com.okla.ops.adapter.ViewPager2FragmentAdapter;
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew;
import com.okla.ops.databinding.FragmentDeviceInfoDetailBinding;
import com.okla.ops.utils.CabinetFormat;
import com.okla.ops.views.monitor.cabinetdetail.cabin.CabinFragment;

import net.lucode.hackware.magicindicator.FragmentContainerHelper;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.CommonNavigator;

import java.util.ArrayList;

import razerdp.basepopup.QuickPopupBuilder;
import razerdp.basepopup.QuickPopupConfig;
import razerdp.widget.QuickPopup;

public class DeviceDetailFragment extends BaseNormalVFragment<DeviceDetailViewModel, FragmentDeviceInfoDetailBinding> {

    private int tabindex = -1;
    private int optType;


    public static DeviceDetailFragment getInstance(EquipmentDeviceSearchBeanNew equipmentDeviceSearchBeanNew, int
            tabindex,int optType) {
        DeviceDetailFragment fragment = new DeviceDetailFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable("searchBean", equipmentDeviceSearchBeanNew);
        bundle.putInt("tabindex", tabindex);
        bundle.putInt("optType", optType);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_device_info_detail;
    }

    @Override
    protected DeviceDetailViewModel onCreateViewModel() {
        return new ViewModelProvider(getActivity()).get(DeviceDetailViewModel.class);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        Bundle arguments = getArguments();
        if (arguments != null) {
            EquipmentDeviceSearchBeanNew equipmentDeviceSearchBeanNew = (EquipmentDeviceSearchBeanNew) arguments.getSerializable("searchBean");
            if (equipmentDeviceSearchBeanNew != null) {
                type = equipmentDeviceSearchBeanNew.getType();
                getViewModel().setDeviceInfo(equipmentDeviceSearchBeanNew.getDeviceInfo());
            }
            tabindex = arguments.getInt("tabindex");
            optType = arguments.getInt("optType", -1);

        }
        initTitles();
        initViewPagerAndTabs();
        initObserver();
        initClick();
    }

    private String mDeviceSn;

    private void initClick() {
        mBinding.ivCabinet.setOnClickListener(v -> showTipDialog());
    }

    private void initTitles() {
        if (type == DEVICE_TYPE_BATTERY) {//电池
            mTitleDataList.add(getResources().getString(R.string.device_detail_base_info));
            mTitleDataList.add(getResources().getString(R.string.device_detail_location_info));
            mTitleDataList.add(getResources().getString(R.string.device_detail_repair_info));
        } else if (type == DEVICE_TYPE_CAR) {//车辆
            mTitleDataList.add(getResources().getString(R.string.device_detail_base_info));
            mTitleDataList.add(getResources().getString(R.string.device_detail_repair_info));
            mTitleDataList.add(getResources().getString(R.string.device_detail_Maintenance_record));
        } else  if(type== DEVICE_TYPE_CABIN){
            mTitleDataList.add(getResources().getString(R.string.device_detail_base_info));
            mTitleDataList.add(getResources().getString(R.string.device_detail_storehouse_info));
            mTitleDataList.add(getResources().getString(R.string.device_detail_location_info));
            mTitleDataList.add(getResources().getString(R.string.device_detail_repair_info));
        }
        else {
            mTitleDataList.add(getResources().getString(R.string.device_detail_base_info));
        }
    }

    private void initViewPagerAndTabs() {
        //设置 ViewPager2 的 Adapter
        mBinding.viewPager.setAdapter(new ViewPager2FragmentAdapter(
                requireActivity(), mTitleDataList.size(), (position) -> {
            switch (position) {
                case 0:
                    return DeviceBaseInfoFragment.getInstance(type);
                case 1:
                    if (type == DEVICE_TYPE_CAR) {
                        return DeviceFixRecordFragment.Companion.getInstance(type, mDeviceSn);
                    } else if(type== DEVICE_TYPE_BATTERY){
                        return DeviceLocationFragment.getInstance(type);
                    }else {
                        return DeviceWarehouseFragment.getInstance(optType);
                    }
                case 2:
                    if (type == DEVICE_TYPE_BATTERY) {
                        return DeviceFixRecordFragment.Companion.getInstance(type, mDeviceSn);
                    } else  if(type==DEVICE_TYPE_CAR){
                        return MaintenanceRecordFragment.Companion.getInstance(mDeviceSn);
                    }else {
                        return DeviceLocationFragment.getInstance(type);
                    }
                case 3:
                    if (type == DEVICE_TYPE_CABIN) {
                        return DeviceFixRecordFragment.Companion.getInstance(type, mDeviceSn);
                    }
                default:
                    throw new IllegalStateException("Invalid position " + position);
            }
        }
        ));
        //禁用手势滑
        mBinding.viewPager.setUserInputEnabled(false);
        // 使用 TabLayoutMediator 绑定 TabLayout 和 ViewPager2
        new TabLayoutMediator(mBinding.tablayout, mBinding.viewPager,
                (tab, position) -> tab.setText(mTitleDataList.get(position))
        ).attach();

        if (tabindex >= 0 && tabindex < mTitleDataList.size()) {
            mBinding.viewPager.post(() -> mBinding.viewPager.setCurrentItem(tabindex, true));
        }
    }

    private final FragmentContainerHelper mFragmentContainerHelper = new FragmentContainerHelper();
    private final ArrayList<String> mTitleDataList = new ArrayList<>();

    public static final int DEVICE_TYPE_BATTERY = 1;
    public static final int DEVICE_TYPE_CAR = 2;

    public static final int DEVICE_TYPE_CABIN=3;
    private int type;
//    private CommonNavigator commonNavigator;

    private Observer<Object> mOpenCabinBackDoorObserver;


    private void initObserver() {
        getViewModel().mDeviceInfo.observe(this, deviceInfo -> {
            if (deviceInfo != null) {
                mDeviceSn = deviceInfo.getSn();
                Glide.with(mActivity).load(deviceInfo.getImg()).into(mBinding.imDevice);

                if (type == DEVICE_TYPE_CABIN) {
                    mTitleDataList.clear();
                    if(deviceInfo.getInstallStatus()!=null){
                        if (deviceInfo.getInstallStatus() == 0) {
                            mTitleDataList.add(getResources().getString(R.string.device_detail_base_info));
                            mTitleDataList.add(getResources().getString(R.string.device_detail_repair_info));
                        } else {
                            mTitleDataList.add(getResources().getString(R.string.device_detail_base_info));
                            mTitleDataList.add(getResources().getString(R.string.device_detail_storehouse_info));
                            mTitleDataList.add(getResources().getString(R.string.device_detail_location_info));
                            mTitleDataList.add(getResources().getString(R.string.device_detail_repair_info));
                        }
                    }else {
                        mTitleDataList.add(getResources().getString(R.string.device_detail_base_info));
                        mTitleDataList.add(getResources().getString(R.string.device_detail_repair_info));
                    }
//                    if (commonNavigator != null && commonNavigator.getAdapter() != null) {
//                        commonNavigator.getAdapter().notifyDataSetChanged();
//                    }
                    if (TextUtils.isEmpty(deviceInfo.getStationName())) {
                        mBinding.tvDeviceInfo.setText("SN: " + deviceInfo.getSn());
                    } else {
                        mBinding.tvDeviceInfo.setText(deviceInfo.getStationName());
                    }
                    if (optType == DeviceWarehouseFragment.OPERATE_TYPE_READ_ONLY) {//查询
                        mBinding.ivCabinet.setVisibility(View.GONE);
                    } else {
                        Integer hasPermission = deviceInfo.getHasPermission();
                        if (hasPermission != null && hasPermission == 1) {
                            mBinding.ivCabinet.setVisibility(View.VISIBLE);
                        } else {
                            mBinding.ivCabinet.setVisibility(View.GONE);
                        }
                    }
                    mBinding.tvBoundStatus.setVisibility(View.GONE);
                    Integer onlineStatus = deviceInfo.getOnlineStatus();
                    if (onlineStatus != null) {
                        mBinding.tvBoundSource.setVisibility(View.VISIBLE);
                        if (onlineStatus == 0) {//离线
                            mBinding.tvBoundSource.setText(getString(R.string.offline));
                            mBinding.tvBoundSource.setTextColor(ContextCompat.getColor(getContext(), R.color.color_fa4b51));
                            mBinding.tvBoundSource.setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(getContext(), R.drawable.icon_wifi_us), null, null, null);
                            mBinding.tvBoundSource.setBackground(ContextCompat.getDrawable(getContext(), R.drawable.bg_line_fa4b51_r4));
                        } else {
                            mBinding.tvBoundSource.setText(getString(R.string.online));
                            mBinding.tvBoundSource.setTextColor(ContextCompat.getColor(getContext(), R.color.main_color));
                            mBinding.tvBoundSource.setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(getContext(), R.drawable.icon_wifi_s), null, null, null);
                            mBinding.tvBoundSource.setBackground(ContextCompat.getDrawable(getContext(), R.drawable.bg_line_maincolor_r4));
                        }
                    } else {
                        mBinding.tvBoundSource.setVisibility(View.GONE);
                    }

                }else {
                    mBinding.tvDeviceInfo.setText("SN: " + deviceInfo.getSn());
                    mBinding.ivCabinet.setVisibility(View.GONE);
                    Integer bindStatus = deviceInfo.getDeviceBindStatus();
                    if (bindStatus != null) {
                        mBinding.tvBoundStatus.setVisibility(View.VISIBLE);
                        if (bindStatus == 0) {//未绑定
                            mBinding.tvBoundStatus.setText(this.getString(R.string.str_unbound));
                        } else {
                            mBinding.tvBoundStatus.setText(this.getString(R.string.str_bound));
                        }
                    } else {
                        mBinding.tvBoundStatus.setVisibility(View.GONE);
                    }

                    Integer bindSource = deviceInfo.getBindSource();
                    if (bindSource != null) {
                        mBinding.tvBoundSource.setVisibility(View.VISIBLE);
                        if (bindSource == 1) {//销售
                            mBinding.tvBoundSource.setText(this.getString(R.string.str_sale));
                            mBinding.tvBoundSource.setTextColor(ContextCompat.getColor(getContext(), R.color.main_color));
                            mBinding.tvBoundSource.setBackground(ContextCompat.getDrawable(getContext(), R.drawable.bg_line_maincolor_r4));
                        } else if (bindSource == 2) { //租赁
                            mBinding.tvBoundSource.setText(this.getString(R.string.str_lease));
                            mBinding.tvBoundSource.setTextColor(ContextCompat.getColor(getContext(), R.color.color_f49300));
                            mBinding.tvBoundSource.setBackground(ContextCompat.getDrawable(getContext(), R.drawable.bg_line_f49300_r4));
                        }
                    } else {
                        mBinding.tvBoundSource.setVisibility(View.GONE);
                    }
                }

            } else {
                mDeviceSn = "";
            }
        });
        mOpenCabinBackDoorObserver = object -> {
            ToastUtils.showShort(getString(R.string.cabinet_opt_cabinet_open_success));
        };

    }

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
                            if (!TextUtils.isEmpty(mDeviceSn))
                                getViewModel().openCabinBackDoor(mDeviceSn).observe(this, mOpenCabinBackDoorObserver);
                        })).build();
        mTipDialog.showPopupWindow();
        mTipDialog.getContentView().post(()->{
            TextView tvContent = mTipDialog.findViewById(R.id.tvContent);
            tvContent.setText(getString(R.string.cabinet_opt_cabinet_open_confirm_tips));
            TextView tvOk = mTipDialog.findViewById(R.id.btn_ok);
            tvOk.setText(getString(R.string.cabinet_opt_cabinet_open_confirm));
        });
    }


}
