package com.okla.ops.views.workbench.devicedetail;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.net.NullAbleObserver;
import com.base.common.net.loading.LoadingTransHelper;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.base.mvvm.State;
import com.base.library.net.exception.ErrorMsgBean;
import com.okla.ops.beans.Cabin;
import com.okla.ops.beans.DeviceFixRecord;
import com.okla.ops.beans.DeviceFixRecordResponse;
import com.okla.ops.beans.DeviceInfo;
import com.okla.ops.beans.DeviceMaintenanceResponse;
import com.okla.ops.beans.MaintenanceRecord;
import com.okla.ops.beans.PolylinePointsBean;
import com.okla.ops.http.HttpMethods;

import java.util.ArrayList;
import java.util.List;

public class DeviceDetailViewModel extends BaseViewModel {

    MutableLiveData<DeviceInfo> mDeviceInfo = new MutableLiveData<>();

    public void setDeviceInfo(DeviceInfo deviceInfo) {
        mDeviceInfo.setValue(deviceInfo);
    }


    MutableLiveData<PolylinePointsBean> mPolyLineData = new MutableLiveData<>();

    //获取路线规划
    public LiveData<PolylinePointsBean> getPolyLine(String origin, String destination, String avoid, String mode, String key) {
        addDisposable(HttpMethods.INSTANCE
                .getPolyLine(origin, destination, avoid, mode, key)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<PolylinePointsBean>() {
                    @Override
                    protected void onSuccess(PolylinePointsBean data) {
                        if (data != null) {
                            mPolyLineData.setValue(data);
                        } else {
                            mPolyLineData.setValue(new PolylinePointsBean());
                        }
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        mPolyLineData.setValue(new PolylinePointsBean());
                        loadState.setValue(
                                State.getInstance(State.ERROR));
                    }
                }));
        return mPolyLineData;
    }


   public MutableLiveData<List<DeviceFixRecord>> mDeviceFixRecordList = new MutableLiveData<>();


    public void getBatteryFixRecordList(int pageNum, int pageSize, String sn) {
        addDisposable(HttpMethods.INSTANCE.getBatteryFixRecordList(pageNum, pageSize, sn).subscribeWith(new NullAbleObserver<DeviceFixRecordResponse>() {
            @Override
            protected void onSuccess(DeviceFixRecordResponse deviceFixRecordResponse) {
                if (deviceFixRecordResponse != null) {
                    mDeviceFixRecordList.setValue(deviceFixRecordResponse.getList());
                } else {
                    mDeviceFixRecordList.setValue(new ArrayList<>());
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
                mDeviceFixRecordList.setValue(new ArrayList<>());
                loadState.postValue(State.getInstance(State.ERROR)
                        .setErrorMsgBean(e)
                        .setShowStatusView(true));
            }
        }));
    }

    public void getCarFixRecordList(int pageNum, int pageSize, String sn) {
        addDisposable(HttpMethods.INSTANCE.getCarFixRecordList(pageNum, pageSize, sn).subscribeWith(new NullAbleObserver<DeviceFixRecordResponse>() {
            @Override
            protected void onSuccess(DeviceFixRecordResponse deviceFixRecordResponse) {
                if (deviceFixRecordResponse != null) {
                    mDeviceFixRecordList.setValue(deviceFixRecordResponse.getList());
                } else {
                    mDeviceFixRecordList.setValue(new ArrayList<>());
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
    }

    public void getCabinFixRecordList(int pageNum, int pageSize, String sn) {
        addDisposable(HttpMethods.INSTANCE.getCabinFixRecordList(pageNum, pageSize, sn)
                .subscribeWith(new NullAbleObserver<DeviceFixRecordResponse>() {
                    @Override
                    protected void onSuccess(DeviceFixRecordResponse deviceFixRecordResponse) {
                        if (deviceFixRecordResponse != null) {
                            mDeviceFixRecordList.setValue(deviceFixRecordResponse.getList());
                        } else {
                            mDeviceFixRecordList.setValue(new ArrayList<>());
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
    }



    public MutableLiveData<List<MaintenanceRecord>> maintenanceRecordList = new MutableLiveData<>();
    public void getCarMaintenanceRecordList(int pageNum, int pageSize, String sn) {
        addDisposable(HttpMethods.INSTANCE.getCarMaintenanceRecordList(pageNum, pageSize, sn).subscribeWith(new NullAbleObserver<DeviceMaintenanceResponse>() {
            @Override
            protected void onSuccess(DeviceMaintenanceResponse maintenanceResponse) {
                if (maintenanceResponse != null) {
                    maintenanceRecordList.setValue(maintenanceResponse.getList());
                } else {
                    maintenanceRecordList.setValue(new ArrayList<>());
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
                maintenanceRecordList.setValue(new ArrayList<>());
                loadState.postValue(State.getInstance(State.ERROR)
                        .setErrorMsgBean(e)
                        .setShowStatusView(true));
            }
        }));
    }
    MutableLiveData<Object> mSetCabinPorts = new MutableLiveData<>();


    /**
     * @param portNum
     * @param stationPid
     * @param type       1 开仓 2 禁仓 3启动
     * @return
     */
    public LiveData<Object> openCabinDoor(int portNum, String stationPid, int type) {
        addDisposable(HttpMethods.INSTANCE.openCabinDoorNew(portNum, stationPid, type).subscribeWith(new NullAbleObserver<Object>() {
            @Override
            protected void onSuccess(Object obj) {
                mSetCabinPorts.setValue(new Object());
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mSetCabinPorts;
    }

    MutableLiveData<Object> mOpenCabinBackDoor = new MutableLiveData<>();

    /**
     * @param stationSn
     * @return
     */
    public LiveData<Object> openCabinBackDoor(String stationSn) {
        addDisposable(HttpMethods.INSTANCE.openCabinBackDoor(stationSn).subscribeWith(new NullAbleObserver<Object>() {
            @Override
            protected void onSuccess(Object obj) {
                mOpenCabinBackDoor.setValue(new Object());
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mOpenCabinBackDoor;
    }
    MutableLiveData<List<Cabin>> mCabinDataList = new MutableLiveData<>();

    public LiveData<List<Cabin>> getCabinList(String sn) {
        addDisposable(HttpMethods.INSTANCE.getCabinList(sn).subscribeWith(new NullAbleObserver<List<Cabin>>() {
            @Override
            protected void onSuccess(List<Cabin> cabinList) {
                if (cabinList != null) {
                    mCabinDataList.setValue(cabinList);
                } else {
                    mCabinDataList.setValue(new ArrayList<>());
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
        return mCabinDataList;
    }


}
