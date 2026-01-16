package com.okla.ops.beans;

/**
 * @Date: 2021/3/1 14:06
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class MaxcEventBusBean {
    public double MaxC;

    public double getMaxC() {
        return MaxC;
    }

    public void setMaxC(double maxC) {
        MaxC = maxC;
    }

    public MaxcEventBusBean(double maxC) {
        MaxC = maxC;
    }
}
