package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

/**
 * @Date: 2021/3/5 11:33
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class ScanUserInfoBean extends BaseObservable {

    /**
     * useraccount : 10000000001
     * token : eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1SUQiOjEwMDAxLCJ0ZW5hbnRJZCI6IkVGMUIyMTJFOUFDRDNBNDMwMDNFODZFN0ZCOUQzNjI4IiwidGltZSI6MTYxMjgzNTI2MTcxOSwiY2FyZE51bSI6IjEwMDAwMDAwMDAxIn0.FkVJIN2wRkVrRxDSfrnr-Cq9HakOqoRvJGbR749-f0E
     */

    private String cardNum;
    private String token;

    @Bindable
    public String getCardNum() {
        return cardNum;
    }

    public void setCardNum(String cardNum) {
        this.cardNum = cardNum;
        notifyPropertyChanged(BR.cardNum);
    }

    @Bindable
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
        notifyPropertyChanged(BR.token);
    }
}
