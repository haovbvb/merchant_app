package com.okla.ops.utils;

public class BluetoothConstants {

    public static final String serviceId = "0000FFE0-0000-1000-8000-00805F9B34FB"; // 服务ID，一个设备下能有多个服务
    /**
     * APP 从蓝牙设备获取数据使用通知通道
     */
    public static final String READ_UUID = "0000ffe4-0000-1000-8000-00805f9b34fb";
    /**
     * APP 向蓝牙设备写数据使用写通道
     */
    public static final String WRITE_UUID = "0000ffe9-0000-1000-8000-00805f9b34fb";

    /**
     * 头
     */
    public static final String command_head = "7E";

    /**
     * 目的地址
     */
    public static final String command_1 = "01";

    /**
     * 源地址
     */
    public static final String command_2 = "00";


    /**
     * 版本号
     */
    public static final String command_3 = "32";


    /**
     * 设备0钥匙，1锁
     */
    public static final String command_4 = "00";

    /**
     * 报文消息长度
     */
    public static String command_len = "";


    /**
     * signal
     */
    public static String command_signal = "";


    /**
     * 消息参数
     */
    public static String command_data = "";

    /**
     * crc
     */
    public static String command_crc = "";

    /**
     * 尾
     */
    public static final String command_end = "7E7E";


    /**
     * 当前用户手机号
     */
    public static String userPhone = "";


    /**
     * 要发送的命令
     */
    public static String commandSend = "";


    /**
     * 发送命令 成功回调
     * 蓝牙设备回调
     */
    public static String commandBack = "";


    /**
     * 钥匙密钥
     */
    public static final String userPwd = "55707578";

    /**
     * 用户特征
     */
    public static String userChar = "";


    /**
     * 电子锁芯id号 当前授权用的 lockDevId
     */
    public static String lockId = "";
    /**
     * 当前授权用
     */
    public static String lockDevId = "";

    /**
     * 拓展预留,默认为零
     */
    public static String lockIcId = "0";
    /**
     * 钥匙id号
     */
    public static String keyId = "";


    /**
     * 权限
     */
    public static final String rights = "00";

    /**
     * 开始时间 增加授权当前时间
     */
    public static String curDate = "";

    /**
     * 结束时间 增加授权当前时间24小时后
     */
    public static String nextDate = "";


    /**
     * 用户编号
     */
    public static String userNum = "";


    /**
     * 开锁密码
     */
    public static final String lockPwd = "5570757890354130";


    /**
     * 电子锁芯分区号
     */
    public static final String lockBlock = "00000000";


    /**
     * 蓝牙钥匙分区号
     */
    public static final String bleKeyBlock = "00000000";


    /**
     * operate type
     */
    public static final int RESET_AUTHORIZATION = 1;

    public static final int CLEAR_AUTHORIZATION = 2;

    /**
     * 换电柜授权
     */
    public static final int ADD_AUTHORIZATION = 1;

    /**
     * 工厂授权
     */
    public static final int ADD_FACTORY_AUTHORIZATION = 2;


}
