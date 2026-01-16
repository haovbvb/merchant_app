package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

/**
 * @Date: 2021/2/18 13:38
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class CabinetAndCameraBoundBean extends BaseObservable {

    /**
     * sn :
     * cameraSn :
     */

    private String sn;
    private int status;

    @Bindable
    public String getSn() {
        return sn;
    }

    public void setSn(String sn) {
        this.sn = sn;
        notifyPropertyChanged(BR.sn);
    }

    @Bindable
    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
        notifyPropertyChanged(BR.status);
    }
}
