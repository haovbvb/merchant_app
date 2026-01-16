package com.base.library.base.mvvm;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;
import androidx.fragment.app.Fragment;
import androidx.test.espresso.IdlingResource;

import com.base.library.R;
import com.base.library.base.BaseAppCompatActivity;
import com.base.library.base.Loading;
import com.base.library.base.delegate.StatusView;
import com.base.library.base.delegate.StatusViewDelegate;
import com.base.library.base.delegate.StatusViewImpl;
import com.base.library.net.exception.ErrorMsgBean;
import com.base.library.utils.EspressoIdlingResource;

import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;

public abstract class BaseVActivity<VM extends BaseViewModel, V extends ViewDataBinding>
        extends BaseAppCompatActivity {
    CompositeDisposable compositeDisposable;
    protected VM viewModel;
    protected V mBinding;
    protected StatusView statusView;
    protected Loading loading;

    @VisibleForTesting
    public IdlingResource getCountingIdlingResource() {
        return EspressoIdlingResource.getIdlingResource();
    }

    public boolean isActive() {
        return false;
    }

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
        setViewModel(onCreateViewModel());
        getStatusView().initStatusView(null, this);
        initViews(savedInstanceState);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
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

    @Override
    public View onCreateView(String name, Context context, AttributeSet attrs) {
        return super.onCreateView(name, context, attrs);
    }

    protected V getBindView() {
        return mBinding;
    }

    protected abstract VM onCreateViewModel();

    protected VM getViewModel() {
        return viewModel == null ? onCreateViewModel() : viewModel;
    }

    @LayoutRes
    protected abstract int getLayoutId();


    public void onBack() {

    }


    public void onRightImage() {

    }


    public void onRightAction() {

    }

    public void setTopRightText(TextView tvTopRight) {

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

    public void resetNoMoreDataView() {
        getStatusView().onResetNoMoreData();
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
        if (compositeDisposable != null && disposable != null)
            compositeDisposable.remove(disposable);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        removeAllDisposable();
    }

}
