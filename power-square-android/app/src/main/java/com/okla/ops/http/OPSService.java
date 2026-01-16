package com.okla.ops.http;

import com.base.common.net.BaseListResponse;
import com.base.common.net.BaseResponse;
import com.okla.ops.beans.AreaCountryResp;
import com.okla.ops.beans.AuthorizationRecordList;
import com.okla.ops.beans.BatterOrVehicleInfo;
import com.okla.ops.beans.Battery;
import com.okla.ops.beans.BatteryDetail;
import com.okla.ops.beans.BatterySwapRecord;
import com.okla.ops.beans.BatteryTransfer;
import com.okla.ops.beans.BatteryType;
import com.okla.ops.beans.BookMaintenanceBean;
import com.okla.ops.beans.Cabin;
import com.okla.ops.beans.CabinFaultBean;
import com.okla.ops.beans.CabinetAndCameraBoundBean;
import com.okla.ops.beans.CabinetAuthorizationList;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.beans.CabinetVersionBean;
import com.okla.ops.beans.CarType;
import com.okla.ops.beans.ChargeHistory;
import com.okla.ops.beans.City;
import com.okla.ops.beans.CityCode;
import com.okla.ops.beans.CurrentPointBean;
import com.okla.ops.beans.DeputyCabinetBean;
import com.okla.ops.beans.DeviceFixRecordResponse;
import com.okla.ops.beans.DeviceInventoryDetail;
import com.okla.ops.beans.DeviceInventoryResp;
import com.okla.ops.beans.DeviceInventoryScanResult;
import com.okla.ops.beans.DeviceMaintenanceResponse;
import com.okla.ops.beans.DeviceTransportDetail;
import com.okla.ops.beans.DeviceTransportResp;
import com.okla.ops.beans.ForbiddenReasonBean;
import com.okla.ops.beans.InstallmentPaymentResponse;
import com.okla.ops.beans.Insurance;
import com.okla.ops.beans.LayoutCabinetInfoBean;
import com.okla.ops.beans.MessageListResponse;
import com.okla.ops.beans.NearByVehicle;
import com.okla.ops.beans.NewCabinetBean;
import com.okla.ops.beans.OpsAndMaintenaceBean;
import com.okla.ops.beans.PaymentOrder;
import com.okla.ops.beans.PaymentPlan;
import com.okla.ops.beans.Personal;
import com.okla.ops.beans.PolylinePoints;
import com.okla.ops.beans.PolylinePointsBean;
import com.okla.ops.beans.PowerChangeBeanNew;
import com.okla.ops.beans.PurchasingUser;
import com.okla.ops.beans.RoadSideListResp;
import com.okla.ops.beans.SNBean;
import com.okla.ops.beans.SaleSumPageData;
import com.okla.ops.beans.SalesBarData;
import com.okla.ops.beans.SellDataListResponse;
import com.okla.ops.beans.ServicePlanInfo;
import com.okla.ops.beans.SettingInfoBean;
import com.okla.ops.beans.Shop;
import com.okla.ops.beans.Shop1;
import com.okla.ops.beans.Shop1Num;
import com.okla.ops.beans.ShopDetail;
import com.okla.ops.beans.ShopPaymentMethod;
import com.okla.ops.beans.StaticBatteryMile;
import com.okla.ops.beans.StaticSaleNum;
import com.okla.ops.beans.StaticSaleShop;
import com.okla.ops.beans.StaticSaleShopDetail;
import com.okla.ops.beans.StationType;
import com.okla.ops.beans.Stock;
import com.okla.ops.beans.StockDetail;
import com.okla.ops.beans.StockNum;
import com.okla.ops.beans.TemporyPSWbean;
import com.okla.ops.beans.User;
import com.okla.ops.beans.UserAuthorizationList;
import com.okla.ops.beans.UserDetail;
import com.okla.ops.beans.UserInfo;
import com.okla.ops.beans.UserPaymentRecord;
import com.okla.ops.beans.VehicleDetailBean;
import com.okla.ops.beans.VehicleRepairListResp;
import com.okla.ops.beans.WarehouseBean;
import com.okla.ops.http.net.TotalListResponse;
import com.okla.ops.views.workbench.SaleData;
import com.okla.ops.views.workbench.qm.RoadSideOrderDetail;
import com.okla.ops.views.workbench.sales.depositrefund.DepositRefundInfoBean;
import com.okla.ops.views.workbench.sales.rentbind.Pack;
import com.okla.ops.views.workbench.sales.rentbind.RentDeviceInfoBean;
import com.okla.ops.views.workbench.sales.swapbind.SwapBindInfo;
import com.okla.ops.views.workbench.user.UserOrderResponse;
import com.okla.ops.views.workbench.vcu.VcuVersion;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.reactivex.Observable;
import okhttp3.MultipartBody;
import okhttp3.ResponseBody;
import retrofit2.http.Body;
import retrofit2.http.FieldMap;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.PUT;
import retrofit2.http.Part;
import retrofit2.http.Path;
import retrofit2.http.Query;
import retrofit2.http.QueryMap;
import retrofit2.http.Streaming;
import retrofit2.http.Url;

public interface OPSService {

    /**
     * 规划路径数据
     */
    @Headers("Content-Type: application/json")
    @GET("maps/api/directions/json")
    Observable<PolylinePoints> getRoutes(@QueryMap Map<String, Object> map);

