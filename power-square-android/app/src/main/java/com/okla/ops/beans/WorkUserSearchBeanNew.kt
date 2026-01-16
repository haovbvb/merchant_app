package com.esquare.ops.beans

data class WorkUserSearchBeanNew(
    val avatar: String,//头像
    val batteryList: List<BatterySearchBeanNew>,//用户绑定电池信息
    val batteryNum: Int,//电池数量
    val batteryType: String,//电池类型
    val birthday: String,//生日
    val carList: List<BatterySearchBeanNew>,//用户绑定车辆信息
    val carType: String,//车辆类型
    val cardNum: String,//用户ID
    val createTime: String,//注册时间
    val depositAmount: Int,//押金要求
    val duration: Int,//固定服务周期（天）
    val email: String,//电子邮箱
    val expireDate: String,//服务到期时间
    val infoName: String,//订阅服务名称，例如包月套餐
    val infoType:Int,//0包自然月 1固定周期
    val moneyUnit: String,//货币单位
    val packageAmount: String,//服务价格
    val phone: String,//手机号码
    val realName: String,//用户姓名
    val remark: String,//备注信息
    val residueTimes: String,//剩余换电次数 25次
    val showBatteryNum: String,//展示用户电池数 单电/双电
    val showDepositAmount: String,//押金要求 ￥100
    val showInfoType: String,//展示类型：包自然月/固定周期
    val showResidueDay: String,//剩余天数，例如 5天
    val showTimes: String,//展示换电次数 25次
    val showTotalDepositAmount: String,//已交押金 ￥100
    val showUserType: String,//展示用户类型
    val times: Int,//换电次数
    val totalDepositAmount: Int,//已交押金
    val type: Int,//用户类型：0=付费 1=有效 2 过期 3 注册
    val userId: Int,//ID,不需要展示，用于提交修改
    val username: String//ID
)

data class BatterySearchBeanNew(
    val bindDate: String,
    val deviceModel: String,
    val deviceSn: String,
    val deviceType: Int,
    val latitude: Double,
    val longitude: Double,
    val lowFlag: Int,
    val locUpdateTime: String,
    val showName: String,
    val soc: Int?,
    val standardImg: String,
    val time: String
)

