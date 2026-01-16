package com.okla.ops.views.workbench.cabinetopt;

import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.databinding.ViewDataBinding;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.Preferences;
import com.base.common.base.mvvm.BaseNormalListVFragment;
import com.base.common.timepicker.DateFormatUtils;
import com.base.common.utils.DateTimeUtils;
import com.bumptech.glide.Glide;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.AuthorizationRecordBean;
import com.okla.ops.beans.AuthorizationRecordList;
import com.okla.ops.databinding.FragmentAuthorizationRecordListBinding;

import java.util.Locale;

import razerdp.basepopup.QuickPopupBuilder;
import razerdp.basepopup.QuickPopupConfig;
import razerdp.widget.QuickPopup;

public class CabinetAuthorizationRecordFragment extends BaseNormalListVFragment<CabinetAuthorizationOperateViewModel, FragmentAuthorizationRecordListBinding> {

    private Observer<AuthorizationRecordList> mAuthorizationRecordListObserver;
    private Observer<Object> mCancelPermissionObserver;

    private SingleDataBindingNoPUseAdapter mAdapter;

    @Override
    protected RecyclerView.Adapter createAdapter() {
        mAdapter = new SingleDataBindingNoPUseAdapter<AuthorizationRecordBean>(R.layout.item_authorization_record) {
            @Override
            public void convert(BaseViewHolder helper, AuthorizationRecordBean item, ViewDataBinding viewDataBinding) {
                Locale locale = DateTimeUtils.getLocaleByLanguage(Preferences.getInstance().getLanguage());
                Glide.with(helper.itemView).load(item.getStandardImg()).into((ImageView) helper.getView(R.id.imDevice));
                helper.setText(R.id.tvCabinetSn, "SN: " + item.getStationSn());
                Long actionTime = item.getActionTime();
                if (actionTime != null) {
                    helper.setText(R.id.tvAuthorizedTime,
                            getString(R.string.cabinet_opt_authorization_time,
                                    DateFormatUtils.long2Str1(actionTime, true, locale))
                    );
                }
                helper.setText(R.id.tvAuthorizationPersonValue, item.getBePermissionName());
                Long beginTime = item.getBeginTime();
                Long expireTime = item.getExpireTime();
                if (beginTime != null && expireTime != null) {
                    helper.setText(R.id.tvValidityPeriodValue,
                            DateFormatUtils.long2Str1(beginTime, true, locale) +
                                    "~" +
                                    DateFormatUtils.long2Str1(expireTime, true, locale)
                    );
                }
            }
        };
        mAdapter.setOnItemClickListener((adapter, view, position) -> {
            AuthorizationRecordBean authorizationRecordBean = (AuthorizationRecordBean) adapter.getData().get(position);
            if (authorizationRecordBean != null) {
                if (authorizationRecordBean.getPermissionStatus() != null && authorizationRecordBean.getPermissionStatus() == 1) {
                    mTempAuthorizationRecord = authorizationRecordBean;
                    showTipDialog();
                }
            }
        });
        return mAdapter;
    }

    @Override
    protected RecyclerView getRecyclerView() {
        return mBinding.rvRecordList;
    }

    @Override
    protected void initPageData() {
        getAuthorizationRecordList();
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_authorization_record_list;
    }

    @Override
    protected CabinetAuthorizationOperateViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinetAuthorizationOperateViewModel.class);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        getStatusView().setEnableLoadMore(true);
        getStatusView().setEnableRefresh(true);
        initObserver();
        initClicks();
        initData();
    }

    private void initObserver() {
        mAuthorizationRecordListObserver = bean -> {
            if (bean != null)
                updateListItems(bean.getList());
            getStatusView().onFinishRefresh();
        };
        mCancelPermissionObserver = bean -> {
            getLoading().onFinish();
            if (bean != null)
                onRefresh();
        };
    }

    private void initClicks() {
        mBinding.includeTitle.topBack.setOnClickListener(v -> {
            if (!Navigation.findNavController(v).popBackStack()) {
                mActivity.finish();
            }
        });
    }

    private void initData() {
        mBinding.includeTitle.topTitle.setText(getString(R.string.cabinet_opt_authorization_record));
        mBinding.includeTitle.topTitle.setGravity(Gravity.CENTER);
        onRefresh();
    }

    private void getAuthorizationRecordList() {
        getViewModel().getAuthorizationRecordListData("", "", pageIndex, pageSize).observe(this, mAuthorizationRecordListObserver);
    }

    private QuickPopup mTipDialog;
    private AuthorizationRecordBean mTempAuthorizationRecord;

    /**
     * 取消授权操作
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
                            getLoading().onStart();
                            getViewModel().cancelPermission(mTempAuthorizationRecord.getStationSn(), mTempAuthorizationRecord.getPermissionId()).observe(this, mCancelPermissionObserver);
                            mTipDialog.dismiss();
                        })).build();
        mTipDialog.showPopupWindow();
        mTipDialog.getContentView().post(()->{
            TextView tvContent = mTipDialog.findViewById(R.id.tvContent);
            String strTip = getString(R.string.cabinet_opt_cancel_authorization_tips);
            tvContent.setText(strTip);
        });
    }

}
