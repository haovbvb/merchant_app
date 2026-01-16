package com.okla.ops.beans;

/**
 * @Date: 2021/2/17 14:23
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class SelectedPersonLiableBean {
    public SelectedPersonLiableBean(String phone, String name, String id) {
        this.phone = phone;
        this.name = name;
        this.id = id;
    }

    String phone;
    String name;
    String id;
}
