package com.okla.ops.beans;

import java.util.List;

public class WorkbenchList {
    String title;
    List<WorkbenchItem> list;

    public WorkbenchList(String title, List<WorkbenchItem> list) {
        this.title = title;
        this.list = list;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<WorkbenchItem> getList() {
        return list;
    }

    public void setList(List<WorkbenchItem> list) {
        this.list = list;
    }

    @Override
    public String toString() {
        return "WorkbenchList{" +
                "title='" + title + '\'' +
                ", list=" + list +
                '}';
    }
}
