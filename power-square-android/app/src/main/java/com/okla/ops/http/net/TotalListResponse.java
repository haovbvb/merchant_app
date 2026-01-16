package com.okla.ops.http.net;

import com.base.common.net.BaseListResponse;

public class TotalListResponse<T> {

    private double orderAmount;

    private int orderNum;

    private BaseListResponse<T> page;

    public double getOrderAmount() {
        return orderAmount;
    }

    public void setOrderAmount(double orderAmount) {
        this.orderAmount = orderAmount;
    }

    public int getOrderNum() {
        return orderNum;
    }

    public void setOrderNum(int orderNum) {
        this.orderNum = orderNum;
    }

    public BaseListResponse<T> getPage() {
        return page;
    }

    public void setPage(BaseListResponse<T> page) {
        this.page = page;
    }
}
