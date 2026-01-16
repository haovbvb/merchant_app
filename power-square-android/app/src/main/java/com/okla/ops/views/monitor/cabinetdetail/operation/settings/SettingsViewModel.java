package com.okla.ops.views.monitor.cabinetdetail.operation.settings;

import android.text.TextUtils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.net.loading.LoadingTransHelper;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.SettingInfoBean;
import com.okla.ops.http.HttpMethods;

/**
 * @Date: 2021/2/24 14:58
 * @Author: craz
 * @Description:
 * @Version:
 */

public class SettingsViewModel extends BaseViewModel {
    MutableLiveData<SettingInfoBean> getCabinetSettingData = new MutableLiveData<>();
    MutableLiveData<String> updateCabinetSettingData = new MutableLiveData<>();

    public LiveData<SettingInfoBean> getCabinetSettingInfo(String pid){
        addDisposable(HttpMethods.INSTANCE.getCabinetSettingInfo(pid)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<SettingInfoBean>() {
            @Override
            protected void onSuccess(SettingInfoBean settingInfoBean) {
                if(settingInfoBean != null) {
                    getCabinetSettingData.setValue(settingInfoBean);
                }else {
                    getCabinetSettingData.setValue(new SettingInfoBean());
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                getCabinetSettingData.setValue(null);
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return getCabinetSettingData;
    }
    public LiveData<String> updateCabinetSettingInfo(String pid,SettingInfoBean bean){
        addDisposable(HttpMethods.INSTANCE.updateCabinetSettingInfo(pid,bean).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String str) {
                updateCabinetSettingData.setValue(str);
                if(!TextUtils.isEmpty(str)){
                    ToastUtils.showShort(str);
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return updateCabinetSettingData;
    }
}