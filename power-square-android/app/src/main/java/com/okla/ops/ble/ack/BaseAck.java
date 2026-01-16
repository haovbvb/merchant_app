package com.okla.ops.ble.ack;

public class BaseAck {
    /**
     * 命令
     */
//    protected Integer msgType;

    /**
     * 设备ID
     */
    protected String devId;
    /**
     * 事务No
     */
    protected Long txnNo;

    /*public Integer getMsgType() {
        return msgType;
    }

    public void setMsgType(Integer msgType) {
        this.msgType = msgType;
    }*/

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
}
