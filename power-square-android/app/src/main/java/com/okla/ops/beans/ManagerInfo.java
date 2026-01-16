package com.okla.ops.beans;

import java.io.Serializable;

public class ManagerInfo implements Serializable {
    private String accountNo;
    private String showName;
    private String phone;

    public String getAccountNo() {
        return accountNo;
    }

    public void setAccountNo(String accountNo) {
        this.accountNo = accountNo;
    }

    public String getShowName() {
        return showName;
    }

    public void setShowName(String showName) {
        this.showName = showName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    @Override
    public String toString() {
        return "ManagerInfo{" +
                "accountNo='" + accountNo + '\'' +
                ", showName='" + showName + '\'' +
                ", phone='" + phone + '\'' +
                '}';
    }
}