    //查询城市列表
    @Headers("Content-Type: application/json")
    @GET("admin/tenant/city/list")
    Observable<BaseResponse<List<City>>> getCityList();

    //登录
    @Headers("Content-Type: application/json")
    @POST("admin/sys/user/login")
    Observable<BaseResponse<User>> login(@Body Object body);

    //刷新TOKEN
    @Headers("Content-Type: application/json")
    @POST("admin/sys/account/refreshToken")
    Observable<BaseResponse<User>> refreshToken();

    //登出
    @Headers("Content-Type: application/json")
    @POST("admin/sys/user/logout")
    Observable<BaseResponse<Object>> logout();

    //获取个人信息
    @Headers("Content-Type: application/json")
    @GET("admin/sys/account/detail")
    Observable<BaseResponse<Personal>> getPersonalInfo();

    //修改密码
    @Headers("Content-Type: application/json")
    @POST("admin/sys/account/changePassword")
    Observable<BaseResponse<Object>> changePSWNew(@Body Object body);

    //修改昵称
    @Headers("Content-Type: application/json")
    @POST("admin/sys/account/changeNickName")
    Observable<BaseResponse<Object>> editNickname(@Body Object body);

    //上传头像
    @Multipart
    @POST("admin/sys/account/changeAvatar")
    Observable<BaseResponse<Object>> editAvatar(@Part MultipartBody.Part file);

    //获取电池型号列表
    @Headers("Content-Type: application/json")
    @GET("admin/battery/getModelList")
    Observable<BaseResponse<List<BatteryType>>> getBatteryTypeList();

    //录入电池
    @Headers("Content-Type: application/json")
    @POST("admin/battery/register")
    Observable<BaseResponse<Object>> registerBattery(@Body Object body);

    //获取电柜型号列表
    @Headers("Content-Type: application/json")
    @GET("admin/station/getModelList")
    Observable<BaseResponse<List<StationType>>> getStationTypeList();
    //录入电柜
    @Headers("Content-Type: application/json")
    @POST("admin/station/register")
    Observable<BaseResponse<Object>> registerStation(@Body Object body);

    //获取车辆型号列表
    @Headers("Content-Type: application/json")
    @GET("admin/vehicle/getModelList")
    Observable<BaseResponse<List<CarType>>> getCarTypeList();

    //录入车辆
    @Headers("Content-Type: application/json")
    @POST("admin/vehicle/register")
    Observable<BaseResponse<Object>> registerCar(@Body Object body);

    //    //根据Agent名查询agent列表
//    @Headers("Content-Type: application/json")
//    @GET("admin/battery/queryAgentByName")
//    Observable<BaseResponse<List<Agent>>> getAgentList(@QueryMap Map<String, Object> map);
//
//    //电池出货-查询电池信息
//    @Headers("Content-Type: application/json")
//    @GET("admin/transfer/checkDeviceSn")
//    Observable<BaseResponse<Battery>> queryShipBatteryBySn(@QueryMap Map<String, Object> map);
//
//    //电池出货
//    @Headers("Content-Type: application/json")
//    @POST("admin/battery/ship")
//    Observable<BaseResponse<String>> shipBattery(@Body Object body);
//
//    //车辆出货-查询车辆信息
//    @Headers("Content-Type: application/json")
//    @GET("admin/transfer/checkDeviceSn")
//    Observable<BaseResponse<Car>> queryShipCarBySn(@QueryMap Map<String, Object> map);
//
//    //车辆出货
//    @Headers("Content-Type: application/json")
//    @POST("admin/battery/ship")
//    Observable<BaseResponse<String>> shipCar(@Body Object body);
//
//    //销售电池-查询电池信息
//    @Headers("Content-Type: application/json")
//    @GET("admin/sell/querySellBatteryBySn")
//    Observable<BaseResponse<SellBattery>> querySellBatteryBySn(@QueryMap Map<String, Object> map);
//

    //获取工作台销售统计信息
    @Headers("Content-Type: application/json")
    @GET("admin/trade/staticMonthlyIncome")
    Observable<BaseResponse<SaleData>> getSaleData();

    //查询销售设备信息
    @Headers("Content-Type: application/json")
    @GET("admin/trade/querySaleDeviceInfo")
    Observable<BaseResponse<BatterOrVehicleInfo>> querySaleDeviceInfo(@QueryMap Map<String, Object> map);

    //分页查询销售套餐信息
    @Headers("Content-Type: application/json")
    @GET("admin/trade/queryInfoPage")
    Observable<BaseResponse<ServicePlanInfo>> queryServicePlanByName(@QueryMap Map<String, Object> map);

    /**
     * 分期方案
     *
     * @param map
     * @return
     */
    @Headers("Content-Type: application/json")
    @GET("admin/trade/queryPaymentPlanList")
    Observable<BaseResponse<List<PaymentPlan>>> getPaymantPlanList(@QueryMap Map<String, Object> map);


    //销售设备绑定-查询用户信息
    @Headers("Content-Type: application/json")
    @GET("admin/trade/queryUserForSell")
    Observable<BaseResponse<PurchasingUser>> queryUserForSell(@QueryMap Map<String, Object> map);


    //售後綁定-查詢用戶信息
    @Headers("Content-Type: application/json")
    @GET("admin/op/queryUserForBindOrder")
    Observable<BaseResponse<UserDetail>> queryUserForAfterSaleBind(@QueryMap Map<String, Object> map);

