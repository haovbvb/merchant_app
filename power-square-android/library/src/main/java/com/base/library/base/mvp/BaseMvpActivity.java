package com.base.library.base.mvp;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.LifecycleObserver;
import androidx.test.espresso.IdlingResource;

import com.base.library.base.BaseAppCompatActivity;
import com.base.library.base.Loading;
import com.base.library.base.delegate.StatusView;
import com.base.library.base.delegate.StatusViewDelegate;
import com.base.library.base.delegate.StatusViewImpl;
import com.base.library.net.exception.ErrorMsgBean;
import com.base.library.utils.EspressoIdlingResource;

import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;


/**
 * @Date: 2017/11/22.13:55
 * @Author: base
 * @Description:
 * @Version:
 */

public abstract class BaseMvpActivity<P extends BasePresenter, V extends ViewDataBinding>
        extends BaseAppCompatActivity
        implements BaseView {
    CompositeDisposable compositeDisposable;

    protected P mPresenter;
    protected V mBinding;
    protected StatusView statusView;

    @VisibleForTesting
    public IdlingResource getCountingIdlingResource() {
        return EspressoIdlingResource.getIdlingResource();
    }

    @Override
    public boolean isActive() {
        return false;
    }

    @Override
    public Fragment getFragment() {
        return null;
    }

    protected boolean viewDataBinding() {
        return true;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (viewDataBinding()) {
            mBinding = DataBindingUtil.setContentView(this, getLayoutId());
            mBinding.setLifecycleOwner(this);
        }
        if (!viewDataBinding()) {
            setContentView(getLayoutId());
        }
        setPresenter(createPresenter());
        if (mPresenter != null) {
            getLifecycle().addObserver((LifecycleObserver) mPresenter);
        }
        getStatusView().initStatusView(null, this);
        initViews(savedInstanceState);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {

    }

    protected StatusView onCreateStatusView() {
        return new StatusViewDelegate();
    }

    public StatusView getStatusView() {
        if (statusView == null) {
            statusView = onCreateStatusView();
            if (statusView == null) {
                statusView = new StatusViewImpl();
            }
            getLifecycle().addObserver(statusView);
        }
        return statusView;
    }

//    public void setStatusView(StatusView statusView) {
//        if (statusView != null)
//            this.statusView = statusView;
//    }

    @Override
    public View onCreateView(String name, Context context, AttributeSet attrs) {
        return super.onCreateView(name, context, attrs);
    }

    protected V getBindView() {
        return mBinding;
    }


    public abstract P createPresenter();

    public void setPresenter(P presenter) {
        this.mPresenter = presenter;
        if (mPresenter != null) {
            mPresenter.attachView(this);
        }
    }

    @LayoutRes
    protected abstract int getLayoutId();

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

    @Override
    public Loading getLoading() {
        return null;
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
        if (compositeDisposable != null && disposable != null) {
            compositeDisposable.remove(disposable);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        removeAllDisposable();
    }

}
