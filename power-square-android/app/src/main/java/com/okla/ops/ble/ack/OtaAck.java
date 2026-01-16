package com.okla.ops.ble.ack;

public class OtaAck extends BaseAck {

    /**
     * 结果
     */
    private Integer B_result;

    /**
     * 额外信息
     */
    private String B_extVal;

    public Integer getB_result() {
        return B_result;
    }

    public void setB_result(Integer b_result) {
        B_result = b_result;
    }

    public String getB_extVal() {
        return B_extVal;
    }

    public void setB_extVal(String b_extVal) {
        B_extVal = b_extVal;
    }
}
