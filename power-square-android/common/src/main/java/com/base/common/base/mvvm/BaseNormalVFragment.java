package com.base.common.base.mvvm;

import android.content.res.Configuration;
import android.content.res.Resources;
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
import com.base.library.base.delegate.RefreshLoadMoreListener;
import com.base.library.base.delegate.RegisterSDKDelegate;
import com.base.library.base.delegate.StateViewClickListener;
import com.base.library.base.delegate.StatusView;
import com.base.common.base.delegate.StatusViewRefreshDelegate;
import com.base.library.base.mvvm.BaseVFragment;
import com.base.library.base.mvvm.BaseViewModel;

public abstract class BaseNormalVFragment<VM extends BaseViewModel, V extends ViewDataBinding>
        extends BaseVFragment<VM, V>
        implements RefreshLoadMoreListener, StateViewClickListener, ToolBarEvent {
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

    /**
     * is bind eventBus
     *
     * @return
     */
    protected boolean isBindEventBusHere() {
        return false;
    }


    @Override
    public Loading getLoading() {
        if (loading == null) {
            loading = new DialogLoading(mActivity, false);
        }
        return loading;
    }

    @Override
    public void onRefresh() {

    }

    @Override
    public void onLoadMore() {

    }

    @Override
    public void onStateViewClick(View view) {
        onRefresh();
    }

    public void initToolBar() {
        ToolBarEventDelegate.initToolBarEvent(getView(), this);
    }
}