    //租赁设备绑定-查询用户信息
    @Headers("Content-Type: application/json")
    @GET("admin/trade/queryUserForRent")
    Observable<BaseResponse<PurchasingUser>> queryUserForRent(@QueryMap Map<String, Object> map);


    //換電綁定绑定-生產訂單
    @Headers("Content-Type: application/json")
    @POST("admin/trade/genSwapOrder")
    Observable<BaseResponse<Object>> createSwapBindOrder(@Body Object body);

    @Headers("Content-Type: application/json")
    @GET("admin/trade/queryShopPayConfig")
    Observable<BaseResponse<ShopPaymentMethod>> getShopPaymentMethod(@QueryMap Map<String, Object> map);

    //上传身份证件图片
    @Multipart
    @POST("admin/sell/uploadCardImg")
    Observable<BaseResponse<String>> uploadCardImg(@Part MultipartBody.Part file);

    //上传分期缴纳凭证
    @Multipart
    @POST("admin/trade/uploadAttachment")
    Observable<BaseResponse<String>> uploadAttachment(@Part MultipartBody.Part file);

    //用户模块-上传凭证
    @Multipart
    @POST("admin/user/uploadAttachment")
    Observable<BaseResponse<String>> userUploadAttachment(@Part MultipartBody.Part file);

    //用户查询模块-付款确认
    @Headers("Content-Type: application/json")
    @POST("admin/trade/confirmPayOrder")
    Observable<BaseResponse<Object>> userConfirmPayOrder(@Body Object body);

    //电池出货
    @Headers("Content-Type: application/json")
    @POST("admin/battery/sell")
    Observable<BaseResponse<Object>> sellBattery(@Body Object body);

    //销售绑定-生成订单
    @Headers("Content-Type: application/json")
    @POST("admin/trade/sellDevice")
    Observable<BaseResponse<Object>> sellBind(@Body Object body);


    //租赁绑定-生成订单
    @Headers("Content-Type: application/json")
    @POST("admin/trade/rentDevice")
    Observable<BaseResponse<Object>> rentBind(@Body Object body);

    //地图车辆监控信息
    @Headers("Content-Type: application/json")
    @GET("admin/monitor/vehicle/monitorOnMap")
    Observable<BaseResponse<List<NearByVehicle>>> getNearByVehicleList(@QueryMap Map<String, Object> map);


    @Headers("Content-Type: application/json")
    @GET("admin/monitor/vehicle/queryRiderPhone")
    Observable<BaseResponse<Object>> getPhoneByCardNum(@Query("cardNum") String cardNum);

    //创建门店
    @Headers("Content-Type: application/json")
    @POST("admin/shop/create")
    Observable<BaseResponse<Object>> createShop(@Body Object body);

    //查询库存汇总信息
    @Headers("Content-Type: application/json")
    @GET("admin/shop/stock/index")
    Observable<BaseResponse<StockNum>> getStockNum(@QueryMap Map<String, Object> map);

    //查询库存列表
    @Headers("Content-Type: application/json")
    @GET("admin/shop/stock/queryList")
    Observable<BaseResponse<BaseListResponse<Stock>>> getStockList(@QueryMap Map<String, Object> map);

    //根据shop名查询shop列表
    @Headers("Content-Type: application/json")
    @GET("admin/shop/stock/queryShopByName")
    Observable<BaseResponse<List<Shop>>> queryShopByName(@QueryMap Map<String, Object> map);

    //电池调拨-查询电池信息
    @Headers("Content-Type: application/json")
    @GET("admin/shop/stock/queryTransferBatteryBySn")
    Observable<BaseResponse<BatteryTransfer>> queryTransferBatteryBySn(@QueryMap Map<String, Object> map);

    //创建电池调拨单据
    @Headers("Content-Type: application/json")
    @POST("admin/shop/stock/transfer")
    Observable<BaseResponse<Object>> stockTransfer(@Body Object body);

    //查询库存详情
    @Headers("Content-Type: application/json")
    @GET("admin/shop/stock/queryDetail")
    Observable<BaseResponse<StockDetail>> queryStockDetailByTransferNo(@QueryMap Map<String, Object> map);

    //查询门店首页汇总信息
    @Headers("Content-Type: application/json")
    @GET("admin/shop/index")
    Observable<BaseResponse<Shop1Num>> getShopNum(@QueryMap Map<String, Object> map);

    //查询商店列表
    @Headers("Content-Type: application/json")
    @GET("admin/shop/queryList")
    Observable<BaseResponse<BaseListResponse<Shop1>>> getShopList(@QueryMap Map<String, Object> map);

    //查询门店详情
    @Headers("Content-Type: application/json")
    @GET("admin/shop/queryDetail")
    Observable<BaseResponse<ShopDetail>> queryShopDetail(@QueryMap Map<String, Object> map);

    //启用/禁用门店
    @Headers("Content-Type: application/json")
    @POST("admin/shop/turn")
    Observable<BaseResponse<Object>> turnShopStatus(@Body Object body);

    //编辑门店
    @Headers("Content-Type: application/json")
    @POST("admin/shop/edit")
    Observable<BaseResponse<Object>> editShop(@Body Object body);

    //查询电池设备
    @Headers("Content-Type: application/json")
    @GET("admin/battery/searchBySn")
    Observable<BaseResponse<BatteryDetail>> searchBatteryBySn(@QueryMap Map<String, Object> map);

    //打开/关闭电池放电开关
    @POST("admin/battery/turnDischargeStatus")
    @FormUrlEncoded
    Observable<BaseResponse<Object>> turnDischargeStatus(@FieldMap Map<String, Object> map);

