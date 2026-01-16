package com.okla.ops.views.monitor.cabinetdetail.cabin;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.databinding.ViewDataBinding;
import androidx.databinding.library.baseAdapters.BR;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.base.mvvm.BaseNormalListVFragment;
import com.base.common.dialog.CustomDialog;
import com.base.common.utils.ToastUtils;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.Cabin;
import com.okla.ops.beans.CabinToolbarBean;
import com.okla.ops.beans.ForbiddenReasonBean;
import com.okla.ops.beans.MaxcEventBusBean;
import com.okla.ops.databinding.FragmentCabinBinding;
import com.okla.ops.dialog.CabinSettingDialog;
import com.okla.ops.dialog.SelectForbiddenReasonDialog;
import com.okla.ops.views.monitor.cabinetdetail.cabin.faultlist.CabinFaultListActivity;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.List;

import razerdp.basepopup.QuickPopupBuilder;
import razerdp.basepopup.QuickPopupConfig;
import razerdp.widget.QuickPopup;


/**
 * @Date: 2021/1/26 14:13
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinFragment extends BaseNormalListVFragment<CabinViewModel, FragmentCabinBinding> {

    private String mCabinetPID;
    private String mCabinetSN;
    private Observer<List<Cabin>> mCabinOberver;
    private SingleDataBindingNoPUseAdapter<CabinToolbarBean> mToolbarAdapter;
    private QuickPopup setDisableDialog;
    private Observer<String> mSetCurrentObserver, mSetPortEnablebserver, mOpenCabinDoorObserver;
    private Observer<List<ForbiddenReasonBean>> mForbiddenObserver;
    private SelectForbiddenReasonDialog mSelectForbiddenReasonDialog;
    private boolean isNoRemotePerssion = true;
    private boolean isEditFlag = false;

    public static CabinFragment getInstance(String pid, String mCabinetSN, boolean isNoRemotePerssion, boolean isEditFlag) {
        CabinFragment fragment = new CabinFragment();
        Bundle bundle = new Bundle();
        bundle.putString("pid", pid);
        bundle.putString("mCabinetSN", mCabinetSN);
        bundle.putBoolean("isNoRemotePerssion", isNoRemotePerssion);
        bundle.putBoolean("isEditFlag", isEditFlag);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_cabin;
    }

    @Override
    protected CabinViewModel onCreateViewModel() {
        return new ViewModelProvider(getActivity()).get(CabinViewModel.class);
    }

    @Override
    protected boolean isBindEventBusHere() {
        return true;
    }

    double mMacValue;

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void getMaxcValue(MaxcEventBusBean maxcEventBusBean) {
        if (maxcEventBusBean != null) {
            mMacValue = maxcEventBusBean.getMaxC();
        }
    }

    int port;//仓位
    //    CabinBean.ListBean mClickPortBean;
    Cabin mClickPortBean;

    @Override
    protected RecyclerView.Adapter createAdapter() {
        return new SingleDataBindingNoPUseAdapter<Cabin>(R.layout.item_cabin) {
            @Override
            public void convert(BaseViewHolder helper, Cabin item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                if (isNoRemotePerssion && (!isEditFlag)) {
                    helper.getView(R.id.ivCabinSet).setVisibility(View.GONE);
                }
                helper.getView(R.id.ivCabinSet).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        port = item.getPortNo();
                        mClickPortBean = item;
                        showCabinSettingDialog(item.getStatus(), helper.getView(R.id.vDot));
                    }
                });
            }
        };
    }

    List<String> mSettingList;
    CabinSettingDialog mCabinSettingDialog;

    private void showCabinSettingDialog(int status, View view) {
        if (mSettingList == null) {
            mSettingList = new ArrayList<>();
            mSettingList.add(getString(R.string.cabin_cabin_enable));
//            mSettingList.add(getString(R.string.cabin_cabin_disable));
            mSettingList.add(getString(R.string.cabin_cabin_open_the_box));
//            mSettingList.add(getString(R.string.cabin_charge_current));
//            mSettingList.add(getString(R.string.cabin_cabin_check_the_fault));
        }
        //状态 1-启用 0-禁用
        if (status == 1) {
            mSettingList.set(0, getString(R.string.cabin_cabin_disable));
        } else {
            mSettingList.set(0, getString(R.string.cabin_cabin_enable));
        }

        mCabinSettingDialog = new CabinSettingDialog(getContext(), mSettingList)
                .setOnSelectClickListener(position -> {
                    settingClickMethod(position);
                });
        if (!mCabinSettingDialog.isShowing()) {
            mCabinSettingDialog.showPopupWindow(view);
        }
    }

    ArrayList<Integer> portList;

    private void settingClickMethod(int position) {
        switch (position) {
            case 0:
                if (mSettingList.get(0).equals(getString(R.string.cabin_cabin_disable))) {
                    //禁用
                    if (mForbiddenReasonList == null || mForbiddenReasonList.size() <= 0) {
                        getViewModel().getForbiddenStorageReason().observe(this, mForbiddenObserver);
                    } else {
                        initForbiddenReasonDialog();
                    }


                } else {
                    //启用:enable : 0-禁用，1-启用
                    getViewModel().setCabinPorts(mCabinetPID, port, 1, "", "", nID).observe(this, mSetPortEnablebserver);
                }
                break;
            case 1:
                showTipDialog();
                break;
            case 2:
                //充电电流
                showSetCurrentDialog();
                break;
            case 3:
                //查看故障
                if (portList == null) {
                    portList = new ArrayList<>();
                    for (int i = 0; i < mCabinListAll.size(); i++) {
                        portList.add(mCabinList.get(i).getPortNo());
                    }
                }
                startActivity(CabinFaultListActivity.getIntents(getContext(), portList, port, mCabinetSN, mCabinetPID));
                break;
            default:
                break;
        }

    }


    private void showTipDialog() {
        try {
            QuickPopup mTipDialog = QuickPopupBuilder.with(getContext())
                    .contentView(R.layout.dialog_base_layout)
                    .config(new QuickPopupConfig()
                            .gravity(Gravity.CENTER)
                            .outSideTouchable(false)
                            .outSideDismiss(false)
                            .backpressEnable(false)
                            .withClick(R.id.tv_cancel, v -> {
                            }, true)
                            .withClick(R.id.tv_sure, v -> {
                                //开仓
                                getViewModel().openCabinDoor(mCabinetPID, port, nID).observe(this, mOpenCabinDoorObserver);
                            }, true)).build();
            mTipDialog.setBackPressEnable(false);
            mTipDialog.showPopupWindow();
            TextView tvTitle = mTipDialog.findViewById(R.id.tvTitle);
            tvTitle.setText(R.string.notifyTitle);
            TextView tvContent = mTipDialog.findViewById(R.id.tvContent);
            tvContent.setText(R.string.txt_opne_locker_hint);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void showSetDisableDialog() {
        setDisableDialog = QuickPopupBuilder.with(getContext())
                .contentView(R.layout.dialog_cabin_disable)
                .config(new QuickPopupConfig()
                        .gravity(Gravity.CENTER)
                        .backpressEnable(false)
                        .dismissOnOutSideTouch(false)
                        .outSideTouchable(false)
                        .withClick(R.id.tvOK, view -> {
                            hideSoftInput();
                            String input = ((EditText) setDisableDialog.getContentView().findViewById(R.id.etInput)).getText().toString();
                            if (TextUtils.isEmpty(input)) {
                                ToastUtils.showShort(getString(R.string.cabin_cabin_enter_disable_reason));
                                return;
                            }
                            setDisableDialog.dismiss();
                            CustomDialog.Builder builder = new CustomDialog.Builder(getActivity())
                                    .setTitle(getString(R.string.cabin_detail_remote_disable_cabin))
                                    .setMessage(getString(R.string.cabin_detail_remote_disable_cabin_tips))
                                    .setNegativeButton((dialog, which) -> {
                                        dialog.dismiss();
                                    })
                                    .setPositiveButton((dialog, which) -> {
                                        //TODO 缺少禁用启用接口，只有促销系统的接口但缺少参数
                                        getViewModel().setCabinPorts(mCabinetPID, port, 0,
                                                input, mForbiddenReasonBean.getCode(), nID).observe(this, mSetPortEnablebserver);
                                        dialog.dismiss();
                                    });
                            builder.create().show();


                        }, false)
                        .withClick(R.id.tvCancel, view -> {
                        }, true)
                ).build();
        setDisableDialog.setBackPressEnable(false);
//        ((TextView) setDisableDialog.getContentView().findViewById(R.id.tvTip)).setText(getString(R.string.user_activation_buy_combo_suc_tip));
        setDisableDialog.showPopupWindow();
    }

    String currentValue;
    double currentValueDouble;

    public void showSetCurrentDialog() {
        setDisableDialog = QuickPopupBuilder.with(this)
                .contentView(R.layout.dialog_cabin_set_current)
                .config(new QuickPopupConfig()
                        .gravity(Gravity.CENTER)
                        .backpressEnable(false)
                        .outSideDismiss(false)
                        .outSideTouchable(false)
                        .withClick(R.id.tvOK, view -> {
                            currentValue = ((EditText) setDisableDialog.getContentView().findViewById(R.id.etInput)).getText().toString();
                            if (TextUtils.isEmpty(currentValue)) {
                                return;
                            }
                            currentValueDouble = Double.parseDouble(currentValue);
                            if (currentValueDouble < 0.4 || currentValueDouble > 7) {
                                return;
                            }
                            hideSoftInput();
                            getViewModel().setChargingCurrent(port, currentValueDouble * 10,
                                    mCabinetPID).observe(this, mSetCurrentObserver);
                        }, true)
                        .withClick(R.id.tvCancel, view -> {
                        }, true)
                ).show();
        ((EditText) setDisableDialog.getContentView().findViewById(R.id.etInput)).setHint(String.format(getString(R.string.cabin_cabin_enter_current), "0.4", mMacValue + ""));
    }

    @Override
    protected RecyclerView getRecyclerView() {
        return mBinding.rvCabinList;
    }

    int nID = 1;//主副柜

    public void reFreshSn(String mCabinetPID, String mCabinetSN, int nID) {
        this.mCabinetPID = mCabinetPID;
        this.mCabinetSN = mCabinetSN;
        this.nID = nID;
        getViewModel().getCabinList(mCabinetSN).observe(this, mCabinOberver);
    }

    @Override
    protected void initPageData() {
        getViewModel().getCabinList(mCabinetSN).observe(this, mCabinOberver);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        getStatusView().setEnableLoadMore(false);
        getStatusView().setEnableRefresh(true);
        mCabinetPID = getArguments().getString("pid");
        mCabinetSN = getArguments().getString("mCabinetSN");
        isNoRemotePerssion = getArguments().getBoolean("isNoRemotePerssion");
        isEditFlag = getArguments().getBoolean("isEditFlag");
        mBinding.setView(this);
        initTablebarAdapter();
        initObserver();
    }

    private void initTablebarAdapter() {
        mToolbarAdapter = new SingleDataBindingNoPUseAdapter<CabinToolbarBean>(R.layout.item_cabin_toolbar) {
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
                    } else {
                        ((CabinToolbarBean) adapter.getData().get(i)).setSelect(false);
                    }
                }
//                mToolbarAdapter.notifyDataSetChanged();
            }
        });
        mBinding.rvCabinToolbar.setLayoutManager(new LinearLayoutManager(getActivity(), LinearLayoutManager.HORIZONTAL, false));
        mBinding.rvCabinToolbar.setAdapter(mToolbarAdapter);
    }

    private void refreshCabinList(String name) {
        if (getString(R.string.cabin_cabin_all).equals(name)) {
            mCabinList.clear();
            mCabinList.addAll(mCabinListAll);
            getAdapter().setNewData(mCabinList);
        } else {
            mCabinList.clear();
            for (int i = 0; i < mCabinListAll.size(); i++) {
                /*if (getString(R.string.cabin_cabin_overcurrent).equals(name)) {
                    if (mCabinListAll.get(i).getOvercurrent() == 1) {
                        mCabinList.add(mCabinListAll.get(i));
                    }
                }*/
                /*if (getString(R.string.cabin_cabin_overvoltage).equals(name)) {
                    if (mCabinListAll.get(i).getOvervoltage() == 1) {
                        mCabinList.add(mCabinListAll.get(i));
                    }
                }*/
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
            getAdapter().setNewData(mCabinList);
        }
    }

    List<Cabin> mCabinList = new ArrayList<>();
    List<Cabin> mCabinListAll = new ArrayList<>();
    //    List<CabinBean.ListBean> mCabinList = new ArrayList<>();
