package com.base.library.base;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.base.library.base.delegate.RegisterSDK;
import com.orhanobut.logger.Logger;

import java.util.Calendar;

public abstract class BaseAppCompatActivity extends AppCompatActivity implements View.OnClickListener {
    protected static String TAG_LOG = null;

    /**
     * context
     */
    protected Context mContext = null;
    private RegisterSDK registerSDK;

    @Override
    public void onContentChanged() {
        super.onContentChanged();
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        TAG_LOG = this.getClass().getSimpleName();
        Logger.i(TAG_LOG + " onCreate");
        getLifecycle().addObserver(getRegisterSDK().onCreate());
        if (getIntent() != null) {
            getIntentExtras(getIntent());
        }

    }

    @Override
    protected void onResume() {
        super.onResume();
        Logger.i(TAG_LOG + " onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        Logger.i(TAG_LOG + " onPause");
    }

    @Override
    protected void onStop() {
        super.onStop();
        Logger.i(TAG_LOG + " onStop");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Logger.i(TAG_LOG + " onDestroy");
    }

    public RegisterSDK getRegisterSDK() {
        if (registerSDK == null) {
            registerSDK = onCreateRegisterSDKDelegate();
            if (registerSDK == null) {
                registerSDK = new RegisterSDK();
            }
        }
        return registerSDK;
    }

    protected RegisterSDK onCreateRegisterSDKDelegate() {
        return new RegisterSDK();
    }

    /**
     * get Intent data
     *
     * @param intent
     */
    protected void getIntentExtras(Intent intent) {

    }

    /**
     * init all views and add events
     */
    protected abstract void initViews(Bundle savedInstanceState);

    protected void hideSoftInput() {
        View view = getWindow().peekDecorView();
        if (view != null) {
            InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            inputMethodManager.hideSoftInputFromWindow(view.getWindowToken(), 0);
        }
    }

    protected void showToast(String msg) {
        if (this.getBaseContext() != null && msg != null)
            Toast.makeText(this.getBaseContext(), msg, Toast.LENGTH_SHORT).show();
    }

    public Activity getActivity() {
        return this;
    }


    public int minClickDelayTime = 500;
    public long lastClickTime = 0L;

    public int getMinClickDelayTime() {
        return this.minClickDelayTime;
    }

    public void setMinClickDelayTime(int minClickDelayTime) {
        this.minClickDelayTime = minClickDelayTime;
    }

    public boolean checkIsDoubleClick() {
        long currentTime = Calendar.getInstance().getTimeInMillis();
        if (Math.abs(currentTime - this.lastClickTime) > (long) this.getMinClickDelayTime()) {
            this.lastClickTime = currentTime;
            return false;
        } else {
            return true;
        }
    }

    public void onClick(View v) {
        if (!this.checkIsDoubleClick()) {
            this.onNoDoubleClick(v);
        }
    }

    public void onNoDoubleClick(View v) {
    }
}
