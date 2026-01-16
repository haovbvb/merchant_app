package com.okla.ops.views.workbench.unshelve;

import android.text.TextUtils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.net.loading.LoadingTransHelper;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.base.mvvm.State;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.NewCabinetBean;
import com.okla.ops.http.HttpMethods;
import com.okla.ops.utils.EventUtils;

/**
 * @Date: DATE.{TIME}
 * @Author: hong_world
 * @Description:
 * @Version:
 */
public class UnshelveViewModel extends BaseViewModel {
    MutableLiveData<Object> unsheleData = new MutableLiveData<>();

    public MutableLiveData<NewCabinetBean> newCabinetBeanMutableLiveData = new MutableLiveData<>();

    //根据sn或pid获取柜子名称和规格
    public LiveData<NewCabinetBean> getStationType(String type, String code) {
        addDisposable(HttpMethods.INSTANCE.getStationSource(type, code)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<NewCabinetBean>() {
            @Override
            protected void onSuccess(NewCabinetBean data) {
                if (data != null) {
                    newCabinetBeanMutableLiveData.setValue(data);
                }
                loadState.setValue(State.getInstance(State.SUCCESS));

            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                if (e.getCode() == 400) {
                    newCabinetBeanMutableLiveData.setValue(null);
                } else {
                    ToastUtils.showShort(e.getMsg());
                }
                loadState.setValue(State.getInstance(State.ERROR));
            }
        }));
        return newCabinetBeanMutableLiveData;
    }

    MutableLiveData<String> mGetDeviceSn = new MutableLiveData<>();

    public LiveData<String> getDeviceSn(String content) {
        addDisposable(HttpMethods.INSTANCE.getDeviceSn(1, content).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String str) {
                if (TextUtils.isEmpty(str)) {
                    mGetDeviceSn.setValue(content);
                } else {
                    mGetDeviceSn.setValue(str);
                }

            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mGetDeviceSn;
    }

    public LiveData<Object> unshelve(String pid, String content) {
        addDisposable(HttpMethods.INSTANCE.unshelveNew(pid, content)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<Object>() {
            @Override
            protected void onSuccess(Object str) {
                unsheleData.setValue("success");
                loadState.setValue(State.getInstance(State.SUCCESS));
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
                if (e.getCode() == EventUtils.INSTANCE.getSuccessResponeCode()) {
                    unsheleData.setValue(0);
                    loadState.setValue(
                            State.getInstance(State.SUCCESS));
                }
            }
        }));
        return unsheleData;
    }

}