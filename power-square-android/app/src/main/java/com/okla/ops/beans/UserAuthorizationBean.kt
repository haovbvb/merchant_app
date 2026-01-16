package com.okla.ops.beans

data class UserAuthorizationList(
    var list: List<UserAuthorizationBean>,
    var total: Int
)

data class UserAuthorizationBean(
    var avatar: String? = "",//头像
    var username: String? = "",//用户名称
    var phone: String? = "",//手机号码
    var accountNo: String? = "",//账号No
    var remark: String? = ""//工作账号备注
)
