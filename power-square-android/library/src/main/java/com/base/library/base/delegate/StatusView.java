package com.base.library.base.delegate;

import android.app.Activity;
import android.view.View;
import android.view.ViewStub;

import androidx.lifecycle.LifecycleObserver;

/**
 * @Date: 2020/9/16 15:45
 * @Author: base
 * @Description:
 * @Version:
 */
public interface StatusView<T> extends LifecycleObserver {
    void initStatusView(View view, Activity activity);

    void onDestroy();

    View getContentDataView();

    void setContentDataView(View contentDataView);

    void hindContentView();

    void showContentView();

    ViewStub getDataErrorViewStub();

    void setDataErrorViewStub(ViewStub dataErrorViewStub);

    View getDataErrorView();

    void setDataErrorView(View dataErrorView);

    void initDataErrorView();

    void showDataErrorView(String msg);

    void showDataErrorView(String msg,int imgId);

    View getNetErrorView();

    void setNetErrorView(View netErrorView);

    ViewStub getNetErrorViewStub();

    void setNetErrorViewStub(ViewStub netErrorViewStub);

    void showNetErrorView(String msg);

    void initNetErrorView();

    //----刷新控件
    T getRefreshLayout();

    boolean getEnableLoadMore();

    boolean getEnableRefresh();

    StatusView<T> setEnableLoadMore(boolean enableLoadMore);

    StatusView<T> setEnableRefresh(boolean enableRefresh);

    void onLoadMoreEnd();

    void onFinishRefresh();

    void onFinishLoadMore();

    void onResetNoMoreData();

}
