package com.base.common.base.mvvm;

import android.os.Bundle;
import android.view.View;

import androidx.databinding.ViewDataBinding;

import com.base.common.R;
import com.base.common.base.delegate.CustomRegisterDelegate;
import com.base.common.base.delegate.ToolBarEvent;
import com.base.common.base.delegate.ToolBarEventDelegate;
import com.base.common.net.loading.DialogLoading;
import com.base.common.utils.WindowInsetsHelper;
import com.base.library.base.Loading;
import com.base.library.base.delegate.RegisterSDKDelegate;
import com.base.library.base.delegate.StatusView;
import com.base.common.base.delegate.StatusViewRefreshDelegate;
import com.base.library.base.mvvm.BaseListVFragment;
import com.base.library.base.mvvm.BaseViewModel;
import com.chad.library.adapter.base.BaseQuickAdapter;

import java.util.List;

public abstract class BaseNormalListVFragment<VM extends BaseViewModel, V extends ViewDataBinding>
        extends BaseListVFragment<VM, V> implements ToolBarEvent {

    @Override
    protected StatusView onCreateStatusView() {
        return new StatusViewRefreshDelegate()
                .setRefreshLoadMoreListener(this)
                .setStateViewClickListener(this);
    }

    @Override
    protected RegisterSDKDelegate onCreateRegisterSDKDelegate() {
        return new CustomRegisterDelegate(this)
                .setBindEventBusHere(isBindEventBusHere());
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        initToolBar();
        WindowInsetsHelper.applyForToolbar(mActivity, R.id.toolbar);
    }

    protected boolean isBindEventBusHere() {
        return false;
    }

    @Override
    public Loading getLoading() {
        if (loading == null) {
            loading = new DialogLoading(getActivity(), false);
        }
        return loading;
    }


    @Override
    public BaseQuickAdapter getAdapter() {
        return (BaseQuickAdapter) adapter;
    }

    @Override
    protected void replaceData(List items) {
        if (getAdapter() != null) {
            getAdapter().setNewData(items);
        }
    }

    @Override
    protected void addData(List items) {
        if (getAdapter() != null) {
            getAdapter().addData(items);
        }
    }

    @Override
    protected List getData() {
        return getAdapter() != null ?
                getAdapter().getData() : null;
    }

    public void initToolBar() {
        ToolBarEventDelegate.initToolBarEvent(getView(), this);
    }

}
