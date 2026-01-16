package com.okla.ops.beans

data class DeviceTransportResp(
    val list: List<DeviceTransport>,
    val total: Int
)

data class DeviceTransport(
    val transferNo: String,//出库编号
    val status: Int,//0=在途 1=已接收 2=部分接收
    val deviceNum: Int,//设备数量
    val deviceType: Int,//设备类型：1 电池 2 电柜 3 电摩
    val inTransitNum: Int,//在途数量
    val inWarehouseName: String,//接收仓库名称
    val inWarehouseNo: String,//接收仓库ID
    val inWarehouseType: Int,//接收仓库类型：0 总仓 1 城市仓 2 服务点位
    val outWarehouseName: String,//发出仓库名称
    val outWarehouseNo: String,//发出仓库ID
    val outWarehouseType: Int,//发出仓库类型：0 总仓 1 城市仓 2 服务点位
    val receivedNum: Int,//接收数量
    val receivedTime: String,//接收时间
    val sendTime: String,//发出时间
)

data class DeviceTransportData(
    val sn: String,
    val status: Int,
)

data class DeviceTransportDetail(
    val detailPage: DeviceTransportDetailPage?,
    val deviceNum: Int,
    val deviceType: Int,//设备类型：1 电池 2电摩
    val inTransitNum: Int,
    val inWarehouseName: String,
    val outWarehouseName: String,
    val receivedNum: Int,
    val sendTime: Long,
    val trackingNumber: String,
    val transferNo: String,
    val withdrawNum: Int
)

data class DeviceTransportDetailPage(
    val total: Int,
    val list: List<DeviceTransportDetailPageData>
)

data class DeviceTransportDetailPageData(
    val deviceSn: String,
    val status: Int,
    val opTime: String,
)