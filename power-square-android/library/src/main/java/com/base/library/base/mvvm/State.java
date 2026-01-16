package com.base.library.base.mvvm;

import com.base.library.net.exception.ErrorMsgBean;

/**
 * @Date: 2020/9/21 9:59
 * @Author: Jayden
 * @Description:
 * @Version:
 */
public class State {
    public static final int START = 1;
    public static final int FINISH = 2;
    public static final int ERROR = 3;
    public static final int SUCCESS = 4;
    public static final int NO_MORE_DATA = 5;
    public int loadingState;
    private String msg;
    private Throwable throwable;
    private ErrorMsgBean errorMsgBean;
    private boolean showToast;
    private boolean showNoNetView;
    private boolean showErrorView;
    private boolean showStatusView;

    public static State getInstance(int loadingState) {
        return new State().setLoadingState(loadingState);
    }

    public boolean isShowStatusView() {
        return showStatusView;
    }

    public State setShowStatusView(boolean showStatusView) {
        this.showStatusView = showStatusView;
        return this;
    }

    public String getMsg() {
        return msg;
    }

    public State setMsg(String msg) {
        this.msg = msg;
        return this;
    }

    public Throwable getThrowable() {
        return throwable;
    }

    public State setThrowable(Throwable throwable) {
        this.throwable = throwable;
        return this;
    }

    public ErrorMsgBean getErrorMsgBean() {
        return errorMsgBean;
    }

    public State setErrorMsgBean(ErrorMsgBean errorMsgBean) {
        this.errorMsgBean = errorMsgBean;
        return this;
    }

    public boolean isShowToast() {
        return showToast;
    }

    public State setShowToast(boolean showToast) {
        this.showToast = showToast;
        return this;
    }

    public boolean isShowNoNetView() {
        return showNoNetView;
    }

    public State setShowNoNetView(boolean showNoNetView) {
        this.showNoNetView = showNoNetView;
        return this;
    }

    public boolean isShowErrorView() {
        return showErrorView;
    }

    public State setShowErrorView(boolean showErrorView) {
        this.showErrorView = showErrorView;
        return this;
    }

    public int getLoadingState() {
        return loadingState;
    }

    public State setLoadingState(int loadingState) {
        this.loadingState = loadingState;
        return this;
    }
}