    //分页查询设备充电记录
    @Headers("Content-Type: application/json")
    @GET("admin/battery/queryDeviceChargeRecord")
    Observable<BaseResponse<BaseListResponse<ChargeHistory>>> queryDeviceChargeRecord(@QueryMap Map<String, Object> map);

    //查询电池设备
    @Headers("Content-Type: application/json")
    @GET("admin/battery/staticBatteryMile")
    Observable<BaseResponse<StaticBatteryMile>> staticBatteryMile(@QueryMap Map<String, Object> map);

    //通过订单号查询待确认信息
    @Headers("Content-Type: application/json")
    @GET("admin/payment/queryOrderByNo")
    Observable<BaseResponse<PaymentOrder>> queryOrderByNo(@QueryMap Map<String, Object> map);

    //收款审核
    @Headers("Content-Type: application/json")
    @POST("admin/payment/confirm")
    Observable<BaseResponse<Object>> confirmPayment(@Body Object body);

    //通过订单号查询待确认信息
    @Headers("Content-Type: application/json")
    @GET("admin/payment/queryList")
    Observable<BaseResponse<TotalListResponse<PaymentOrder>>> queryPaymentOrderList(@QueryMap Map<String, Object> map);

    //购买保险-查询用户信息
    @Headers("Content-Type: application/json")
    @GET("admin/manager/queryUserForInsurance")
    Observable<BaseResponse<PurchasingUser>> queryUserForInsurance(@QueryMap Map<String, Object> map);

    //申请保险-查询设备信息
    @Headers("Content-Type: application/json")
    @GET("admin/manager/queryDeviceForInsurance")
    Observable<BaseResponse<Battery>> queryDeviceForInsurance(@QueryMap Map<String, Object> map);

    //申请保险-查询保险方案
    @Headers("Content-Type: application/json")
    @GET("admin/manager/queryInsurancePlan")
    Observable<BaseResponse<Insurance>> queryInsurancePlan(@QueryMap Map<String, Object> map);

    //申请保险
    @Headers("Content-Type: application/json")
    @POST("admin/manager/applyInsurance")
    Observable<BaseResponse<Object>> applyInsurance(@Body Object body);

    //销售统计汇总信息
    @Headers("Content-Type: application/json")
    @GET("admin/shop/static/index")
    Observable<BaseResponse<StaticSaleNum>> getStaticSaleNum();

    //分页销售统计信息
    @Headers("Content-Type: application/json")
    @GET("admin/shop/static/queryList")
    Observable<BaseResponse<BaseListResponse<StaticSaleShop>>> queryStaticShopList(@QueryMap Map<String, Object> map);

    //查询门店销售详情
    @Headers("Content-Type: application/json")
    @GET("admin/shop/static/queryDetail")
    Observable<BaseResponse<StaticSaleShopDetail>> getSellStaticDetail(@QueryMap Map<String, Object> map);

    //查询12个月数据
    @Headers("Content-Type: application/json")
    @GET("admin/trade/staticLast12MonthOrderData")
    Observable<BaseResponse<SalesBarData>> get12MonthOrderDate();

    //销售统计页面数据
    @Headers("Content-Type: application/json")
    @GET("admin/trade/staticShopIncomeRank")
    Observable<BaseResponse<SaleSumPageData>> getSellPageRankData(@QueryMap Map<String, Object> map);

    //门店业绩统计-分页查询销售数据
    @GET("admin/trade/queryShopSaleData")
    Observable<BaseResponse<SellDataListResponse>> getShopSaleData(@QueryMap Map<String, Object> map);

    //门店业绩统计-分页查询售后服务数据
    @GET("admin/trade/queryAfterSaleData")
    Observable<BaseResponse<SellDataListResponse>> getAfterSaleData(@QueryMap Map<String, Object> map);

    //查询门店用户列表
    @Headers("Content-Type: application/json")
    @GET("admin/user/queryList")
    Observable<BaseResponse<BaseListResponse<UserInfo>>> getUserList(@QueryMap Map<String, Object> map);

    //搜索用户
    @Headers("Content-Type: application/json")
    @GET("admin/user/searchList")
    Observable<BaseResponse<BaseListResponse<UserInfo>>> getUserListByKeyWord(@QueryMap Map<String, Object> map);

    //查询门店用户详情
    @Headers("Content-Type: application/json")
    @GET("admin/user/getDetail")
    Observable<BaseResponse<UserDetail>> getUserDetail(@QueryMap Map<String, Object> map);

    //查询门店用户详情
    @Headers("Content-Type: application/json")
    @GET("admin/vehicle/getDetail")
    Observable<BaseResponse<VehicleDetailBean>> getVehicleDetail(@QueryMap Map<String, Object> map);

    //查询门店用户订单信息
    @Headers("Content-Type: application/json")
    @GET("admin/user/queryUserOrderList")
    Observable<BaseResponse<UserOrderResponse>> getUserOrderList(@QueryMap Map<String, Object> map);

    //分页查询用户付款信息
    @Headers("Content-Type: application/json")
    @GET("admin/user/queryUserPayList")
    Observable<BaseResponse<BaseListResponse<UserPaymentRecord>>> getUserPayList(@QueryMap Map<String, Object> map);

    //分页查询用户换电记录
    @Headers("Content-Type: application/json")
    @GET("admin/user/queryUserSwapPage")
    Observable<BaseResponse<PowerChangeBeanNew>> getBatterySwapRecord(@QueryMap Map<String, Object> map);

//        仓管

