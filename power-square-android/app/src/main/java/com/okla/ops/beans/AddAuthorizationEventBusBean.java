package com.okla.ops.beans;

public class AddAuthorizationEventBusBean {
    /**
     * 0,开始
     * 1，成功
     * -1 失败
     */
    public int state;

    public int day;

    public AddAuthorizationEventBusBean(int state) {
        this.state = state;
    }
}
