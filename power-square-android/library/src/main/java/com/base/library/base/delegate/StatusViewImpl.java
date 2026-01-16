package com.base.library.base.delegate;

import android.app.Activity;
import android.view.View;
import android.view.ViewStub;

import com.orhanobut.logger.Logger;

/**
 * @Date: 2020/9/16 15:39
 * @Author: base
 * @Description:
 * @Version:
 */
public class StatusViewImpl<T> implements StatusView<T> {

    @Override
    public void initStatusView(View view, Activity activity) {
        Logger.i("StatusViewImpl initStatusView");
    }

    @Override
    public void onDestroy() {
        Logger.i("StatusViewImpl onDestroy");
    }

    @Override
    public View getContentDataView() {
        return null;
    }

    @Override
    public void setContentDataView(View contentDataView) {

    }

    @Override
    public void hindContentView() {

    }

    @Override
    public void showContentView() {

    }

    @Override
    public ViewStub getDataErrorViewStub() {
        return null;
    }

    @Override
    public void setDataErrorViewStub(ViewStub dataErrorViewStub) {

    }

    @Override
    public View getDataErrorView() {
        return null;
    }

    @Override
    public void setDataErrorView(View dataErrorView) {

    }

    @Override
    public void initDataErrorView() {

    }

    @Override
    public void showDataErrorView(String msg) {

    }
    @Override
    public void showDataErrorView(String msg,int imgId) {

    }

    @Override
    public View getNetErrorView() {
        return null;
    }

    @Override
    public void setNetErrorView(View netErrorView) {

    }

    @Override
    public ViewStub getNetErrorViewStub() {
        return null;
    }

    @Override
    public void setNetErrorViewStub(ViewStub netErrorViewStub) {

    }

    @Override
    public void showNetErrorView(String msg) {

    }

    @Override
    public void initNetErrorView() {

    }

    @Override
    public T getRefreshLayout() {
        return null;
    }

    @Override
    public boolean getEnableLoadMore() {
        return false;
    }

    @Override
    public boolean getEnableRefresh() {
        return false;
    }

    @Override
    public StatusView<T> setEnableLoadMore(boolean enableLoadMore) {
        return this;
    }

    @Override
    public StatusView<T> setEnableRefresh(boolean enableRefresh) {
        return this;
    }

    @Override
    public void onLoadMoreEnd() {

    }

    @Override
    public void onFinishRefresh() {

    }

    @Override
    public void onFinishLoadMore() {

    }

    @Override
    public void onResetNoMoreData() {

    }
}
