package com.base.common.base.mvvm;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.databinding.ViewDataBinding;

import com.base.common.R;
import com.base.common.base.delegate.CustomRegisterDelegate;
import com.base.common.base.delegate.ToolBarEvent;
import com.base.common.base.delegate.ToolBarEventDelegate;
import com.base.common.net.loading.DialogLoading;
import com.base.common.utils.DataStoreKeyUtils;
import com.base.common.utils.DataStoreUtils;
import com.base.common.utils.LanguageUtils;
import com.base.common.utils.WindowInsetsHelper;
import com.base.library.base.Loading;
import com.base.library.base.delegate.RegisterSDKDelegate;
import com.base.library.base.delegate.StatusView;
import com.base.common.base.delegate.StatusViewRefreshDelegate;
import com.base.library.base.mvvm.BaseListVActivity;
import com.base.library.base.mvvm.BaseViewModel;
import com.chad.library.adapter.base.BaseQuickAdapter;

import java.util.List;

public abstract class BaseNormalListVActivity<VM extends BaseViewModel, V extends ViewDataBinding>
        extends BaseListVActivity<VM, V> implements ToolBarEvent {

    @Override
    protected StatusView onCreateStatusView() {
        return new StatusViewRefreshDelegate()
                .setRefreshLoadMoreListener(this)
                .setStateViewClickListener(this);
    }

    @Override
    protected RegisterSDKDelegate onCreateRegisterSDKDelegate() {
        return new CustomRegisterDelegate(this)
                .setBindEventBusHere(isBindEventBusHere());
    }

    protected boolean isBindEventBusHere() {
        return false;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void attachBaseContext(Context newBase) {
        String settingLanguage = DataStoreUtils.readStringData(
                DataStoreKeyUtils.Companion.getLANGUAGE_SETTING(),
                LanguageUtils.LanguageType.ENGLISH.getLanguage()
        );
        if (TextUtils.isEmpty(settingLanguage)) {
            settingLanguage = LanguageUtils.LanguageUtil.INSTANCE.getSystemLanguage(newBase);
            DataStoreUtils.INSTANCE.saveSyncStringData(
                    DataStoreKeyUtils.Companion.getLANGUAGE_SETTING(),
                    settingLanguage
            );
        }
        Context languageContext = LanguageUtils.LanguageUtil.INSTANCE.attachBaseContext(newBase, settingLanguage);
        Configuration override = new Configuration(languageContext.getResources().getConfiguration());
        override.fontScale = 1.0f;
        Context finalContext = languageContext.createConfigurationContext(override);
        super.attachBaseContext(finalContext);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        initToolBar();
        //自动刘海屏适配（仅加padding，不改透明、颜色）
        WindowInsetsHelper.applyForToolbar(this, R.id.toolbar);
    }

    public void initToolBar() {
        ToolBarEventDelegate.initToolBarEvent(this, this);
    }

    @Override
    public void onBack() {
        super.onBack();
        finish();
    }

    @Override
    public Loading getLoading() {
        if (loading == null) {
            loading = new DialogLoading(getActivity(), false);
        }
        return loading;
    }

    @Override
    public BaseQuickAdapter getAdapter() {
        return (BaseQuickAdapter) adapter;
    }

    @Override
    protected void replaceData(List items) {
        if (getAdapter() != null) {
            getAdapter().setNewData(items);
        }
    }

    @Override
    protected void addData(List items) {
        if (getAdapter() != null) {
            getAdapter().addData(items);
        }
    }

    @Override
    protected List getData() {
        return getAdapter() != null ?
                getAdapter().getData() : null;
    }

}
