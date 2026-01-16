package com.base.library.base.mvp;


import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;

import com.base.library.net.exception.ErrorMsgBean;
import com.orhanobut.logger.Logger;

import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;

/**
 * @Date: 2017/10/31.17:02
 * @Author: base
 * @Description:
 * @Version:
 */

public abstract class BaseNormalPresenter<V extends BaseView> implements BasePresenter<V>, LifecycleObserver {
    protected V mView;
    //用来存放Disposable的容器
    private CompositeDisposable mCompositeDisposable;
    protected boolean isDestroy;

    public BaseNormalPresenter() {
    }

    public BaseNormalPresenter(V mView) {
        this.mView = mView;
    }

    @Override
    public void attachView(V mView) {
        this.mView = mView;
        isDestroy = false;
//        mView.setPresenter(this);
    }

    /**
     * 是否已断开关联
     */
    public boolean isViewDetached() {
        return mView == null || isDestroy;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    @Override
    public void detachView() {
        Logger.i("BaseNormalPresenter detachView");
//        if (mView != null) {
//            mView = null;
//        }
        isDestroy = true;
    }

    @Override
    public V getView() {
        if (mView == null)
            throw new RuntimeException("You have no binding this view");
        return mView;
    }

    @Override
    public void initData() {
    }

    @Override
    public void onBack() {
        mView.onBack();
    }

    @Override
    public void onLeftAction() {
        mView.onLeftAction();
    }

    @Override
    public void onRightAction() {
        mView.onRightAction();
    }

    @Override
    public void onRightImage() {
        mView.onRightImage();
    }

    @Override
    public String title() {
        return mView.title();
    }

    public void showErrorView(ErrorMsgBean e, boolean showToast, boolean showStatusView) {
        if (!isViewDetached() && e != null && getView() instanceof BaseView) {
            if (e.getType() == ErrorMsgBean.NET_TYPE_ERROR) {
                getView().onError(e.getMsg(), showToast, showStatusView, false);
            } else if (e.getType() == ErrorMsgBean.API_TYPE_ERROR) {
                getView().onError(e.getMsg(), showToast, false, showStatusView);
            } else {
                getView().onError(e.getMsg(), showToast, false, showStatusView);
            }
        }
    }

    //添加指定的请求
    @Override
    public Disposable addDisposable(Disposable disposable) {
        if (mCompositeDisposable == null)
            mCompositeDisposable = new CompositeDisposable();
        if (disposable != null)
            mCompositeDisposable.add(disposable);
        return disposable;
    }

    //移除指定的请求
    @Override
    public void removeDisposable(Disposable disposable) {
        if (mCompositeDisposable != null && disposable != null)
            mCompositeDisposable.remove(disposable);
    }

    //取消所有的请求Tag
    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    @Override
    public void removeAllDisposable() {
        Logger.i("BaseNormalPresenter removeAllDisposable");
        if (mCompositeDisposable != null)
            mCompositeDisposable.clear();
    }

}
