package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;
import androidx.databinding.library.baseAdapters.BR;

import java.io.Serializable;
import java.util.List;

public class DeviceInfo extends BaseObservable implements Serializable {
    private String address;
    private String bindUserId;
    private String bindUserName;
    private String bindUserPhone;
    private String carNumber;
    private String createTime;
    private Integer deviceBindStatus;
    private String deviceId;
    private String deviceModel;
    private Integer hasPermission;
    private String img;
    private String imgList;
    private Integer installStatus=0;
    private String installTime;
    private String insuranceNumber;
    private Double latitude;
    private Double longitude;
    private List<ManagerInfo> managerList;
    private Integer onlineStatus;
    private String showDeviceBindStatus;
    private String showDeviceModel;
    private String showDeviceType;
    private String showInstallStatus;
    private String showOnlineStatus;
    private String simNo;
    private String sn;
    private String stationName;
    private String vin;
    private String ctrlId;
    private Integer bindSource = 0; //1 sale 2 lease

    public boolean isNeedMaintenance() {
        return needMaintenance;
    }

    public void setNeedMaintenance(boolean needMaintenance) {
        this.needMaintenance = needMaintenance;
    }

    private boolean needMaintenance;

    public String getBindTime() {
        return bindTime;
    }

    public void setBindTime(String bindTime) {
        this.bindTime = bindTime;
    }

    private String bindTime;


    public Integer getBindSource() {
        return bindSource;
    }

    public void setBindSource(Integer bindSource) {
        this.bindSource = bindSource;
    }


    @Bindable
    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
        notifyPropertyChanged(BR.address);
    }

    @Bindable
    public String getBindUserId() {
        return bindUserId;
    }

    public void setBindUserId(String bindUserId) {
        this.bindUserId = bindUserId;
        notifyPropertyChanged(BR.bindUserId);
    }

    @Bindable
    public String getBindUserName() {
        return bindUserName;
    }

    public void setBindUserName(String bindUserName) {
        this.bindUserName = bindUserName;
        notifyPropertyChanged(BR.bindUserName);
    }

    @Bindable
    public String getBindUserPhone() {
        return bindUserPhone;
    }

    public void setBindUserPhone(String bindUserPhone) {
        this.bindUserPhone = bindUserPhone;
        notifyPropertyChanged(BR.bindUserPhone);
    }

    @Bindable
    public String getCarNumber() {
        return carNumber;
    }

    public void setCarNumber(String carNumber) {
        this.carNumber = carNumber;
        notifyPropertyChanged(BR.carNumber);
    }

    @Bindable
    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
        notifyPropertyChanged(BR.createTime);
    }

    @Bindable
    public Integer getDeviceBindStatus() {
        return deviceBindStatus;
    }

    public void setDeviceBindStatus(Integer deviceBindStatus) {
        this.deviceBindStatus = deviceBindStatus;
        notifyPropertyChanged(BR.deviceBindStatus);
    }

    @Bindable
    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
        notifyPropertyChanged(BR.deviceId);
    }

    @Bindable
    public String getDeviceModel() {
        return deviceModel;
    }

    public void setDeviceModel(String deviceModel) {
        this.deviceModel = deviceModel;
        notifyPropertyChanged(BR.deviceModel);
    }

    @Bindable
    public Integer getHasPermission() {
        return hasPermission;
    }

    public void setHasPermission(Integer hasPermission) {
        this.hasPermission = hasPermission;
        notifyPropertyChanged(BR.hasPermission);
    }

    public String getImg() {
        return img;
    }

    public void setImg(String img) {
        this.img = img;
    }

    public String getImgList() {
        return imgList;
    }

    public void setImgList(String imgList) {
        this.imgList = imgList;
    }

    @Bindable
    public Integer getInstallStatus() {
        return installStatus;
    }

    public void setInstallStatus(Integer installStatus) {
        this.installStatus = installStatus;
        notifyPropertyChanged(BR.installStatus);
    }

    @Bindable
    public String getInstallTime() {
        return installTime;
    }

    public void setInstallTime(String installTime) {
        this.installTime = installTime;
        notifyPropertyChanged(BR.installTime);
    }

    @Bindable
    public String getInsuranceNumber() {
        return insuranceNumber;
    }

    public void setInsuranceNumber(String insuranceNumber) {
        this.insuranceNumber = insuranceNumber;
        notifyPropertyChanged(BR.insuranceNumber);
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public List<ManagerInfo> getManagerList() {
        return managerList;
    }

    public void setManagerList(List<ManagerInfo> managerList) {
        this.managerList = managerList;
    }

    @Bindable
    public Integer getOnlineStatus() {
        return onlineStatus;
    }

    public void setOnlineStatus(Integer onlineStatus) {
        this.onlineStatus = onlineStatus;
        notifyPropertyChanged(BR.onlineStatus);
    }

    @Bindable
    public String getShowDeviceBindStatus() {
        return showDeviceBindStatus;
    }

    public void setShowDeviceBindStatus(String showDeviceBindStatus) {
        this.showDeviceBindStatus = showDeviceBindStatus;
        notifyPropertyChanged(BR.showDeviceBindStatus);
    }

    @Bindable
    public String getShowDeviceModel() {
        return showDeviceModel;
    }

    public void setShowDeviceModel(String showDeviceModel) {
        this.showDeviceModel = showDeviceModel;
        notifyPropertyChanged(BR.showDeviceModel);
    }

    @Bindable
    public String getShowDeviceType() {
        return showDeviceType;
    }

    public void setShowDeviceType(String showDeviceType) {
        this.showDeviceType = showDeviceType;
        notifyPropertyChanged(BR.showDeviceType);
    }

    @Bindable
    public String getShowInstallStatus() {
        return showInstallStatus;
    }

    public void setShowInstallStatus(String showInstallStatus) {
        this.showInstallStatus = showInstallStatus;
        notifyPropertyChanged(BR.showInstallStatus);
    }

    @Bindable
    public String getShowOnlineStatus() {
        return showOnlineStatus;
    }

    public void setShowOnlineStatus(String showOnlineStatus) {
        this.showOnlineStatus = showOnlineStatus;
        notifyPropertyChanged(BR.showOnlineStatus);
    }

    @Bindable
    public String getSimNo() {
        return simNo;
    }

    public void setSimNo(String simNo) {
        this.simNo = simNo;
        notifyPropertyChanged(BR.simNo);
    }

    @Bindable
    public String getSn() {
        return sn;
    }

    public void setSn(String sn) {
        this.sn = sn;
        notifyPropertyChanged(BR.sn);
    }

    @Bindable
    public String getStationName() {
        return stationName;
    }

    public void setStationName(String stationName) {
        this.stationName = stationName;
        notifyPropertyChanged(BR.stationName);
    }

    @Bindable
    public String getVin() {
        return vin;
    }

    public void setVin(String vin) {
        this.vin = vin;
        notifyPropertyChanged(BR.vin);
    }

    @Bindable
    public String getCtrlId() {
        return ctrlId;
    }

    public void setCtrlId(String ctrlId) {
        this.ctrlId = ctrlId;
        notifyPropertyChanged(BR.ctrlId);
    }
}
