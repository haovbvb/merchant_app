package com.base.common.base.mvp;

import android.view.View;

import androidx.databinding.ViewDataBinding;

import com.base.common.base.delegate.CustomRegisterDelegate;
import com.base.common.net.loading.DialogLoading;
import com.base.library.base.Loading;
import com.base.library.base.delegate.RefreshLoadMoreListener;
import com.base.library.base.delegate.RegisterSDKDelegate;
import com.base.library.base.delegate.StateViewClickListener;
import com.base.library.base.delegate.StatusView;
import com.base.common.base.delegate.StatusViewRefreshDelegate;
import com.base.library.base.mvp.BaseMvpActivity;
import com.base.library.base.mvp.BasePresenter;

public abstract class BaseNormalMvpActivity<P extends BasePresenter, V extends ViewDataBinding>
        extends BaseMvpActivity<P, V>
        implements RefreshLoadMoreListener, StateViewClickListener {

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
        return new DialogLoading(getActivity(), false);
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
}
