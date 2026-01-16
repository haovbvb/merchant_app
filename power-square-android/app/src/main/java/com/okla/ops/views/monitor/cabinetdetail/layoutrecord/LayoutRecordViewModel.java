package com.okla.ops.views.monitor.cabinetdetail.layoutrecord;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.base.mvvm.State;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.LayoutCabinetInfoBean;
import com.okla.ops.http.HttpMethods;

/**
 * @Date: 2021/1/28 10:40
 * @Author: craz
 * @Description:
 * @Version:
 */

public class LayoutRecordViewModel extends BaseViewModel {
    MutableLiveData<LayoutCabinetInfoBean> layoutInfoData = new MutableLiveData<>();

    public LiveData<LayoutCabinetInfoBean> getLayouCabinetInfo(String sn,int pageNum,int pageSize){
        addDisposable(HttpMethods.INSTANCE.getLayouCabinetInfo(sn,pageNum,pageSize).subscribeWith(new NullAbleObserver<LayoutCabinetInfoBean>() {
            @Override
            protected void onSuccess(LayoutCabinetInfoBean layoutCabinetInfoBean) {
                if(layoutCabinetInfoBean != null){
                    layoutInfoData.setValue(layoutCabinetInfoBean);
                }else {
                    layoutInfoData.setValue(new LayoutCabinetInfoBean());
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
        return layoutInfoData;
    }
}