package com.okla.ops.ble.enums;

public enum UpDataEnum {
    MCU_VERSION("MCU版本号", "043130002"),
    VERIFY_RESULT("MCU通知BLE校验结果：1-校验成功，0-校验失败停止升级", "043130006"),
    OTA_RESULT("MCU升级成功上报BLE当前版本：1-升级成功，0-升级失败", "043130007"),
    ;
    private String desc;
    private String id;

    UpDataEnum(String desc, String id) {
        this.desc = desc;
        this.id = id;
    }

    public String getDesc() {
        return desc;
    }

    public String getId() {
        return id;
    }
}
