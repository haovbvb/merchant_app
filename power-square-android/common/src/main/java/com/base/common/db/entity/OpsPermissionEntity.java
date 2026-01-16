package com.base.common.db.entity;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "opspermission")
public class OpsPermissionEntity {
    /**
     * id : 50e84cccb2ac451d8bf2678589adf2b8
     * name : 上架
     * code : location
     * description : null
     * isOwn : 0
     * dictionaryCode : search
     * platform : 2
     */
    @NonNull
    @PrimaryKey
    private int id;
    private String idStr;
    private String code;
    private String name;
    private String description;
    private int isOwn;//0 不展示
    private String dictionaryCode;
    private int platform;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }
    public String getIdStr() {
        return idStr;
    }

    public void setIdStr(String idStr) {
        this.idStr = idStr;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getIsOwn() {
        return isOwn;
    }

    public void setIsOwn(int isOwn) {
        this.isOwn = isOwn;
    }

    public String getDictionaryCode() {
        return dictionaryCode;
    }

    public void setDictionaryCode(String dictionaryCode) {
        this.dictionaryCode = dictionaryCode;
    }

    public int getPlatform() {
        return platform;
    }

    public void setPlatform(int platform) {
        this.platform = platform;
    }

    @Override
    public String toString() {
        return "OpsPermissionEntity{" +
                "id='" + id + '\'' +
                ", code='" + code + '\'' +
                ", name='" + name + '\'' +
                ", description=" + description +
                ", isOwn=" + isOwn +
                ", dictionaryCode='" + dictionaryCode + '\'' +
                ", platform=" + platform +
                '}';
    }
}
