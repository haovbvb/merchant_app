package com.okla.ops.views.monitor.cabinetdetail.search.localstatus;

import android.text.TextUtils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.http.HttpMethods;

/**
 * @Date: 2021/2/23 10:25
 * @Author: craz
 * @Description:
 * @Version:
 */

public class LocalStatusViewModel extends BaseViewModel {
    MutableLiveData<String> statusData = new MutableLiveData<>();

    public LiveData<String> getLocalStatus(String pid){
        addDisposable(HttpMethods.INSTANCE.getLocalStatus(pid).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String str) {
                statusData.setValue(TextUtils.isEmpty(str)? "" :str);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                statusData.setValue("");
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return statusData;
    }
}