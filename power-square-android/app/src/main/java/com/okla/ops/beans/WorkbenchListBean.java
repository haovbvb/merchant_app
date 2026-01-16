package com.okla.ops.beans;

import java.util.List;

public class WorkbenchListBean {
    String title;
    List<WorkbenchItemBean> list;

    public WorkbenchListBean(String title, List<WorkbenchItemBean> list) {
        this.title = title;
        this.list = list;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<WorkbenchItemBean> getList() {
        return list;
    }

    public void setList(List<WorkbenchItemBean> list) {
        this.list = list;
    }

    @Override
    public String toString() {
        return "WorkbenchListBean{" +
                "title='" + title + '\'' +
                ", list=" + list +
                '}';
    }
}
