package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

/**
 * @Date: 2021/1/18 9:32
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class CityCode extends BaseObservable {

    /**
     * code : 110000
     * name : 北京市
     */

    private String code;
    private String name;
    private boolean select;

    @Bindable
    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
        notifyPropertyChanged(BR.code);
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
    public boolean isSelect() {
        return select;
    }

    public void setSelect(boolean select) {
        this.select = select;
        notifyPropertyChanged(BR.select);
    }
}
