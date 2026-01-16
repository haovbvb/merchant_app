package com.okla.ops.ble.ack;

public class IccidAck extends BaseAck {
    private String ICCID;

    public String getICCID() {
        return ICCID;
    }

    public void setICCID(String ICCID) {
        this.ICCID = ICCID;
    }
}
