package com.okla.ops.views.workbench.devicedetail;

import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.style.ClickableSpan;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;
import androidx.databinding.ViewDataBinding;
import androidx.databinding.library.baseAdapters.BR;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.utils.DensityUtil;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.custom.deviceinfo.MyGridItemDecoration;
import com.okla.ops.databinding.FragmentDeviceWarehouseBinding;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.okla.ops.R;
import com.okla.ops.beans.Cabin;
import com.okla.ops.beans.CabinToolbarBean;
import com.okla.ops.beans.DeviceInfo;
import com.okla.ops.custom.BatteryCapacityView;
import com.okla.ops.views.monitor.cabinetdetail.cabin.faultlist.CabinFaultListActivity;

import java.util.ArrayList;
import java.util.List;

import razerdp.basepopup.QuickPopupBuilder;
import razerdp.basepopup.QuickPopupConfig;
import razerdp.widget.QuickPopup;

public class DeviceWarehouseFragment extends BaseNormalVFragment<DeviceDetailViewModel, FragmentDeviceWarehouseBinding> {

    public static final int OPERATE_TYPE_READ_ONLY = -1;
    private int optType = OPERATE_TYPE_READ_ONLY;

    public static DeviceWarehouseFragment getInstance(int optType) {
        DeviceWarehouseFragment fragment = new DeviceWarehouseFragment();
        Bundle bundle = new Bundle();
        bundle.putInt("optType", optType);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_device_warehouse;
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
            optType = arguments.getInt("optType", OPERATE_TYPE_READ_ONLY);
        }
        initTablebarAdapter();
        initWarehouseAdapter();
        initObserver();
        initData();
    }

    private SingleDataBindingNoPUseAdapter<CabinToolbarBean> mToolbarAdapter;

    private void initTablebarAdapter() {
        mToolbarAdapter = new SingleDataBindingNoPUseAdapter<CabinToolbarBean>(R.layout.item_warehouse_toolbar) {
            @Override
            public void convert(BaseViewHolder helper, CabinToolbarBean item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                viewDataBinding.setVariable(BR.index, mToolbarAdapter.getData().indexOf(item));
            }
        };
        mToolbarAdapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
                for (int i = 0; i < adapter.getData().size(); i++) {
                    if (i == position) {
                        ((CabinToolbarBean) adapter.getData().get(i)).setSelect(true);
                        refreshCabinList(((CabinToolbarBean) adapter.getData().get(i)).getName());
                        if (mCabinList.isEmpty()) {
                            mBinding.vNoDataView.setVisibility(View.VISIBLE);
                        } else {
                            mBinding.vNoDataView.setVisibility(View.GONE);
                        }
                    } else {
                        ((CabinToolbarBean) adapter.getData().get(i)).setSelect(false);
                    }
                }
//                mToolbarAdapter.notifyDataSetChanged();
            }
        });
        mBinding.rvWarehouseToolbar.setLayoutManager(new LinearLayoutManager(getActivity(), LinearLayoutManager.HORIZONTAL, false));
        mBinding.rvWarehouseToolbar.setAdapter(mToolbarAdapter);
    }

    private void refreshCabinList(String name) {
        if (getString(R.string.cabin_cabin_all).equals(name)) {
            mCabinList.clear();
            mCabinList.addAll(mCabinListAll);
            adapter.setNewData(mCabinList);
        } else {
            mCabinList.clear();
            for (int i = 0; i < mCabinListAll.size(); i++) {
                if (getString(R.string.cabin_cabin_occupy).equals(name)) {
                    if (mCabinListAll.get(i).getBatteryStatus() == 1) {
                        mCabinList.add(mCabinListAll.get(i));
                    }
                } else if (getString(R.string.cabin_cabin_disable).equals(name)) {
                    if (mCabinListAll.get(i).getStatus() == 0) {
                        mCabinList.add(mCabinListAll.get(i));
                    }
                } else if (getString(R.string.cabin_cabin_free).equals(name)) {
                    if (mCabinListAll.get(i).getBatteryStatus() == 0) {
                        mCabinList.add(mCabinListAll.get(i));
                    }
                }
            }
            adapter.setNewData(mCabinList);
        }
    }

    private Observer<List<Cabin>> mCabinObserver;
    private SingleDataBindingNoPUseAdapter adapter;

    private void initWarehouseAdapter() {
        mBinding.rvWarehouseList.setLayoutManager(new StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL));
        mBinding.rvWarehouseList.addItemDecoration(new MyGridItemDecoration(2, DensityUtil.dp2px(12)));
        adapter = new SingleDataBindingNoPUseAdapter<Cabin>(R.layout.item_warehouse) {
            @Override
            public void convert(BaseViewHolder helper, Cabin item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                if (item.getStatus() == 0) {
                    ((BatteryCapacityView) helper.getView(R.id.vPowerImg)).setDisable();
                    ((TextView) helper.getView(R.id.tvWarehouseStatus)).setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(getContext(), R.mipmap.icon_cabin_unable), null, null, null);
                    ((TextView) helper.getView(R.id.tvWarehouseStatus)).setText(getString(R.string.cabinet_opt_box_no_use));
                } else if (item.getStatus() == 1 && item.getSwapFlag() == 1) {
                    ((TextView) helper.getView(R.id.tvWarehouseStatus)).setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(getContext(), R.mipmap.icon_cabin_enable), null, null, null);
                    ((TextView) helper.getView(R.id.tvWarehouseStatus)).setText(getString(R.string.cabinet_opt_box_can_use));
                }
                ((TextView) helper.getView(R.id.tvPortNum)).setText(String.valueOf(item.getPortNo()));
                ((TextView) helper.getView(R.id.tvBatterySoc)).setText(item.getBatterySoc() + "%");
                ((BatteryCapacityView) helper.getView(R.id.vPowerImg)).setCurrentSwap(item.getBatterySoc(), item.getSwapFlag(), item.getStatus());
                ((TextView) helper.getView(R.id.tvSn)).setText("SN: " + item.getBatterySn());
                if (optType == OPERATE_TYPE_READ_ONLY) {//查询
                    ((ConstraintLayout) helper.getView(R.id.btnSetting)).setVisibility(View.GONE);
                } else {
                    if (hasPermission != null && hasPermission == 1) {
                        ((ConstraintLayout) helper.getView(R.id.btnSetting)).setVisibility(View.VISIBLE);
                        ConstraintLayout root = helper.getView(R.id.item_root);
                        root.setMinHeight(DensityUtil.dp2px(194));
                    } else {
                        ((ConstraintLayout) helper.getView(R.id.btnSetting)).setVisibility(View.GONE);
                    }
                }
                ((ConstraintLayout) helper.getView(R.id.btnSetting)).setOnClickListener(v -> {
                    initBottomSheet(item);
                });
            }
        };
        adapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
            }
        });
        mBinding.rvWarehouseList.setAdapter(adapter);
    }

    private Observer<Object> mSetPortEnableObserver, mOpenCabinDoorObserver;

    private void initObserver() {
        mCabinObserver = beans -> {
            mBinding.swipRefresh.finishRefresh();
            mCabinList.clear();
            mCabinList.addAll(beans);
            mCabinListAll.clear();
            mCabinListAll.addAll(beans);
            getToolbarData();
            adapter.setNewData(mCabinList);
            if (mCabinList.isEmpty()) {
                mBinding.vNoDataView.setVisibility(View.VISIBLE);
            } else {
                mBinding.vNoDataView.setVisibility(View.GONE);
            }
        };
        mOpenCabinDoorObserver = bean -> getWarehouseData();

        mBinding.swipRefresh.setOnRefreshListener(refreshLayout -> {
            getWarehouseData();
        });
    }

    private String cabinetSn;
    private Integer hasPermission;

    private void initData() {
        DeviceInfo deviceInfo = getViewModel().mDeviceInfo.getValue();
        if (deviceInfo != null) {
            cabinetSn = deviceInfo.getSn();
            hasPermission = deviceInfo.getHasPermission();
        }
        getWarehouseData();
    }

    private void getWarehouseData() {
        getViewModel().getCabinList(cabinetSn).observe(this, mCabinObserver);
    }

    List<Cabin> mCabinList = new ArrayList<>();
    List<Cabin> mCabinListAll = new ArrayList<>();

    CabinToolbarBean mOverAll;
    CabinToolbarBean mOverCurrent;
    CabinToolbarBean mOverVoltage;
    CabinToolbarBean mOverOccupy;
    CabinToolbarBean mOverDisable;
    CabinToolbarBean mOverFree;
    List<CabinToolbarBean> mToolbarList = new ArrayList<>();

    private void getToolbarData() {
        mToolbarList.clear();
        mOverFree = null;
        mOverDisable = null;
        mOverOccupy = null;
        mOverVoltage = null;
        mOverCurrent = null;
        if (mOverAll == null) {
            mOverAll = new CabinToolbarBean();
            mOverAll.setName(getString(R.string.cabin_cabin_all));
            mOverAll.setSize(mCabinList.size());
            mOverAll.setSelect(true);
        }
        mOverAll.setSelect(true);
        mToolbarList.add(mOverAll);
        for (Cabin listBean : mCabinListAll) {
            if (listBean.getBatteryStatus() == 0) {
                if (mOverFree == null) {
                    mOverFree = new CabinToolbarBean();
                    mOverFree.setName(getString(R.string.cabin_cabin_free));
                    mOverFree.setSize(1);
                    mOverFree.setSelect(false);
                    mToolbarList.add(mOverFree);
                } else {
                    mOverFree.setSize(mOverFree.getSize() + 1);
                }
            } else {
                if (mOverFree == null) {
                    mOverFree = new CabinToolbarBean();
                    mOverFree.setName(getString(R.string.cabin_cabin_free));
                    mOverFree.setSize(0);
                    mOverFree.setSelect(false);
                    mToolbarList.add(mOverFree);
                }
            }

            if (listBean.getStatus() == 0) {
                if (mOverDisable == null) {
                    mOverDisable = new CabinToolbarBean();
                    mOverDisable.setName(getString(R.string.cabin_cabin_disable));
                    mOverDisable.setSize(1);
                    mOverDisable.setSelect(false);
                    mToolbarList.add(mOverDisable);
                } else {
                    mOverDisable.setSize(mOverDisable.getSize() + 1);
                }
            } else {
                if (mOverDisable == null) {
                    mOverDisable = new CabinToolbarBean();
                    mOverDisable.setName(getString(R.string.cabin_cabin_disable));
                    mOverDisable.setSize(0);
                    mOverDisable.setSelect(false);
                    mToolbarList.add(mOverDisable);
                }
            }
            if (listBean.getBatteryStatus() == 1) {
                if (mOverOccupy == null) {
                    mOverOccupy = new CabinToolbarBean();
                    mOverOccupy.setName(getString(R.string.cabin_cabin_occupy));
                    mOverOccupy.setSize(1);
                    mOverOccupy.setSelect(false);
                    mToolbarList.add(mOverOccupy);
                } else {
                    mOverOccupy.setSize(mOverOccupy.getSize() + 1);
                }
            } else {
                if (mOverOccupy == null) {
                    mOverOccupy = new CabinToolbarBean();
                    mOverOccupy.setName(getString(R.string.cabin_cabin_occupy));
                    mOverOccupy.setSize(0);
                    mOverOccupy.setSelect(false);
                    mToolbarList.add(mOverOccupy);
                }
            }
        }
        mToolbarAdapter.setNewData(mToolbarList);
    }

    private BottomSheetDialog mBottomSheetDialog;
    private TextView vTitle;
    private Button openCloseBt;
    private Button enableDisableBt;
    private ArrayList<Integer> portList;
    private Cabin tempCabin;

    /**
     * 初始化操作对话框
     */
    public void initBottomSheet(Cabin item) {
        tempCabin = item;
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = new BottomSheetDialog(getContext());
            View view = LayoutInflater.from(getContext()).inflate(R.layout.dialog_cabinet_opt_sheet, null, false);
            vTitle = view.findViewById(R.id.tvTitle);
            openCloseBt = (Button) view.findViewById(R.id.open_close_bt);
            Button checkFaultBt = (Button) view.findViewById(R.id.check_fault_bt);
            View line = view.findViewById(R.id.line);
            enableDisableBt = (Button) view.findViewById(R.id.enable_disable_bt);
            Button btnCancel = (Button) view.findViewById(R.id.btn_cancel);
            openCloseBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mBottomSheetDialog.dismiss();
                    showTipDialog(1);
                }
            });
            checkFaultBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mBottomSheetDialog.dismiss();
                    if (portList == null) {
                        portList = new ArrayList<>();
                        for (int i = 0; i < mCabinListAll.size(); i++) {
                            portList.add(mCabinList.get(i).getPortNo());
                        }
                    }
                    startActivity(CabinFaultListActivity.getIntents(getContext(), portList, tempCabin.getPortNo(), cabinetSn, cabinetSn));
                }
            });
            checkFaultBt.setVisibility(View.GONE);
            line.setVisibility(View.GONE);
            enableDisableBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mBottomSheetDialog.dismiss();
                    showTipDialog(tempCabin.getStatus() == 0 ? 3 : 2);
                }
            });
            btnCancel.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mBottomSheetDialog.dismiss();
                }
            });
            mBottomSheetDialog.setContentView(view);
        }
        vTitle.setText(tempCabin.getPortName());
        if (tempCabin.getDoorStatus() == 0) {
            openCloseBt.setTextColor(ContextCompat.getColor(getContext(), R.color.color_e60c0c0d));
            openCloseBt.setText(getString(R.string.cabinet_opt_box_open));
        } else {
            openCloseBt.setTextColor(ContextCompat.getColor(getContext(), R.color.color_4d0c0c0d));
            openCloseBt.setText(getString(R.string.cabinet_opt_box_opened));
        }
        if (tempCabin.getStatus() == 0) {
            enableDisableBt.setTextColor(ContextCompat.getColor(getContext(), R.color.color_e60c0c0d));
            enableDisableBt.setText(getString(R.string.user_state_enable));
        } else {
            enableDisableBt.setTextColor(ContextCompat.getColor(getContext(), R.color.color_fa4b51));
            enableDisableBt.setText(getString(R.string.cabin_cabin_disable));
        }
        mBottomSheetDialog.show();
    }

    private void showTipDialog(int type) {
        try {
            QuickPopup mTipDialog = QuickPopupBuilder.with(getContext())
                    .contentView(R.layout.dialog_warning)
                    .config(new QuickPopupConfig()
                            .gravity(Gravity.CENTER)
                            .outSideTouchable(false)
                            .outSideDismiss(false)
                            .backpressEnable(false)
                            .withClick(R.id.btn_cancel, v -> {
                            }, true)
                            .withClick(R.id.btn_ok, v -> {
                                //开仓
                                getViewModel().openCabinDoor(tempCabin.getPortNo(), cabinetSn, type).observe(this, mOpenCabinDoorObserver);
                            }, true)).build();
            mTipDialog.setBackPressEnable(false);
            mTipDialog.showPopupWindow();
            TextView tvContent = mTipDialog.findViewById(R.id.tvContent);
            if (type == 1) {//开仓
                int portNo = tempCabin.getPortNo();
                String string = getString(R.string.cabinet_opt_box_open_confirm_tips, portNo);
                int start = string.indexOf(String.valueOf(portNo));
                int end = start + 1;
                if (portNo > 9)
                    end = end + 1;
                SpannableString spannableString = new SpannableString(string);
                spannableString.setSpan(new ClickableSpan() {
                    @Override
                    public void onClick(@NonNull View widget) {

                    }

                    @Override
                    public void updateDrawState(@NonNull TextPaint ds) {
                        super.updateDrawState(ds);
                        ds.setColor(ContextCompat.getColor(mActivity, R.color.color_00b39b));
                        ds.setUnderlineText(false);
                    }
                }, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                tvContent.setText(spannableString);
            } else if (type == 2) {//禁用
                tvContent.setText(R.string.cabin_detail_remote_disable_cabin_tips);
            } else if (type == 3) {//启用
                tvContent.setText(R.string.cabinet_opt_box_remote_enable);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
