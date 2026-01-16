package com.okla.ops.views.monitor.cabinetdetail;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.beans.DeputyCabinetBean;
import com.okla.ops.http.HttpMethods;

import java.util.List;

/**
 * @Date: 2021/1/25 16:24
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinetDetailViewModel extends BaseViewModel {
    MutableLiveData<CabinetDetailBaseInfoBean> baseInfoData = new MutableLiveData<>();
    MutableLiveData<List<DeputyCabinetBean>> deputyCabinetData = new MutableLiveData<>();
    public LiveData<List<DeputyCabinetBean>> getDeputyCabinetData(String pid){
        addDisposable(HttpMethods.INSTANCE.getDeputyCabinet(pid).subscribeWith(new NullAbleObserver<List<DeputyCabinetBean>>() {
            @Override
            protected void onSuccess(List<DeputyCabinetBean> deputyCabinetBeans) {
                deputyCabinetData.setValue(deputyCabinetBeans);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                deputyCabinetData.setValue(null);
            }
        }));
        return deputyCabinetData;
    }

    public LiveData<CabinetDetailBaseInfoBean> getCabinetBaseInfo(String sn) {
        addDisposable(HttpMethods.INSTANCE.getCabinetBaseInfo(sn).subscribeWith(new NullAbleObserver<CabinetDetailBaseInfoBean>() {
            @Override
            protected void onSuccess(CabinetDetailBaseInfoBean cabinetDetailBaseInfoBean) {
                baseInfoData.setValue(cabinetDetailBaseInfoBean);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                baseInfoData.setValue(null);
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return baseInfoData;
    }
}