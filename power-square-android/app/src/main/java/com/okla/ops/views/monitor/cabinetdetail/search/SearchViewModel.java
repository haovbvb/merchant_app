package com.okla.ops.views.monitor.cabinetdetail.search;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.http.HttpMethods;

/**
 * @Date: 2021/1/26 14:27
 * @Author: craz
 * @Description:
 * @Version:
 */

public class SearchViewModel extends BaseViewModel {
    MutableLiveData<Long> cabinetTime = new MutableLiveData<>();

    public LiveData<Long> getCabinetTime(String pid){
        addDisposable(HttpMethods.INSTANCE.getCabinetTime(pid).subscribeWith(new NullAbleObserver<Long>() {
            @Override
            protected void onSuccess(Long aDouble) {
                cabinetTime.setValue(aDouble);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));

        return cabinetTime;
    }
}