//    List<CabinBean.ListBean> mCabinListAll = new ArrayList<>();
    List<ForbiddenReasonBean> mForbiddenReasonList;

    private void initObserver() {
        mCabinOberver = beans -> {
            mCabinList.clear();
            mCabinList.addAll(beans);
            mCabinListAll.clear();
            mCabinListAll.addAll(beans);
            pageIndex = defaultStartPageIndex;
            getToolbarData();
            updateListItems(mCabinList);
        };
        getViewModel().getCabinList(mCabinetSN).observe(this, mCabinOberver);

        mSetCurrentObserver = str -> {
            onRefresh();
        };

        mSetPortEnablebserver = str -> {
            onRefresh();
        };
        mOpenCabinDoorObserver = str -> {
            onRefresh();
        };
        mForbiddenObserver = forbiddenList -> {
            mForbiddenReasonList = forbiddenList;
            initForbiddenReasonDialog();
        };

    }

    ForbiddenReasonBean mForbiddenReasonBean;

    private void initForbiddenReasonDialog() {
        if (mForbiddenReasonList == null || mForbiddenReasonList.size() <= 0) {
            return;
        }
        if (mSelectForbiddenReasonDialog == null) {
            mSelectForbiddenReasonDialog = new SelectForbiddenReasonDialog(getContext(), mForbiddenReasonList)
                    .setOnSelectClickListener(bean -> {
                        mForbiddenReasonBean = bean;
                        if ("6".equals(mForbiddenReasonBean.getCode())) {
                            showSetDisableDialog();
                        } else {
                            CustomDialog.Builder builder = new CustomDialog.Builder(getActivity())
                                    .setTitle(getString(R.string.cabin_detail_remote_disable_cabin))
                                    .setMessage(getString(R.string.cabin_detail_remote_disable_cabin_tips))
                                    .setNegativeButton((dialog, which) -> {
                                        dialog.dismiss();
                                    })
                                    .setPositiveButton((dialog, which) -> {
                                        //TODO 缺少禁用启用接口，只有促销系统的接口但缺少参数
                                        getViewModel().setCabinPorts(mCabinetPID, port, 0,
                                                mForbiddenReasonBean.getValue(), mForbiddenReasonBean.getCode(), nID).observe(this, mSetPortEnablebserver);
                                        dialog.dismiss();
                                    });
                            builder.create().show();

                        }
                    });
        }
        if (!mSelectForbiddenReasonDialog.isShowing()) {
            mSelectForbiddenReasonDialog.showPopupWindow();
        }
    }

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

            /*if (listBean.getOvervoltage() == 1) {
                if (mOverVoltage == null) {
                    mOverVoltage = new CabinToolbarBean();
                    mOverVoltage.setName(getString(R.string.cabin_cabin_overvoltage));
                    mOverVoltage.setSize(1);
                    mOverVoltage.setSelect(false);
                    mToolbarList.add(mOverVoltage);
                } else {
                    mOverVoltage.setSize(mOverVoltage.getSize() + 1);
                }
            } else {
                if (mOverVoltage == null) {
                    mOverVoltage = new CabinToolbarBean();
                    mOverVoltage.setName(getString(R.string.cabin_cabin_overvoltage));
                    mOverVoltage.setSize(0);
                    mOverVoltage.setSelect(false);
                    mToolbarList.add(mOverVoltage);
                }
            }*/

            /*if (listBean.getOvercurrent() == 1) {
                if (mOverCurrent == null) {
                    mOverCurrent = new CabinToolbarBean();
                    mOverCurrent.setName(getString(R.string.cabin_cabin_overcurrent));
                    mOverCurrent.setSize(1);
                    mOverCurrent.setSelect(false);
                    mToolbarList.add(mOverCurrent);
                } else {
                    mOverCurrent.setSize(mOverCurrent.getSize() + 1);
                }
            } else {
                if (mOverCurrent == null) {
                    mOverCurrent = new CabinToolbarBean();
                    mOverCurrent.setName(getString(R.string.cabin_cabin_overcurrent));
                    mOverCurrent.setSize(0);
                    mOverCurrent.setSelect(false);
                    mToolbarList.add(mOverCurrent);
                }
            }*/
        }
        mToolbarAdapter.setNewData(mToolbarList);
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            default:
                break;
        }
    }
}