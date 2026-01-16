package com.okla.ops.views.monitor.cabinetdetail.search.cabinetversion;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.CabinetVersionBean;
import com.okla.ops.http.HttpMethods;

/**
 * @Date: 2021/2/23 10:27
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinetVersionViewModel extends BaseViewModel {
    MutableLiveData<CabinetVersionBean> versionData = new MutableLiveData<>();

    public LiveData<CabinetVersionBean> getCabinetVersion(String pid){
        addDisposable(HttpMethods.INSTANCE.getCabinetVersion(pid).subscribeWith(new NullAbleObserver<CabinetVersionBean>() {
            @Override
            protected void onSuccess(CabinetVersionBean cabinetVersionBean) {
                versionData.setValue(cabinetVersionBean);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                versionData.setValue(new CabinetVersionBean());
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return versionData;
    }
}