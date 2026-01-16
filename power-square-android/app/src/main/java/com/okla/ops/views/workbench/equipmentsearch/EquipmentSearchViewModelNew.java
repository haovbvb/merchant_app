package com.okla.ops.views.workbench.equipmentsearch;

import android.text.TextUtils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.Preferences;
import com.base.common.net.NullAbleObserver;
import com.base.common.net.loading.LoadingTransHelper;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.base.mvvm.State;
import com.base.library.net.exception.ErrorMsgBean;
import com.base.library.utils.GsonUtils;
import com.google.gson.reflect.TypeToken;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.beans.DeviceInfo;
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew;
import com.okla.ops.beans.ManagerInfo;
import com.okla.ops.beans.SearchHistory;
import com.okla.ops.http.HttpMethods;
import com.okla.ops.views.workbench.equipmentsearch.net.DeviceSearchHttpMethods;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * @Date: 2021/1/21 16:41
 * @Author: craz
 * @Description:
 * @Version:
 */

public class EquipmentSearchViewModelNew extends BaseViewModel {
    MutableLiveData<EquipmentDeviceSearchBeanNew> mEquipmentDeviceSearchBeanData = new MutableLiveData<>();

    public LiveData<EquipmentDeviceSearchBeanNew> getDeviceListSearchData(String inputData) {
        addDisposable(DeviceSearchHttpMethods.INSTANCE.getDeviceListSearchDataNew(inputData)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<EquipmentDeviceSearchBeanNew>() {
                    @Override
                    protected void onSuccess(EquipmentDeviceSearchBeanNew list) {
                        if (list != null) {
                            mEquipmentDeviceSearchBeanData.setValue(list);
                        } else {
                            mEquipmentDeviceSearchBeanData.setValue(null);
                        }
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        mEquipmentDeviceSearchBeanData.setValue(null);
                        ToastUtils.showShort(e.getMsg());
                        loadState.setValue(State.getInstance(State.ERROR));
                    }
                }));
        return mEquipmentDeviceSearchBeanData;
    }

