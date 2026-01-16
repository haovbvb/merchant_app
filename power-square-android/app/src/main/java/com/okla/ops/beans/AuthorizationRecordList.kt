package com.okla.ops.beans

data class AuthorizationRecordList(
    var list: List<AuthorizationRecordBean>,
    var total: Int
)

data class AuthorizationRecordBean(
    var actionTime: Long? = 0,//授权时间
    var bePermissionName: String? = "",//被操作对象名
    var beginTime: Long? = 0,//授权开始时间
    var expireTime: Long? = 0,//授权结束时间
    var permissionId: Int? = 0,//授权记录ID
    var permissionStatus: Int? = 0,//授权状态 1=正常 2=已取消
    var standardImg: String? = "",//标准图片
    var stationSn: String? = ""//电柜SN
)
