package com.base.common.db.entity;

public class RoleEntity {


    private String role;

    private boolean isSelected;

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean getSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }

    @Override
    public String toString() {
        return "RoleEntity{" +
                "role='" + role + '\'' +
                ", isSelected=" + isSelected +
                '}';
    }
}