    /**
     * 发出设备验证
     */
    @Headers("Content-Type: application/json")
    @GET("admin/transfer/checkDeviceSn")
    Observable<BaseResponse<Object>> checkDeviceSn(@QueryMap Map<String, Object> map);

    /**
     * 接收入库
     */
    @Headers("Content-Type: application/json")
    @POST("admin/transfer/receive")
    Observable<BaseResponse<Object>> receiveDevice(@Body Object body);

    /**
     * 接收入库
     */
    @Headers("Content-Type: application/json")
    @POST("admin/transfer/withdraw")
    Observable<BaseResponse<Object>> withdrawDevice(@Body Object body);

    /**
     * 分页查询设备盘点记录
     */
    @Headers("Content-Type: application/json")
    @GET("admin/inventory/queryDeviceInventoryPage")
    Observable<BaseResponse<DeviceInventoryResp>> queryDeviceInventoryPage(@QueryMap Map<String, Object> map);

    /**
     * 获取盘点仓库列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/inventory/queryInventoryHouseList")
    Observable<BaseResponse<List<WarehouseBean>>> queryDeviceInventoryPage();

    /**
     * 新建设备盘点单据
     */
    @Headers("Content-Type: application/json")
    @POST("admin/inventory/start")
    Observable<BaseResponse<DeviceInventoryDetail>> startInventory(@Body Object body);

    /**
     * 盘点详情
     */
    @Headers("Content-Type: application/json")
    @GET("admin/inventory/queryInventoryDetail")
    Observable<BaseResponse<DeviceInventoryDetail>> queryInventoryDetail(@QueryMap Map<String, Object> map);

    /**
     * 扫码设备到盘点单
     */
    @Headers("Content-Type: application/json")
    @POST("admin/inventory/scan")
    Observable<BaseResponse<DeviceInventoryScanResult>> scanInventory(@Body Object body);

    /**
     * 作废盘点单
     */
    @Headers("Content-Type: application/json")
    @POST("admin/inventory/revoke")
    Observable<BaseResponse<Object>> revokeInventory(@Body Object body);

    /**
     * 完成盘点单
     */
    @Headers("Content-Type: application/json")
    @POST("admin/inventory/complete")
    Observable<BaseResponse<Object>> completeInventory(@Body Object body);

    /**
     * 获取发出信息详情
     */
    @Headers("Content-Type: application/json")
    @GET("admin/transfer/queryIssueDetail")
    Observable<BaseResponse<DeviceTransportDetail>> queryOutTransportDetail(@QueryMap Map<String, Object> map);

    /**
     * 分页查询设备发出记录
     */
    @Headers("Content-Type: application/json")
    @GET("admin/transfer/queryDeviceIssuePage")
    Observable<BaseResponse<DeviceTransportResp>> queryDeviceIssuePage(@QueryMap Map<String, Object> map);

    /**
     * 编辑物流单号
     */
    @Headers("Content-Type: application/json")
    @POST("admin/transfer/editTrackingNumber")
    Observable<BaseResponse<Object>> editTrackingNumber(@Body Object body);

    /**
     * 获取出仓单位信息
     */
    @Headers("Content-Type: application/json")
    @GET("admin/transfer/queryMyWarehouseInfo")
    Observable<BaseResponse<WarehouseBean>> queryMyWarehouseInfo();

    /**
     * 分页查询设备接收记录
     */
    @Headers("Content-Type: application/json")
    @GET("admin/transfer/queryDeviceReceivePage")
    Observable<BaseResponse<DeviceTransportResp>> queryDeviceReceivePage(@QueryMap Map<String, Object> map);


    /**
     * 获取接收单位列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/transfer/queryInWarehouseList")
    Observable<BaseResponse<List<WarehouseBean>>> queryInWarehouseList(@QueryMap Map<String, Object> map);

    /**
     * 新建设备发出单据
     */
    @Headers("Content-Type: application/json")
    @POST("admin/transfer/createIssue")
    Observable<BaseResponse<Object>> createIssue(@Body Object body);
//
//    /**
//     * 工作台工单统计
//     */
//    @Headers("Content-Type: application/json")
//    @GET("admin/workOrder/workOrderStat")
//    Observable<BaseResponse<WorkOrderStat>> queryWorkOrderStat();

    /**
     * 查询道路救援列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/op/queryRoadSavePage")
    Observable<BaseResponse<RoadSideListResp>> queryRoadSideList(@QueryMap Map<String, Object> map);

    /**
     * 查询道路救援工单详情
     */
    @Headers("Content-Type: application/json")
    @GET("admin/op/queryRoadSaveInfo")
    Observable<BaseResponse<RoadSideOrderDetail>> queryRoadOrderDetail(@QueryMap Map<String, Object> map);


    /**
     * 支付道路救援
     *
     * @return
     */
    @Headers("Content-Type: application/json")
    @POST("admin/op/payRoadSave")
    Observable<BaseResponse<Object>> payRoadSide(@Body Object body);

    /**
     * 处理道路救援
     */
    @Headers("Content-Type: application/json")
    @POST("admin/op/saveRoadSaveResponse")
    Observable<BaseResponse<Object>> dealRoadSide(@Body Object body);

    //上传道路救援处理图片
    @Multipart
    @POST("admin/op/uploadRoadSaveImg")
    Observable<BaseResponse<String>> uploadRoadSideImage(@Part MultipartBody.Part file);

