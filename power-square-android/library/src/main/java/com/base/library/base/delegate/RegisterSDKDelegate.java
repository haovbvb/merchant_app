package com.base.library.base.delegate;

import android.app.Activity;

import androidx.fragment.app.Fragment;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.OnLifecycleEvent;

/**
 * @Date: 2020/9/17 15:32
 * @Author: Jayden
 * @Description: 注册第三方库
 * @Version:
 */
public class RegisterSDKDelegate extends RegisterSDK {
    protected Activity activity;
    protected Fragment fragment;

    public RegisterSDKDelegate(Activity activity) {
        this.activity = activity;
    }

    public RegisterSDKDelegate(Fragment fragment) {
        this.fragment = fragment;
    }

    public RegisterSDK onCreate() {
        return this;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    public void onDestroy() {
        activity = null;
        fragment = null;
    }
}
