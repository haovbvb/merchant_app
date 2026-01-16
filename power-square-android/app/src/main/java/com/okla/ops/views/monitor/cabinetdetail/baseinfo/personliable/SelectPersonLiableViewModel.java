package com.okla.ops.views.monitor.cabinetdetail.baseinfo.personliable;

import android.text.TextUtils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.OpsAndMaintenaceBean;
import com.okla.ops.beans.SelectedPersonLiableBean;
import com.okla.ops.http.HttpMethods;
import com.okla.ops.utils.EventUtils;

/**
 * @Date: 2021/2/1 14:23
 * @Author: craz
 * @Description:
 * @Version:
 */

public class SelectPersonLiableViewModel extends BaseViewModel {
    MutableLiveData<OpsAndMaintenaceBean> mOpsAndMaintenaceBean = new MutableLiveData<>();
    MutableLiveData<String> maddPersonLiableBean = new MutableLiveData<>();

    public LiveData<OpsAndMaintenaceBean> getOpsAndMaintenaceList(int pageNum, int pageSize, String phone, String userName,int platform,int enabled){
        addDisposable(HttpMethods.INSTANCE.getOpsAndMaintenaceList(pageNum,pageSize, phone,userName,platform,enabled).subscribeWith(new NullAbleObserver<OpsAndMaintenaceBean>() {
            @Override
            protected void onSuccess(OpsAndMaintenaceBean opsAndMaintenaceBean) {
                if(opsAndMaintenaceBean != null){
                    mOpsAndMaintenaceBean.setValue(opsAndMaintenaceBean);
                }else {
                    mOpsAndMaintenaceBean.setValue(new OpsAndMaintenaceBean());
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                mOpsAndMaintenaceBean.setValue(new OpsAndMaintenaceBean());
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mOpsAndMaintenaceBean;
    }

    public LiveData<String> addPersonLiable(String mCabinetSN,SelectedPersonLiableBean[] details){
        addDisposable(HttpMethods.INSTANCE.addPersonLiable(mCabinetSN,details).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String s) {
                if(TextUtils.isEmpty(s)){
                    maddPersonLiableBean.setValue("");
                }else {
                    maddPersonLiableBean.setValue(s);
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
                if(e.getCode() == EventUtils.INSTANCE.getSuccessResponeCode()){
                    maddPersonLiableBean.setValue("");
                }
            }
        }));
        return maddPersonLiableBean;
    }
}