package com.base.library.base.mvvm;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;
import androidx.fragment.app.Fragment;

import com.base.library.R;
import com.base.library.base.BaseAppCompatFragment;
import com.base.library.base.Loading;
import com.base.library.base.delegate.StatusView;
import com.base.library.base.delegate.StatusViewDelegate;
import com.base.library.base.delegate.StatusViewImpl;
import com.base.library.net.exception.ErrorMsgBean;

import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;

public abstract class BaseVFragment<VM extends BaseViewModel, V extends ViewDataBinding>
        extends BaseAppCompatFragment {
    CompositeDisposable compositeDisposable;

    protected VM viewModel;
    protected V mBinding;
    protected StatusView statusView;
    protected Loading loading;

    protected String RESULT_KEY = "ResultKey";

    @LayoutRes
    protected abstract int getLayoutId();


    public Fragment getFragment() {
        return this;
    }


    public boolean isActive() {
        return isAdded();
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
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
    protected void initViews(View view, Bundle savedInstanceState) {
        getStatusView().initStatusView(view, null);
        setViewModel(onCreateViewModel());
        initViewModelListener();
    }

    private void initViewModelListener() {
        if (getViewModel() != null)
            getViewModel().loadState.observe(this, state -> {
                switch (state.getLoadingState()) {
                    case State.SUCCESS:
                        if (getLoading() != null)
                            getLoading().onFinish();
                        onSuccess();
                        break;
                    case State.START:
                        if (getLoading() != null)
                            getLoading().onStart();
                        break;
                    case State.FINISH:
                        if (getLoading() != null)
                            getLoading().onFinish();
                        break;
                    case State.ERROR:
                        if (getLoading() != null)
                            getLoading().onFinish();
                        if (state.getErrorMsgBean() != null) {
                            onError(state.getErrorMsgBean(), state.isShowToast(), state.isShowStatusView());
                        } else if (state.getThrowable() != null) {
                            onError(state.getErrorMsgBean(), state.isShowToast(), state.isShowStatusView());
                        } else {
                            onError(state.getMsg(), state.isShowToast(), state.isShowNoNetView(), state.isShowErrorView());
                        }
                        break;
                    case State.NO_MORE_DATA:
                        if (getLoading() != null)
                            getLoading().onFinish();
                        showNoMoreDataView();
                        break;
                    default:
                        break;
                }
            });
    }

    protected abstract VM onCreateViewModel();

    protected VM getViewModel() {
        return viewModel == null ? onCreateViewModel() : viewModel;
    }

    /**
     * 如不需要任何状态页功能，子类重写返回null即可
     *
     * @return
     */
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

    public void setViewModel(VM viewModel) {
        this.viewModel = viewModel;
    }

    public void onBack() {

    }

    public void onRightImage() {

    }

    public void onRightAction() {

    }

    public void onLeftAction() {

    }

    public void onSuccess() {
        showContentView();
    }

    public void onEmpty() {
        hideSoftInput();
        onError(getString(R.string.textNoData), false, false, true);
    }

    public void onError(Throwable e) {
        onError(e, false, true);
    }

    public void onError(ErrorMsgBean e) {
        onError(e, false, true);
    }

    public void onError(String msg) {
        onError(msg, true, false, false);
    }

    public void onError(Throwable e, boolean showToast, boolean showStatusView) {
        onError(e.getMessage(), showToast, false, showStatusView);
    }

    public void onError(ErrorMsgBean e, boolean showToast, boolean showStatusView) {
        onError(e.getMsg(), showToast, false, showStatusView);
    }

    public void onError(String msg, boolean showToast, boolean showNetErrorView, boolean showDataErrorView) {
        getStatusView().onFinishRefresh();
        getStatusView().onFinishLoadMore();
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
        getStatusView().onFinishRefresh();
        getStatusView().onFinishLoadMore();
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
