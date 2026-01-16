package com.base.library.base.mvp;

import io.reactivex.disposables.Disposable;

/**
 * @Date: 2017/10/31.17:02
 * @Author: base
 * @Description:
 * @Version:
 */

public interface BasePresenter<V extends BaseView> {
    void detachView();

    void attachView(V mView);

    V getView();

    void initData();

    void onBack();

    void onLeftAction();

    void onRightAction();

    void onRightImage();

    String title();

    //添加指定的请求
    Disposable addDisposable(Disposable disposable);

    //移除指定的请求
    void removeDisposable(Disposable disposable);

    //取消所有请求
    void removeAllDisposable();
}
