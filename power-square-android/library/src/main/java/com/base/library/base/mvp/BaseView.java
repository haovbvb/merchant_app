package com.base.library.base.mvp;

import android.app.Activity;

import androidx.fragment.app.Fragment;

import com.base.library.base.Loading;
import com.base.library.net.exception.ErrorMsgBean;

/**
 * @Date: 2017/10/31.17:02
 * @Author: base
 * @Description:
 * @Version:
 */

public interface BaseView {
    void onBack();

    void onLeftAction();

    void onRightAction();

    void onRightImage();

    String title();

    void onEmpty();

    void onError(String msg);

    void onError(String msg, boolean showToast, boolean showNoNetView, boolean showErrorView);

    void onError(Throwable e);

    void onError(Throwable e, boolean showToast, boolean showStatusView);

    void onError(ErrorMsgBean e);

    void onError(ErrorMsgBean e, boolean showToast, boolean showStatusView);

    void onSuccess();

    boolean isActive();

    Activity getActivity();

    Fragment getFragment();//注意：默认在activity中调用时为空

    Loading getLoading();

}
