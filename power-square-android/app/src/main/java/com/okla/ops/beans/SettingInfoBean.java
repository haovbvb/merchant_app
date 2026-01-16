package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

/**
 * @Date: 2021/3/5 11:04
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class SettingInfoBean extends BaseObservable {

    /**
     * emptySpaceDetection : {"count":9}
     * noCharging : {"blackoutTime":"14:40","chargingTime":"14:43"}
     * restartTheChargerRegularly : {"open":1,"time":"11:8"}
     * heating : {"pmsAutoControl":0,"apkControl":{"open":0,"permit":15,"prohibit":28}}
     * homePageDetails : {"show":1}
     * microSwitch : {"open":1}
     * batteryConnector : {"open":1}
     * chargingStrategy : {"type":1,"level":null}
     * minimumElectricityBorrowed : {"level":70}
     * maximumChargeCapacity : {"level":100}
     */

    private EmptySpaceDetectionBean emptySpaceDetection;
    private NoChargingBean noCharging;
    private RestartTheChargerRegularlyBean restartTheChargerRegularly;
    private HeatingBean heating;
    private HomePageDetailsBean homePageDetails;
    private MicroSwitchBean microSwitch;
    private BatteryConnectorBean batteryConnector;
    private ChargingStrategyBean chargingStrategy;
    private MinimumElectricityBorrowedBean minimumElectricityBorrowed;
    private MaximumChargeCapacityBean maximumChargeCapacity;

    @Bindable
    public EmptySpaceDetectionBean getEmptySpaceDetection() {
        return emptySpaceDetection;
    }

    public void setEmptySpaceDetection(EmptySpaceDetectionBean emptySpaceDetection) {
        this.emptySpaceDetection = emptySpaceDetection;
        notifyPropertyChanged(BR.emptySpaceDetection);
    }

    @Bindable
    public NoChargingBean getNoCharging() {
        return noCharging;
    }

    public void setNoCharging(NoChargingBean noCharging) {
        this.noCharging = noCharging;
        notifyPropertyChanged(BR.noCharging);
    }

    @Bindable
    public RestartTheChargerRegularlyBean getRestartTheChargerRegularly() {
        return restartTheChargerRegularly;
    }

    public void setRestartTheChargerRegularly(RestartTheChargerRegularlyBean restartTheChargerRegularly) {
        this.restartTheChargerRegularly = restartTheChargerRegularly;
        notifyPropertyChanged(BR.restartTheChargerRegularly);
    }

    @Bindable
    public HeatingBean getHeating() {
        return heating;
    }

    public void setHeating(HeatingBean heating) {
        this.heating = heating;
        notifyPropertyChanged(BR.heating);
    }

    @Bindable
    public HomePageDetailsBean getHomePageDetails() {
        return homePageDetails;
    }

    public void setHomePageDetails(HomePageDetailsBean homePageDetails) {
        this.homePageDetails = homePageDetails;
        notifyPropertyChanged(BR.homePageDetails);
    }

    @Bindable
    public MicroSwitchBean getMicroSwitch() {
        return microSwitch;
    }

    public void setMicroSwitch(MicroSwitchBean microSwitch) {
        this.microSwitch = microSwitch;
        notifyPropertyChanged(BR.microSwitch);
    }

    @Bindable
    public BatteryConnectorBean getBatteryConnector() {
        return batteryConnector;
    }

    public void setBatteryConnector(BatteryConnectorBean batteryConnector) {
        this.batteryConnector = batteryConnector;
        notifyPropertyChanged(BR.batteryConnector);
    }

    @Bindable
    public ChargingStrategyBean getChargingStrategy() {
        return chargingStrategy;
    }

    public void setChargingStrategy(ChargingStrategyBean chargingStrategy) {
        this.chargingStrategy = chargingStrategy;
        notifyPropertyChanged(BR.chargingStrategy);
    }

    @Bindable
    public MinimumElectricityBorrowedBean getMinimumElectricityBorrowed() {
        return minimumElectricityBorrowed;
    }

    public void setMinimumElectricityBorrowed(MinimumElectricityBorrowedBean minimumElectricityBorrowed) {
        this.minimumElectricityBorrowed = minimumElectricityBorrowed;
        notifyPropertyChanged(BR.minimumElectricityBorrowed);
    }

    @Bindable
    public MaximumChargeCapacityBean getMaximumChargeCapacity() {
        return maximumChargeCapacity;
    }

    public void setMaximumChargeCapacity(MaximumChargeCapacityBean maximumChargeCapacity) {
        this.maximumChargeCapacity = maximumChargeCapacity;
        notifyPropertyChanged(BR.maximumChargeCapacity);
    }

    public static class EmptySpaceDetectionBean extends BaseObservable {
        /**
         * count : 9
         */

        private int count;

        @Bindable
        public int getCount() {
            return count;
        }

        public void setCount(int count) {
            this.count = count;
            notifyPropertyChanged(BR.count);
        }
    }

    public static class NoChargingBean extends BaseObservable {
        /**
         * blackoutTime : 14:40
         * chargingTime : 14:43
         */

        private String blackoutTime;
        private String chargingTime;

        @Bindable
        public String getBlackoutTime() {
            return blackoutTime;
        }

        public void setBlackoutTime(String blackoutTime) {
            this.blackoutTime = blackoutTime;
            notifyPropertyChanged(BR.blackoutTime);
        }

        @Bindable
        public String getChargingTime() {
            return chargingTime;
        }

        public void setChargingTime(String chargingTime) {
            this.chargingTime = chargingTime;
            notifyPropertyChanged(BR.chargingTime);
        }
    }

    public static class RestartTheChargerRegularlyBean extends BaseObservable {
        /**
         * open : 1 ,1-开启 0-关闭
         * time : 11:8
         */

        private int open;
        private String time;

        @Bindable
        public int getOpen() {
            return open;
        }

        public void setOpen(int open) {
            this.open = open;
            notifyPropertyChanged(BR.open);
        }

        @Bindable
        public String getTime() {
            return time;
        }

        public void setTime(String time) {
            this.time = time;
            notifyPropertyChanged(BR.time);
        }
    }

    public static class HeatingBean extends BaseObservable {
        /**
         * pmsAutoControl : 0  ,0-关闭，1-开启
         * apkControl : {"open":0,"permit":15,"prohibit":28}
         */

        private int pmsAutoControl;
        private ApkControlBean apkControl;

        @Bindable
        public int getPmsAutoControl() {
            return pmsAutoControl;
        }

        public void setPmsAutoControl(int pmsAutoControl) {
            this.pmsAutoControl = pmsAutoControl;
            notifyPropertyChanged(BR.pmsAutoControl);
        }

        @Bindable
        public ApkControlBean getApkControl() {
            return apkControl;
        }

        public void setApkControl(ApkControlBean apkControl) {
            this.apkControl = apkControl;
            notifyPropertyChanged(BR.apkControl);
        }

        public static class ApkControlBean extends BaseObservable {
            /**
             * open : 0
             * permit : 15
             * prohibit : 28
             */

            private int open;
            private int permit;
            private int prohibit;

            @Bindable
            public int getOpen() {
                return open;
            }

            public void setOpen(int open) {
                this.open = open;
                notifyPropertyChanged(BR.open);
            }

            @Bindable
            public int getPermit() {
                return permit;
            }

            public void setPermit(int permit) {
                this.permit = permit;
                notifyPropertyChanged(BR.permit);
            }

            @Bindable
            public int getProhibit() {
                return prohibit;
            }

            public void setProhibit(int prohibit) {
                this.prohibit = prohibit;
                notifyPropertyChanged(BR.prohibit);
            }
        }
    }

    public static class HomePageDetailsBean extends BaseObservable {
        /**
         * show : 1
         */

        private int show;

        @Bindable
        public int getShow() {
            return show;
        }

        public void setShow(int show) {
            this.show = show;
            notifyPropertyChanged(BR.show);
        }
    }

    public static class MicroSwitchBean extends BaseObservable {
        /**
         * open : 1
         */

        private int open;

        @Bindable
        public int getOpen() {
            return open;
        }

        public void setOpen(int open) {
            this.open = open;
            notifyPropertyChanged(BR.open);
        }
    }

    public static class BatteryConnectorBean extends BaseObservable {
        /**
         * open : 1
         */

        private int open;

        @Bindable
        public int getOpen() {
            return open;
        }

        public void setOpen(int open) {
            this.open = open;
            notifyPropertyChanged(BR.open);
        }
    }

    public static class ChargingStrategyBean extends BaseObservable {
        /**
         * type : 1
         * level : null
         */

        private int type;
        private int level;

        @Bindable
        public int getType() {
            return type;
        }

        public void setType(int type) {
            this.type = type;
            notifyPropertyChanged(BR.type);
        }

        @Bindable
        public int getLevel() {
            return level;
        }

        public void setLevel(int level) {
            this.level = level;
            notifyPropertyChanged(BR.level);
        }
    }

    public static class MinimumElectricityBorrowedBean extends BaseObservable {
        /**
         * level : 70
         */

        private int level;

        @Bindable
        public int getLevel() {
            return level;
        }

        public void setLevel(int level) {
            this.level = level;
            notifyPropertyChanged(BR.level);
        }
    }

    public static class MaximumChargeCapacityBean extends BaseObservable {
        /**
         * level : 100
         */

        private int level;

        @Bindable
        public int getLevel() {
            return level;
        }

        public void setLevel(int level) {
            this.level = level;
            notifyPropertyChanged(BR.level);
        }
    }
}
