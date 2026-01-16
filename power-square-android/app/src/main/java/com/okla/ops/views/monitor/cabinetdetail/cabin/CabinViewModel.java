package com.okla.ops.views.monitor.cabinetdetail.cabin;

import android.text.TextUtils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.base.mvvm.State;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.Cabin;
import com.okla.ops.beans.ForbiddenReasonBean;
import com.okla.ops.http.HttpMethods;

import java.util.ArrayList;
import java.util.List;

/**
 * @Date: 2021/1/26 14:13
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinViewModel extends BaseViewModel {
    MutableLiveData<String> mSetCabinPorts = new MutableLiveData<>();
    MutableLiveData<List<Cabin>> mCabinDataList = new MutableLiveData<>();
    MutableLiveData<List<ForbiddenReasonBean>> mForbiddenData = new MutableLiveData<>();
    MutableLiveData<String> mSetCurrentData = new MutableLiveData<>();

    public LiveData<List<Cabin>> getCabinList(String sn) {
        addDisposable(HttpMethods.INSTANCE.getCabinList(sn).subscribeWith(new NullAbleObserver<List<Cabin>>() {
            @Override
            protected void onSuccess(List<Cabin> cabinList) {
                if (cabinList != null) {
                    mCabinDataList.setValue(cabinList);
                } else {
                    mCabinDataList.setValue(new ArrayList<>());
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
                loadState.postValue(State.getInstance(State.ERROR)
                        .setErrorMsgBean(e)
                        .setShowStatusView(true));
            }
        }));
        return mCabinDataList;
    }

    public LiveData<List<ForbiddenReasonBean>> getForbiddenStorageReason() {
        addDisposable(HttpMethods.INSTANCE.getForbiddenStorageReason().subscribeWith(new NullAbleObserver<List<ForbiddenReasonBean>>() {
            @Override
            protected void onSuccess(List<ForbiddenReasonBean> cabinBean) {
                if (cabinBean != null) {
                    mForbiddenData.setValue(cabinBean);
                } else {
                    mForbiddenData.setValue(new ArrayList<>());
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mForbiddenData;
    }

    public LiveData<String> setCabinPorts(String pID, int port, int enable, String remark, String reasonCode,int nID) {
        addDisposable(HttpMethods.INSTANCE.setCabinPorts(pID, port, enable, remark, reasonCode,nID + "").subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String cabinBean) {
                if (cabinBean != null) {
                    mSetCabinPorts.setValue(cabinBean);
                    ToastUtils.showShort(cabinBean);
                } else {
                    mSetCabinPorts.setValue("");
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mSetCabinPorts;
    }

    public LiveData<String> openCabinDoor(String pID, int port,int nID) {
        addDisposable(HttpMethods.INSTANCE.openCabinDoor(pID, port,nID + "").subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String cabinBean) {
                if (cabinBean != null) {
                    mSetCabinPorts.setValue(cabinBean);
                    ToastUtils.showShort(cabinBean);
                } else {
                    mSetCabinPorts.setValue("");
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mSetCabinPorts;
    }

    public LiveData<String> setChargingCurrent(int port, double electricCurrent, String pID) {
        addDisposable(HttpMethods.INSTANCE.setChargingCurrent(port, electricCurrent, pID).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String s) {
                mSetCurrentData.setValue(TextUtils.isEmpty(s) ? "" : s);
                if(!TextUtils.isEmpty(s)){
                    ToastUtils.showShort(s);
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mSetCurrentData;
    }
}