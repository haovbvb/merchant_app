package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

import java.util.List;

/**
 * @Date: 2021/1/28 10:48
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class LayoutCabinetInfoBean extends BaseObservable{


    /**
     * total : 30
     * list : [{"id":"1513","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"1","cityCode":0,"latitude":"","longitude":"","opPhone":"13631661321","opName":"乔治","createTime":1611741464000,"address":"中国广东省深圳市南山区留仙大道众冠时代广场益田假日里商业裙楼L23金翠皇宫(西丽店)"},{"id":"1512","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":"","longitude":"","opPhone":"17665367114","opName":"warrent","createTime":1611729275000,"address":"xxxxxxxxxx"},{"id":"1511","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":"","longitude":"","opPhone":"17665367114","opName":"warrent","createTime":1611727805000,"address":"xxxxxxxxxx"},{"id":"1510","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":113.9371933,"longitude":22.5340017,"opPhone":"17665367114","opName":"warrent","createTime":1611727347000,"address":"xxxxxxxxxx"},{"id":"1509","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":"","longitude":"","opPhone":"18201906846","opName":"liwen","createTime":1611726956000,"address":"xxxxxxxxxx"},{"id":"1508","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":22.5340017,"longitude":113.9371933,"opPhone":"18201906846","opName":"liwen","createTime":1611726906000,"address":"xxxxxxxxxx"},{"id":"1507","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":22.5340017,"longitude":113.9371933,"opPhone":"18201906846","opName":"liwen","createTime":1611726877000,"address":"xxxxxxxxxx"},{"id":"1506","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":"","longitude":"","opPhone":"17665367114","opName":"warrent","createTime":1611718478000,"address":"xxxxxxxxxx"},{"id":"1505","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":"","longitude":"","opPhone":"17665367114","opName":"warrent","createTime":1611713777000,"address":"中国广东省深圳市南山区留仙大道4168号L4-21台熹牛排(益田·假日里店)"},{"id":"1504","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":"","longitude":"","opPhone":"13631661321","opName":"乔治","createTime":1611662791000,"address":"中国广东省深圳市南山区留仙大道众冠时代广场益田假日里商业裙楼L23金翠皇宫(西丽店)"},{"id":"1503","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":666666,"latitude":13.721152343432871,"longitude":100.45108720846181,"opPhone":"13631661321","opName":"乔治","createTime":1611662537000,"address":"中国广东省深圳市南山区西丽镇平山一路维也纳酒店49-1号中华料理(大学城店)"},{"id":"1502","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":22.584431,"longitude":113.969904,"opPhone":"17665367114","opName":"warrent","createTime":1611661703000,"address":"中国广东省深圳市南山区留仙大道4168号L4-21台熹牛排(益田·假日里店)"},{"id":"1498","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":22.584431,"longitude":113.969904,"opPhone":"17665367114","opName":"warrent","createTime":1611640759000,"address":"中国广东省深圳市南山区平山一路1-14粤泰港式茶餐厅"},{"id":"1497","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":"","longitude":"","opPhone":"17665367114","opName":"warrent","createTime":1611640320000,"address":"中国广东省深圳市南山区平山一路1-14粤泰港式茶餐厅"},{"id":"1496","pid":"fa50c05c02a3b724","sn":"STA612000005","status":"0","cityCode":0,"latitude":13.727815686451411,"longitude":100.46593545221882,"opPhone":"17665367114","opName":"warrent","createTime":1611639464000,"address":"中国广东省深圳市南山区平山一路1-14粤泰港式茶餐厅"}]
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
         * id : 1513
         * pid : fa50c05c02a3b724
         * sn : STA612000005
         * status : 1
         * cityCode : 0
         * latitude :
         * longitude :
         * opPhone : 13631661321
         * opName : 乔治
         * createTime : 1611741464000
         * address : 中国广东省深圳市南山区留仙大道众冠时代广场益田假日里商业裙楼L23金翠皇宫(西丽店)
         */

        private String id;
        private String pid;
        private String sn;
        private String status;
        private int cityCode;
        private String latitude;
        private String longitude;
        private String opPhone;
        private String opName;
        private long createTime;
        private String address;

        @Bindable
        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
            notifyPropertyChanged(BR.id);
        }

        @Bindable
        public String getPid() {
            return pid;
        }

        public void setPid(String pid) {
            this.pid = pid;
            notifyPropertyChanged(BR.pid);
        }

        @Bindable
        public String getSn() {
            return sn;
        }

        public void setSn(String sn) {
            this.sn = sn;
            notifyPropertyChanged(BR.sn);
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
        public int getCityCode() {
            return cityCode;
        }

        public void setCityCode(int cityCode) {
            this.cityCode = cityCode;
            notifyPropertyChanged(BR.cityCode);
        }

        @Bindable
        public String getLatitude() {
            return latitude;
        }

        public void setLatitude(String latitude) {
            this.latitude = latitude;
            notifyPropertyChanged(BR.latitude);
        }

        @Bindable
        public String getLongitude() {
            return longitude;
        }

        public void setLongitude(String longitude) {
            this.longitude = longitude;
            notifyPropertyChanged(BR.longitude);
        }

        @Bindable
        public String getOpPhone() {
            return opPhone;
        }

        public void setOpPhone(String opPhone) {
            this.opPhone = opPhone;
            notifyPropertyChanged(BR.opPhone);
        }

        @Bindable
        public String getOpName() {
            return opName;
        }

        public void setOpName(String opName) {
            this.opName = opName;
            notifyPropertyChanged(BR.opName);
        }

        @Bindable
        public long getCreateTime() {
            return createTime;
        }

        public void setCreateTime(long createTime) {
            this.createTime = createTime;
            notifyPropertyChanged(BR.createTime);
        }

        @Bindable
        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
            notifyPropertyChanged(BR.address);
        }
    }
}
