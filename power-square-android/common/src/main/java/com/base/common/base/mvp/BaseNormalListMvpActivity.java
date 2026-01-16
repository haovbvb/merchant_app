package com.base.common.base.mvp;

import androidx.databinding.ViewDataBinding;

import com.base.common.base.delegate.CustomRegisterDelegate;
import com.base.library.base.delegate.RegisterSDKDelegate;
import com.base.library.base.delegate.StatusView;
import com.base.common.base.delegate.StatusViewRefreshDelegate;
import com.base.library.base.mvp.BaseListMvpActivity;
import com.base.library.base.mvp.BasePresenter;
import com.chad.library.adapter.base.BaseQuickAdapter;

import java.util.List;

public abstract class BaseNormalListMvpActivity<P extends BasePresenter, V extends ViewDataBinding>
        extends BaseListMvpActivity<P, V> {

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

    protected boolean isBindEventBusHere() {
        return false;
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

}
