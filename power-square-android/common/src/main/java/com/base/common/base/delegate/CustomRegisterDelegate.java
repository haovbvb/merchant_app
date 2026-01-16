package com.base.common.base.delegate;

import android.app.Activity;

import androidx.fragment.app.Fragment;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.OnLifecycleEvent;

import com.base.library.base.delegate.RegisterSDK;
import com.base.library.base.delegate.RegisterSDKDelegate;

import org.greenrobot.eventbus.EventBus;

public class CustomRegisterDelegate extends RegisterSDKDelegate {
    private boolean isBindEventBusHere;

    public CustomRegisterDelegate(Activity activity) {
        super(activity);
    }

    public CustomRegisterDelegate(Fragment fragment) {
        super(fragment);
    }


    public boolean isBindEventBusHere() {
        return isBindEventBusHere;
    }

    public CustomRegisterDelegate setBindEventBusHere(boolean bindEventBusHere) {
        isBindEventBusHere = bindEventBusHere;
        return this;
    }


    @Override
    public RegisterSDK onCreate() {
        super.onCreate();
        initEventBus(fragment);
        initEventBus(activity);
        return this;
    }


    public void initEventBus(Object context) {
        if (isBindEventBusHere() && context != null) {
            EventBus.getDefault().register(context);
        }
    }

    public void unRegisterEventBus(Object context) {
        if (isBindEventBusHere() && context != null) {
            EventBus.getDefault().unregister(context);
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    @Override
    public void onDestroy() {
        unRegisterEventBus(fragment);
        unRegisterEventBus(activity);
        super.onDestroy();
    }
}
