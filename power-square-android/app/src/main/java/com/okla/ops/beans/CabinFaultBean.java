package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

import java.util.List;

/**
 * @Date: 2021/2/7 11:02
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class CabinFaultBean extends BaseObservable{


    /**
     * total : 8370
     * list : [{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626292,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626293,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626295,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626297,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626300,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626302,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626304,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626306,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626307,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区���乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626309,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626311,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626313,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626315,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626316,"type":2,"port":1},{"sn":"STA612000005","site":"中国广东省深圳市宝安区安乐社区安乐社区","faultDesc":"电池非法取出","createTime":1613616626318,"type":2,"port":1}]
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
         * sn : STA612000005
         * site : 中国广东省深圳市宝安区安乐社区安乐社区
         * faultDesc : 电池非法取出
         * createTime : 1613616626292
         * type : 2
         * port : 1
         */

        private String sn;
        private String site;
        private String faultDesc;
        private long createTime;
        private int type;
        private int port;

        @Bindable
        public String getSn() {
            return sn;
        }

        public void setSn(String sn) {
            this.sn = sn;
            notifyPropertyChanged(BR.sn);
        }

        @Bindable
        public String getSite() {
            return site;
        }

        public void setSite(String site) {
            this.site = site;
            notifyPropertyChanged(BR.site);
        }

        @Bindable
        public String getFaultDesc() {
            return faultDesc;
        }

        public void setFaultDesc(String faultDesc) {
            this.faultDesc = faultDesc;
            notifyPropertyChanged(BR.faultDesc);
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
        public int getType() {
            return type;
        }

        public void setType(int type) {
            this.type = type;
            notifyPropertyChanged(BR.type);
        }

        @Bindable
        public int getPort() {
            return port;
        }

        public void setPort(int port) {
            this.port = port;
            notifyPropertyChanged(BR.port);
        }
    }
}
