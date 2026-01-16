package com.okla.ops.views.workbench.bluetoothauthorization;

import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.base.mvvm.State;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.BluetoothOperateData;
import com.okla.ops.beans.SNBean;
import com.okla.ops.http.HttpMethods;

import java.util.Map;

/**
 * @Date: DATE.{TIME}
 * @Author: hong_world
 * @Description:
 * @Version:
 */
public class BluetoothAuthorizationViewModel extends BaseViewModel {
    //
    public MutableLiveData<BluetoothOperateData> mBluetoothEnOrDecrypt = new MutableLiveData<>();

    public void blueToothEnOrDecrypt(Map<String, Object> map) {
        addDisposable(HttpMethods.INSTANCE.blueToothEnOrDecrypt(map).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String s) {
                BluetoothOperateData bluetoothOperateData = new BluetoothOperateData();
                bluetoothOperateData.map = map;
                bluetoothOperateData.data = s;
                mBluetoothEnOrDecrypt.setValue(bluetoothOperateData);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                loadState.postValue(State.getInstance(State.ERROR)
                        .setErrorMsgBean(e)
                        .setShowToast(true));
            }
        }));

    }

    public MutableLiveData<Long> mUidLiveData = new MutableLiveData<>();

    /**
     * 获取用户唯一编码
     */
    public void getUidByPhone(String phone) {
        addDisposable(HttpMethods.INSTANCE.getUidByPhone(phone).subscribeWith(new NullAbleObserver<Long>() {
            @Override
            protected void onSuccess(Long s) {
                mUidLiveData.setValue(s);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
//                ToastUtils.showShort(e.getMsg());
                loadState.postValue(State.getInstance(State.ERROR)
                        .setErrorMsgBean(e)
                        .setShowStatusView(true));

            }
        }));

    }


    public MutableLiveData<SNBean> mSnLiveData = new MutableLiveData<>();

    /**
     * 获取柜子锁id
     */
    public void getLockIdBySn(String sn) {
        addDisposable(HttpMethods.INSTANCE.getLockIdBySn(sn).subscribeWith(new NullAbleObserver<SNBean>() {
            @Override
            protected void onSuccess(SNBean s) {
                mSnLiveData.setValue(s);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                loadState.postValue(State.getInstance(State.ERROR)
                        .setErrorMsgBean(e)
                        .setShowToast(true));
            }
        }));

    }

    public MutableLiveData<Object> mAddAuthLiveData = new MutableLiveData<>();

    /**
     * 增加授权
     */
    public void authAdd(Map<String, Object> map) {
        addDisposable(HttpMethods.INSTANCE.authAdd(map).subscribeWith(new NullAbleObserver<Object>() {
            @Override
            protected void onSuccess(Object s) {
                mAddAuthLiveData.setValue(s);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                loadState.postValue(State.getInstance(State.ERROR)
                        .setErrorMsgBean(e)
                        .setShowToast(true));
            }
        }));

    }
}