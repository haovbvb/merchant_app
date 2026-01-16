package com.okla.ops.views.monitor.cabinetdetail.baseinfo.personliable;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;

import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.base.mvvm.BaseNormalListVActivity;
import com.base.common.utils.ToastUtils;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.beans.OpsAndMaintenaceBean;
import com.okla.ops.beans.SelectedPersonLiableBean;
import com.okla.ops.databinding.ActivitySelectPersonLiableBinding;
import com.okla.ops.dialog.SelectPersonLiableDialog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import razerdp.basepopup.BasePopupWindow;

/**
 * @Date: 2021/2/1 14:23
 * @Author: craz
 * @Description:
 * @Version:
 */

public class SelectPersonLiableActivity extends BaseNormalListVActivity<SelectPersonLiableViewModel, ActivitySelectPersonLiableBinding> {

    private Observer<OpsAndMaintenaceBean> mOpsAndMaintenaceObserver;
    private SingleDataBindingNoPUseAdapter adapter;
    private OpsAndMaintenaceBean.ListBean mSelectBean;
    private SelectPersonLiableDialog mSelectPersonLiableDialog;
    private List<OpsAndMaintenaceBean.ListBean> mSelectedBeanList;
    private Observer<String> mAddPersonLiable;
    private String mCabinetSN;
    private String[] sns;
    private SelectedPersonLiableBean[] userDetails;
    private ArrayList<CabinetDetailBaseInfoBean.ManagerBean> mPersonLiablePreList;

    public static Intent getIntents(Context context, String sn, ArrayList<CabinetDetailBaseInfoBean.ManagerBean> list) {
        Intent intent = new Intent(context, SelectPersonLiableActivity.class);
        intent.putExtra("sn", sn);
        intent.putParcelableArrayListExtra("list", list);
        return intent;
    }

    @Override
    public int title() {
        return R.string.person_liable_title;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_select_person_liable;
    }

