package com.okla.ops.views.workbench

enum class Role(
    val roleKey: String, // 与后台对应的角色标识
    val displayName: String, // 显示名称
    val modules: Set<Module>
) {
    // 定义所有角色映射关系
    WAREHOUSE_MANAGER(
        roleKey = "app_role_store_man",
        displayName = "仓管",
        modules = setOf(
            Module.DEVICE_RECORD,
            Module.DEVICE_SEND,
            Module.DEVICE_RECEIVE,
            Module.DEVICE_QUERY
        )
    ),


    SALES(
        roleKey = "app_role_sales", // 假设销售角色key
        displayName = "销售",
        modules = setOf(
            Module.SALE_BIND,
            Module.LEASE_BIND,
            Module.BATTERY_SWAP_BIND,
            Module.BATTERY_SWAP,
            Module.SALE_STATISTICS,
            Module.DEPOST_REFUND,
            Module.OFFLINE_USER_REGISTER,
            Module.INSTALLMENT_PAYMENT,
            Module.DEVICE_QUERY,
            Module.USER_QUERY
        )
    ),

    MAINTENANCE(
        roleKey = "app_role_op",
        displayName = "运维",
        modules = setOf(
            Module.MAINTENANCE_SCHEDULE,
            Module.REPAIR_REGISTRATION,
            Module.ROAD_ASSISTANCE,
            Module.DEVICE_UNBIND,
            Module.AFTER_SALE_BIND,
            Module.DEVICE_QUERY,
            Module.USER_QUERY
        )
    );

    companion object {
        private val roleMap = values().associateBy { it.roleKey }

        // 安全转换方法（返回可空类型）
        fun fromRoleKey(key: String?): Role? {
            return key?.let { roleMap[it] }
        }

        // 带默认值的转换方法
        fun fromRoleKeyOrDefault(key: String?, default: Role = WAREHOUSE_MANAGER): Role {
            return fromRoleKey(key) ?: default
        }
    }
}