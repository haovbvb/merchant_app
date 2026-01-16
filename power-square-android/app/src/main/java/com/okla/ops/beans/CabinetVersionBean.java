package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

/**
 * @Date: 2021/2/23 11:31
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class CabinetVersionBean extends BaseObservable {

    /**
     * apkCode : 126
     * apkCodeF : -1
     * apkVer : 1.2.5.5
     * charge : 2.1_2.1.4.20191018,0.0_0.0.0.0,2.1_2.1.5.20200927,2.1_2.1.5.20200927,2.1_2.1.5.20200927,2.1_2.1.5.20200927,2.1_2.1.5.20200927,2.1_2.1.5.20200927,2.1_2.1.5.20200927,2.1_2.1.5.20200927,2.1_2.1.5.20200927,2.1_2.1.5.20200927,0.0_0.0.0.0,
     * chargeF : 2.1_2.1.4.20191018
     * ctrl : 2.0_2.0.39.41
     * ctrlF : 2.0_2.0.39.41
     * pms : 1.0_1.0.0.75,1.0_1.0.0.75,1.0_1.0.0.78,1.0_1.0.0.77,1.0_1.0.0.78,1.1_1.0.0.1040,1.0_1.0.0.75,1.0_1.0.0.78,1.0_1.0.0.78,1.0_1.0.0.75,1.0_1.0.0.77,1.0_1.0.0.75,0.0_0.0.0.0,
     * pmsF : 0.0_0.0.0.0
     */

    private int apkCode;
    private int apkCodeF;
    private String apkVer;
    private String charge;
    private String chargeF;
    private String ctrl;
    private String ctrlF;
    private String pms;
    private String pmsF;

    @Bindable
    public int getApkCode() {
        return apkCode;
    }

    public void setApkCode(int apkCode) {
        this.apkCode = apkCode;
        notifyPropertyChanged(BR.apkCode);
    }

    @Bindable
    public int getApkCodeF() {
        return apkCodeF;
    }

    public void setApkCodeF(int apkCodeF) {
        this.apkCodeF = apkCodeF;
        notifyPropertyChanged(BR.apkCodeF);
    }

    @Bindable
    public String getApkVer() {
        return apkVer;
    }

    public void setApkVer(String apkVer) {
        this.apkVer = apkVer;
        notifyPropertyChanged(BR.apkVer);
    }

    @Bindable
    public String getCharge() {
        return charge;
    }

    public void setCharge(String charge) {
        this.charge = charge;
        notifyPropertyChanged(BR.charge);
    }

    @Bindable
    public String getChargeF() {
        return chargeF;
    }

    public void setChargeF(String chargeF) {
        this.chargeF = chargeF;
        notifyPropertyChanged(BR.chargeF);
    }

    @Bindable
    public String getCtrl() {
        return ctrl;
    }

    public void setCtrl(String ctrl) {
        this.ctrl = ctrl;
        notifyPropertyChanged(BR.ctrl);
    }

    @Bindable
    public String getCtrlF() {
        return ctrlF;
    }

    public void setCtrlF(String ctrlF) {
        this.ctrlF = ctrlF;
        notifyPropertyChanged(BR.ctrlF);
    }

    @Bindable
    public String getPms() {
        return pms;
    }

    public void setPms(String pms) {
        this.pms = pms;
        notifyPropertyChanged(BR.pms);
    }

    @Bindable
    public String getPmsF() {
        return pmsF;
    }

    public void setPmsF(String pmsF) {
        this.pmsF = pmsF;
        notifyPropertyChanged(BR.pmsF);
    }
}
