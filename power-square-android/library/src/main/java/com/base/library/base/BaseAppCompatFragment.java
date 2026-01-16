package com.base.library.base;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.base.library.base.delegate.RegisterSDK;
import com.orhanobut.logger.Logger;

import java.util.Calendar;

public abstract class BaseAppCompatFragment extends Fragment implements View.OnClickListener {
    /**
     * Log tag
     */
    protected static String TAG_LOG = null;

    protected Activity mActivity;
    protected RegisterSDK registerSDK;
    /**
     * 是否执行懒加载
     */
    private boolean isLoaded = false;

    /**
     * 当前Fragment是否对用户可见
     */
    private boolean isVisibleToUser = false;

    /**
     * 当使用ViewPager+Fragment形式会调用该方法时，setUserVisibleHint会优先Fragment生命周期函数调用，
     * 所以这个时候就,会导致在setUserVisibleHint方法执行时就执行了懒加载，
     * 而不是在onResume方法实际调用的时候执行懒加载。所以需要这个变量
     */
    private boolean isCallResume = false;

    /**
     * 是否调用了setUserVisibleHint方法。处理show+add+hide模式下，默认可见 Fragment 不调用
     * onHiddenChanged 方法，进而不执行懒加载方法的问题。
     */
    private boolean isCallUserVisibleHint = false;

    public int minClickDelayTime = 500;
    public long lastClickTime = 0L;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        this.mActivity = (Activity) context;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG_LOG = this.getClass().getSimpleName();
        Logger.i(TAG_LOG + " onCreate");

        getLifecycle().addObserver(getRegisterSDK().onCreate());
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

    /**
     * 如不需要任何注册SDK，子类重写返回null即可
     *
     * @return
     */
    protected RegisterSDK onCreateRegisterSDKDelegate() {
        return new RegisterSDK();
    }

    protected abstract View onCreateMyView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState);

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        Logger.i(TAG_LOG + " onCreateView");
        View view = onCreateMyView(inflater, container, savedInstanceState);
        if (view != null) {
            return view;
        } else {
            return super.onCreateView(inflater, container, savedInstanceState);
        }
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Logger.i(TAG_LOG + " onViewCreated");
        if (getArguments() != null) {
            getArgumentsBundle(getArguments());
        }
        initViews(view, savedInstanceState);
    }

    /**
     * init all views and add events
     */
    protected abstract void initViews(View view, Bundle savedInstanceState);

    /**
     * get bundle data
     *
     * @param arguments
     */

    protected void getArgumentsBundle(Bundle arguments) {
    }

    @Override
    public void onResume() {
        super.onResume();
        Logger.i(TAG_LOG + " onResume");
        isCallResume = true;
        if (!isCallUserVisibleHint) {
            isVisibleToUser = !isHidden();
        }
        checkLazyInit();
    }

    @Override
    public void onStop() {
        super.onStop();
        Logger.i(TAG_LOG + " onStop");
    }

    @Override
    public void onPause() {
        super.onPause();
        Logger.i(TAG_LOG + " onPause");
    }

    private void checkLazyInit() {
        if (!isLoaded && isVisibleToUser && isCallResume) {
            isLoaded = true;
            onLazyInit();
        }
    }

    public void onLazyInit() {
        Logger.i(TAG_LOG + " onLazyInit");
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        Logger.i(TAG_LOG + " setUserVisibleHint " + isVisibleToUser);
        this.isVisibleToUser = isVisibleToUser;
        isCallUserVisibleHint = true;
        checkLazyInit();
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        Logger.i(TAG_LOG + " onHiddenChanged " + hidden);
        isVisibleToUser = !hidden;
        checkLazyInit();
        if (hidden) {
            hideSoftInput();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        Logger.i(TAG_LOG + " onDestroyView ");
        hideSoftInput();
        isLoaded = false;
        isVisibleToUser = false;
        isCallUserVisibleHint = false;
        isCallResume = false;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Logger.i(TAG_LOG + " onDestroy ");
    }

    protected void hideSoftInput() {
        if (this.getView() == null || this.getView().getContext() == null) {
            return;
        }
        InputMethodManager imm = (InputMethodManager) this.getView().getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(this.getView().getWindowToken(), 0);
    }

    protected void showToast(String msg) {
        if (getContext() != null && msg != null) {
            Toast.makeText(getContext(), msg, Toast.LENGTH_SHORT).show();
        }
    }

    public int getMinClickDelayTime() {
        return this.minClickDelayTime;
    }

    public void setMinClickDelayTime(int minClickDelayTime) {
        this.minClickDelayTime = minClickDelayTime;
    }

    public boolean checkIsDoubleClick() {
        long currentTime = Calendar.getInstance().getTimeInMillis();
        if (Math.abs(currentTime - this.lastClickTime) > (long)this.getMinClickDelayTime()) {
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
