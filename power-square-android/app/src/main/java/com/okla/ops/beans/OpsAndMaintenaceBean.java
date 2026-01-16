package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

import java.util.List;

/**
 * @Date: 2021/2/2 10:07
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class OpsAndMaintenaceBean extends BaseObservable{

    /**
     * total : 1021
     * list : [{"id":"9682f21685784b4899862af8f0ba17db","name":"10122121","phone":"18745397595","enabled":1,
     * "time":1602901992000,"updtime":1612160150000,"roles":[{"id":"05857ca4e5ed4f1ba7b2f03bc6bbc8ba","name":"电池管理",
     * "enabled":1,"time":1543972812000,"description":"电池管理ssf","platform":2,"edit":1,"deptId":"","tenantId":"EF1B212E9ACD3A43003E86E7FB9D3628"},
     * {"id":"857a1db9ddde46cd9d932dec03d2a209","name":"多变的天空1","enabled":1,"time":1480386502000,"description":"   fadfasdf",
     * "platform":1,"edit":0,"deptId":"","tenantId":"EF1B212E9ACD3A43003E86E7FB9D3628"}]
     */

    private int total;
    private List<ListBean> list;

    @Bindable
    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
        notifyPropertyChanged(BR.total);
    }

    @Bindable
    public List<ListBean> getList() {
        return list;
    }

    public void setList(List<ListBean> list) {
        this.list = list;
        notifyPropertyChanged(BR.list);
    }

    public static class ListBean extends BaseObservable {
        /**
         * id : 9682f21685784b4899862af8f0ba17db
         * name : 10122121
         * phone : 18745397595
         * enabled : 1
         * time : 1602901992000
         * updtime : 1612160150000
         * roles : [{"id":"05857ca4e5ed4f1ba7b2f03bc6bbc8ba","name":"电池管理","enabled":1,"time":1543972812000,"description":"电池管理ssf","platform":2,"edit":1,"deptId":"","tenantId":"EF1B212E9ACD3A43003E86E7FB9D3628"},{"id":"857a1db9ddde46cd9d932dec03d2a209","name":"多变的天空1","enabled":1,"time":1480386502000,"description":"   fadfasdf","platform":1,"edit":0,"deptId":"","tenantId":"EF1B212E9ACD3A43003E86E7FB9D3628"},{"id":"A04B92FCC93340FDB83EAB140E95D362","name":"城市运营","enabled":1,"time":1568080440000,"description":"物资管理-城市运营角色","platform":2,"edit":1,"deptId":"","tenantId":"EF1B212E9ACD3A43003E86E7FB9D3628"}]
         * type : 1
         * createBy :
         * cityCode :
         * cityName :
         * depts : [{"id":"0003","parentId":"","treeSort":3,"name":"未分类","status":"0","createBy":"a3a94937283a46bbbacd6e370f29aaf8","createDate":1570781205000,"updateBy":"","updateDate":1611906428000,"remarks":"","edit":1,"deptId":"","isEdit":1}]
         * posts : []
         * isDirector : 0
         * dimissionDate :
         * source : 1
         * agentId :
         * agentPhone :
         * agentName :
         * remark :
         * tenantId : EF1B212E9ACD3A43003E86E7FB9D3628
         * areaCode : +66
         */

        private String id;
        private String name;
        private String phone;
        private int enabled;
        private long time;
        private long updtime;
        private int type;
        private String createBy;
        private String cityCode;
        private String cityName;
        private int isDirector;
        private String dimissionDate;
        private int source;
        private String agentId;
        private String agentPhone;
        private String agentName;
        private String remark;
        private String tenantId;
        private String areaCode;
        private List<RolesBean> roles;
        private List<DeptsBean> depts;
        private List<?> posts;
        private boolean select;

        @Bindable
        public boolean isSelect() {
            return select;
        }

        public void setSelect(boolean select) {
            this.select = select;
            notifyPropertyChanged(BR.select);
        }
        @Bindable
        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
            notifyPropertyChanged(BR.id);
        }

        @Bindable
        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
            notifyPropertyChanged(BR.name);
        }

        @Bindable
        public String getPhone() {
            return phone;
        }

        public void setPhone(String phone) {
            this.phone = phone;
            notifyPropertyChanged(BR.phone);
        }

        @Bindable
        public int getEnabled() {
            return enabled;
        }

        public void setEnabled(int enabled) {
            this.enabled = enabled;
            notifyPropertyChanged(BR.enabled);
        }

        @Bindable
        public long getTime() {
            return time;
        }

        public void setTime(long time) {
            this.time = time;
            notifyPropertyChanged(BR.time);
        }

        @Bindable
        public long getUpdtime() {
            return updtime;
        }

        public void setUpdtime(long updtime) {
            this.updtime = updtime;
            notifyPropertyChanged(BR.updtime);
        }

        @Bindable
        public int getType() {
            return type;
        }

        public void setType(int type) {
            this.type = type;
            notifyPropertyChanged(BR.type);
        }

        @Bindable
        public String getCreateBy() {
            return createBy;
        }

        public void setCreateBy(String createBy) {
            this.createBy = createBy;
            notifyPropertyChanged(BR.createBy);
        }

        @Bindable
        public String getCityCode() {
            return cityCode;
        }

        public void setCityCode(String cityCode) {
            this.cityCode = cityCode;
            notifyPropertyChanged(BR.cityCode);
        }

        @Bindable
        public String getCityName() {
            return cityName;
        }

        public void setCityName(String cityName) {
            this.cityName = cityName;
            notifyPropertyChanged(BR.cityName);
        }

        @Bindable
        public int getIsDirector() {
            return isDirector;
        }

        public void setIsDirector(int isDirector) {
            this.isDirector = isDirector;
            notifyPropertyChanged(BR.isDirector);
        }

        @Bindable
        public String getDimissionDate() {
            return dimissionDate;
        }

        public void setDimissionDate(String dimissionDate) {
            this.dimissionDate = dimissionDate;
            notifyPropertyChanged(BR.dimissionDate);
        }

        @Bindable
        public int getSource() {
            return source;
        }

        public void setSource(int source) {
            this.source = source;
            notifyPropertyChanged(BR.source);
        }

        @Bindable
        public String getAgentId() {
            return agentId;
        }

        public void setAgentId(String agentId) {
            this.agentId = agentId;
            notifyPropertyChanged(BR.agentId);
        }

        @Bindable
        public String getAgentPhone() {
            return agentPhone;
        }

        public void setAgentPhone(String agentPhone) {
            this.agentPhone = agentPhone;
            notifyPropertyChanged(BR.agentPhone);
        }

        @Bindable
        public String getAgentName() {
            return agentName;
        }

        public void setAgentName(String agentName) {
            this.agentName = agentName;
            notifyPropertyChanged(BR.agentName);
        }

        @Bindable
        public String getRemark() {
            return remark;
        }

        public void setRemark(String remark) {
            this.remark = remark;
            notifyPropertyChanged(BR.remark);
        }

        @Bindable
        public String getTenantId() {
            return tenantId;
        }

        public void setTenantId(String tenantId) {
            this.tenantId = tenantId;
            notifyPropertyChanged(BR.tenantId);
        }

        @Bindable
        public String getAreaCode() {
            return areaCode;
        }

        public void setAreaCode(String areaCode) {
            this.areaCode = areaCode;
            notifyPropertyChanged(BR.areaCode);
        }

        @Bindable
        public List<RolesBean> getRoles() {
            return roles;
        }

        public void setRoles(List<RolesBean> roles) {
            this.roles = roles;
            notifyPropertyChanged(BR.roles);
        }

        @Bindable
        public List<DeptsBean> getDepts() {
            return depts;
        }

        public void setDepts(List<DeptsBean> depts) {
            this.depts = depts;
            notifyPropertyChanged(BR.depts);
        }

        @Bindable
        public List<?> getPosts() {
            return posts;
        }

        public void setPosts(List<?> posts) {
            this.posts = posts;
            notifyPropertyChanged(BR.posts);
        }

        public static class RolesBean extends BaseObservable {
            /**
             * id : 05857ca4e5ed4f1ba7b2f03bc6bbc8ba
             * name : 电池管理
             * enabled : 1
             * time : 1543972812000
             * description : 电池管理ssf
             * platform : 2
             * edit : 1
             * deptId :
             * tenantId : EF1B212E9ACD3A43003E86E7FB9D3628
             */

            private String id;
            private String name;
            private int enabled;
            private long time;
            private String description;
            private int platform;
            private int edit;
            private String deptId;
            private String tenantId;

            @Bindable
            public String getId() {
                return id;
            }

            public void setId(String id) {
                this.id = id;
                notifyPropertyChanged(BR.id);
            }

            @Bindable
            public String getName() {
                return name;
            }

            public void setName(String name) {
                this.name = name;
                notifyPropertyChanged(BR.name);
            }

            @Bindable
            public int getEnabled() {
                return enabled;
            }

            public void setEnabled(int enabled) {
                this.enabled = enabled;
                notifyPropertyChanged(BR.enabled);
            }

            @Bindable
            public long getTime() {
                return time;
            }

            public void setTime(long time) {
                this.time = time;
                notifyPropertyChanged(BR.time);
            }

            @Bindable
            public String getDescription() {
                return description;
            }

            public void setDescription(String description) {
                this.description = description;
                notifyPropertyChanged(BR.description);
            }

            @Bindable
            public int getPlatform() {
                return platform;
            }

            public void setPlatform(int platform) {
                this.platform = platform;
                notifyPropertyChanged(BR.platform);
            }

            @Bindable
            public int getEdit() {
                return edit;
            }

            public void setEdit(int edit) {
                this.edit = edit;
                notifyPropertyChanged(BR.edit);
            }

            @Bindable
            public String getDeptId() {
                return deptId;
            }

            public void setDeptId(String deptId) {
                this.deptId = deptId;
                notifyPropertyChanged(BR.deptId);
            }

            @Bindable
            public String getTenantId() {
                return tenantId;
            }

            public void setTenantId(String tenantId) {
                this.tenantId = tenantId;
                notifyPropertyChanged(BR.tenantId);
            }
        }

        public static class DeptsBean extends BaseObservable {
            /**
             * id : 0003
             * parentId :
             * treeSort : 3
             * name : 未分类
             * status : 0
             * createBy : a3a94937283a46bbbacd6e370f29aaf8
             * createDate : 1570781205000
             * updateBy :
             * updateDate : 1611906428000
             * remarks :
             * edit : 1
             * deptId :
             * isEdit : 1
             */

            private String id;
            private String parentId;
            private int treeSort;
            private String name;
            private String status;
            private String createBy;
            private long createDate;
            private String updateBy;
            private long updateDate;
            private String remarks;
            private int edit;
            private String deptId;
            private int isEdit;

            @Bindable
            public String getId() {
                return id;
            }

            public void setId(String id) {
                this.id = id;
                notifyPropertyChanged(BR.id);
            }

            @Bindable
            public String getParentId() {
                return parentId;
            }

            public void setParentId(String parentId) {
                this.parentId = parentId;
                notifyPropertyChanged(BR.parentId);
            }

            @Bindable
            public int getTreeSort() {
                return treeSort;
            }

            public void setTreeSort(int treeSort) {
                this.treeSort = treeSort;
                notifyPropertyChanged(BR.treeSort);
            }

            @Bindable
            public String getName() {
                return name;
            }

            public void setName(String name) {
                this.name = name;
                notifyPropertyChanged(BR.name);
            }

            @Bindable
            public String getStatus() {
                return status;
            }

            public void setStatus(String status) {
                this.status = status;
                notifyPropertyChanged(BR.status);
            }

            @Bindable
            public String getCreateBy() {
                return createBy;
            }

            public void setCreateBy(String createBy) {
                this.createBy = createBy;
                notifyPropertyChanged(BR.createBy);
            }

            @Bindable
            public long getCreateDate() {
                return createDate;
            }

            public void setCreateDate(long createDate) {
                this.createDate = createDate;
                notifyPropertyChanged(BR.createDate);
            }

            @Bindable
            public String getUpdateBy() {
                return updateBy;
            }

            public void setUpdateBy(String updateBy) {
                this.updateBy = updateBy;
                notifyPropertyChanged(BR.updateBy);
            }

            @Bindable
            public long getUpdateDate() {
                return updateDate;
            }

            public void setUpdateDate(long updateDate) {
                this.updateDate = updateDate;
                notifyPropertyChanged(BR.updateDate);
            }

            @Bindable
            public String getRemarks() {
                return remarks;
            }

            public void setRemarks(String remarks) {
                this.remarks = remarks;
                notifyPropertyChanged(BR.remarks);
            }

            @Bindable
            public int getEdit() {
                return edit;
            }

            public void setEdit(int edit) {
                this.edit = edit;
                notifyPropertyChanged(BR.edit);
            }

            @Bindable
            public String getDeptId() {
                return deptId;
            }

            public void setDeptId(String deptId) {
                this.deptId = deptId;
                notifyPropertyChanged(BR.deptId);
            }

            @Bindable
            public int getIsEdit() {
                return isEdit;
            }

            public void setIsEdit(int isEdit) {
                this.isEdit = isEdit;
                notifyPropertyChanged(BR.isEdit);
            }
        }
    }
}