    @Override
    protected SelectPersonLiableViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(SelectPersonLiableViewModel.class);
    }

    HashMap<String, OpsAndMaintenaceBean.ListBean> mSelectedMap = new HashMap<>();

    @Override
    protected RecyclerView.Adapter createAdapter() {
        adapter = new SingleDataBindingNoPUseAdapter<OpsAndMaintenaceBean.ListBean>(R.layout.item_select_responsible_person);
        adapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
                mSelectBean = (OpsAndMaintenaceBean.ListBean) adapter.getData().get(position);
                if (mSelectBean.isSelect()) {
                    mSelectBean.setSelect(false);
                    mSelectedMap.remove(mSelectBean.getId());
                    setSelectedNum();
                    adapter.notifyItemChanged(position);
                } else {
                    if (mSelectedMap.size() < 5) {
                        mSelectBean.setSelect(true);
                        mSelectedMap.put(mSelectBean.getId(), mSelectBean);
                        setSelectedNum();
                        adapter.notifyItemChanged(position);
                    }
                }
            }
        });
        return adapter;
    }

    private void setSelectedNum() {
        mBinding.tvShowWindow.setText(String.format(getString(R.string.person_liable_selected), mSelectedMap.size()));
    }

    @Override
    protected RecyclerView getRecyclerView() {
        return mBinding.rvPersonLiable;
    }

    @Override
    protected void initPageData() {
        getViewModel().getOpsAndMaintenaceList(pageIndex, pageSize, mBinding.etInput.getText().toString(),mBinding.etInput.getText().toString(),2,1).observe(this, mOpsAndMaintenaceObserver);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        Intent intent = getIntent();
        mCabinetSN = intent.getStringExtra("sn");
        mPersonLiablePreList = intent.getParcelableArrayListExtra("list");
        setPrePersonLiableMap();
        getStatusView().setEnableLoadMore(true);
        getStatusView().setEnableRefresh(true);
        mBinding.setView(this);
        initObserver();
        onRefresh();
        setSelectedNum();
    }

    String inputString;

    private void initObserver() {
        mBinding.etInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                mBinding.setData(s.toString());
                inputString = s.toString();
            }
        });
        getLoading().onStart();
        mOpsAndMaintenaceObserver = opsAndMaintBean -> {
            getLoading().onFinish();
            if(opsAndMaintBean != null && opsAndMaintBean.getList() != null){
                if(pageIndex == 1){
                    removePrePersonLiable(opsAndMaintBean);
                    getSelectedPersonList();
                    opsAndMaintBean.getList().addAll(0,mSelectedBeanList);
                }else {
                    removePrePersonLiable(opsAndMaintBean);
                }
            }
            updateListItems(opsAndMaintBean.getList());
        };

        mAddPersonLiable = str -> {
            Intent intent = new Intent();
            intent.putParcelableArrayListExtra("list", mPersonLiablePreList);
            setResult(444,intent);
            finish();
        };
    }

    private void removePrePersonLiable(OpsAndMaintenaceBean opsAndMaintBean) {
        Iterator<OpsAndMaintenaceBean.ListBean> iterator = opsAndMaintBean.getList().iterator();
        while (iterator.hasNext()) {
            OpsAndMaintenaceBean.ListBean next = iterator.next();
            if (mSelectedMap.containsKey(next.getId())) {
                iterator.remove();
            }
        }
    }
    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.tvShowWindow:
                showPersonLiblePop();
                break;
            case R.id.tvOK:
                if(mSelectedMap.size()<=0){
                    ToastUtils.showLong(getString(R.string.liable_tips_error));
                    return;
                }
                userDetails = new SelectedPersonLiableBean[mSelectedMap.size()];
                getSelectedPersonList();
                mPersonLiablePreList.clear();
                for (int i = 0; i < mSelectedBeanList.size(); i++) {
                    userDetails[i] = new SelectedPersonLiableBean(mSelectedBeanList.get(i).getPhone(),mSelectedBeanList.get(i).getName(),mSelectedBeanList.get(i).getId());
                    mPersonLiablePreList.add(new CabinetDetailBaseInfoBean.ManagerBean(mSelectedBeanList.get(i).getPhone(),mSelectedBeanList.get(i).getName(),mSelectedBeanList.get(i).getId()));
                }
                getViewModel().addPersonLiable(mCabinetSN,userDetails).observe(this,mAddPersonLiable);
                break;
            case R.id.tvSearch:
                hideSoftInput();
                onRefresh();
                break;
            case R.id.ivDelete:
                mBinding.etInput.setText("");
                break;
            default:
                break;
        }
    }

    private void showPersonLiblePop() {
        if (mSelectedMap.size() <= 0) {
            return;
        }
        getSelectedPersonList();
        mSelectPersonLiableDialog = new SelectPersonLiableDialog(this, mSelectedBeanList)
                .setOnSelectClickListener(bean -> {
                    int index = getAdapter().getData().indexOf(bean);
                    ((OpsAndMaintenaceBean.ListBean) adapter.getData().get(index)).setSelect(false);
                    adapter.notifyItemChanged(index);
                    mSelectedBeanList.remove(bean);
                    mSelectedMap.remove(bean.getId());
                    setSelectedNum();
                    if (mSelectedMap.size() == 0) {
                        mSelectPersonLiableDialog.dismiss();
                    }
                });
        mSelectPersonLiableDialog.setOnDismissListener(new BasePopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                mBinding.tvShowWindow.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, R.mipmap.ic_triangle_up, 0);
            }
        });
        if (!mSelectPersonLiableDialog.isShowing()) {
            mSelectPersonLiableDialog.showPopupWindow(mBinding.clBottom);
            mBinding.tvShowWindow.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, R.mipmap.ic_triangle_down, 0);
        }
    }

    OpsAndMaintenaceBean.ListBean prePersonLiableBean;
    private void setPrePersonLiableMap(){
        if(mPersonLiablePreList != null) {
            for (int i = 0; i < mPersonLiablePreList.size(); i++) {
                prePersonLiableBean = new OpsAndMaintenaceBean.ListBean();
                prePersonLiableBean.setSelect(true);
                prePersonLiableBean.setId(mPersonLiablePreList.get(i).getId());
                prePersonLiableBean.setName(mPersonLiablePreList.get(i).getName());
                prePersonLiableBean.setPhone(mPersonLiablePreList.get(i).getPhone());
                mSelectedMap.put(mPersonLiablePreList.get(i).getId(), prePersonLiableBean);
            }
        }
    }

    private void getSelectedPersonList() {
        if (mSelectedBeanList == null) {
            mSelectedBeanList = new ArrayList<>();
        }
        mSelectedBeanList.clear();
        for (OpsAndMaintenaceBean.ListBean bean : mSelectedMap.values()) {
            mSelectedBeanList.add(bean);
        }
    }
}