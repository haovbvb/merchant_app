package com.okla.ops.ble.cmd;

import java.util.List;

public class BaseCmd {
    /**
     * 命令
     */
    protected Integer msgType;

    /**
     * 设备ID
     */
    protected String devId;
    /**
     * 事务No
     */
    protected Long txnNo;

    /**
     * 参数
     */
    public List<CmdParam> paramList;

    public static class CmdParam {
        /**
         * 信号量
         */
        private String id;
        /**
         * 值
         */
        private Object value;

        public CmdParam(String id, Object value) {
            this.id = id;
            this.value = value;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public Object getValue() {
            return value;
        }

        public void setValue(Object value) {
            this.value = value;
        }
    }

    public Integer getMsgType() {
        return msgType;
    }

    public void setMsgType(Integer msgType) {
        this.msgType = msgType;
    }

    public String getDevId() {
        return devId;
    }

    public void setDevId(String devId) {
        this.devId = devId;
    }

    public Long getTxnNo() {
        return txnNo;
    }

    public void setTxnNo(Long txnNo) {
        this.txnNo = txnNo;
    }

    public List<CmdParam> getParamList() {
        return paramList;
    }

    public void setParamList(List<CmdParam> paramList) {
        this.paramList = paramList;
    }
}
