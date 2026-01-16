package com.okla.ops.beans;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;


public class ServiceNetworkBean extends BaseObservable implements Parcelable {

    private String networkNo;//记录ID
    private String networkName;//网点名称
    private String networkAddress;//地址
    private String networkPhone;//联系方式
    private Double longitude;//经度
    private Double latitude;//纬度
    private String serviceType;//1 用户注册 2 购买套餐 3 检测维修 4 资产领用/退还

    protected ServiceNetworkBean(Parcel in) {
        networkNo = in.readString();
        networkName = in.readString();
        networkAddress = in.readString();
        networkPhone = in.readString();
        longitude = in.readDouble();
        latitude = in.readDouble();
        serviceType = in.readString();
    }

    public static final Creator<ServiceNetworkBean> CREATOR = new Creator<ServiceNetworkBean>() {
        @Override
        public ServiceNetworkBean createFromParcel(Parcel in) {
            return new ServiceNetworkBean(in);
        }

        @Override
        public ServiceNetworkBean[] newArray(int size) {
            return new ServiceNetworkBean[size];
        }
    };

    @Bindable
    public String getNetworkNo() {
        return networkNo;
    }

    public void setNetworkNo(String networkNo) {
        this.networkNo = networkNo;
        notifyPropertyChanged(BR.networkNo);
    }

    @Bindable
    public String getNetworkName() {
        return networkName;
    }

    public void setNetworkName(String networkName) {
        this.networkName = networkName;
        notifyPropertyChanged(BR.networkName);
    }

    @Bindable
    public String getNetworkAddress() {
        return networkAddress;
    }

    public void setNetworkAddress(String networkAddress) {
        this.networkAddress = networkAddress;
        notifyPropertyChanged(BR.networkAddress);
    }

    @Bindable
    public String getNetworkPhone() {
        return networkPhone;
    }

    public void setNetworkPhone(String networkPhone) {
        this.networkPhone = networkPhone;
        notifyPropertyChanged(BR.networkPhone);
    }

    @Bindable
    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
        notifyPropertyChanged(BR.longitude);
    }

    @Bindable
    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
        notifyPropertyChanged(BR.latitude);
    }

    @Bindable
    public String getServiceType() {
        return serviceType;
    }

    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
        notifyPropertyChanged(BR.serviceType);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(networkNo);
        dest.writeString(networkName);
        dest.writeString(networkAddress);
        dest.writeString(networkPhone);
        dest.writeDouble(longitude);
        dest.writeDouble(latitude);
        dest.writeString(serviceType);
    }

}
