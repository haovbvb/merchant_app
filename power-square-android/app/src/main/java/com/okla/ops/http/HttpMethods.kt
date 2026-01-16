package com.okla.ops.http

import com.base.common.GlobalConfigure
import com.base.common.net.BaseListResponse
import com.base.common.net.ServiceGenerator
import com.base.library.net.down.DownProgress
import com.okla.ops.beans.AreaCountryResp
import com.okla.ops.beans.AuthorizationRecordList
import com.okla.ops.beans.BatterOrVehicleInfo
import com.okla.ops.beans.Battery
import com.okla.ops.beans.BatteryDetail
import com.okla.ops.beans.BatterySwapRecord
import com.okla.ops.beans.BatteryTransfer
import com.okla.ops.beans.BatteryType
import com.okla.ops.beans.BookMaintenanceBean
import com.okla.ops.beans.Cabin
import com.okla.ops.beans.CabinFaultBean
import com.okla.ops.beans.CabinetAndCameraBoundBean
import com.okla.ops.beans.CabinetAuthorizationList
import com.okla.ops.beans.CabinetDetailBaseInfoBean
import com.okla.ops.beans.CabinetVersionBean
import com.okla.ops.beans.CarType
import com.okla.ops.beans.ChargeHistory
import com.okla.ops.beans.City
import com.okla.ops.beans.CityCode
import com.okla.ops.beans.CurrentPointBean
import com.okla.ops.beans.DeputyCabinetBean
import com.okla.ops.beans.DeviceFixRecordResponse
import com.okla.ops.beans.DeviceInventoryDetail
import com.okla.ops.beans.DeviceInventoryResp
import com.okla.ops.beans.DeviceInventoryScanResult
import com.okla.ops.beans.DeviceMaintenanceResponse
import com.okla.ops.beans.DeviceTransportDetail
import com.okla.ops.beans.DeviceTransportResp
import com.okla.ops.beans.ForbiddenReasonBean
import com.okla.ops.beans.InstallmentPaymentResponse
import com.okla.ops.beans.Insurance
import com.okla.ops.beans.LayoutCabinetInfoBean
import com.okla.ops.beans.MessageListResponse
import com.okla.ops.beans.NearByVehicle
import com.okla.ops.beans.NewCabinetBean
import com.okla.ops.beans.OpsAndMaintenaceBean
import com.okla.ops.beans.PaymentOrder
import com.okla.ops.beans.PaymentPlan
import com.okla.ops.beans.Personal
import com.okla.ops.beans.PolylinePoints
import com.okla.ops.beans.PolylinePointsBean
import com.okla.ops.beans.PowerChangeBeanNew
import com.okla.ops.beans.PurchasingUser
import com.okla.ops.beans.RoadSideListResp
import com.okla.ops.beans.SNBean
import com.okla.ops.beans.SaleSumPageData
import com.okla.ops.beans.SalesBarData
import com.okla.ops.beans.SelectedPersonLiableBean
import com.okla.ops.beans.SellDataListResponse
import com.okla.ops.beans.ServicePlanInfo
import com.okla.ops.beans.SettingInfoBean
import com.okla.ops.beans.Shop
import com.okla.ops.beans.Shop1
import com.okla.ops.beans.Shop1Num
import com.okla.ops.beans.ShopDetail
import com.okla.ops.beans.ShopPaymentMethod
import com.okla.ops.beans.StaticBatteryMile
import com.okla.ops.beans.StaticSaleNum
import com.okla.ops.beans.StaticSaleShop
import com.okla.ops.beans.StaticSaleShopDetail
import com.okla.ops.beans.StationType
import com.okla.ops.beans.Stock
import com.okla.ops.beans.StockDetail
import com.okla.ops.beans.StockNum
import com.okla.ops.beans.TemporyPSWbean
import com.okla.ops.beans.User
import com.okla.ops.beans.UserAuthorizationList
import com.okla.ops.beans.UserDetail
import com.okla.ops.beans.UserInfo
import com.okla.ops.beans.UserPaymentRecord
import com.okla.ops.beans.VehicleDetailBean
import com.okla.ops.beans.VehicleRepairListResp
import com.okla.ops.beans.WarehouseBean
import com.okla.ops.http.net.TotalListResponse
import com.okla.ops.views.workbench.SaleData
import com.okla.ops.views.workbench.qm.RoadSideOrderDetail
import com.okla.ops.views.workbench.sales.depositrefund.DepositRefundInfoBean
import com.okla.ops.views.workbench.sales.rentbind.Pack
import com.okla.ops.views.workbench.sales.rentbind.RentDeviceInfoBean
import com.okla.ops.views.workbench.sales.swapbind.SwapBindInfo
import com.okla.ops.views.workbench.user.UserOrderResponse
import com.okla.ops.views.workbench.vcu.VcuVersion
import io.reactivex.Observable
import okhttp3.MultipartBody
import okhttp3.ResponseBody


object HttpMethods {

    internal var opsService: OPSService = ServiceGenerator.createService(
        OPSService::class.java,
        GlobalConfigure.getBaseUrl()
    )

    private val googleService: OPSService = ServiceGenerator.createService(
        OPSService::class.java,
        GlobalConfigure.getGooglePolyLineUrl(),
        false
    )

