package com.okla.ops.views.workbench

import android.content.Context
import androidx.annotation.StringRes
import com.okla.ops.R

// 扩展 Module 枚举，添加点击行为标识
enum class Module(
    @StringRes val titleResId: Int,
    val iconRes: Int,
    val actionKey: String // 用于标识点击行为的唯一键
) {
    // 仓管
    DEVICE_RECORD(R.string.str_device_record, R.mipmap.icon_ship_entry, "ShipmentDeviceRegistration"
    ),
    DEVICE_SEND(R.string.str_device_send, R.mipmap.icon_device_issue, "DeviceDispatch"),
    DEVICE_RECEIVE(R.string.str_device_receive, R.mipmap.icon_device_reception, "DeviceReceiving"),
    INVENTORY_AUDIT(R.string.str_inventory_audit, R.mipmap.icon_inventory_count, "InventoryAudit"),
    //运维
    MAINTENANCE_SCHEDULE(R.string.str_maintenance_schedule, R.mipmap.icon_schedule_maintenance, "MaintenanceScheduling"),
    REPAIR_REGISTRATION(R.string.str_repair_registration, R.mipmap.icon_repair_registration, "RepairRegistration"),
    ROAD_ASSISTANCE(R.string.str_road_assistance, R.mipmap.icon_roadside_assistance, "RoadsideAssistance"),
    DEVICE_UNBIND(R.string.str_device_unbind, R.mipmap.icon_device_unbinding, "DeviceUnbinding"),
    AFTER_SALE_BIND(R.string.str_after_sale_bind, R.mipmap.icon_aftersale_binding, "AfterSalesBinding"),
    VCU_TESTING(R.string.str_vcu_testing, R.mipmap.icon_vcu_testing, "VCUTesting"),

    // 销售
    SALE_BIND(R.string.str_sale_bind, R.mipmap.icon_sale_bind, "SalesBinding"),
    LEASE_BIND(R.string.str_lease_bind, R.mipmap.icon_lease_bind, "LeaseBinding"),
    BATTERY_SWAP_BIND(R.string.str_battery_swap_bind, R.mipmap.icon_swap_bind, "BatterySwapBinding"),
    DEPOST_REFUND(R.string.str_depost_refund, R.mipmap.icon_deposit_refund, "DepositRefund"),
    BATTERY_SWAP(R.string.str_battery_swap, R.mipmap.icon_manual_swap, "ManualBatterySwap"),
    INSTALLMENT_PAYMENT(R.string.str_installment_payment, R.mipmap.icon_installment, "InstallmentPayment"),
    OFFLINE_USER_REGISTER(R.string.str_offline_user_register, R.mipmap.icon_offline_register, "OfflineUserRegistration"),
    SALE_STATISTICS(R.string.str_sale_statistics, R.mipmap.icon_sale_statistic, "SalesPerformanceStatistics"),

    //电柜 代理商运维
    RELEASE_STATION(R.string.str_release_station,R.mipmap.icon_release_station,"releaseStation"),
    RETIRE_STATION(R.string.str_retire_station,R.mipmap.icon_retire_station,"retireStation"),
    STATION_OPERATION(R.string.str_station_operation,R.mipmap.icon_station_operation,"stationOperation"),
    REPAIR_REGISTRATION_STATION(R.string.str_repair_registration, R.mipmap.icon_repair_registration, "StationRepairRegistration"),
    STATION_QUERY(R.string.str_station_query,R.mipmap.icon_device_query,"stationInquery"),
    //设备查询
    DEVICE_QUERY(R.string.str_device_query, R.mipmap.icon_device_query, "DeviceInquiry"),
    //用户查询
    USER_QUERY(R.string.str_user_query, R.mipmap.icon_user_query, "UserInquiry");

    fun getTitle(context: Context): String {
        return context.getString(titleResId)
    }
}