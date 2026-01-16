package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

/**
 * @Date: 2021/2/17 16:19
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class ForbiddenReasonBean extends BaseObservable {
    public ForbiddenReasonBean(String code, String value) {
        this.code = code;
        this.value = value;
    }

    /**
     * code : 1
     * value : 仓门故障
     * select : false
     */

    private String code;
    private String value;
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
    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
        notifyPropertyChanged(BR.value);
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