    /**
     * 获取手机区号配置
     */
    @Headers("Content-Type: application/json")
    @GET("admin/getAreaCodeConfig")
    Observable<BaseResponse<AreaCountryResp>> getAreaCodeConfig();

    /**
     * 注册账号
     */
    @Multipart
    @POST("/admin/register")
    Observable<BaseResponse<Object>> offlineRegister(@Part List<MultipartBody.Part> data);

    /**
     * 获取验证码
     */
    @Headers("Content-Type: application/json")
    @POST("admin/sendSms")
    Observable<BaseResponse<Object>> sendSms(@Body Object body);

    /**
     * 修改手机号码获取验证码
     */
    @Headers("Content-Type: application/json")
    @POST("user/sendChangePhoneSms")
    Observable<BaseResponse<Object>> changePhoneSendSms(@Body Object body);

    /**
     * 查询二维码sn
     */
    @Headers("Content-Type: application/json")
    @POST("admin/device/getDeviceSn")
    Observable<BaseResponse<String>> getDeviceSn(@Body Object body);


    /**
     * 查询车辆保养预约
     */
    @Headers("Content-Type: application/json")
    @GET("admin/op/queryVehicleForMaintain")
    Observable<BaseResponse<BookMaintenanceBean>> queryAppointment(@QueryMap Map<String, Object> map);

    /**
     * 分页查询设备盘点记录
     */
    @Headers("Content-Type: application/json")
    @GET("admin/maintenance/queryFixList")
    Observable<BaseResponse<VehicleRepairListResp>> queryRepairRecordList(@QueryMap Map<String, Object> map);

    /**
     * 车辆保养登记
     */
    @Headers("Content-Type: application/json")
    @POST("admin/maintenance/addRecord")
    Observable<BaseResponse<Object>> addRepairRecord(@Body Object body);


    /**
     * 分页查询保养记录
     */
    @Headers("Content-Type: application/json")
    @GET("admin/car/queryMaintainList")
    Observable<BaseResponse<DeviceMaintenanceResponse>> getDeviceMaintenanceRecordList(@Query("pageNum") int pageNum, @Query("pageSize") int pageSize, @Query("sn") String sn);


    /**
     * 获取电池维修记录列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/battery/queryFixList")
    Observable<BaseResponse<DeviceFixRecordResponse>> getBatteryFixRecordList(@Query("pageNum") int pageNum, @Query("pageSize") int pageSize, @Query("sn") String sn);

    /**
     * 获取车辆维修记录列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/car/queryFixList")
    Observable<BaseResponse<DeviceFixRecordResponse>> getCarFixRecordList(@Query("pageNum") int pageNum, @Query("pageSize") int pageSize, @Query("sn") String sn);

    /**
     * 导航规划
     *
     * @return
     */
    @Headers("Content-Type: application/json")
    @GET("maps/api/directions/json")
    Observable<BaseResponse<PolylinePointsBean>> getPolyLine(@Query("origin") String origin, @Query("destination") String destination, @Query("avoid") String avoid, @Query("mode") String mode, @Query("key") String key);

//    //上传凭证
//    @Headers("Content-Type: application/json")
//    @POST("admin/sys/")
//    Observable<BaseResponse<String>> uploadProof(@Body Object body);

    //产生车辆保养订单
    @Headers("Content-Type: application/json")
    @POST("admin/op/genMaintainRecord")
    Observable<BaseResponse<Object>> genMaintainRecord(@Body Object body);

    /**
     * 获取租赁绑定信息
     *
     * @param deviceSn
     * @return
     */
    @Headers("Content-Type: application/json")
    @GET("/admin/trade/queryRentDeviceInfo")
    Observable<BaseResponse<RentDeviceInfoBean>> getRentInfo(@Query("deviceSn") String deviceSn);

    @Headers("Content-Type: application/json")
    @GET("admin/trade/queryUserForSwap")
    Observable<BaseResponse<SwapBindInfo>> getSwapBindInfo(@Query("cardNum") String cardNum);

    @Headers("Content-Type: application/json")
    @GET("admin/trade/querySwapPackList")
    Observable<BaseResponse<List<Pack>>> getSwapPackInfo(@QueryMap Map<String, Object> map);

    @Headers("Content-Type: application/json")
    @GET("admin/trade/queryUserForRefundDeposit")
    Observable<BaseResponse<DepositRefundInfoBean>> getDepositRefundInfo(@Query("cardNum") String cardNum);

    @Headers("Content-Type: application/json")
    @POST("admin/trade/refundDeposit")
    Observable<BaseResponse<Object>> refundDeposit(@Body Object body);

    @Headers("Content-Type: application/json")
    @GET("admin/trade/queryUserForPayPeriod")
    Observable<BaseResponse<InstallmentPaymentResponse>> getInstallmentPayInfo(@Query("cardNum") String cardNum);

    //分期缴纳
    @Headers("Content-Type: application/json")
    @POST("admin/trade/payPeriod")
    Observable<BaseResponse<String>> payPeriod(@Body Object body);

//    //上传凭证图片
//    @Multipart
//    @POST("admin/uploadproof")
//    Observable<BaseResponse<String>> uploadProof(@Part MultipartBody.Part file);

