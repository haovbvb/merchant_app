package com.okla.ops.views.workbench.cabinetopt;

import android.util.Log;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.http.HttpMethods;
import com.okla.ops.utils.CabinetFormat;
import com.okla.ops.utils.CabinetParam;

import java.util.ArrayList;
import java.util.List;

public class CabinetOfflineViewModel extends BaseViewModel {

    MutableLiveData<String> secretKeyLiveData = new MutableLiveData<>();

    public void getStationSecretKey(String sn) {
        addDisposable(HttpMethods.INSTANCE.getStationSecretKey(sn).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String secretKey) {
                secretKeyLiveData.setValue(secretKey);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                secretKeyLiveData.setValue("");
                ToastUtils.showShort(e.getMsg());
            }
        }));
    }

    MutableLiveData<CabinetDetailBaseInfoBean> baseInfoDataLiveData = new MutableLiveData<>();

    public void getCabinetBaseInfo(String sn) {
        addDisposable(HttpMethods.INSTANCE.getCabinetBaseInfo(sn).subscribeWith(new NullAbleObserver<CabinetDetailBaseInfoBean>() {
            @Override
            protected void onSuccess(CabinetDetailBaseInfoBean cabinetDetailBaseInfoBean) {
                baseInfoDataLiveData.setValue(cabinetDetailBaseInfoBean);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                baseInfoDataLiveData.setValue(null);
                ToastUtils.showShort(e.getMsg());
            }
        }));
    }

    public void configCabinet(String startTime, String stopTime, String stationPid, Integer type, Integer value) {
        addDisposable(HttpMethods.INSTANCE.configCabinet(startTime, stopTime, stationPid, type, value).subscribeWith(new NullAbleObserver<Object>() {
            @Override
            protected void onSuccess(Object obj) {
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                if(e!=null){
                    ToastUtils.showShort(e.getMsg());
                }
            }
        }));
    }

    public CabinetFormat buildFormat(int msgType, String deviceSn, List<CabinetParam> params) {
        return new CabinetFormat(msgType, deviceSn, params, String.valueOf(System.currentTimeMillis()));
    }

    public List<CabinetParam> buildParam(String... id) {
        List<CabinetParam> params = new ArrayList<>();
        for (String s : id) {
            params.add(new CabinetParam(s, null, null));
        }
        return params;
    }

    public List<CabinetParam> buildParamSetting(String id, String value) {
        List<CabinetParam> params = new ArrayList<>();
        params.add(new CabinetParam(id, value, null));
        return params;
    }

    public List<CabinetParam> buildParamSetting(String id, String value, String doorId) {
        List<CabinetParam> params = new ArrayList<>();
        params.add(new CabinetParam(id, value, doorId));
        return params;
    }

    private String mTempAllData;

    public void saveAllData(String data) {
        mTempAllData = data;
    }

    public String getAllData() {
        return mTempAllData;
    }

}
