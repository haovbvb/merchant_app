package com.okla.ops.ble.enums;

public enum CommandEnum {
    LOCK("一键锁车", "043010011", 1, "Lock"),
    LAUNCH("一键启动", "043010012", 2, "On-Click Start"),
    ANTI_THEFT("防盗模式", "043010013", 3, "Anti-Theft"),
    FIND("一键找车", "043110011", 4, "Find Vehicle"),
    REMOTE_LOCK("远程锁车", "043110012", 5, "Remote Lock"),
    ELECTRONIC_FENCE("电子围栏", "044010013", 6),
    REMOTE_UNLOCK("远程解锁", "043110013", 7, "Remote Unlock"),
    LOCK_CUT_4("一键锁车+断电（4轮车）", "043010005", 8),
    UNLOCK_CUT_4("一键解锁（4轮车）", "043010004", 9),
    FIND_4("一键找车(4轮车）", "043010006", 10),
    GOLF_UNLOCK("高尔夫解锁电门", "043010007", 14),
    GOLF_LOCK("高尔夫锁电门", "043010007", 15),
    RESET("复位", "043110014", 16),
    QUERY_MCU_VERSION("查询MCU版本号", "043130001", 1, "Query Mcu version"),
    OTA_VERIFY_VERSION("下发OTA升级版本", "043130003", 2, "Verify OTA version"),
    OTA_UPGRADE("强制升级(1)，非强制升级(0)", "043130004", 2),
    OTA_DATA("升级数据（最大58字节）", "043130005", 3, "OTA data"),
    EDIT_URL("设置服务器域名", "043110016", 6, "Edit server url and port"),
    EDIT_PORT("设置服务器端口", "043110017", 6, "Edit server url and port"),
    EDIT_APN("修改APN", "043110018", 5, "Edit APN"),
    EDIT_FREQUENCY_VEHICLE("修改主电池车辆上报频率", "043110019", 7, "Edit vehicle data upload frequency"),
    EDIT_FREQUENCY_VEHICLE_1("修改锂电池车辆上报频率", "043110020", 7, "Edit vehicle data upload frequency"),
    EDIT_FREQUENCY_GPS("修改主电池GPS上报频率", "043110021", 8, "Edit gps upload frequency"),
    QUERY_STATUS("查询当前车辆状态", "043110015", 9, "Query vehicle status"),
    QUERY_ICCID("查询ICCID", "043110023", 4, "Query Iccid"),
    ;
    private String desc;
    private String id;
    private Integer cmd;
    private String command;

    CommandEnum(String desc, String id, Integer cmd) {
        this.desc = desc;
        this.id = id;
        this.cmd = cmd;
    }

    CommandEnum(String desc, String id, Integer cmd, String command) {
        this.desc = desc;
        this.id = id;
        this.cmd = cmd;
        this.command = command;
    }

    public String getDesc() {
        return desc;
    }

    public String getId() {
        return id;
    }

    public Integer getCmd() {
        return cmd;
    }

    public String getCommand() {
        return command;
    }

    public static String getCommandById(String id) {
        if (LOCK.id.equals(id)) {
            return LOCK.command;
        }
        if (LAUNCH.id.equals(id)) {
            return LAUNCH.command;
        }
        if (ANTI_THEFT.id.equals(id)) {
            return ANTI_THEFT.command;
        }
        if (FIND.id.equals(id)) {
            return FIND.command;
        }
        if (REMOTE_LOCK.id.equals(id)) {
            return REMOTE_LOCK.command;
        }
        if (REMOTE_UNLOCK.id.equals(id)) {
            return REMOTE_UNLOCK.command;
        }
        if (RESET.id.equals(id)) {
            return RESET.command;
        }
        if (QUERY_MCU_VERSION.id.equals(id)) {
            return QUERY_MCU_VERSION.command;
        }
        if (OTA_VERIFY_VERSION.id.equals(id)) {
            return OTA_VERIFY_VERSION.command;
        }
        if (OTA_DATA.id.equals(id)) {
            return OTA_DATA.command;
        }
        if (QUERY_ICCID.id.equals(id)) {
            return QUERY_ICCID.command;
        }
        if (EDIT_APN.id.equals(id)) {
            return EDIT_APN.command;
        }
        if (EDIT_URL.id.equals(id)) {
            return EDIT_URL.command;
        }
        if (EDIT_PORT.id.equals(id)) {
            return EDIT_PORT.command;
        }
        if (EDIT_FREQUENCY_VEHICLE.id.equals(id)) {
            return EDIT_FREQUENCY_VEHICLE.command;
        }
        if (EDIT_FREQUENCY_GPS.id.equals(id)) {
            return EDIT_FREQUENCY_GPS.command;
        }
        if (QUERY_STATUS.id.equals(id)) {
            return QUERY_STATUS.command;
        }
        return null;
    }

    public static String getCommandByCmd(int cmd) {
        if (LOCK.cmd.equals(cmd)) {
            return LOCK.command;
        }
        if (LAUNCH.cmd.equals(cmd)) {
            return LAUNCH.command;
        }
        if (ANTI_THEFT.cmd.equals(cmd)) {
            return ANTI_THEFT.command;
        }
        if (FIND.cmd.equals(cmd)) {
            return FIND.command;
        }
        if (REMOTE_LOCK.cmd.equals(cmd)) {
            return REMOTE_LOCK.command;
        }
        if (REMOTE_UNLOCK.cmd.equals(cmd)) {
            return REMOTE_UNLOCK.command;
        }
        if (QUERY_MCU_VERSION.cmd.equals(cmd)) {
            return QUERY_MCU_VERSION.command;
        }
        if (OTA_VERIFY_VERSION.cmd.equals(cmd)) {
            return OTA_VERIFY_VERSION.command;
        }
        if (OTA_DATA.cmd.equals(cmd)) {
            return OTA_DATA.command;
        }
        if (EDIT_APN.cmd.equals(cmd)) {
            return EDIT_APN.command;
        }
        if (EDIT_URL.cmd.equals(cmd)) {
            return EDIT_URL.command;
        }
        if (EDIT_PORT.cmd.equals(cmd)) {
            return EDIT_PORT.command;
        }
        if (EDIT_FREQUENCY_VEHICLE.cmd.equals(cmd)) {
            return EDIT_FREQUENCY_VEHICLE.command;
        }
        if (EDIT_FREQUENCY_GPS.cmd.equals(cmd)) {
            return EDIT_FREQUENCY_GPS.command;
        }
        if (QUERY_STATUS.cmd.equals(cmd)) {
            return QUERY_STATUS.command;
        }
        return null;
    }
}