    /**
     * 获取消息列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/sys/msg/getSysMessage")
    Observable<BaseResponse<MessageListResponse>> getMsgList(@QueryMap HashMap<String, Object> map);


    /**
     * 设置消息已读
     */
    @Headers("Content-Type: application/json")
    @POST("admin/sys/msg/updateMsgFlag")
    Observable<BaseResponse<Object>> setMsgRead(@Body Object object);

    /**
     * 获取未读消息数
     */
    @Headers("Content-Type: application/json")
    @GET("admin/sys/msg/getUnReadMsgNum")
    Observable<BaseResponse<Integer>> getUnReadMsgCount();


    /**
     * 获取仓列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/getPortDetail")
    Observable<BaseResponse<List<Cabin>>> getCabinList(@Query("sn") String sn);

    /**
     * 获取仓故障列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/faultReport/queryBySnAndPort")
    Observable<BaseResponse<CabinFaultBean>> getFaultList(@Query("pageNum") int pageNum, @Query("pageSize") int pageSize, @Query("sn") String sn, @Query("port") int port/*,@Query("nID") String nID*/);

    /**
     * 获取禁仓原因
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/remote/forbiddenStorageReason")
    Observable<BaseResponse<List<ForbiddenReasonBean>>> getForbiddenStorageReason();

    /**
     * 设置仓门
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/remote/setPorts")
    Observable<BaseResponse<String>> setCabinPorts(@Body Object body);

    /**
     * 开仓门
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/remote/openDoor")
    Observable<BaseResponse<String>> openCabinDoor(@Body Object body);

    /**
     * 开仓门
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/ctrlPort")
    Observable<BaseResponse<Object>> openCabinDoorNew(@Body Object body);

    /**
     * 开柜门
     */
//    @Headers("Content-Type: application/json")
    @POST("admin/station/openBackDoor")
    @FormUrlEncoded
    Observable<BaseResponse<Object>> openCabinBackDoor(@FieldMap Map<String, Object> map);

    /**
     * 获取电柜维修记录列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/queryFixList")
    Observable<BaseResponse<DeviceFixRecordResponse>> getCabinFixRecordList(@Query("pageNum") int pageNum, @Query("pageSize") int pageSize, @Query("sn") String sn);
    /**
     * 修改柜子信息
     */
    @Headers("Content-Type: application/json")
    @PUT("admin/stations/{sn}")
    Observable<BaseResponse<String>> modifyCabinetInfo(@Path("sn") String sn, @Body Object body);

    /**
     * 获取运维人员列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/sys/accounts")
    Observable<BaseResponse<OpsAndMaintenaceBean>> getOpsAndMaintenaceList(@Query("pageNum") int pageNum, @Query("pageSize") int pageSize,
                                                                           @Query("phone") String phone, @Query("userName") String userName, @Query("platform") int platform, @Query("enabled") int enabled);

    /**
     * 添加柜子责任人
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/manager/add")
    Observable<BaseResponse<String>> addPersonLiable(@Body Object body);

    /**
     * 上传图片
     *
     * @return
     */
    @Multipart
    @POST("admin/sys/upload")
    Observable<BaseResponse<List<String>>> updateCabinetImage(@Query("pid") String pid, @Part() List<MultipartBody.Part> files);

    @Multipart
    @POST("admin/station/upload")
    Observable<BaseResponse<String>> updateCabinetImage(@Part MultipartBody.Part file);

    /**
     * 获取充电柜附近点类型
     *
     * @return
     */
    @Headers("Content-Type:application/x-www-form-urlencoded")
    @GET("admin/sys/config/location")
    Observable<BaseResponse<List<CurrentPointBean>>> getCurrentAndPoints();
    /**
     * 获取柜子详情基本信息
     *
     * @param sn
     * @return
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/queryStationDetail")
    Observable<BaseResponse<CabinetDetailBaseInfoBean>> getCabinetBaseInfo(@Query("sn") String sn);
    /**
     * 获取主柜副柜信息
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/relation/{pid}")
    Observable<BaseResponse<List<DeputyCabinetBean>>> getDeputyCabinet(@Path("pid") String pid);


    /**
     * 设置充电电流
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/remote/setElectricCurrent")
    Observable<BaseResponse<String>> setChargingCurrent(@Body Object body);

    /**
     * 获取柜子布置信息
     *
     * @param sn
     * @return
     */
    @Headers("Content-Type: application/json")
    @GET("admin/stations/{sn}/history")
    Observable<BaseResponse<LayoutCabinetInfoBean>> getLayouCabinetInfo(@Path("sn") String sn, @Query("pageNum") int pageNum, @Query("pageSize") int pageSize);

    /**
     * 拉取柜子配置信息
     */
    @Headers("Content-Type: application/json")
    @GET("admin/stations/{pid}/config")
    Observable<BaseResponse<SettingInfoBean>> getCabinetSettingInfo(@Path("pid") String pid);
    /**
     * 上传柜子配置信息
     */
    @Headers("Content-Type: application/json")
    @PUT("admin/stations/{pid}/config")
    Observable<BaseResponse<String>> updateCabinetSettingInfo(@Path("pid") String pid, @Body Object body);

    /**
     * 重启-整机/android/充电器
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/remote/restart")
    Observable<BaseResponse<String>> restartCompleteMachine(@Body Object body);

    /**
     * 获取临时密码
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/accountInfo")
    Observable<BaseResponse<TemporyPSWbean>> getTemporyPSW(@Query("stationId") String stationId);

    /**
     * 获取柜子时间
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/remote/queryAndroidTime")
    Observable<BaseResponse<Long>> getCabinetTime(@Query("pID") String pID);

    /**
     * 打开电子锁
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/remote/openLock")
    Observable<BaseResponse<String>> openElectronicLock(@Body Object body);

    /**
     * 关机-整机
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/remote/shutDown")
    Observable<BaseResponse<String>> shutDaownMachine(@Body Object body);
    /**
     * 获取版本信息
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/remote/queryVersion")
    Observable<BaseResponse<CabinetVersionBean>> getCabinetVersion(@Query("pID") String pID);

    /**
     * 获取本地状态
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/remote/querySnapshotData")
    Observable<BaseResponse<String>> getLocalStatus(@Query("pID") String pID);

    /**
     * 下架
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/takeOff")
    Observable<BaseResponse<Object>> unshelveNew(@Body Object body);

//    @Headers("Content-Type: application/json")
//    @POST("admin/operations/locationTakeBack")
//    Observable<BaseResponse<Integer>> unshelve(@Body Object body);

    /**
     * 根据pid或sn码查询电柜类型及名称
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/getStationType/{source}/{code}")
    Observable<BaseResponse<NewCabinetBean>> getStationSource(@Path("source") String type, @Path("code") String code);

    /**
     * 获取柜子锁id
     */
    @Headers("Content-Type: application/json")
    @GET("admin/blueTooth/getLockIdBySn")
    Observable<BaseResponse<SNBean>> getLockIdBySn(@Query("sn") String sn);

    /**
     * 增加授权
     */
    @Headers("Content-Type: application/json")
    @POST("admin/blueTooth/authAdd")
    Observable<BaseResponse<Object>> authAdd(@Body Object body);

    /**
     * 获取授权记录列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/queryStationPermission")
    Observable<BaseResponse<AuthorizationRecordList>> getAuthorizationRecordListData(@QueryMap Map<String, Object> map);

    /**
     * 获取用户唯一编码
     */
    @Headers("Content-Type: application/json")
    @GET("admin/blueTooth/getUidByPhone")
    Observable<BaseResponse<Long>> getUidByPhone(@Query("phone") String phone);
    /**
     * 授权用户操作电柜
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/stationPermission")
    Observable<BaseResponse<Object>> stationPermission(@Body Object body);

    /**
     * 蓝牙加解密
     *
     * @return
     */
