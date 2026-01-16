package com.okla.ops.beans;

import android.net.Uri;

import java.io.File;

public class ImageBean {
    public ImageBean(boolean isAdd) {
        this.isAdd = isAdd;
    }

    public ImageBean(String path, boolean isAdd) {
        this.path = path;
        this.isAdd = isAdd;
    }

    public ImageBean(File file, boolean isAdd) {
        this.file = file;
        this.isAdd = isAdd;
    }

    public ImageBean(File file, Uri fileUri, boolean isAdd) {
        this.file = file;
        this.fileUri = fileUri;
        this.isAdd = isAdd;
    }

    public ImageBean(Uri fileUri, boolean isAdd) {
        this.fileUri = fileUri;
        this.isAdd = isAdd;
    }

    public ImageBean(File file, boolean isAdd, boolean isEdit) {
        this.file = file;
        this.isAdd = isAdd;
        this.isEdit = isEdit;
    }

    public ImageBean(Uri fileUri, boolean isAdd, boolean isEdit) {
        this.fileUri = fileUri;
        this.isAdd = isAdd;
        this.isEdit = isEdit;
    }

    public ImageBean(File file, Uri fileUri, boolean isAdd, boolean isEdit) {
        this.file = file;
        this.fileUri = fileUri;
        this.isAdd = isAdd;
        this.isEdit = isEdit;
    }

    public File getFile() {
        return file;
    }

    public void setFile(File file) {
        this.file = file;
    }

    public boolean isAdd() {
        return isAdd;
    }

    public void setAdd(boolean add) {
        isAdd = add;
    }

    public File file;
    public Uri fileUri;
    public String path;
    public boolean isAdd;

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public boolean isEdit() {
        return isEdit;
    }

    public void setEdit(boolean edit) {
        isEdit = edit;
    }

    public boolean isEdit;
}
