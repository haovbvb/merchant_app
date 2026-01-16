package com.okla.ops.views.monitor.cabinetdetail;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.databinding.ViewDataBinding;
import androidx.databinding.library.baseAdapters.BR;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.CommonApplication;
import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.db.entity.OpsPermissionEntity;
import com.base.common.utils.DensityUtil;
import com.base.library.base.BaseAppCompatFragment;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.CustomFragmentPagerAdapter;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.beans.CabinetDetailToolbarBean;
import com.okla.ops.beans.DeputyCabinetBean;
import com.okla.ops.databinding.ActivityCabinetDetailBinding;
import com.okla.ops.dialog.SelectDeputyCabinetDialog;
import com.okla.ops.views.monitor.cabinetdetail.baseinfo.CabinetBaseInfoFragment;
import com.okla.ops.views.monitor.cabinetdetail.cabin.CabinFragment;
import com.okla.ops.views.monitor.cabinetdetail.operation.OperationFragment;
import com.okla.ops.views.monitor.cabinetdetail.search.SearchFragment;

import java.util.ArrayList;
import java.util.List;

import razerdp.basepopup.BasePopupWindow;

/**
 * @Date: 2021/1/25 16:23
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinetDetailActivity extends BaseNormalVActivity<CabinetDetailViewModel, ActivityCabinetDetailBinding> {

    private SingleDataBindingNoPUseAdapter adapter;
    int mViewPagerCount = 4;
    private CabinetBaseInfoFragment baseInfoFragment;
    private CabinFragment cabinFragment;
    private OperationFragment operationFragment;
    private String mCabinetSN, mCabinetPID;
    private SearchFragment searchFragment;
    private int mStationModel;
    private Observer<List<OpsPermissionEntity>> mOpsPermissionObserver;
    private boolean isNoRemotePerssion = true;//是否关闭远程控制权限，
    private boolean isNoTempPSWPermission = true;//是否关闭获取临时密码权限，
    private boolean isStationEditPermission = false;//是否有编辑电柜权限，

    public static Intent getIntents(Context context, String sn, String pid, int stationModel) {
        Intent intent = new Intent(context, CabinetDetailActivity.class);
        intent.putExtra("sn", sn);
        intent.putExtra("pid", pid);
        intent.putExtra("stationModel", stationModel);
        return intent;
    }

    @Override
    public int title() {
        return R.string.cabinet_detail_title;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_cabinet_detail;
    }

    @Override
    protected CabinetDetailViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinetDetailViewModel.class);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        Intent intent = getIntent();
        mCabinetSN = intent.getStringExtra("sn");
        mCabinetPID = intent.getStringExtra("pid");
        mStationModel = intent.getIntExtra("stationModel", -1);
        mBinding.setView(this);
        getOpsPermissionEntities();
        initTopTablebar();
        initObserver();
        initClicks();
    }

    private void getOpsPermissionEntities() {
        mOpsPermissionObserver = list -> {

            for (int i = 0; i < list.size(); i++) {
                switch (list.get(i).getCode()) {
                    case "station:remote":
                        if (list.get(i).getIsOwn() == 1) {
                            isNoRemotePerssion = false;
                        }
                        break;
                    case "station:tmppassword":
                        if (list.get(i).getIsOwn() == 1) {
                            isNoTempPSWPermission = false;
                        }
                        break;
                    case "monitor:station_edit":
                        if (list.get(i).getIsOwn() == 1) {
                            isStationEditPermission = true;
                        }
                        break;
                }
            }

            initViewPager();
        };

        CommonApplication.getCommonApplication().getRepository().loadAllOpsPermissionEntities().observe(this, mOpsPermissionObserver);
    }

    private void initClicks() {
        mBinding.includeTitle.topRight.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                initSelectDeputyCabinetDialog();
            }
        });
    }

    private void initViewPager() {
        FragmentManager mFragmentManager = getSupportFragmentManager();
        CustomFragmentPagerAdapter mPagerAdapter = new CustomFragmentPagerAdapter(mFragmentManager, mOnFragmentChangeListener);
        mPagerAdapter.setCount(mViewPagerCount);
        mBinding.mViewpager.setOffscreenPageLimit(mViewPagerCount);
        mBinding.mViewpager.setAdapter(mPagerAdapter);
        mBinding.mViewpager.setNoScroll(true);
        mBinding.mViewpager.setScrollContainer(false);
    }

    private CustomFragmentPagerAdapter.OnFragmentChangeListener mOnFragmentChangeListener = new CustomFragmentPagerAdapter.OnFragmentChangeListener() {
        @Override
        public Fragment getFragment(int position) {
            return getAllFragmentByIndex(position);
        }
    };

    private BaseAppCompatFragment getAllFragmentByIndex(int position) {
        switch (position) {
            case 0:
                return getBaseInfoFragment();
            case 1:
                return getCabinFragment();
            case 2:
                return getSearchFragment();
            case 3:
                return getOperationFragment();
            default:
                return getBaseInfoFragment();
        }
    }

    private BaseAppCompatFragment getOperationFragment() {
        if (operationFragment == null) {
            operationFragment = OperationFragment.getInstance(mCabinetPID, isNoRemotePerssion, isNoTempPSWPermission);
        }
        return operationFragment;
    }

    private BaseAppCompatFragment getSearchFragment() {
        if (searchFragment == null) {
            searchFragment = SearchFragment.getInstance(mCabinetPID);
        }
        return searchFragment;
    }

    private BaseAppCompatFragment getCabinFragment() {
        if (cabinFragment == null) {
            cabinFragment = CabinFragment.getInstance(mCabinetPID, mCabinetSN, isNoRemotePerssion, isEditFlag);
        }
        return cabinFragment;
    }

    private BaseAppCompatFragment getBaseInfoFragment() {
        if (baseInfoFragment == null) {
            baseInfoFragment = CabinetBaseInfoFragment.getInstance(mCabinetSN, isStationEditPermission);
        }
        return baseInfoFragment;
    }

    private void initTopTablebar() {
        List<CabinetDetailToolbarBean> mTablebarList = new ArrayList<>();
        mTablebarList.add(new CabinetDetailToolbarBean(getString(R.string.cabinet_detail_base_info), true));
        mTablebarList.add(new CabinetDetailToolbarBean(getString(R.string.cabinet_detail_cabin), false));
//        if(mStationModel<4) {
//         mTablebarList.add(new CabinetDetailToolbarBean(getString(R.string.cabinet_detail_search),false));
//         mTablebarList.add(new CabinetDetailToolbarBean(getString(R.string.cabinet_detail_operation),false));
//        }

        mBinding.rvCabinetDetail.setLayoutManager(new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false));
        adapter = new SingleDataBindingNoPUseAdapter<CabinetDetailToolbarBean>(R.layout.item_cabinet_detail_top_toolbar) {
            @Override
            public void convert(BaseViewHolder helper, CabinetDetailToolbarBean item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                helper.getView(R.id.tvTitle).setPadding(15, 10, 15, 10);
                viewDataBinding.setVariable(BR.index, adapter.getData().indexOf(item));

            }
        };
        adapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
                for (int i = 0; i < mTablebarList.size(); i++) {
                    if (i == position) {
                        mTablebarList.get(i).setSelect(true);
                        controlBotttomNav(i);
                    } else {
                        mTablebarList.get(i).setSelect(false);
                    }
                }
            }
        });
        mBinding.rvCabinetDetail.setAdapter(adapter);
        adapter.addData(mTablebarList);

    }

    private void controlBotttomNav(int position) {
        mBinding.mViewpager.setCurrentItem(position, false);
    }

    List<DeputyCabinetBean> mDeputyCabinetList;
    private Observer<List<DeputyCabinetBean>> mDeputyCabinetBeanObserver;
    private Observer<CabinetDetailBaseInfoBean> baseInfoObserver;
    private boolean isEditFlag = false;

    private void initObserver() {
        mDeputyCabinetBeanObserver = deputyCabinetBeanList -> {
            if (deputyCabinetBeanList != null && deputyCabinetBeanList.size() > 1) {
                if (mDeputyCabinetList == null) {
                    mDeputyCabinetList = new ArrayList<>();
                }
                mDeputyCabinetList.addAll(deputyCabinetBeanList);
                mBinding.includeTitle.topRight.setVisibility(View.VISIBLE);
                mBinding.includeTitle.topRight.setPadding(0, 0, DensityUtil.dp2px(this, 20), 0);
                mBinding.includeTitle.topRight.setCompoundDrawablesWithIntrinsicBounds(0, 0, R.mipmap.detail_down, 0);
                mBinding.includeTitle.topRight.setCompoundDrawablePadding(4);
                mBinding.includeTitle.topRight.setText(String.format(getString(R.string.device_detail_mainframe), 1));
            }
        };
//        getViewModel().getDeputyCabinetData(mCabinetPID).observe(this, mDeputyCabinetBeanObserver);

        baseInfoObserver = cabinetDetailBaseInfoBean -> {
            if (cabinetDetailBaseInfoBean != null)
                isEditFlag = cabinetDetailBaseInfoBean.isEditFlag();
        };
        getViewModel().getCabinetBaseInfo(mCabinetSN).observe(this, baseInfoObserver);
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            default:
                break;
        }
    }

    DeputyCabinetBean mDeputyCabinetBean;
    SelectDeputyCabinetDialog mSelectDeputyCabinetDialog;

    private void initSelectDeputyCabinetDialog() {
        if (mDeputyCabinetList == null || mDeputyCabinetList.size() <= 0) {
            return;
        }
        if (mSelectDeputyCabinetDialog == null) {
            mSelectDeputyCabinetDialog = new SelectDeputyCabinetDialog(this, mDeputyCabinetList)
                    .setOnSelectClickListener(bean -> {
                        mDeputyCabinetBean = bean;
                        if (1 == bean.getNodeId()) {
                            mBinding.includeTitle.topRight.setText(String.format(getString(R.string.device_detail_mainframe), bean.getNodeId()));
                        } else {
                            mBinding.includeTitle.topRight.setText(String.format(getString(R.string.device_detail_deputy_ark), bean.getNodeId()));
                        }
                        if (operationFragment != null) {
                            operationFragment.reFreshSn(mCabinetPID, mDeputyCabinetBean.getNodeId());
                        }
                        if (searchFragment != null) {
                            searchFragment.reFreshSn(mCabinetPID, mCabinetSN);
                        }
                        if (cabinFragment != null) {
                            cabinFragment.reFreshSn(mCabinetPID, mCabinetSN, mDeputyCabinetBean.getNodeId());
                        }
                        if (baseInfoFragment != null) {
                            baseInfoFragment.reFreshSn(bean.getPid(), bean.getSn(), mDeputyCabinetBean.getNodeId());
                        }
                    });
            mSelectDeputyCabinetDialog.setOnDismissListener(new BasePopupWindow.OnDismissListener() {
                @Override
                public void onDismiss() {
                    mBinding.includeTitle.topRight.setCompoundDrawablesWithIntrinsicBounds(0, 0, R.mipmap.detail_down, 0);
                }
            });
        }
        if (!mSelectDeputyCabinetDialog.isShowing()) {
            mSelectDeputyCabinetDialog.showPopupWindow(mBinding.includeTitle.topRight);
            mBinding.includeTitle.topRight.setCompoundDrawablesWithIntrinsicBounds(0, 0, R.mipmap.detail_up, 0);
        }
    }
}