//    @Headers("Content-Type:application/x-www-form-urlencoded")
    @POST("admin/blueTooth/enOrDecrypt")
    @FormUrlEncoded
    Observable<BaseResponse<String>> blueToothEnOrDecrypt(@FieldMap Map<String, Object> map);

    /**
     * 取消授权操作
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/cancelPermission")
    Observable<BaseResponse<Object>> cancelPermission(@Body Object body);

    /**
     * 获取搜索授权设备列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/queryListBySn")
    Observable<BaseResponse<CabinetAuthorizationList>> getCabinetAuthorizationListSearchData(@QueryMap Map<String, Object> map);

    /**
     * 获取授权用户列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/sys/account/queryBePermissionList")
    Observable<BaseResponse<UserAuthorizationList>> getUserAuthorizationListSearchData(@QueryMap Map<String, Object> map);

    /**
     * 查询电柜蓝牙秘钥
     *
     * @param sn
     * @return
     */
    @Headers("Content-Type: application/json")
    @GET("admin/station/queryStationSecretKey")
    Observable<BaseResponse<String>> getStationSecretKey(@Query("sn") String sn);

    /**
     * 设置换电柜参数
     *
     * @param sn
     * @return
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/config")
    Observable<BaseResponse<Object>> configCabinet(@Body Object body);

    /**
     * 上架
     */
    @Headers("Content-Type: application/json")
    @POST("admin/station/install")
    Observable<BaseResponse<Object>> putawayCabinetNew(@Body Object body);

    /**
     * 获取城市列表
     *
     * @return
     */
    @Headers("Content-Type: application/json")
    @GET("admin/citys")
    Observable<BaseResponse<List<CityCode>>> getCityCodeList();


    @Headers("Content-Type: application/json")
    @POST("admin/operations/location")
    Observable<BaseResponse<String>> putawayCabinet(@Body Object body);

    /**
     * 校验柜子摄像头是否存在绑定关系
     *
     * @param cameraSn 柜子摄像头sn
     * @param sn       柜子sn
     * @return
     */
    @Headers("Content-Type: application/json")
    @GET("admin/operations/verifyStationLocation")
    Observable<BaseResponse<CabinetAndCameraBoundBean>> checkCabinetAndCameraBound(@Query("cameraSn") String cameraSn, @Query("sn") String sn);

    /**
     * 解绑摄像头或者柜子
     */
//    @Headers("Content-Type: application/x-www-form-urlencoded")
    @POST("admin/operations/unBindDevice")
    @FormUrlEncoded
    Observable<BaseResponse<String>> unbindCabinetAndCamera(@FieldMap Map<String, String> body);

    /**
     * 下发车辆指令
     */
    @Headers("Content-Type: application/json")
    @POST("admin/car/ctrlVehicle")
    Observable<BaseResponse<Object>> sendCommandToCar(@Body Object object);

    /**
     * 获取VCU软件版本列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/car/queryVceVersionList")
    Observable<BaseResponse<List<VcuVersion>>> getVcuVersionList();

    /**
     * 下载文件
     *
     * @param fileUrl 文件URL
     * @return
     */
    @GET
    @Streaming
    Observable<ResponseBody> downloadFile(@Url String fileUrl);
}
