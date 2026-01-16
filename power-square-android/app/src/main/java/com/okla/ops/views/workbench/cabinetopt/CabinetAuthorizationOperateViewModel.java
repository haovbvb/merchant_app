package com.okla.ops.views.workbench.cabinetopt;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.net.loading.LoadingTransHelper;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.base.mvvm.State;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.AuthorizationRecordList;
import com.okla.ops.beans.CabinetAuthorizationList;
import com.okla.ops.beans.UserAuthorizationList;
import com.okla.ops.http.HttpMethods;

public class CabinetAuthorizationOperateViewModel extends BaseViewModel {

    MutableLiveData<CabinetAuthorizationList> mCabinetAuthorizationListSearchBeanData = new MutableLiveData<>();

    public LiveData<CabinetAuthorizationList> getCabinetAuthorizationListSearchData(String inputString, int page, int pageSize) {
        addDisposable(HttpMethods.INSTANCE.getCabinetAuthorizationListSearchData(inputString, page, pageSize)
                .subscribeWith(new NullAbleObserver<CabinetAuthorizationList>() {
                    @Override
                    protected void onSuccess(CabinetAuthorizationList list) {
                        mCabinetAuthorizationListSearchBeanData.setValue(list);
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        mCabinetAuthorizationListSearchBeanData.setValue(null);
                        ToastUtils.showShort(e.getMsg());
                    }
                }));
        return mCabinetAuthorizationListSearchBeanData;
    }

    MutableLiveData<UserAuthorizationList> mUserAuthorizationListSearchBeanData = new MutableLiveData<>();

    public LiveData<UserAuthorizationList> getUserAuthorizationListSearchData(String sn, String keyword, int page, int pageSize) {
        addDisposable(HttpMethods.INSTANCE.getUserAuthorizationListSearchData(sn, keyword, page, pageSize)
                .subscribeWith(new NullAbleObserver<UserAuthorizationList>() {
                    @Override
                    protected void onSuccess(UserAuthorizationList list) {
                        mUserAuthorizationListSearchBeanData.setValue(list);
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        mUserAuthorizationListSearchBeanData.setValue(null);
                        ToastUtils.showShort(e.getMsg());
                    }
                }));
        return mUserAuthorizationListSearchBeanData;
    }

    MutableLiveData<Integer> mPermissionData = new MutableLiveData<>();

    public void stationPermission(String sn, String accountNo, String beginTime, String endTime) {
        addDisposable(HttpMethods.INSTANCE.stationPermission(sn, accountNo, beginTime, endTime)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<Object>() {
                    @Override
                    protected void onSuccess(Object obj) {
                        mPermissionData.setValue(1);
                        loadState.postValue(State.getInstance(State.SUCCESS));

                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        mPermissionData.setValue(null);
                        ToastUtils.showShort(e.getMsg());
                        loadState.postValue(State.getInstance(State.ERROR));

                    }
                }));
    }

    MutableLiveData<AuthorizationRecordList> mAuthorizationRecordListData = new MutableLiveData<>();

    public LiveData<AuthorizationRecordList> getAuthorizationRecordListData(String sn, String bePermission, int page, int size) {
        addDisposable(HttpMethods.INSTANCE.getUserAuthorizationListData(sn, bePermission, page, size)
                .subscribeWith(new NullAbleObserver<AuthorizationRecordList>() {
                    @Override
                    protected void onSuccess(AuthorizationRecordList list) {
                        mAuthorizationRecordListData.setValue(list);
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        mAuthorizationRecordListData.setValue(null);
                        ToastUtils.showShort(e.getMsg());
                    }
                }));
        return mAuthorizationRecordListData;
    }

    MutableLiveData<Object> mCancelPermission = new MutableLiveData<>();

    public LiveData<Object> cancelPermission(String sn, Integer permissionId) {
        addDisposable(HttpMethods.INSTANCE.cancelPermission(sn, permissionId)
                .subscribeWith(new NullAbleObserver<Object>() {
                    @Override
                    protected void onSuccess(Object obj) {
                        mCancelPermission.setValue(obj);
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        mCancelPermission.setValue(null);
                        ToastUtils.showShort(e.getMsg());
                    }
                }));
        return mCancelPermission;
    }

}
