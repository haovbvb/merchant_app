package com.okla.ops.views.workbench.cabinetopt;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.ImageView;

import androidx.databinding.ViewDataBinding;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.base.mvvm.BaseNormalListVFragment;
import com.base.common.utils.WindowInsetsHelper;
import com.base.library.utils.GsonUtils;
import com.bumptech.glide.Glide;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.BR;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.UserAuthorizationBean;
import com.okla.ops.beans.UserAuthorizationList;
import com.okla.ops.databinding.FragmentUserAuthorizationListBinding;

public class CabinetAuthorizationUserFragment extends BaseNormalListVFragment<CabinetAuthorizationOperateViewModel, FragmentUserAuthorizationListBinding> {

    private Observer<UserAuthorizationList> mUserAuthorizationListSearchObserver;

    private SingleDataBindingNoPUseAdapter mAdapter;

    @Override
    protected RecyclerView.Adapter createAdapter() {
        mAdapter = new SingleDataBindingNoPUseAdapter<UserAuthorizationBean>(R.layout.item_user_authorization) {
            @Override
            public void convert(BaseViewHolder helper, UserAuthorizationBean item, ViewDataBinding viewDataBinding) {
                Glide.with(helper.itemView).load(item.getAvatar()).circleCrop().into((ImageView) helper.getView(R.id.imDevice));
                if (TextUtils.equals(accountNo, item.getAccountNo())) {
                    helper.getView(R.id.ivSelect).setVisibility(View.VISIBLE);
                } else {
                    helper.getView(R.id.ivSelect).setVisibility(View.GONE);
                }
            }
        };
        mAdapter.setOnItemClickListener((adapter, view, position) -> {
            UserAuthorizationBean userAuthorizationBean = (UserAuthorizationBean) adapter.getData().get(position);
            if (getView() != null) {
                NavController navController = Navigation.findNavController(getView());
                if (navController.getPreviousBackStackEntry() != null) {
                    navController.getPreviousBackStackEntry().getSavedStateHandle().set("USER", GsonUtils.toGson(userAuthorizationBean));
                    navController.popBackStack();
                }
            }
        });
        return mAdapter;
    }

    @Override
    protected RecyclerView getRecyclerView() {
        return mBinding.rvUserList;
    }

    @Override
    protected void initPageData() {
        getUserAuthorizationList();
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_user_authorization_list;
    }

    @Override
    protected CabinetAuthorizationOperateViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinetAuthorizationOperateViewModel.class);
    }

    private String stationSn;
    private String accountNo;

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        getStatusView().setEnableLoadMore(true);
        getStatusView().setEnableRefresh(true);
        WindowInsetsHelper.applyForToolbar(mActivity, mBinding.rootlayout.getId());
        initObserver();
        initClicks();
        initData();
    }

    private void initObserver() {
        mUserAuthorizationListSearchObserver = bean -> {
            if (bean != null)
                updateListItems(bean.getList());
            getStatusView().onFinishRefresh();
        };
        mBinding.etInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (TextUtils.isEmpty(s)) {
                    mBinding.imClear.setVisibility(View.GONE);
                    inputString = "";
                    onRefresh();
                } else {
                    mBinding.imClear.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                inputString = s.toString();
            }
        });
    }

    String inputString = "";

    private void initClicks() {
        mBinding.etInput.setOnEditorActionListener((v, actionId, event) -> {

            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                hideSoftInput();
                onRefresh();
                return true;
            }
            return false;
        });
        mBinding.imClear.setOnClickListener(v -> {
            mBinding.etInput.setText("");
        });
        mBinding.includeTitle.topBack.setOnClickListener(v -> {
            if (!Navigation.findNavController(v).popBackStack()) {
                mActivity.finish();
            }
        });
    }

    private void initData() {
        mBinding.includeTitle.topTitle.setText(getString(R.string.cabinet_opt_user_select_title));
        mBinding.includeTitle.topTitle.setGravity(Gravity.CENTER);
        Bundle arguments = getArguments();
        if (arguments != null) {
            stationSn = arguments.getString("sn");
            accountNo = arguments.getString("accountNo");
        }
        if (TextUtils.isEmpty(stationSn) && getView() != null) {
            Navigation.findNavController(getView()).popBackStack();
            return;
        }
        onRefresh();
    }

    private void getUserAuthorizationList() {
        getViewModel().getUserAuthorizationListSearchData(stationSn, inputString, pageIndex, pageSize).observe(this, mUserAuthorizationListSearchObserver);
    }

}
