package com.base.library.base.delegate;

import androidx.lifecycle.LifecycleObserver;

/**
 * @Date: 2020/9/17 15:32
 * @Author: Jayden
 * @Description: 注册第三方库
 * @Version:
 */
public class RegisterSDK implements LifecycleObserver {

    public RegisterSDK onCreate() {
        return this;
    }

    public void onDestroy() {
    }
}
