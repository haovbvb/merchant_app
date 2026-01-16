package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;


import com.okla.ops.BR;

import java.io.Serializable;

/**
 * @Date: 2021/1/20 10:28
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class AddressBean extends BaseObservable implements Serializable{

    public AddressBean() {
    }

    /**
     * address :
     * latitude : 0.0
     * lontitude : 0.0
     */

    private String address;
    private String distance;
    private String name;
    private double latitude;
    private double lontitude;
    private String latitudeStr;
    private String lontitudeStr;
    private String placeId;

    @Bindable
    public String getPlaceId() {
        return placeId;
    }

    public void setPlaceId(String placeId) {
        this.placeId = placeId;
        notifyPropertyChanged(BR.placeId);
    }
    @Bindable
    public String getDistance() {
        return distance;
    }

    public void setDistance(String distance) {
        this.distance = distance;
        notifyPropertyChanged(BR.distance);
    }
    @Bindable
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
        notifyPropertyChanged(BR.name);
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
    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
        notifyPropertyChanged(BR.latitude);
    }

    @Bindable
    public double getLontitude() {
        return lontitude;
    }

    public void setLontitude(double lontitude) {
        this.lontitude = lontitude;
        notifyPropertyChanged(BR.lontitude);
    }
    @Bindable
    public String getLatitudeStr() {
        return latitudeStr;
    }

    public void setLatitudeStr(String latitudeStr) {
        this.latitudeStr = latitudeStr;
        notifyPropertyChanged(BR.latitudeStr);
    }

    @Bindable
    public String getLontitudeStr() {
        return lontitudeStr;
    }

    public void setLontitudeStr(String lontitudeStr) {
        this.lontitudeStr = lontitudeStr;
        notifyPropertyChanged(BR.lontitudeStr);
    }
}
