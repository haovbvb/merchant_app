package com.okla.ops.views.mine;

import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.http.HttpMethods;

import java.util.HashMap;
import java.util.Map;

public class ChangePSWViewModel extends BaseViewModel {

    MutableLiveData<Object> changePwdData = new MutableLiveData<>();

    public MutableLiveData<Object> changePwd(String oldPwd, String newPwd, String confirmPwd) {
        HashMap<String, String> map = new HashMap<>();
        map.put("existingPassword", oldPwd);
        map.put("newPassword", newPwd);
        map.put("confirmPassword", confirmPwd);
        addDisposable(HttpMethods.INSTANCE.changePSWNew(map)
                .subscribeWith(new NullAbleObserver<Object>() {
                    @Override
                    protected void onSuccess(Object obj) {
                        changePwdData.setValue("");
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        ToastUtils.showShort(e.getMsg());
                    }
                }));
        return changePwdData;
    }

}