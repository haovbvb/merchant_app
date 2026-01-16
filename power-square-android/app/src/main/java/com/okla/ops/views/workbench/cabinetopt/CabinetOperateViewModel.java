package com.okla.ops.views.workbench.cabinetopt;

import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.http.HttpMethods;

public class CabinetOperateViewModel extends BaseViewModel {

    MutableLiveData<CabinetDetailBaseInfoBean> baseInfoData = new MutableLiveData<>();

    public void getStationType(String sn) {
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
    }
}
