package com.okla.ops.beans;

public class SNBean {
    /*{
        "code": 1000,
            "msg": "成功",
            "result": {
        "lockIcId": "7531c225",
                "lockDevId": "0a002825"
    },
        "ok": true
    }*/

    private String lockIcId;
    private String lockDevId;

    public String getLockIcId() {
        return lockIcId;
    }

    public void setLockIcId(String lockIcId) {
        this.lockIcId = lockIcId;
    }

    public String getLockDevId() {
        return lockDevId;
    }

    public void setLockDevId(String lockDevId) {
        this.lockDevId = lockDevId;
    }
}
