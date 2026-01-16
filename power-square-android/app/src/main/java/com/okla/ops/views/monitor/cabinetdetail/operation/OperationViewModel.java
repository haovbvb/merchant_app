package com.okla.ops.views.monitor.cabinetdetail.operation;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.net.loading.LoadingTransHelper;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.TemporyPSWbean;
import com.okla.ops.http.HttpMethods;

/**
 * @Date: 2021/1/26 14:25
 * @Author: craz
 * @Description:
 * @Version:
 */

public class OperationViewModel extends BaseViewModel {
    MutableLiveData<String> openElectronicLockData = new MutableLiveData<>();
    MutableLiveData<String> shutDownMachineData = new MutableLiveData<>();
    MutableLiveData<String> restartCompleteMachineData = new MutableLiveData<>();
    MutableLiveData<TemporyPSWbean> getTemporyPSWData = new MutableLiveData<>();

    public LiveData<String> openElectronicLock(String pID,int nID){
        addDisposable(HttpMethods.INSTANCE.openElectronicLock(pID, nID + "").subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String s) {
                openElectronicLockData.setValue(s);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                openElectronicLockData.setValue(e.getMsg());
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return openElectronicLockData;
    }
    public LiveData<String> shutDaownMachine(String pID,int sleep){
        addDisposable(HttpMethods.INSTANCE.shutDaownMachine(pID,sleep)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String s) {
                shutDownMachineData.setValue(s);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                shutDownMachineData.setValue(e.getMsg());
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return shutDownMachineData;
    }
    public LiveData<String> restartCompleteMachine(String pID,int shutDown,int type){
        addDisposable(HttpMethods.INSTANCE.restartCompleteMachine(pID,shutDown,type)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String s) {
                restartCompleteMachineData.setValue(s);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                restartCompleteMachineData.setValue(e.getMsg());
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return restartCompleteMachineData;
    }
    public LiveData<TemporyPSWbean> getTemporyPSW(String pID){
        addDisposable(HttpMethods.INSTANCE.getTemporyPSW(pID)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<TemporyPSWbean>() {
            @Override
            protected void onSuccess(TemporyPSWbean bean) {
                getTemporyPSWData.setValue(bean);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                getTemporyPSWData.setValue(null);
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return getTemporyPSWData;
    }
}