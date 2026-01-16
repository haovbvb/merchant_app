package com.base.library.base.mvp;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.LifecycleObserver;

import com.base.library.base.BaseAppCompatFragment;
import com.base.library.base.Loading;
import com.base.library.base.delegate.StatusView;
import com.base.library.base.delegate.StatusViewDelegate;
import com.base.library.base.delegate.StatusViewImpl;
import com.base.library.net.exception.ErrorMsgBean;

import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;

/**
 * @Date: 2017/10/31.17:56
 * @Author: base
 * @Description:
 * @Version:
 */

public abstract class BaseMvpFragment<P extends BasePresenter, V extends ViewDataBinding>
        extends BaseAppCompatFragment
        implements BaseView {
    CompositeDisposable compositeDisposable;

    protected P mPresenter;
    protected V mBinding;
    protected StatusView statusView;

    public abstract P createPresenter();

    @LayoutRes
    protected abstract int getLayoutId();

    @Override
    public Fragment getFragment() {
        return this;
    }

    @Override
    public boolean isActive() {
        return isAdded();
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setPresenter(createPresenter());
        if (getPresenter() != null) getLifecycle().addObserver((LifecycleObserver) getPresenter());
    }

    protected boolean viewDataBinding() {
        return true;
    }

    @Override
    protected View onCreateMyView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View v = viewDataBinding() ?
                (mBinding = DataBindingUtil.inflate(inflater, getLayoutId(), null, false)).getRoot() :
                inflater.inflate(getLayoutId(), container, false);
        if (viewDataBinding() && mBinding != null) {
            mBinding.setLifecycleOwner(this);
        }
        return v;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        getStatusView().initStatusView(view, null);
    }

    protected StatusView onCreateStatusView() {
        return new StatusViewDelegate();
    }

    public StatusView getStatusView() {
        if (statusView == null) {
            statusView = onCreateStatusView();
            if (statusView == null)
                statusView = new StatusViewImpl();
            getLifecycle().addObserver(statusView);
        }
        return statusView;
    }

//    public void setStatusView(StatusView statusView) {
//        if (statusView != null)
//            this.statusView = statusView;
//    }

    protected V getBindView() {
        return mBinding;
    }

    public void setPresenter(P presenter) {
        this.mPresenter = presenter;
        if (mPresenter != null) {
            mPresenter.attachView(this);
        }
    }

    public P getPresenter() {
        return mPresenter;
    }


    @Override
    public void onBack() {

    }

    @Override
    public void onRightImage() {

    }

    @Override
    public void onRightAction() {

    }

    @Override
    public void onLeftAction() {

    }

    @Override
    public void onSuccess() {
        showContentView();
    }

    @Override
    public void onEmpty() {
        hideSoftInput();
    }

    @Override
    public void onError(Throwable e) {
        onError(e, false, true);
    }

    @Override
    public void onError(ErrorMsgBean e) {
        onError(e, false, true);
    }

    @Override
    public void onError(String msg) {
        onError(msg, true, false, false);
    }

    @Override
    public void onError(Throwable e, boolean showToast, boolean showStatusView) {
        onError(e.getMessage(), showToast, false, showStatusView);
    }

    @Override
    public void onError(ErrorMsgBean e, boolean showToast, boolean showStatusView) {
        onError(e.getMsg(), showToast, false, showStatusView);
    }

    @Override
    public void onError(String msg, boolean showToast, boolean showNetErrorView, boolean showDataErrorView) {
        getStatusView().onFinishLoadMore();
        getStatusView().onFinishRefresh();
        if (showDataErrorView) {
            showDataErrorView(msg);
        }
        if (showNetErrorView) {
            showNetErrorView(msg);
        }
        if (showToast) {
            showToast(msg);
        }
    }

    public void showContentView() {
        getStatusView().showContentView();
        getStatusView().onFinishLoadMore();
        getStatusView().onFinishRefresh();
    }

    public void showNoMoreDataView() {
        getStatusView().showContentView();
        getStatusView().onFinishRefresh();
        getStatusView().onLoadMoreEnd();
    }

    public void showNetErrorView(String msg) {
        getStatusView().showNetErrorView(msg);
    }

    public void showDataErrorView(String msg) {
        getStatusView().showDataErrorView(msg);
    }

    @Override
    public Loading getLoading() {
        return null;
    }

    protected Disposable addDisposable(Disposable disposable) {
        if (disposable != null) {
            if (compositeDisposable == null || compositeDisposable.isDisposed()) {
                compositeDisposable = new CompositeDisposable();
            }
            compositeDisposable.add(disposable);
        }
        return disposable;
    }

    public void removeAllDisposable() {
        if (compositeDisposable != null) {
            compositeDisposable.dispose();
            compositeDisposable.clear();
            compositeDisposable = null;
        }
    }

    public void removeDisposable(Disposable disposable) {
        if (compositeDisposable != null && disposable != null)
            compositeDisposable.remove(disposable);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        removeAllDisposable();
    }
}
