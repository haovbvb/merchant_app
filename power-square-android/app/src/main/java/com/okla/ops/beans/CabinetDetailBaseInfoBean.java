package com.okla.ops.beans;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

import java.util.ArrayList;
import java.util.List;

/**
 * @Date: 2021/1/26 17:25
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class CabinetDetailBaseInfoBean extends BaseObservable implements Parcelable {

    /**
     * id : 10223
     * createTime : 1598004313000
     * imgs :
     * img :
     * latitude : 22.584431
     * longitude : 113.969904
     * name : 中国广东省深圳市南山区平山一路1-14粤泰港式茶餐厅
     * pid : fa50c05c02a3b724
     * sn : STA612000005
     * useCount :
     * cityName : 全国
     * stationStatus : 1
     * cityCode : 0
     * maxC : 18
     * portStatus :
     * isRecycling : 0
     * storeNum : 13
     * label : 1
     * lastHbTime :
     * hide : 0
     * businessHours :
     * iccid :
     * vpcId : 0
     * putOnShelvesTime : 1611640759000
     * manager : [{"phone":"13823791642","name":"impact"},{"phone":"13266894424","name":"Jaymes"},{"phone":"15019401742","name":"Nero"},{"phone":"17665367114","name":"warrent"}]
     * address :
     * location :
     * standardName :
     * type : 0
     * lockDevId :
     * lockIcId :
     * macId :
     * mark :
     * online :
     */

    private int id;
    private String createTime;
    //    private String imgs;
    private List<String> installImgSet;
    //    private String img;
    private String standardImg;
    private double latitude;
    private double longitude;
    //    private String name;
    private String stationAddress;
    //    private String pid;
    private String stationPid;
    //    private String sn;
    private String stationSn;
    private String useCount;
    private String cityName;
    //    private int stationStatus;
    private int stationStatus;
    private String showOnlineStatus;
    private int cityCode;
    private String maxC;
    private String portStatus;
    private int isRecycling;
    private int storeNum;
    private int label;
    private String labelStr;
    private String lastHbTime;
    private int hide;
    private String businessHours;
    private String iccid;
    private String vpcId;
    private long putOnShelvesTime;
    private String address;
    private String location;
    //    private String standardName;
    private String stationName;
    //    private String stationModelName;
    private String stationSpec;
    private int type;
    //    private int stationModel;
    private String stationModel;
    private String lockDevId;
    private String lockIcId;
    private String macId;
    private String mark;
    private String online;
    private boolean editFlag;//是否是责任人
    //    private List<ManagerBean> manager;
    private List<ManagerBean> stationManagerList;

    private String contractNo;//合同
    private String electricPrice;//电费单价
    private Integer hasPermission;//是否有权限操作 1 是 0 否
    private Integer installStatus;//上架状态
    private String installTime;//上架时间
    private Integer onlineStatus;//联网状态 1 在线 0 离线
    private String simNo;//SIM卡号
    private String spotRental;//点位租金
    private Integer standardSwapTime;//换电次数标准
    private Integer threshold;//换电阈值
    private Integer volume;//换电柜音量
    private Integer maxChargeSoc;//充电上限

    @Bindable
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
        notifyPropertyChanged(BR.id);
    }

    @Bindable
    public String getStationModel() {
        return stationModel;
    }

    public void setStationModel(String stationModel) {
        this.stationModel = stationModel;
        notifyPropertyChanged(BR.stationModel);
    }

    @Bindable
    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
        notifyPropertyChanged(BR.createTime);
    }

    @Bindable
    public List<String> getImgs() {
        return installImgSet;
    }

    public void setImgs(List<String> imgs) {
        this.installImgSet = imgs;
        notifyPropertyChanged(BR.imgs);
    }

    @Bindable
    public String getImg() {
        return standardImg;
    }

    public void setImg(String img) {
        this.standardImg = img;
        notifyPropertyChanged(BR.img);
    }

    @Bindable
    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
        notifyPropertyChanged(BR.latitude);
    }

    @Bindable
    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
        notifyPropertyChanged(BR.longitude);
    }

    @Bindable
    public String getName() {
        return stationAddress;
    }

    public void setName(String name) {
        this.stationAddress = name;
        notifyPropertyChanged(BR.name);
    }

    @Bindable
    public String getPid() {
        return stationPid;
    }

    public void setPid(String pid) {
        this.stationPid = pid;
        notifyPropertyChanged(BR.pid);
    }

    @Bindable
    public String getSn() {
        return stationSn;
    }

    public void setSn(String sn) {
        this.stationSn = sn;
        notifyPropertyChanged(BR.sn);
    }

    @Bindable
    public String getUseCount() {
        return useCount;
    }

    public void setUseCount(String useCount) {
        this.useCount = useCount;
        notifyPropertyChanged(BR.useCount);
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
    public int getStationStatus() {
        return stationStatus;
    }

    public void setStationStatus(int stationStatus) {
        this.stationStatus = stationStatus;
        notifyPropertyChanged(BR.stationStatus);
    }

    @Bindable
    public String getShowOnlineStatus() {
        return showOnlineStatus;
    }

    public void setShowOnlineStatus(String showOnlineStatus) {
        this.showOnlineStatus = showOnlineStatus;
        notifyPropertyChanged(BR.showOnlineStatus);
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
    public String getMaxC() {
        return maxC;
    }

    public void setMaxC(String maxC) {
        this.maxC = maxC;
        notifyPropertyChanged(BR.maxC);
    }

    @Bindable
    public String getPortStatus() {
        return portStatus;
    }

    public void setPortStatus(String portStatus) {
        this.portStatus = portStatus;
        notifyPropertyChanged(BR.portStatus);
    }

    @Bindable
    public int getIsRecycling() {
        return isRecycling;
    }

    public void setIsRecycling(int isRecycling) {
        this.isRecycling = isRecycling;
        notifyPropertyChanged(BR.isRecycling);
    }

    @Bindable
    public int getStoreNum() {
        return storeNum;
    }

    public void setStoreNum(int storeNum) {
        this.storeNum = storeNum;
        notifyPropertyChanged(BR.storeNum);
    }

    @Bindable
    public int getLabel() {
        return label;
    }

    public void setLabel(int label) {
        this.label = label;
        notifyPropertyChanged(BR.label);
    }

    @Bindable
    public String getLabelStr() {
        return labelStr;
    }

    public void setLabelStr(String labelStr) {
        this.labelStr = labelStr;
        notifyPropertyChanged(BR.labelStr);
    }

    @Bindable
    public String getLastHbTime() {
        return lastHbTime;
    }

    public void setLastHbTime(String lastHbTime) {
        this.lastHbTime = lastHbTime;
        notifyPropertyChanged(BR.lastHbTime);
    }

    @Bindable
    public int getHide() {
        return hide;
    }

    public void setHide(int hide) {
        this.hide = hide;
        notifyPropertyChanged(BR.hide);
    }

    @Bindable
    public String getBusinessHours() {
        return businessHours;
    }

    public void setBusinessHours(String businessHours) {
        this.businessHours = businessHours;
        notifyPropertyChanged(BR.businessHours);
    }

    @Bindable
    public String getIccid() {
        return iccid;
    }

    public void setIccid(String iccid) {
        this.iccid = iccid;
        notifyPropertyChanged(BR.iccid);
    }

    @Bindable
    public String getVpcId() {
        return vpcId;
    }

    public void setVpcId(String vpcId) {
        this.vpcId = vpcId;
        notifyPropertyChanged(BR.vpcId);
    }

    @Bindable
    public long getPutOnShelvesTime() {
        return putOnShelvesTime;
    }

    public void setPutOnShelvesTime(long putOnShelvesTime) {
        this.putOnShelvesTime = putOnShelvesTime;
        notifyPropertyChanged(BR.putOnShelvesTime);
    }

    @Bindable
    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
        notifyPropertyChanged(BR.address);
    }

    @Bindable
    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
        notifyPropertyChanged(BR.location);
    }

    @Bindable
    public String getStandardName() {
        return stationName;
    }

    public void setStandardName(String standardName) {
        this.stationName = standardName;
        notifyPropertyChanged(BR.standardName);
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
    public String getLockDevId() {
        return lockDevId;
    }

    public void setLockDevId(String lockDevId) {
        this.lockDevId = lockDevId;
        notifyPropertyChanged(BR.lockDevId);
    }

    @Bindable
    public String getLockIcId() {
        return lockIcId;
    }

    public void setLockIcId(String lockIcId) {
        this.lockIcId = lockIcId;
        notifyPropertyChanged(BR.lockIcId);
    }

    @Bindable
    public String getMacId() {
        return macId;
    }

    public void setMacId(String macId) {
        this.macId = macId;
        notifyPropertyChanged(BR.macId);
    }

    @Bindable
    public String getMark() {
        return mark;
    }

    public void setMark(String mark) {
        this.mark = mark;
        notifyPropertyChanged(BR.mark);
    }

    @Bindable
    public String getOnline() {
        return online;
    }

    public void setOnline(String online) {
        this.online = online;
        notifyPropertyChanged(BR.online);
    }

    @Bindable
    public String getStationModelName() {
        return stationSpec;
    }

    public void setStationModelName(String stationModelName) {
        this.stationSpec = stationModelName;
        notifyPropertyChanged(BR.stationModelName);
    }

    @Bindable
    public boolean isEditFlag() {
        return editFlag;
    }

    public void setEditFlag(boolean editFlag) {
        this.editFlag = editFlag;
        notifyPropertyChanged(BR.editFlag);
    }

    @Bindable
    public List<ManagerBean> getManager() {
        return stationManagerList;
    }

    public void setManager(List<ManagerBean> manager) {
        this.stationManagerList = manager;
        notifyPropertyChanged(BR.manager);
    }

    @Bindable
    public String getContractNo() {
        return contractNo;
    }

    public void setContractNo(String contractNo) {
        this.contractNo = contractNo;
        notifyPropertyChanged(BR.contractNo);
    }

    @Bindable
    public String getElectricPrice() {
        return electricPrice;
    }

    public void setElectricPrice(String electricPrice) {
        this.electricPrice = electricPrice;
        notifyPropertyChanged(BR.electricPrice);
    }

    @Bindable
    public Integer getHasPermission() {
        return hasPermission;
    }

    public void setHasPermission(Integer hasPermission) {
        this.hasPermission = hasPermission;
        notifyPropertyChanged(BR.hasPermission);
    }

    @Bindable
    public Integer getInstallStatus() {
        return installStatus;
    }

    public void setInstallStatus(Integer installStatus) {
        this.installStatus = installStatus;
        notifyPropertyChanged(BR.installStatus);
    }

    @Bindable
    public String getInstallTime() {
        return installTime;
    }

    public void setInstallTime(String installTime) {
        this.installTime = installTime;
        notifyPropertyChanged(BR.installTime);
    }

    @Bindable
    public Integer getOnlineStatus() {
        return onlineStatus;
    }

    public void setOnlineStatus(Integer onlineStatus) {
        this.onlineStatus = onlineStatus;
        notifyPropertyChanged(BR.onlineStatus);
    }

    @Bindable
    public String getSimNo() {
        return simNo;
    }

    public void setSimNo(String simNo) {
        this.simNo = simNo;
        notifyPropertyChanged(BR.simNo);
    }

    @Bindable
    public String getSpotRental() {
        return spotRental;
    }

    public void setSpotRental(String spotRental) {
        this.spotRental = spotRental;
        notifyPropertyChanged(BR.spotRental);
    }

    @Bindable
    public Integer getStandardSwapTime() {
        return standardSwapTime;
    }

    public void setStandardSwapTime(Integer standardSwapTime) {
        this.standardSwapTime = standardSwapTime;
        notifyPropertyChanged(BR.standardSwapTime);
    }

    @Bindable
    public Integer getThreshold() {
        return threshold;
    }

    public void setThreshold(Integer threshold) {
        this.threshold = threshold;
        notifyPropertyChanged(BR.threshold);
    }

    @Bindable
    public Integer getVolume() {
        return volume;
    }

    public void setVolume(Integer volume) {
        this.volume = volume;
        notifyPropertyChanged(BR.volume);
    }

    @Bindable
    public Integer getMaxChargeSoc() {
        return maxChargeSoc;
    }

    public void setMaxChargeSoc(Integer maxChargeSoc) {
        this.maxChargeSoc = maxChargeSoc;
        notifyPropertyChanged(BR.maxChargeSoc);
    }

    public static class ManagerBean extends BaseObservable implements Parcelable {
        public ManagerBean(String phone, String name, String id) {
            this.phone = phone;
//            this.name = name;
            this.showName = name;
//            this.id = id;
            this.accountNo = id;
        }

        /**
         * phone : 13823791642
         * name : impact
         */

        private String phone;
        //        private String name;
        private String showName;
        //        private String id;
        private String accountNo;

        @Bindable
        public String getId() {
            return accountNo;
        }

        public void setId(String id) {
            this.accountNo = id;
            notifyPropertyChanged(BR.id);
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
        public String getName() {
            return showName;
        }

        public void setName(String name) {
            this.showName = name;
            notifyPropertyChanged(BR.name);
        }

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(this.phone);
//            dest.writeString(this.name);
            dest.writeString(this.showName);
//            dest.writeString(this.id);
            dest.writeString(this.accountNo);
        }

        public ManagerBean() {
        }

        protected ManagerBean(Parcel in) {
            this.phone = in.readString();
//            this.name = in.readString();
            this.showName = in.readString();
//            this.id = in.readString();
            this.accountNo = in.readString();
        }

        public static final Creator<ManagerBean> CREATOR = new Creator<ManagerBean>() {
            @Override
            public ManagerBean createFromParcel(Parcel source) {
                return new ManagerBean(source);
            }

            @Override
            public ManagerBean[] newArray(int size) {
                return new ManagerBean[size];
            }
        };
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(this.id);
        dest.writeString(this.createTime);
//        dest.writeString(this.imgs);
        dest.writeList(this.installImgSet);
//        dest.writeString(this.img);
        dest.writeString(this.standardImg);
        dest.writeDouble(this.latitude);
        dest.writeDouble(this.longitude);
//        dest.writeString(this.name);
        dest.writeString(this.stationAddress);
//        dest.writeString(this.pid);
        dest.writeString(this.stationPid);
//        dest.writeString(this.sn);
        dest.writeString(this.stationSn);
        dest.writeString(this.useCount);
        dest.writeString(this.cityName);
        dest.writeInt(this.stationStatus);
        dest.writeString(this.showOnlineStatus);
        dest.writeInt(this.cityCode);
        dest.writeString(this.maxC);
        dest.writeString(this.portStatus);
        dest.writeInt(this.isRecycling);
        dest.writeInt(this.storeNum);
        dest.writeInt(this.label);
        dest.writeString(this.labelStr);
        dest.writeString(this.lastHbTime);
        dest.writeInt(this.hide);
        dest.writeString(this.businessHours);
        dest.writeString(this.iccid);
        dest.writeString(this.vpcId);
        dest.writeLong(this.putOnShelvesTime);
        dest.writeString(this.address);
        dest.writeString(this.location);
//        dest.writeString(this.standardName);
        dest.writeString(this.stationName);
//        dest.writeString(this.stationModelName);
        dest.writeString(this.stationSpec);
        dest.writeInt(this.type);
        dest.writeString(this.lockDevId);
        dest.writeString(this.lockIcId);
        dest.writeString(this.macId);
        dest.writeString(this.mark);
        dest.writeString(this.online);
//        dest.writeList(this.manager);
        dest.writeList(this.stationManagerList);
        dest.writeString(this.contractNo);
        dest.writeString(this.electricPrice);
        dest.writeInt(this.hasPermission);
        dest.writeInt(this.installStatus);
        dest.writeString(this.installTime);
        dest.writeInt(this.onlineStatus);
        dest.writeString(this.simNo);
        dest.writeString(this.spotRental);
        dest.writeInt(this.standardSwapTime);
        dest.writeInt(this.threshold);
        dest.writeInt(this.volume);
        dest.writeInt(this.maxChargeSoc);
    }

    public CabinetDetailBaseInfoBean() {
    }

    protected CabinetDetailBaseInfoBean(Parcel in) {
        this.id = in.readInt();
        this.createTime = in.readString();
//        this.imgs = in.readString();
        this.installImgSet = new ArrayList<String>();
        in.readList(this.installImgSet, String.class.getClassLoader());
//        this.img = in.readString();
        this.standardImg = in.readString();
        this.latitude = in.readDouble();
        this.longitude = in.readDouble();
//        this.name = in.readString();
        this.stationAddress = in.readString();
//        this.pid = in.readString();
        this.stationPid = in.readString();
//        this.sn = in.readString();
        this.stationSn = in.readString();
        this.useCount = in.readString();
        this.cityName = in.readString();
        this.stationStatus = in.readInt();
        this.showOnlineStatus = in.readString();
        this.cityCode = in.readInt();
        this.maxC = in.readString();
        this.portStatus = in.readString();
        this.isRecycling = in.readInt();
        this.storeNum = in.readInt();
        this.label = in.readInt();
        this.labelStr = in.readString();
        this.lastHbTime = in.readString();
        this.hide = in.readInt();
        this.businessHours = in.readString();
        this.iccid = in.readString();
        this.vpcId = in.readString();
        this.putOnShelvesTime = in.readLong();
        this.address = in.readString();
        this.location = in.readString();
//        this.standardName = in.readString();
        this.stationName = in.readString();
//        this.stationModelName = in.readString();
        this.stationSpec = in.readString();
        this.type = in.readInt();
        this.lockDevId = in.readString();
        this.lockIcId = in.readString();
        this.macId = in.readString();
        this.mark = in.readString();
        this.online = in.readString();
        this.stationManagerList = new ArrayList<ManagerBean>();
        in.readList(this.stationManagerList, ManagerBean.class.getClassLoader());
        this.contractNo = in.readString();
        this.electricPrice = in.readString();
        this.hasPermission = in.readInt();
        this.installStatus = in.readInt();
        this.installTime = in.readString();
        this.onlineStatus = in.readInt();
        this.simNo = in.readString();
        this.spotRental = in.readString();
        this.standardSwapTime = in.readInt();
        this.threshold = in.readInt();
        this.volume = in.readInt();
        this.maxChargeSoc = in.readInt();
    }

    public static final Creator<CabinetDetailBaseInfoBean> CREATOR = new Creator<CabinetDetailBaseInfoBean>() {
        @Override
        public CabinetDetailBaseInfoBean createFromParcel(Parcel source) {
            return new CabinetDetailBaseInfoBean(source);
        }

        @Override
        public CabinetDetailBaseInfoBean[] newArray(int size) {
            return new CabinetDetailBaseInfoBean[size];
        }
    };
}
