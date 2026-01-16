package com.okla.ops.views.monitor.cabinetdetail.cabin.faultlist;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.CabinFaultBean;
import com.okla.ops.beans.DeputyCabinetBean;
import com.okla.ops.http.HttpMethods;

import java.util.List;

/**
 * @Date: 2021/2/13 11:14
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinFaultListViewModel extends BaseViewModel {
    MutableLiveData<CabinFaultBean> mFaultData = new MutableLiveData<>();
    MutableLiveData<List<DeputyCabinetBean>> deputyCabinetData = new MutableLiveData<>();

    public LiveData<List<DeputyCabinetBean>> getDeputyCabinetData(String pid) {
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

    public LiveData<CabinFaultBean> getFaultList(int pageNum, int pageSize, String sn, int port,int nID) {
        addDisposable(HttpMethods.INSTANCE.getFaultList(pageNum, pageSize, sn, port,nID + "").subscribeWith(new NullAbleObserver<CabinFaultBean>() {
            @Override
            protected void onSuccess(CabinFaultBean cabinFaultBean) {
                if (cabinFaultBean != null) {
                    mFaultData.setValue(cabinFaultBean);
                } else {
                    mFaultData.setValue(new CabinFaultBean());
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mFaultData;
    }
}