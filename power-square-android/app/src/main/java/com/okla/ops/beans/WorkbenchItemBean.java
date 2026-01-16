package com.okla.ops.beans;

import androidx.databinding.Bindable;
import androidx.databinding.Observable;
import androidx.databinding.PropertyChangeRegistry;

import com.okla.ops.BR;

/**
 * @Date: 2021/3/9 10:37
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class WorkbenchItemBean implements Comparable<WorkbenchItemBean>, Observable {
    int id;
    String code;
    int img;

    public WorkbenchItemBean(int id, String code, int img, int name) {
        this.id = id;
        this.code = code;
        this.img = img;
        this.name = name;
    }

    int name;
    private transient PropertyChangeRegistry propertyChangeRegistry = new PropertyChangeRegistry();

    @Bindable
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
        notifyChange(BR.id);
    }

    @Bindable
    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
        notifyChange(BR.code);
    }

    @Bindable
    public int getImg() {
        return img;
    }

    public void setImg(int img) {
        this.img = img;
        notifyChange(BR.img);
    }

    @Bindable
    public int getName() {
        return name;
    }

    public void setName(int name) {
        this.name = name;
        notifyChange(BR.name);
    }

    private synchronized void notifyChange(int propertyId) {
        if (propertyChangeRegistry == null) {
            propertyChangeRegistry = new PropertyChangeRegistry();
        }
        propertyChangeRegistry.notifyChange(this, propertyId);
    }

    @Override
    public synchronized void addOnPropertyChangedCallback(OnPropertyChangedCallback callback) {
        if (propertyChangeRegistry == null) {
            propertyChangeRegistry = new PropertyChangeRegistry();
        }
        propertyChangeRegistry.add(callback);

    }

    @Override
    public synchronized void removeOnPropertyChangedCallback(OnPropertyChangedCallback callback) {
        if (propertyChangeRegistry != null) {
            propertyChangeRegistry.remove(callback);
        }
    }

    @Override
    public int compareTo(WorkbenchItemBean o) {
        return this.getId() - o.getId();
    }
}
