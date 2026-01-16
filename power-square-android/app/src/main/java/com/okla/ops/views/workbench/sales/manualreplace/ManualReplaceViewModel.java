package com.okla.ops.views.workbench.sales.manualreplace;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.net.loading.LoadingTransHelper;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.base.mvvm.State;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.views.workbench.sales.manualreplace.net.ManualreplaceHttpMethods;


/**
 * @Date: 2021/3/4 16:10
 * @Author: craz
 * @Description:
 * @Version:
 */

public class ManualReplaceViewModel extends BaseViewModel {
    MutableLiveData<String> manualReplaceData = new MutableLiveData<>();
//    MutableLiveData<String> mGetDeviceSn = new MutableLiveData<>();

    public LiveData<String> manualReplace(String ins, String outs, String cardNum, String reason) {
        addDisposable(ManualreplaceHttpMethods.INSTANCE.manualReplace(ins, outs, cardNum, reason)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<String>() {
                    @Override
                    protected void onSuccess(String s) {
                        manualReplaceData.setValue("success");
                        loadState.postValue(State.getInstance(State.SUCCESS));

                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        manualReplaceData.setValue(" ");
                        ToastUtils.showLong(e.getMsg());
                        loadState.postValue(State.getInstance(State.ERROR));

                    }
                }));
        return manualReplaceData;
    }

//    public LiveData<String> getDeviceSn(int type, String content) {
//        addDisposable(HttpMethods.INSTANCE.getDeviceSn(type, content).subscribeWith(new NullAbleObserver<String>() {
//            @Override
//            protected void onSuccess(String s) {
//                if (TextUtils.isEmpty(s)) {
//                    mGetDeviceSn.setValue("");
////                    ToastUtils.showShort(R.string.qr_code_error);
//                } else {
//                    mGetDeviceSn.setValue(s);
//                }
//
//            }
//
//            @Override
//            protected void onFail(ErrorMsgBean e) {
//                mGetDeviceSn.setValue("");
//                ToastUtils.showShort(e.getMsg());
//            }
//        }));
//        return mGetDeviceSn;
//    }
}