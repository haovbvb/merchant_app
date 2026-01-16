package com.okla.ops.beans;

import android.text.TextUtils;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

/**
 * @Date: 2021/1/21 15:21
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class WorkbenchStatisticsBean extends BaseObservable {

    /**
     * lostContact :
     * noShortPosition :
     * newToday :
     * myPowerStation :
     */

    private String lostContact;
    private String lostContactPercent;
    private String noShortPosition;
    private String newToday;
    private String myPowerStation;
    private String statsionModel;
    private String fullStation;
    private String fullStationPercent;
    private String damageDoor;
    private String damageDoorPercent;

    @Bindable
    public String getStatsionModel() {
        return statsionModel;
    }

    public void setStatsionModel(String statsionModel) {
        this.statsionModel = statsionModel;
        notifyPropertyChanged(BR.statsionModel);
    }

    @Bindable
    public String getLostContact() {
        if(TextUtils.isEmpty(lostContact)){
            lostContact = "0";
        }
        return lostContact;
    }

    public void setLostContact(String lostContact) {
        this.lostContact = lostContact;
        notifyPropertyChanged(BR.lostContact);
    }

    @Bindable
    public String getNoShortPosition() {
        if(TextUtils.isEmpty(noShortPosition)){
            noShortPosition = "0";
        }
        return noShortPosition;
    }

    public void setNoShortPosition(String noShortPosition) {
        this.noShortPosition = noShortPosition;
        notifyPropertyChanged(BR.noShortPosition);
    }

    @Bindable
    public String getNewToday() {
        if(TextUtils.isEmpty(newToday)){
            newToday = "0";
        }
        return newToday;
    }

    public void setNewToday(String newToday) {
        this.newToday = newToday;
        notifyPropertyChanged(BR.newToday);
    }

    @Bindable
    public String getMyPowerStation() {
        if(TextUtils.isEmpty(myPowerStation)){
            myPowerStation = "0";
        }
        return myPowerStation;
    }

    public void setMyPowerStation(String myPowerStation) {
        this.myPowerStation = myPowerStation;
        notifyPropertyChanged(BR.myPowerStation);
    }

    public String getLostContactPercent() {
        return lostContactPercent;
    }

    public void setLostContactPercent(String lostContactPercent) {
        this.lostContactPercent = lostContactPercent;
    }

    public String getFullStation() {
        return fullStation;
    }

    public void setFullStation(String fullStation) {
        this.fullStation = fullStation;
    }

    public String getFullStationPercent() {
        return fullStationPercent;
    }

    public void setFullStationPercent(String fullStationPercent) {
        this.fullStationPercent = fullStationPercent;
    }

    public String getDamageDoor() {
        return damageDoor;
    }

    public void setDamageDoor(String damageDoor) {
        this.damageDoor = damageDoor;
    }

    public String getDamageDoorPercent() {
        return damageDoorPercent;
    }

    public void setDamageDoorPercent(String damageDoorPercent) {
        this.damageDoorPercent = damageDoorPercent;
    }
}