    /**
     * 获取路径
     */
    fun getRoutes(hashMap: HashMap<String, Any>): Observable<PolylinePoints> {
        return googleService.getRoutes(hashMap)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerDataGoogle())
    }

    fun getPhoneByCardNum(cardNum: String):Observable<Any>{
        return opsService.getPhoneByCardNum(cardNum).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun login(map: HashMap<String, Any>): Observable<User> {
        return opsService.login(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun refreshToken(): Observable<User> {
        return opsService.refreshToken().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun logout(): Observable<Any> {
        return opsService.logout().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getPersonalInfo(): Observable<Personal> {
        return opsService.getPersonalInfo().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun changePSWNew(map: HashMap<String, String>): Observable<Any> {
        return opsService.changePSWNew(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun editNickName(map: HashMap<String, String>): Observable<Any> {
        return opsService.editNickname(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun editAvatar(avatarFile: MultipartBody.Part): Observable<Any> {
        return opsService.editAvatar(avatarFile)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取电池型号录入列表
     */
    fun getBatteryTypeList(): Observable<MutableList<BatteryType>> {
        return opsService.getBatteryTypeList().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 录入电池
     */
    fun registerBattery(map: HashMap<String, Any>): Observable<Any> {
        return opsService.registerBattery(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取电柜型号录入列表
     */
    fun getStationTypeList(): Observable<MutableList<StationType>> {
        return opsService.getStationTypeList().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    /**
     * 录入电柜
     */
    fun registerStation(map: HashMap<String, Any>): Observable<Any> {
        return opsService.registerStation(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取车辆型号录入列表
     */
    fun getCarTypeList(): Observable<MutableList<CarType>> {
        return opsService.getCarTypeList().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 录入车辆
     */
    fun registerCar(map: HashMap<String, Any>): Observable<Any> {
        return opsService.registerCar(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

//    fun getAgentList(map: HashMap<String, Any>): Observable<MutableList<Agent>> {
//        return opsService.getAgentList(map).compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }
//
//    fun queryShipBatteryBySn(map: HashMap<String, Any>): Observable<Battery> {
//        return opsService.queryShipBatteryBySn(map).compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }
//
//    fun shipBattery(map: HashMap<String, Any>): Observable<String> {
//        return opsService.shipBattery(map).compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }
//
//    fun queryShipCarBySn(map: HashMap<String, Any>): Observable<Car> {
//        return opsService.queryShipCarBySn(map).compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }

//    fun shipCar(map: HashMap<String, Any>): Observable<String> {
//        return opsService.shipCar(map).compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }

    //    fun querySellBatteryBySn(map: HashMap<String, Any>): Observable<SellBattery> {
//        return opsService.querySellBatteryBySn(map).compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }
//

    //获取工作台销售统计信息
    fun getSaleData(): Observable<SaleData> {
        return opsService.getSaleData().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    //查询销售设备信息
    fun querySaleDeviceInfo(map: HashMap<String, Any>): Observable<BatterOrVehicleInfo> {
        return opsService.querySaleDeviceInfo(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryServicePlanByName(map: HashMap<String, Any>): Observable<ServicePlanInfo> {
        return opsService.queryServicePlanByName(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getPaymentPlanList(map: HashMap<String, Any>): Observable<List<PaymentPlan>> {
        return opsService.getPaymantPlanList(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 销售绑定-查询用户
     */
    fun queryUserForSell(map: HashMap<String, Any>): Observable<PurchasingUser> {
        return opsService.queryUserForSell(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 售後綁定-查詢用戶
     */
    fun queryUserForAfterSaleBind(map: HashMap<String, Any>): Observable<UserDetail> {
        return opsService.queryUserForAfterSaleBind(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 租赁绑定-查询用户
     */
    fun queryUserForRent(map: HashMap<String, Any>): Observable<PurchasingUser> {
        return opsService.queryUserForRent(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun uploadCardImg(part: MultipartBody.Part): Observable<String> {
        return opsService.uploadCardImg(part).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun uploadAttachment(part: MultipartBody.Part): Observable<String> {
        return opsService.uploadAttachment(part).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }


    /**
     * 用户查询模块-上传缴纳凭证
     */
    fun userUploadAttachment(part: MultipartBody.Part): Observable<String> {
        return opsService.userUploadAttachment(part).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 用户查询模块-确定付款
     */
    fun userConfirmPayOrder(map: HashMap<String, Any>): Observable<Any> {
        return opsService.userConfirmPayOrder(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

//    fun sellBattery(map: HashMap<String, Any>): Observable<Any> {
//        return opsService.sellBattery(map).compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }

    /**
     * 销售绑定-生成订单
     */
    fun sellBind(map: HashMap<String, Any>): Observable<Any> {
        return opsService.sellBind(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 租赁绑定-生成订单
     */
    fun rentBind(map: HashMap<String, Any>): Observable<Any> {
        return opsService.rentBind(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 換電綁定-生產訂單
     */
    fun createSwapBindOrder(map: HashMap<String, Any>): Observable<Any> {
        return opsService.createSwapBindOrder(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getShopPaymethod(shopNo:String):Observable<ShopPaymentMethod>{
        val map = HashMap<String,Any>()
        map["shopNo"] = shopNo
        return opsService.getShopPaymentMethod(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getNearByVehicleList(map: HashMap<String, Any>): Observable<MutableList<NearByVehicle>> {
        return opsService.getNearByVehicleList(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getCityList(): Observable<MutableList<City>> {
        return opsService.getCityList().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun createShop(map: HashMap<String, Any>): Observable<Any> {
        return opsService.createShop(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryShopByName(map: HashMap<String, Any>): Observable<MutableList<Shop>> {
        return opsService.queryShopByName(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getStockNum(map: HashMap<String, Any>): Observable<StockNum> {
        return opsService.getStockNum(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getStockList(map: HashMap<String, Any>): Observable<BaseListResponse<Stock>> {
        return opsService.getStockList(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryTransferBatteryBySn(map: HashMap<String, Any>): Observable<BatteryTransfer> {
        return opsService.queryTransferBatteryBySn(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun stockTransfer(map: HashMap<String, Any>): Observable<Any> {
        return opsService.stockTransfer(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryStockDetailByTransferNo(map: HashMap<String, Any>): Observable<StockDetail> {
        return opsService.queryStockDetailByTransferNo(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getShopNum(map: HashMap<String, Any>): Observable<Shop1Num> {
        return opsService.getShopNum(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getShopList(map: HashMap<String, Any>): Observable<BaseListResponse<Shop1>> {
        return opsService.getShopList(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryShopDetail(map: HashMap<String, Any>): Observable<ShopDetail> {
        return opsService.queryShopDetail(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun turnShopStatus(map: HashMap<String, Any>): Observable<Any> {
        return opsService.turnShopStatus(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun editShop(map: HashMap<String, Any>): Observable<Any> {
        return opsService.editShop(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun searchBatteryBySn(map: HashMap<String, Any>): Observable<BatteryDetail> {
        return opsService.searchBatteryBySn(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun turnDischargesStatus(map: HashMap<String, Any>): Observable<Any> {
        return opsService.turnDischargeStatus(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryDeviceChargeRecord(map: HashMap<String, Any>): Observable<BaseListResponse<ChargeHistory>> {
        return opsService.queryDeviceChargeRecord(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun staticBatteryMile(map: HashMap<String, Any>): Observable<StaticBatteryMile> {
        return opsService.staticBatteryMile(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryOrderByNo(map: HashMap<String, Any>): Observable<PaymentOrder> {
        return opsService.queryOrderByNo(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun confirmPayment(map: HashMap<String, Any>): Observable<Any> {
        return opsService.confirmPayment(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryPaymentOrderList(map: HashMap<String, Any>): Observable<TotalListResponse<PaymentOrder>> {
        return opsService.queryPaymentOrderList(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryUserForInsurance(map: HashMap<String, Any>): Observable<PurchasingUser> {
        return opsService.queryUserForInsurance(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryDeviceForInsurance(map: HashMap<String, Any>): Observable<Battery> {
        return opsService.queryDeviceForInsurance(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryInsurancePlan(map: HashMap<String, Any>): Observable<Insurance> {
        return opsService.queryInsurancePlan(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun applyInsurance(map: HashMap<String, Any>): Observable<Any> {
        return opsService.applyInsurance(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getStaticSaleNum(): Observable<StaticSaleNum> {
        return opsService.getStaticSaleNum().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun queryStaticShopList(map: HashMap<String, Any>): Observable<BaseListResponse<StaticSaleShop>> {
        return opsService.queryStaticShopList(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getSellStaticDetail(map: HashMap<String, Any>): Observable<StaticSaleShopDetail> {
        return opsService.getSellStaticDetail(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun get12MonthOrderData(): Observable<SalesBarData> {
        return opsService.get12MonthOrderDate().compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getSellPageRankData(map: HashMap<String, Any>): Observable<SaleSumPageData> {
        return opsService.getSellPageRankData(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    //门店业绩统计-分页查询销售数据 /售后服务数据
    fun getShopSellData(map: HashMap<String, Any>,getDataType:Int): Observable<SellDataListResponse>? {
        if(getDataType==0){
            return opsService.getShopSaleData(map).compose(ServiceGenerator.uiScheduler())
                .compose(ServiceGenerator.transformerData())
        }else if(getDataType==1){
            return opsService.getAfterSaleData(map).compose(ServiceGenerator.uiScheduler())
                .compose(ServiceGenerator.transformerData())
        }
        return null
    }

    fun getUserList(map: HashMap<String, Any>): Observable<BaseListResponse<UserInfo>> {
        return opsService.getUserList(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getUserListByKeyword(map: HashMap<String, Any>): Observable<BaseListResponse<UserInfo>> {
        return opsService.getUserListByKeyWord(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getUserDetail(map: HashMap<String, Any>): Observable<UserDetail> {
        return opsService.getUserDetail(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getVehicleDetail(map: HashMap<String, Any>): Observable<VehicleDetailBean> {
        return opsService.getVehicleDetail(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getUserOrderList(map: HashMap<String, Any>): Observable<UserOrderResponse> {
        return opsService.getUserOrderList(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getUserPayList(map: HashMap<String, Any>): Observable<BaseListResponse<UserPaymentRecord>> {
        return opsService.getUserPayList(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getUserBatterySwapRecord(map: HashMap<String, Any>): Observable<PowerChangeBeanNew> {
        return opsService.getBatterySwapRecord(map).compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
//    仓管

    /**
     * 查询二维码sn
     */
    fun checkDeviceSn(deviceType: Int, deviceSn: String, warehouseNo: String): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["deviceType"] = deviceType //1电池 2车辆
        map["deviceSn"] = deviceSn
        map["warehouseNo"] = warehouseNo
        return opsService.checkDeviceSn(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 入库
     *
     * @param deviceSn
     * @param transferNo
     * @return
     */
    fun receiveDevice(deviceSn: String, transferNo: String): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["deviceSn"] = deviceSn
        map["transferNo"] = transferNo
        return opsService.receiveDevice(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 撤回出库
     *
     * @param deviceSn
     * @param transferNo
     * @return
     */
    fun withdrawDevice(deviceSn: String, transferNo: String): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["deviceSn"] = deviceSn
        map["transferNo"] = transferNo
        return opsService.withdrawDevice(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 扫码设备到盘点单
     *
     * @return
     */
    fun scanInventory(
        deviceSn: String,
        inventoryNo: String
    ): Observable<DeviceInventoryScanResult> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["deviceSn"] = deviceSn
        map["inventoryNo"] = inventoryNo
        return opsService.scanInventory(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取接收单位列表
     *
     * @param transferNo 出库编号
     * @return
     */
    fun queryOutTransportDetail(
        transferNo: String,
        page: Int,
        size: Int
    ): Observable<DeviceTransportDetail> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["transferNo"] = transferNo
        map["pageNum"] = page
        map["pageSize"] = size
        return opsService.queryOutTransportDetail(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 分页查询设备发出记录
     *
     * @param deviceType
     * @param status
     * @param page
     * @param size
     * @return
     */
    fun queryDeviceIssuePage(
        keyword: String?,
        status: Int?,
        page: Int,
        size: Int
    ): Observable<DeviceTransportResp> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        if (keyword != null) map["keyword"] = keyword
        if (status != null) map["status"] = status
        map["pageNum"] = page
        map["pageSize"] = size
        return opsService.queryDeviceIssuePage(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 编辑物流单号
     *
     * @param trackingNo     出库编号
     * @param trackingNumber 物流单号
     * @return
     */
    fun editTrackingNumber(trackingNo: String, trackingNumber: String): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["transferNo"] = trackingNo
        map["trackingNumber"] = trackingNumber
        return opsService.editTrackingNumber(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取出仓单位信息
     *
     * @return
     */
    fun queryMyWarehouseInfo(): Observable<WarehouseBean> {
        return opsService.queryMyWarehouseInfo()
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 分页查询设备发出记录
     *
     * @param deviceType
     * @param status
     * @param page
     * @param size
     * @return
     */
    fun queryDeviceReceivePage(
        keyword: String?,
        status: Int?,
        page: Int,
        size: Int
    ): Observable<DeviceTransportResp> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        if (status != null) map["status"] = status
        map["keyword"] = keyword ?: ""
        map["pageNum"] = page
        map["pageSize"] = size
        return opsService.queryDeviceReceivePage(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取接收单位列表
     *
     * @param warehouseNo   出仓仓库编号
     * @param warehouseType 接收仓库类型
     * @return
     */
    fun queryInWarehouseList(
        map: HashMap<String, Any>
    ): Observable<List<WarehouseBean>> {
        return opsService.queryInWarehouseList(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }


    /**
     * 新建设备发出单据
     *
     * @param inWarehouseNo  进仓仓库编号
     * @param outWarehouseNo 出仓仓库编号
     * @return
     */
    fun createIssue(
        inWarehouseNo: String,
        outWarehouseNo: String?,
        deviceType: Int,
        sns: List<String?>,
        trackingNumber: String
    ): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["inWarehouseNo"] = inWarehouseNo
        map["outWarehouseNo"] = outWarehouseNo ?: ""
        map["deviceType"] = deviceType
        map["sns"] = sns
        map["trackingNumber"] = trackingNumber
        return opsService.createIssue(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }


    /**
     * 分页查询设备盘点记录
     *
     * @param page
     * @param size
     * @return
     */
    fun queryDeviceInventoryPage(
        page: Int,
        size: Int,
        keyword: String?,
        status: Int?
    ): Observable<DeviceInventoryResp> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["keyword"] = keyword ?: ""
        map["pageNum"] = page
        map["pageSize"] = size
        if (status != null) {
            map["status"] = status
        }
        return opsService.queryDeviceInventoryPage(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取盘点仓库列表
     *
     * @return
     */
    fun queryInventoryWarehouseList(): Observable<List<WarehouseBean>> {
        return opsService.queryDeviceInventoryPage()
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 设备盘点详情信息
     *
     * @return
     */
    fun queryInventory(
        inventoryNo: String,
        page: Int,
        size: Int
    ): Observable<DeviceInventoryDetail> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["inventoryNo"] = inventoryNo
        map["pageNum"] = page
        map["pageSize"] = size
        return opsService.queryInventoryDetail(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 作废盘点单
     *
     * @return
     */
    fun evokeInventory(inventoryNo: String): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["inventoryNo"] = inventoryNo
        return opsService.revokeInventory(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }


    /**
     * 开始盘点
     *
     * @return
     */
    fun startInventory(deviceTyp: Int, warehouseNo: String): Observable<DeviceInventoryDetail> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["deviceType"] = deviceTyp
        map["warehouseNo"] = warehouseNo
        return opsService.startInventory(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 完成盘点单
     *
     * @return
     */
    fun completeInventory(inventoryNo: String): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["inventoryNo"] = inventoryNo
        return opsService.completeInventory(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

//    /**
//     * 工作台工单统计
//     */
//    fun queryWorkOrderStat(): Observable<WorkOrderStat> {
//        return opsService.queryWorkOrderStat()
//            .compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }

    /**
     * 上传道路救援图片
     */
    fun uploadRoadSideImage(part: MultipartBody.Part?): Observable<String> {
        return opsService.uploadRoadSideImage(part)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    //处理道路救援结果
    fun dealRoadSideOrder(
        imgList: String,
        processDesc: String,
        result: Int,
        sheetNo: String
    ): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["imgList"] = imgList
        map["opResponse"] = processDesc
        map["result"] = result
        map["recordNo"] = sheetNo
        map["payFlag"]=0
        return opsService.dealRoadSide(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 查询道路救援列表
     *
     * @param sheetStatus
     * @param keyword
     * @param page
     * @param size
     * @return
     */
    fun queryRoadSideList(
        status: Int?,
        page: Int,
        size: Int
    ): Observable<RoadSideListResp> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        if (status != null) {
            map["status"] = status
        }
        map["pageNum"] = page
        map["pageSize"] = size
        return opsService.queryRoadSideList(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

//    /**
//     * 查询工单列表
//     *
//     * @param sheetStatus
//     * @param keyword
//     * @param page
//     * @param size
//     * @return
//     */
//    fun queryWorkOrderList(
//        sheetStatus: Int?,
//        keyword: String?,
//        page: Int,
//        size: Int
//    ): Observable<WorkOrderListResp> {
//        val map: MutableMap<String, Any> = java.util.HashMap()
//        if (sheetStatus != null) map["sheetStatus"] = sheetStatus
//        if (keyword != null) map["keyword"] = keyword
//        map["pageNum"] = page
//        map["pageSize"] = size
//        return opsService.queryWorkOrderList(map)
//            .compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }

    /**
     * 查询道路救援工单详细
     *
     * @param sheetNo
     * @return
     */
    fun queryRoadOrderDetail(sheetNo: String): Observable<RoadSideOrderDetail> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["recordNo"] = sheetNo
        return opsService.queryRoadOrderDetail(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }


    /**
     * 获取手机区号
     */
    fun getAreaCodeConfig(): Observable<AreaCountryResp> {
        return opsService.getAreaCodeConfig()
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 发送验证码
     */
    fun sendSms(smsMap: java.util.HashMap<String, Any>): Observable<Any> {
        return opsService.sendSms(smsMap)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 注册
     */
    fun offlineRegister(data: List<MultipartBody.Part>): Observable<Any> {
        return opsService.offlineRegister(data)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 查询二维码sn
     */
    fun getDeviceSn(type: Int?, content: String): Observable<String> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        if (type != null) map["type"] = type //0：电池，1：电柜，2：车辆

        map["content"] = content
        return opsService.getDeviceSn(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 查询车辆保养预约
     *
     * @param sn
     * @return
     */
    fun queryAppointment(sn: String): Observable<BookMaintenanceBean> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["code"] = sn
        return opsService.queryAppointment(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取车辆保养记录
     */
    fun getCarMaintenanceRecordList(
        pageNum: Int,
        pageSize: Int,
        sn: String?
    ): Observable<DeviceMaintenanceResponse> {
        return opsService.getDeviceMaintenanceRecordList(
            pageNum,
            pageSize,
            sn
        )
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 分页查询电摩维修记录列表
     *
     * @param page
     * @param size
     * @return
     */
    fun queryRepairRecordList(sn: String, page: Int, size: Int): Observable<VehicleRepairListResp> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["sn"] = sn
        map["pageNum"] = page
        map["pageSize"] = size
        return opsService.queryRepairRecordList(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 分页查询电摩维修记录列表
     *
     * @param page
     * @param size
     * @return
     */
    fun addRepairRecord(appointmentNo: String, note: String): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["appointmentNo"] = appointmentNo
        map["maintenanceNote"] = note
        return opsService.addRepairRecord(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getBatteryFixRecordList(
        pageNum: Int,
        pageSize: Int,
        sn: String?
    ): Observable<DeviceFixRecordResponse> {
        return opsService.getBatteryFixRecordList(
            pageNum,
            pageSize,
            sn
        )
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getCarFixRecordList(
        pageNum: Int,
        pageSize: Int,
        sn: String?
    ): Observable<DeviceFixRecordResponse> {
        return opsService.getCarFixRecordList(
            pageNum,
            pageSize,
            sn
        )
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * google 路线规划
     * @param origin
     * @param destination
     * @param avoid
     * @param mode
     * @param key
     * @return
     */
    fun getPolyLine(
        origin: String?,
        destination: String?,
        avoid: String?,
        mode: String?,
        key: String?
    ): Observable<PolylinePointsBean> {
        return opsService.getPolyLine(origin, destination, avoid, mode, key)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

//    fun uploadProof(url: String, type: Int): Observable<String> {
//        val map: MutableMap<String, Any> = java.util.HashMap()
//        map["url"] = url
//        map["type"] = type
//        return opsService.uploadProof(map)
//            .compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }

    /**
     * 根据设备号获取租赁信息
     */
    fun getRentInfo(deviceSn: String): Observable<RentDeviceInfoBean> {
        return opsService.getRentInfo(deviceSn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 根据用户id，获取分期缴纳信息
     */
    fun getInstallmentInfo(cardNum: String): Observable<InstallmentPaymentResponse> {
        return opsService.getInstallmentPayInfo(cardNum)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 分期缴纳
     */
    fun payPerido(map: HashMap<String, Any>): Observable<Any> {
        return opsService.payPeriod(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 根据用户id获取换电绑定信息
     */
    fun getSwapBindInfo(userSn: String): Observable<SwapBindInfo> {
        return opsService.getSwapBindInfo(userSn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取可以绑定的换电套餐
     */
    fun getSwapPackInfo(
        batteryType: String,
        carType: String,
        minDay: Int?
    ): Observable<List<Pack>?> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["batteryType"] = batteryType
        map["carType"] = carType
        return opsService.getSwapPackInfo(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 根据用户id获取押金退还信息
     */
    fun getDepositRefundInfo(userSn: String): Observable<DepositRefundInfoBean> {
        return opsService.getDepositRefundInfo(userSn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 根据用户id获取押金退还信息
     */
    fun refundDeposit(map: HashMap<String, Any>): Observable<Any> {
        return opsService.refundDeposit(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
//
//    /**
//     * 上传凭证文件
//     */
//    fun uploadProof(part: MultipartBody.Part): Observable<String> {
//        return opsService.uploadProof(part).compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }


    /**
     * 支付道路救援
     */
    fun payRoadSide(
        attachment: String,
        fee: String,
        payType: Int,
        recordNo: String
    ): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["attachment"] = attachment
        map["fee"] = fee
        map["payType"] = payType
        map["recordNo"] = recordNo
        return opsService.payRoadSide(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 产生车辆保养订单
     */
    fun genMaintainRecord(
        attachment: String,
        cardNum: String,
        paySource: Int,
        price: String,
        remark: String,
        vehicleSn: String
    ): Observable<Any> {
        val map: MutableMap<String, Any> = java.util.HashMap()
        map["attachment"] = attachment
        map["cardNum"] = cardNum
        map["paySource"] = paySource
        map["price"] = price
        map["remark"] = remark
        map["vehicleSn"] = vehicleSn
        return opsService.genMaintainRecord(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getMsgList(map: HashMap<String, Any>): Observable<MessageListResponse> {
        return opsService.getMsgList(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun setMsgRead(map: HashMap<String, Any>): Observable<Any> {
        return opsService.setMsgRead(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取我的未读消息数
     */
    fun getUnReadMsgCount(): Observable<Int> {
        return opsService.getUnReadMsgCount()
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun openCabinBackDoor(sn: String): Observable<Any?> {
        val hashMap = HashMap<String, Any>()
        hashMap["devId"] = sn
        return opsService.openCabinBackDoor(hashMap)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun openCabinDoorNew(portNo: Int, stationPid: String, type: Int): Observable<Any> {
        val map: MutableMap<String, Any> = HashMap()
        map["portNo"] = portNo
        map["stationPid"] = stationPid
        map["type"] = type
        return opsService.openCabinDoorNew(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getCabinList(sn: String?): Observable<List<Cabin>> {
        return opsService.getCabinList(sn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getOpsAndMaintenaceList(
        pageNum: Int,
        pageSize: Int,
        phone: String?,
        userName: String?,
        platform: Int,
        enabled: Int
    ): Observable<OpsAndMaintenaceBean> {
        return opsService.getOpsAndMaintenaceList(pageNum, pageSize, phone, userName, platform, enabled)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun addPersonLiable(
        mCabinetSN: String,
        details: Array<SelectedPersonLiableBean?>
    ): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["sn"] = mCabinetSN
        map["details"] = details
        return opsService.addPersonLiable(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun updateCabinetImage(pid: String?, parts: List<MultipartBody.Part?>?): Observable<List<String>> {
        return opsService.updateCabinetImage(pid, parts)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun updateCabinetImage(part: MultipartBody.Part?): Observable<String> {
        return opsService.updateCabinetImage(part)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun modifyCabinetInfo(
        sn: String?,
        address: String,
        location: String,
        imgs: String,
        label: String
    ): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["address"] = address
        map["location"] = location
        map["imgs"] = imgs
        map["label"] = label
        return opsService.modifyCabinetInfo(sn, map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getCabinetBaseInfo(sn: String?): Observable<CabinetDetailBaseInfoBean> {
        return opsService.getCabinetBaseInfo(sn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getCurrentAndPoints(): Observable<List<CurrentPointBean>> {
        return opsService.getCurrentAndPoints()
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取主柜副柜信息
     */
    fun getDeputyCabinet(pid: String?): Observable<List<DeputyCabinetBean>> {
        return opsService.getDeputyCabinet(pid)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getFaultList(
        pageNum: Int,
        pageSize: Int,
        sn: String?,
        port: Int,
        nID: String?
    ): Observable<CabinFaultBean> {
        return opsService.getFaultList(pageNum, pageSize, sn, port /*,nID*/)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun openCabinDoor(pID: String, port: Int, nID: String): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["pID"] = pID
        map["num"] = port
        map["nID"] = nID
        return opsService.openCabinDoor(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun setChargingCurrent(port: Int, electricCurrent: Double, pID: String): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["port"] = port
        map["electricCurrent"] = electricCurrent
        map["pID"] = pID
        return opsService.setChargingCurrent(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun setCabinPorts(
        pID: String,
        port: Int,
        enable: Int,
        remark: String,
        reasonCode: String,
        nID: String
    ): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["pID"] = pID
        map["port"] = port
        map["enable"] = enable
        map["remark"] = remark
        map["reasonCode"] = reasonCode
        map["nID"] = nID
        return opsService.setCabinPorts(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getForbiddenStorageReason(): Observable<List<ForbiddenReasonBean>> {
        return opsService.forbiddenStorageReason
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getLayouCabinetInfo(
        sn: String?,
        pageNum: Int,
        pageSize: Int
    ): Observable<LayoutCabinetInfoBean> {
        return opsService.getLayouCabinetInfo(sn, pageNum, pageSize)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getCabinetSettingInfo(pid: String?): Observable<SettingInfoBean> {
        return opsService.getCabinetSettingInfo(pid)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun updateCabinetSettingInfo(pid: String?, bean: SettingInfoBean?): Observable<String> {
        return opsService.updateCabinetSettingInfo(pid, bean)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getTemporyPSW(stationId: String?): Observable<TemporyPSWbean> {
        return opsService.getTemporyPSW(stationId)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun restartCompleteMachine(pID: String, shutDown: Int, type: Int): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["pID"] = pID
        map["shutDown"] = shutDown //1 关机  其他重启
        map["type"] = type //1-安卓机  2-充电器   3-整机
        return opsService.restartCompleteMachine(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun shutDaownMachine(pID: String, sleep: Int): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["pID"] = pID
        map["sleep"] = sleep //“sleep”:0,   //0表示关机后不重启，1-60表示延迟x秒重启
        return opsService.shutDaownMachine(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun openElectronicLock(pID: String, nID: String): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["pID"] = pID
        map["nID"] = nID
        return opsService.openElectronicLock(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getCabinetVersion(pID: String?): Observable<CabinetVersionBean> {
        return opsService.getCabinetVersion(pID)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getLocalStatus(pID: String?): Observable<String> {
        return opsService.getLocalStatus(pID)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
//    fun unshelve(pid: String, content: String): Observable<Int> {
//        val map: MutableMap<String, Any> = HashMap()
//        map["sn"] = pid
//        map["operator"] = ""
//        map["reason"] = content
//        /*Map<String, Object> map = new HashMap<>();
//      map.put("pid", pid);
//      map.put("operator", "");
//      map.put("content", content);*/
//        return opsService.unshelve(map)
//            .compose(ServiceGenerator.uiScheduler())
//            .compose(ServiceGenerator.transformerData())
//    }

    fun unshelveNew(sn: String, content: String): Observable<Any> {
        val map: MutableMap<String, Any> = HashMap()
        map["sn"] = sn
        map["reason"] = content
//        map["storeStatus"] = storageStatusStr
        return opsService.unshelveNew(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getStationSource(source: String?, code: String?): Observable<NewCabinetBean> {
        return opsService.getStationSource(source, code)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 增加授权
     */
    fun authAdd(map: Map<String?, Any?>?): Observable<Any> {
        return opsService.authAdd(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取柜子锁id
     */
    fun getLockIdBySn(sn: String?): Observable<SNBean> {
        return opsService.getLockIdBySn(sn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun blueToothEnOrDecrypt(map: Map<String?, Any?>?): Observable<String> {
        return opsService.blueToothEnOrDecrypt(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取用户唯一编码
     */
    fun getUidByPhone(phone: String?): Observable<Long> {
        return opsService.getUidByPhone(phone)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun stationPermission(
        sn: String,
        accountNo: String,
        beginTime: String,
        endTime: String
    ): Observable<Any> {
        val map: MutableMap<String, Any> = HashMap()
        map["accountNo"] = accountNo
        map["sn"] = sn
        map["beginTime"] = beginTime
        map["endTime"] = endTime
        return opsService.stationPermission(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getUserAuthorizationListData(
        sn: String,
        bePermission: String,
        page: Int,
        size: Int
    ): Observable<AuthorizationRecordList> {
        val map: MutableMap<String, Any> = HashMap()
        map["pageNum"] = page
        map["pageSize"] = size
        map["bePermission"] = bePermission
        map["sn"] = sn
        return opsService.getAuthorizationRecordListData(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun cancelPermission(sn: String, permissionId: Int): Observable<Any> {
        val map: MutableMap<String, Any> = HashMap()
        map["sn"] = sn
        map["permissionId"] = permissionId
        return opsService.cancelPermission(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getCabinetAuthorizationListSearchData(
        sn: String,
        page: Int,
        size: Int
    ): Observable<CabinetAuthorizationList> {
        val map: MutableMap<String, Any> = HashMap()
        map["pageNum"] = page
        map["pageSize"] = size
        map["sn"] = sn
        return opsService.getCabinetAuthorizationListSearchData(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getUserAuthorizationListSearchData(
        sn: String,
        keyword: String,
        page: Int,
        size: Int
    ): Observable<UserAuthorizationList> {
        val map: MutableMap<String, Any> = HashMap()
        map["pageNum"] = page
        map["pageSize"] = size
        map["keyword"] = keyword
        map["sn"] = sn
        return opsService.getUserAuthorizationListSearchData(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 查询电柜蓝牙秘钥
     *
     * @param sn 电柜SN
     * @return
     */
    fun getStationSecretKey(sn: String?): Observable<String> {
        return opsService.getStationSecretKey(sn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun configCabinet(
        startTime: String,
        stopTime: String,
        stationPid: String,
        type: Int,
        value: Int
    ): Observable<Any> {
        val map: MutableMap<String, Any> = HashMap()
        map["startTime"] = startTime
        map["stopTime"] = stopTime
        map["stationPid"] = stationPid
        map["type"] = type
        map["value"] = value
        return opsService.configCabinet(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun putawayCabinetNew(
        pid: String,
        sn: String,
        imgs: String,
        latitude: Double,
        longitude: Double,
        standardName: String,  //电柜名称
        stationModel: String,  //电柜型号
        standardSwapTime: Int,  //换电次数标准
        storeNum: Int,  //仓数规格
        label: Int,  //落柜区域
        address: String
    ): Observable<Any> {
        val map: MutableMap<String, Any> = HashMap()
        map["pid"] = pid
        map["sn"] = sn
        map["latitude"] = latitude
        map["longitude"] = longitude
        map["name"] = standardName //电柜名称
        map["model"] = stationModel //电柜型号
        map["label"] = label
        map["imgList"] = imgs
        map["standardSwapTime"] = standardSwapTime //换电次数标准
        map["storeNum"] = storeNum //仓数规格
        map["address"] = address
        return opsService.putawayCabinetNew(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getCityCodeList(): Observable<List<CityCode>> {
        return opsService.getCityCodeList()
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun putawayCabinet(
        pid: String,
        sn: String,
        cityCode: String,
        latitude: Double,
        longitude: Double,
        chargingCurrent: Double,
        standardName: String,
        stationModel: String,
        cameraSn: String,
        cameraCode: String,
        maxC: String?,
        label: String,
        imgs: String,
        name: String
    ): Observable<String> {
        val map: MutableMap<String, Any> = HashMap()
        map["pid"] = pid
        map["sn"] = sn
        map["cityCode"] = cityCode //城市Code
        map["latitude"] = latitude
        map["longitude"] = longitude
        map["name"] = standardName //电柜名称
        map["model"] = stationModel //电柜型号
        //        map.put("chargingCurrent", chargingCurrent);
        map["cameraSn"] = cameraSn
        map["cameraCode"] = cameraCode
        //        map.put("maxC", maxC);
        map["label"] = label
        map["imgList"] = imgs
        map["operator"] = ""
        map["address"] = name

        /*Map<String, Object> map = new HashMap<>();
   map.put("pid", pid);
   map.put("sn", sn);
   map.put("cityCode", cityCode);
   map.put("latitude", latitude);
   map.put("longitude", longitude);
   map.put("standardName", standardName);
   map.put("stationModel", stationModel);
//        map.put("chargingCurrent", chargingCurrent);
   map.put("cameraSn", cameraSn);
   map.put("cameraCode", cameraCode);
//        map.put("maxC", maxC);
   map.put("label", label);
   map.put("imgs", imgs);
   map.put("operator", "");
   map.put("name", name);*/
        return opsService.putawayCabinet(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun checkCabinetAndCameraBound(
        cameraSn: String?,
        sn: String?
    ): Observable<CabinetAndCameraBoundBean> {
        return opsService.checkCabinetAndCameraBound(cameraSn, sn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * @param oldCameraSn 校验接口status=2 时候返回的sn
     * @param newCameraSn 输入的摄像头sn
     * @param oldSn       校验接口status=1 时候返回的sn
     * @param newSn       输入的柜子sn
     * @param cameraCode  摄像头
     * @return
     */
    fun unbindCabinetAndCamera(
        oldCameraSn: String, newCameraSn: String,
        oldSn: String, newSn: String, cameraCode: String
    ): Observable<String> {
        val map: MutableMap<String, String> = HashMap()
        map["oldCameraSn"] = oldCameraSn
        map["newCameraSn"] = newCameraSn
        map["oldSn"] = oldSn
        map["newSn"] = newSn
        map["cameraCode"] = cameraCode
        return opsService.unbindCabinetAndCamera(map)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }
    fun getCabinetTime(pID: String?): Observable<Long> {
        return opsService.getCabinetTime(pID)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    fun getCabinFixRecordList(
        pageNum: Int,
        pageSize: Int,
        sn: String?
    ): Observable<DeviceFixRecordResponse> {
        return opsService.getCabinFixRecordList(pageNum, pageSize, sn)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }


    /**
     * 下发车辆指令
     */
    fun sendCommandToCar(hashMap: HashMap<String, Any>): Observable<Any> {
        return opsService.sendCommandToCar(hashMap)
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 获取VCU软件版本列表
     */
    fun getVcuVersionList(): Observable<List<VcuVersion>> {
        return opsService.getVcuVersionList()
            .compose(ServiceGenerator.uiScheduler())
            .compose(ServiceGenerator.transformerData())
    }

    /**
     * 下载文件
     */
    fun downloadFile(
        url: String,
        savePath: String,
        start: Long,
        filename: String?
    ): Observable<DownProgress> {
        return opsService.downloadFile(url)
            .compose(ServiceGenerator.transformerFileDown<ResponseBody>(start, savePath, filename))
    }
}