//    MutableLiveData<String> mGetDeviceSn = new MutableLiveData<>();
//
//    public LiveData<String> getDeviceSn(String content) {
//        addDisposable(HttpMethods.INSTANCE.getDeviceSn(1, content).subscribeWith(new NullAbleObserver<String>() {
//            @Override
//            protected void onSuccess(String str) {
//                if (TextUtils.isEmpty(str)) {
//                    mGetDeviceSn.setValue(content);
//                } else {
//                    mGetDeviceSn.setValue(str);
//                }
//            }
//
//            @Override
//            protected void onFail(ErrorMsgBean e) {
//                ToastUtils.showShort(e.getMsg());
//            }
//        }));
//        return mGetDeviceSn;
//    }

    public LiveData<EquipmentDeviceSearchBeanNew> getStationDetail(String sn) {
        addDisposable(HttpMethods.INSTANCE.getCabinetBaseInfo(sn).subscribeWith(new NullAbleObserver<CabinetDetailBaseInfoBean>() {
            @Override
            protected void onSuccess(CabinetDetailBaseInfoBean cabinetDetailBaseInfoBean) {
                if (cabinetDetailBaseInfoBean != null) {
                    DeviceInfo deviceInfo = new DeviceInfo();
                    deviceInfo.setAddress(cabinetDetailBaseInfoBean.getName());
//                    deviceInfo.setBindUserId("");
//                    deviceInfo.setBindUserName("");
//                    deviceInfo.setBindUserPhone("");
//                    deviceInfo.setCarNumber("");
                    deviceInfo.setCreateTime(cabinetDetailBaseInfoBean.getCreateTime());
//                    deviceInfo.setDeviceBindStatus(1);
//                    deviceInfo.setDeviceId("");
                    deviceInfo.setInstallTime(cabinetDetailBaseInfoBean.getInstallTime());
                    deviceInfo.setDeviceModel(cabinetDetailBaseInfoBean.getStationModel());
                    deviceInfo.setHasPermission(cabinetDetailBaseInfoBean.getHasPermission());
                    deviceInfo.setImg(cabinetDetailBaseInfoBean.getImg());
                    List<String> imgs = cabinetDetailBaseInfoBean.getImgs();
                    if (imgs != null && imgs.size() > 0) {
                        StringBuilder stringBuffer = new StringBuilder();
                        for (String path : imgs) {
                            stringBuffer.append(path);
                            stringBuffer.append(",");
                        }
                        deviceInfo.setImgList(stringBuffer.toString());
                    }
                    deviceInfo.setInstallTime(cabinetDetailBaseInfoBean.getInstallTime());
//                    deviceInfo.setInsuranceNumber("");
                    deviceInfo.setLatitude(cabinetDetailBaseInfoBean.getLatitude());
                    deviceInfo.setLongitude(cabinetDetailBaseInfoBean.getLongitude());
                    List<CabinetDetailBaseInfoBean.ManagerBean> manager = cabinetDetailBaseInfoBean.getManager();
                    if (manager != null && manager.size() > 0) {
                        List<ManagerInfo> managerInfoList = new ArrayList<>();
                        for (CabinetDetailBaseInfoBean.ManagerBean managerBean : manager) {
                            ManagerInfo managerInfo = new ManagerInfo();
                            managerInfo.setAccountNo(managerBean.getId());
                            managerInfo.setShowName(managerBean.getName());
                            managerInfoList.add(managerInfo);
                        }
                        deviceInfo.setManagerList(managerInfoList);
                    }
                    deviceInfo.setOnlineStatus(cabinetDetailBaseInfoBean.getOnlineStatus());
//                    deviceInfo.setShowDeviceBindStatus("");
                    deviceInfo.setShowDeviceModel(cabinetDetailBaseInfoBean.getStationModelName());
//                    deviceInfo.setShowDeviceType("");
                    deviceInfo.setInstallStatus(cabinetDetailBaseInfoBean.getInstallStatus());
                    deviceInfo.setShowOnlineStatus(cabinetDetailBaseInfoBean.getShowOnlineStatus());
                    deviceInfo.setSimNo(cabinetDetailBaseInfoBean.getSimNo());
                    deviceInfo.setSn(cabinetDetailBaseInfoBean.getSn());
                    deviceInfo.setStationName(cabinetDetailBaseInfoBean.getStandardName());
//                    deviceInfo.setVin("");
                    EquipmentDeviceSearchBeanNew equipmentDeviceSearchBeanNew = new EquipmentDeviceSearchBeanNew(deviceInfo, 1);
                    mEquipmentDeviceSearchBeanData.setValue(equipmentDeviceSearchBeanNew);
                } else {
                    mEquipmentDeviceSearchBeanData.setValue(null);
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                mEquipmentDeviceSearchBeanData.setValue(null);
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mEquipmentDeviceSearchBeanData;
    }

    MutableLiveData<List<SearchHistory>> searchHistoryListMutableLiveData = new MutableLiveData<>();

    public void readSearchHistory() {
        String searchDevice = Preferences.getInstance().getSearchDevice();
        if (!TextUtils.isEmpty(searchDevice)) {
            try {
                Type type = new TypeToken<List<SearchHistory>>() {
                }.getType();
                List<SearchHistory> list = GsonUtils.fromGson(searchDevice, type);
                searchHistoryListMutableLiveData.setValue(list);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public void saveSearchHistory(String searchData) {
        String searchDevice = Preferences.getInstance().getSearchDevice();
        try {
            List<SearchHistory> list;
            if (!TextUtils.isEmpty(searchDevice)) {
                Type type = new TypeToken<List<SearchHistory>>() {
                }.getType();
                list = GsonUtils.fromGson(searchDevice, type);
                if (list != null && list.size() > 0) {
                    boolean isExist = false;
                    for (SearchHistory searchHistory : list) {
                        if (searchHistory.getId().equals(searchData)) {
                            isExist = true;
                            break;
                        }
                    }
                    if (list.size() > 4) {
                        list.remove(0);
                    }
                    if (!isExist) {
                        list.add(0, new SearchHistory(searchData, searchData));
                    }
                } else {
                    list = new ArrayList<>();
                    list.add(new SearchHistory(searchData, searchData));
                }
            } else {
                list = new ArrayList<>();
                list.add(new SearchHistory(searchData, searchData));
            }
            String s = GsonUtils.toGson(list);
            Preferences.getInstance().setSearchDevice(s);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    MutableLiveData<Object> mOpenCabinBackDoor = new MutableLiveData<>();

    /**
     * 打开柜门
     *
     * @param stationSn 柜子SN
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

}