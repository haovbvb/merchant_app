package com.base.common.base.delegate;

import android.app.Activity;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.OnLifecycleEvent;

import com.base.common.R;
import com.base.library.base.delegate.RefreshLoadMoreListener;
import com.base.library.base.delegate.StateViewClickListener;
import com.base.library.base.delegate.StatusViewDelegate;
import com.scwang.smartrefresh.layout.SmartRefreshLayout;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.listener.OnRefreshLoadMoreListener;

public class StatusViewRefreshDelegate extends StatusViewDelegate {
    private SmartRefreshLayout refreshLayout;
    private RefreshLoadMoreListener refreshLoadMoreListener;
    private boolean enableRefresh = true;
    private boolean enableLoadMore = false;

    public RefreshLoadMoreListener getRefreshLoadMoreListener() {
        return refreshLoadMoreListener;
    }

    public StatusViewRefreshDelegate setRefreshLoadMoreListener(RefreshLoadMoreListener refreshLoadMoreListener) {
        this.refreshLoadMoreListener = refreshLoadMoreListener;
        return this;
    }

    @Override
    public void onViewCreated(View view) {
        super.onViewCreated(view);
        refreshLayout = view.findViewById(R.id.swipRefresh);
        initRefreshListener();
    }

    public void initRefreshListener() {
        if (getRefreshLayout() != null) {
            getRefreshLayout().setEnableRefresh(getEnableRefresh());
            getRefreshLayout().setEnableLoadMore(getEnableLoadMore());
            getRefreshLayout().setOnRefreshLoadMoreListener(new OnRefreshLoadMoreListener() {
                @Override
                public void onLoadMore(@NonNull RefreshLayout refreshLayout) {
                    if (getRefreshLoadMoreListener() != null) {
                        getRefreshLoadMoreListener().onLoadMore();
                    }
                }

                @Override
                public void onRefresh(@NonNull RefreshLayout refreshLayout) {
                    if (getRefreshLoadMoreListener() != null) {
                        getRefreshLoadMoreListener().onRefresh();
                    }
                }
            });
        }
    }

    @Override
    public void onCreated(Activity view) {
        super.onCreated(view);
        refreshLayout = view.findViewById(R.id.swipRefresh);
        initRefreshListener();
    }

    @Override
    public SmartRefreshLayout getRefreshLayout() {
        return refreshLayout;
    }

    @Override
    public boolean getEnableLoadMore() {
        return enableLoadMore;
    }

    @Override
    public StatusViewRefreshDelegate setEnableRefresh(boolean enableRefresh) {
        this.enableRefresh = enableRefresh;
        getRefreshLayout().setEnableRefresh(enableRefresh);
        return this;
    }

    @Override
    public StatusViewRefreshDelegate setEnableLoadMore(boolean enableLoadMore) {
        this.enableLoadMore = enableLoadMore;
        getRefreshLayout().setEnableLoadMore(enableLoadMore);
        return this;
    }

    @Override
    public boolean getEnableRefresh() {
        return enableRefresh;
    }

    @Override
    public void onLoadMoreEnd() {
        if (getRefreshLayout() != null && getEnableLoadMore()) {
            getRefreshLayout().finishLoadMoreWithNoMoreData();
        }
    }

    @Override
    public void onFinishRefresh() {
        if (getRefreshLayout() != null && getEnableRefresh()) {
            getRefreshLayout().finishRefresh();
        }
    }

    @Override
    public void onFinishLoadMore() {
        if (getRefreshLayout() != null && getEnableLoadMore()) {
            getRefreshLayout().finishLoadMore();
        }
    }

    @Override
    public void onResetNoMoreData() {
        if (getRefreshLayout() != null && getEnableLoadMore()) {
            getRefreshLayout().resetNoMoreData();
        }
    }

    @Override
    public StatusViewRefreshDelegate setStateViewClickListener(StateViewClickListener stateViewClickListener) {
        super.setStateViewClickListener(stateViewClickListener);
        return this;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    @Override
    public void onDestroy() {
        super.onDestroy();
        refreshLoadMoreListener = null;
        refreshLayout = null;
    }
}
