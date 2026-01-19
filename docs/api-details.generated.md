## 8.2 接口明细（含参数/返回）

> 来源：Retrofit Service 接口自动抽取。

### OPSService.java

| Method | Path | MethodName | ReturnType | Params | Notes |
|---|---|---|---|---|---|
| GET | maps/api/directions/json | getRoutes | Observable<PolylinePoints> | QueryMap Map<String, Object> map |  |
| GET | admin/tenant/city/list | getCityList | Observable<BaseResponse<List<City>>> |  |  |
| POST | admin/sys/user/login | login | Observable<BaseResponse<User>> | Body Object body |  |
| POST | admin/sys/account/refreshToken | refreshToken | Observable<BaseResponse<User>> |  |  |
| POST | admin/sys/user/logout | logout | Observable<BaseResponse<Object>> |  |  |
| GET | admin/sys/account/detail | getPersonalInfo | Observable<BaseResponse<Personal>> |  |  |
| POST | admin/sys/account/changePassword | changePSWNew | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/sys/account/changeNickName | editNickname | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/sys/account/changeAvatar | editAvatar | Observable<BaseResponse<Object>> | Part MultipartBody.Part file | Multipart |
| GET | admin/battery/getModelList | getBatteryTypeList | Observable<BaseResponse<List<BatteryType>>> |  |  |
| POST | admin/battery/register | registerBattery | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/station/getModelList | getStationTypeList | Observable<BaseResponse<List<StationType>>> |  |  |
| POST | admin/station/register | registerStation | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/vehicle/getModelList | getCarTypeList | Observable<BaseResponse<List<CarType>>> |  |  |
| POST | admin/vehicle/register | registerCar | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/trade/staticMonthlyIncome | getSaleData | Observable<BaseResponse<SaleData>> |  |  |
| GET | admin/trade/querySaleDeviceInfo | querySaleDeviceInfo | Observable<BaseResponse<BatterOrVehicleInfo>> | QueryMap Map<String, Object> map |  |
| GET | admin/trade/queryInfoPage | queryServicePlanByName | Observable<BaseResponse<ServicePlanInfo>> | QueryMap Map<String, Object> map |  |
| GET | admin/trade/queryPaymentPlanList | getPaymantPlanList | Observable<BaseResponse<List<PaymentPlan>>> | QueryMap Map<String, Object> map |  |
| GET | admin/trade/queryUserForSell | queryUserForSell | Observable<BaseResponse<PurchasingUser>> | QueryMap Map<String, Object> map |  |
| GET | admin/op/queryUserForBindOrder | queryUserForAfterSaleBind | Observable<BaseResponse<UserDetail>> | QueryMap Map<String, Object> map |  |
| GET | admin/trade/queryUserForRent | queryUserForRent | Observable<BaseResponse<PurchasingUser>> | QueryMap Map<String, Object> map |  |
| POST | admin/trade/genSwapOrder | createSwapBindOrder | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/trade/queryShopPayConfig | getShopPaymentMethod | Observable<BaseResponse<ShopPaymentMethod>> | QueryMap Map<String, Object> map |  |
| POST | admin/sell/uploadCardImg | uploadCardImg | Observable<BaseResponse<String>> | Part MultipartBody.Part file | Multipart |
| POST | admin/trade/uploadAttachment | uploadAttachment | Observable<BaseResponse<String>> | Part MultipartBody.Part file | Multipart |
| POST | admin/user/uploadAttachment | userUploadAttachment | Observable<BaseResponse<String>> | Part MultipartBody.Part file | Multipart |
| POST | admin/trade/confirmPayOrder | userConfirmPayOrder | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/battery/sell | sellBattery | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/trade/sellDevice | sellBind | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/trade/rentDevice | rentBind | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/monitor/vehicle/monitorOnMap | getNearByVehicleList | Observable<BaseResponse<List<NearByVehicle>>> | QueryMap Map<String, Object> map |  |
| GET | admin/monitor/vehicle/queryRiderPhone | getPhoneByCardNum | Observable<BaseResponse<Object>> | Query("cardNum") String cardNum |  |
| POST | admin/shop/create | createShop | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/shop/stock/index | getStockNum | Observable<BaseResponse<StockNum>> | QueryMap Map<String, Object> map |  |
| GET | admin/shop/stock/queryList | getStockList | Observable<BaseResponse<BaseListResponse<Stock>>> | QueryMap Map<String, Object> map |  |
| GET | admin/shop/stock/queryShopByName | queryShopByName | Observable<BaseResponse<List<Shop>>> | QueryMap Map<String, Object> map |  |
| GET | admin/shop/stock/queryTransferBatteryBySn | queryTransferBatteryBySn | Observable<BaseResponse<BatteryTransfer>> | QueryMap Map<String, Object> map |  |
| POST | admin/shop/stock/transfer | stockTransfer | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/shop/stock/queryDetail | queryStockDetailByTransferNo | Observable<BaseResponse<StockDetail>> | QueryMap Map<String, Object> map |  |
| GET | admin/shop/index | getShopNum | Observable<BaseResponse<Shop1Num>> | QueryMap Map<String, Object> map |  |
| GET | admin/shop/queryList | getShopList | Observable<BaseResponse<BaseListResponse<Shop1>>> | QueryMap Map<String, Object> map |  |
| GET | admin/shop/queryDetail | queryShopDetail | Observable<BaseResponse<ShopDetail>> | QueryMap Map<String, Object> map |  |
| POST | admin/shop/turn | turnShopStatus | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/shop/edit | editShop | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/battery/searchBySn | searchBatteryBySn | Observable<BaseResponse<BatteryDetail>> | QueryMap Map<String, Object> map |  |
| POST | admin/battery/turnDischargeStatus | turnDischargeStatus | Observable<BaseResponse<Object>> | FieldMap Map<String, Object> map | Form |
| GET | admin/battery/queryDeviceChargeRecord | queryDeviceChargeRecord | Observable<BaseResponse<BaseListResponse<ChargeHistory>>> | QueryMap Map<String, Object> map |  |
| GET | admin/battery/staticBatteryMile | staticBatteryMile | Observable<BaseResponse<StaticBatteryMile>> | QueryMap Map<String, Object> map |  |
| GET | admin/payment/queryOrderByNo | queryOrderByNo | Observable<BaseResponse<PaymentOrder>> | QueryMap Map<String, Object> map |  |
| POST | admin/payment/confirm | confirmPayment | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/payment/queryList | queryPaymentOrderList | Observable<BaseResponse<TotalListResponse<PaymentOrder>>> | QueryMap Map<String, Object> map |  |
| GET | admin/manager/queryUserForInsurance | queryUserForInsurance | Observable<BaseResponse<PurchasingUser>> | QueryMap Map<String, Object> map |  |
| GET | admin/manager/queryDeviceForInsurance | queryDeviceForInsurance | Observable<BaseResponse<Battery>> | QueryMap Map<String, Object> map |  |
| GET | admin/manager/queryInsurancePlan | queryInsurancePlan | Observable<BaseResponse<Insurance>> | QueryMap Map<String, Object> map |  |
| POST | admin/manager/applyInsurance | applyInsurance | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/shop/static/index | getStaticSaleNum | Observable<BaseResponse<StaticSaleNum>> |  |  |
| GET | admin/shop/static/queryList | queryStaticShopList | Observable<BaseResponse<BaseListResponse<StaticSaleShop>>> | QueryMap Map<String, Object> map |  |
| GET | admin/shop/static/queryDetail | getSellStaticDetail | Observable<BaseResponse<StaticSaleShopDetail>> | QueryMap Map<String, Object> map |  |
| GET | admin/trade/staticLast12MonthOrderData | get12MonthOrderDate | Observable<BaseResponse<SalesBarData>> |  |  |
| GET | admin/trade/staticShopIncomeRank | getSellPageRankData | Observable<BaseResponse<SaleSumPageData>> | QueryMap Map<String, Object> map |  |
| GET | admin/trade/queryShopSaleData | getShopSaleData | Observable<BaseResponse<SellDataListResponse>> | QueryMap Map<String, Object> map |  |
| GET | admin/trade/queryAfterSaleData | getAfterSaleData | Observable<BaseResponse<SellDataListResponse>> | QueryMap Map<String, Object> map |  |
| GET | admin/user/queryList | getUserList | Observable<BaseResponse<BaseListResponse<UserInfo>>> | QueryMap Map<String, Object> map |  |
| GET | admin/user/searchList | getUserListByKeyWord | Observable<BaseResponse<BaseListResponse<UserInfo>>> | QueryMap Map<String, Object> map |  |
| GET | admin/user/getDetail | getUserDetail | Observable<BaseResponse<UserDetail>> | QueryMap Map<String, Object> map |  |
| GET | admin/vehicle/getDetail | getVehicleDetail | Observable<BaseResponse<VehicleDetailBean>> | QueryMap Map<String, Object> map |  |
| GET | admin/user/queryUserOrderList | getUserOrderList | Observable<BaseResponse<UserOrderResponse>> | QueryMap Map<String, Object> map |  |
| GET | admin/user/queryUserPayList | getUserPayList | Observable<BaseResponse<BaseListResponse<UserPaymentRecord>>> | QueryMap Map<String, Object> map |  |
| GET | admin/user/queryUserSwapPage | getBatterySwapRecord | Observable<BaseResponse<PowerChangeBeanNew>> | QueryMap Map<String, Object> map |  |
| GET | admin/transfer/checkDeviceSn | checkDeviceSn | Observable<BaseResponse<Object>> | QueryMap Map<String, Object> map |  |
| POST | admin/transfer/receive | receiveDevice | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/transfer/withdraw | withdrawDevice | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/inventory/queryDeviceInventoryPage | queryDeviceInventoryPage | Observable<BaseResponse<DeviceInventoryResp>> | QueryMap Map<String, Object> map |  |
| GET | admin/inventory/queryInventoryHouseList | queryDeviceInventoryPage | Observable<BaseResponse<List<WarehouseBean>>> |  |  |
| POST | admin/inventory/start | startInventory | Observable<BaseResponse<DeviceInventoryDetail>> | Body Object body |  |
| GET | admin/inventory/queryInventoryDetail | queryInventoryDetail | Observable<BaseResponse<DeviceInventoryDetail>> | QueryMap Map<String, Object> map |  |
| POST | admin/inventory/scan | scanInventory | Observable<BaseResponse<DeviceInventoryScanResult>> | Body Object body |  |
| POST | admin/inventory/revoke | revokeInventory | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/inventory/complete | completeInventory | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/transfer/queryIssueDetail | queryOutTransportDetail | Observable<BaseResponse<DeviceTransportDetail>> | QueryMap Map<String, Object> map |  |
| GET | admin/transfer/queryDeviceIssuePage | queryDeviceIssuePage | Observable<BaseResponse<DeviceTransportResp>> | QueryMap Map<String, Object> map |  |
| POST | admin/transfer/editTrackingNumber | editTrackingNumber | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/transfer/queryMyWarehouseInfo | queryMyWarehouseInfo | Observable<BaseResponse<WarehouseBean>> |  |  |
| GET | admin/transfer/queryDeviceReceivePage | queryDeviceReceivePage | Observable<BaseResponse<DeviceTransportResp>> | QueryMap Map<String, Object> map |  |
| GET | admin/transfer/queryInWarehouseList | queryInWarehouseList | Observable<BaseResponse<List<WarehouseBean>>> | QueryMap Map<String, Object> map |  |
| POST | admin/transfer/createIssue | createIssue | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/op/queryRoadSavePage | queryRoadSideList | Observable<BaseResponse<RoadSideListResp>> | QueryMap Map<String, Object> map |  |
| GET | admin/op/queryRoadSaveInfo | queryRoadOrderDetail | Observable<BaseResponse<RoadSideOrderDetail>> | QueryMap Map<String, Object> map |  |
| POST | admin/op/payRoadSave | payRoadSide | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/op/saveRoadSaveResponse | dealRoadSide | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/op/uploadRoadSaveImg | uploadRoadSideImage | Observable<BaseResponse<String>> | Part MultipartBody.Part file | Multipart |
| GET | admin/getAreaCodeConfig | getAreaCodeConfig | Observable<BaseResponse<AreaCountryResp>> |  |  |
| POST | /admin/register | offlineRegister | Observable<BaseResponse<Object>> | Part List<MultipartBody.Part> data | Multipart |
| POST | admin/sendSms | sendSms | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | user/sendChangePhoneSms | changePhoneSendSms | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/device/getDeviceSn | getDeviceSn | Observable<BaseResponse<String>> | Body Object body |  |
| GET | admin/op/queryVehicleForMaintain | queryAppointment | Observable<BaseResponse<BookMaintenanceBean>> | QueryMap Map<String, Object> map |  |
| GET | admin/maintenance/queryFixList | queryRepairRecordList | Observable<BaseResponse<VehicleRepairListResp>> | QueryMap Map<String, Object> map |  |
| POST | admin/maintenance/addRecord | addRepairRecord | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/car/queryMaintainList | getDeviceMaintenanceRecordList | Observable<BaseResponse<DeviceMaintenanceResponse>> | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn |  |
| GET | admin/battery/queryFixList | getBatteryFixRecordList | Observable<BaseResponse<DeviceFixRecordResponse>> | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn |  |
| GET | admin/car/queryFixList | getCarFixRecordList | Observable<BaseResponse<DeviceFixRecordResponse>> | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn |  |
| GET | maps/api/directions/json | getPolyLine | Observable<BaseResponse<PolylinePointsBean>> | Query("origin") String origin; Query("destination") String destination; Query("avoid") String avoid; Query("mode") String mode; Query("key") String key |  |
| POST | admin/op/genMaintainRecord | genMaintainRecord | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | /admin/trade/queryRentDeviceInfo | getRentInfo | Observable<BaseResponse<RentDeviceInfoBean>> | Query("deviceSn") String deviceSn |  |
| GET | admin/trade/queryUserForSwap | getSwapBindInfo | Observable<BaseResponse<SwapBindInfo>> | Query("cardNum") String cardNum |  |
| GET | admin/trade/querySwapPackList | getSwapPackInfo | Observable<BaseResponse<List<Pack>>> | QueryMap Map<String, Object> map |  |
| GET | admin/trade/queryUserForRefundDeposit | getDepositRefundInfo | Observable<BaseResponse<DepositRefundInfoBean>> | Query("cardNum") String cardNum |  |
| POST | admin/trade/refundDeposit | refundDeposit | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/trade/queryUserForPayPeriod | getInstallmentPayInfo | Observable<BaseResponse<InstallmentPaymentResponse>> | Query("cardNum") String cardNum |  |
| POST | admin/trade/payPeriod | payPeriod | Observable<BaseResponse<String>> | Body Object body |  |
| GET | admin/sys/msg/getSysMessage | getMsgList | Observable<BaseResponse<MessageListResponse>> | QueryMap HashMap<String, Object> map |  |
| POST | admin/sys/msg/updateMsgFlag | setMsgRead | Observable<BaseResponse<Object>> | Body Object object |  |
| GET | admin/sys/msg/getUnReadMsgNum | getUnReadMsgCount | Observable<BaseResponse<Integer>> |  |  |
| GET | admin/station/getPortDetail | getCabinList | Observable<BaseResponse<List<Cabin>>> | Query("sn") String sn |  |
| GET | admin/faultReport/queryBySnAndPort | getFaultList | Observable<BaseResponse<CabinFaultBean>> | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn; Query("port") int port/*; Query("nID") String nID*/ |  |
| GET | admin/station/remote/forbiddenStorageReason | getForbiddenStorageReason | Observable<BaseResponse<List<ForbiddenReasonBean>>> |  |  |
| POST | admin/station/remote/setPorts | setCabinPorts | Observable<BaseResponse<String>> | Body Object body |  |
| POST | admin/station/remote/openDoor | openCabinDoor | Observable<BaseResponse<String>> | Body Object body |  |
| POST | admin/station/ctrlPort | openCabinDoorNew | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/station/openBackDoor | openCabinBackDoor | Observable<BaseResponse<Object>> | FieldMap Map<String, Object> map | Form |
| GET | admin/station/queryFixList | getCabinFixRecordList | Observable<BaseResponse<DeviceFixRecordResponse>> | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn |  |
| PUT | admin/stations/{sn} | modifyCabinetInfo | Observable<BaseResponse<String>> | Path("sn") String sn; Body Object body |  |
| GET | admin/sys/accounts | getOpsAndMaintenaceList | Observable<BaseResponse<OpsAndMaintenaceBean>> | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("phone") String phone; Query("userName") String userName; Query("platform") int platform; Query("enabled") int enabled |  |
| POST | admin/station/manager/add | addPersonLiable | Observable<BaseResponse<String>> | Body Object body |  |
| POST | admin/sys/upload | updateCabinetImage | Observable<BaseResponse<List<String>>> | Query("pid") String pid; Part List<MultipartBody.Part> files | Multipart |
| POST | admin/station/upload | updateCabinetImage | Observable<BaseResponse<String>> | Part MultipartBody.Part file | Multipart |
| GET | admin/sys/config/location | getCurrentAndPoints | Observable<BaseResponse<List<CurrentPointBean>>> |  |  |
| GET | admin/station/queryStationDetail | getCabinetBaseInfo | Observable<BaseResponse<CabinetDetailBaseInfoBean>> | Query("sn") String sn |  |
| GET | admin/station/relation/{pid} | getDeputyCabinet | Observable<BaseResponse<List<DeputyCabinetBean>>> | Path("pid") String pid |  |
| POST | admin/station/remote/setElectricCurrent | setChargingCurrent | Observable<BaseResponse<String>> | Body Object body |  |
| GET | admin/stations/{sn}/history | getLayouCabinetInfo | Observable<BaseResponse<LayoutCabinetInfoBean>> | Path("sn") String sn; Query("pageNum") int pageNum; Query("pageSize") int pageSize |  |
| GET | admin/stations/{pid}/config | getCabinetSettingInfo | Observable<BaseResponse<SettingInfoBean>> | Path("pid") String pid |  |
| PUT | admin/stations/{pid}/config | updateCabinetSettingInfo | Observable<BaseResponse<String>> | Path("pid") String pid; Body Object body |  |
| POST | admin/station/remote/restart | restartCompleteMachine | Observable<BaseResponse<String>> | Body Object body |  |
| GET | admin/station/accountInfo | getTemporyPSW | Observable<BaseResponse<TemporyPSWbean>> | Query("stationId") String stationId |  |
| GET | admin/station/remote/queryAndroidTime | getCabinetTime | Observable<BaseResponse<Long>> | Query("pID") String pID |  |
| POST | admin/station/remote/openLock | openElectronicLock | Observable<BaseResponse<String>> | Body Object body |  |
| POST | admin/station/remote/shutDown | shutDaownMachine | Observable<BaseResponse<String>> | Body Object body |  |
| GET | admin/station/remote/queryVersion | getCabinetVersion | Observable<BaseResponse<CabinetVersionBean>> | Query("pID") String pID |  |
| GET | admin/station/remote/querySnapshotData | getLocalStatus | Observable<BaseResponse<String>> | Query("pID") String pID |  |
| POST | admin/station/takeOff | unshelveNew | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/station/getStationType/{source}/{code} | getStationSource | Observable<BaseResponse<NewCabinetBean>> | Path("source") String type; Path("code") String code |  |
| GET | admin/blueTooth/getLockIdBySn | getLockIdBySn | Observable<BaseResponse<SNBean>> | Query("sn") String sn |  |
| POST | admin/blueTooth/authAdd | authAdd | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/station/queryStationPermission | getAuthorizationRecordListData | Observable<BaseResponse<AuthorizationRecordList>> | QueryMap Map<String, Object> map |  |
| GET | admin/blueTooth/getUidByPhone | getUidByPhone | Observable<BaseResponse<Long>> | Query("phone") String phone |  |
| POST | admin/station/stationPermission | stationPermission | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/blueTooth/enOrDecrypt | blueToothEnOrDecrypt | Observable<BaseResponse<String>> | FieldMap Map<String, Object> map | Form |
| POST | admin/station/cancelPermission | cancelPermission | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/station/queryListBySn | getCabinetAuthorizationListSearchData | Observable<BaseResponse<CabinetAuthorizationList>> | QueryMap Map<String, Object> map |  |
| GET | admin/sys/account/queryBePermissionList | getUserAuthorizationListSearchData | Observable<BaseResponse<UserAuthorizationList>> | QueryMap Map<String, Object> map |  |
| GET | admin/station/queryStationSecretKey | getStationSecretKey | Observable<BaseResponse<String>> | Query("sn") String sn |  |
| POST | admin/station/config | configCabinet | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/station/install | putawayCabinetNew | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/citys | getCityCodeList | Observable<BaseResponse<List<CityCode>>> |  |  |
| POST | admin/operations/location | putawayCabinet | Observable<BaseResponse<String>> | Body Object body |  |
| GET | admin/operations/verifyStationLocation | checkCabinetAndCameraBound | Observable<BaseResponse<CabinetAndCameraBoundBean>> | Query("cameraSn") String cameraSn; Query("sn") String sn |  |
| POST | admin/operations/unBindDevice | unbindCabinetAndCamera | Observable<BaseResponse<String>> | FieldMap Map<String, String> body | Form |
| POST | admin/car/ctrlVehicle | sendCommandToCar | Observable<BaseResponse<Object>> | Body Object object |  |
| GET | admin/car/queryVceVersionList | getVcuVersionList | Observable<BaseResponse<List<VcuVersion>>> |  |  |

### RepairRecordOpsService.java

| Method | Path | MethodName | ReturnType | Params | Notes |
|---|---|---|---|---|---|
| GET | admin/op/queryDeviceForFix | getFixDeviceInfo | Observable<BaseResponse<DeviceFix>> | QueryMap Map<String, Object> map |  |
| POST | admin/op/saveDeviceFixRecord | addFixDeviceRecord | Observable<BaseResponse<Object>> | Body Object body |  |
| POST | admin/op/uploadImg | uploadFixImg | Observable<BaseResponse<String>> | Part MultipartBody.Part file | Multipart |
| GET | admin/device/commonSearch | getDeviceListSearchDataNew | Observable<BaseResponse<EquipmentDeviceSearchBeanNew>> | QueryMap Map<String, String> map |  |

### AfterSaleBindOpsService.java

| Method | Path | MethodName | ReturnType | Params | Notes |
|---|---|---|---|---|---|
| GET | admin/op/queryCanBindOrderList | queryCanBindOrderByUserId | Observable<BaseResponse<List<AfterSaleCanBindOrderBean>>> | Query("cardNum") String userId |  |
| GET | admin/op/queryDeviceForBindOrder | getAfterSaleBindDeviceInfo | Observable<BaseResponse<BatterOrVehicleInfo>> | QueryMap Map<String,Object> map |  |
| POST | admin/op/bindOrderDevice | afterSellBind | Observable<BaseResponse<String>> | Body Object body |  |

### UnbindOpsService.java

| Method | Path | MethodName | ReturnType | Params | Notes |
|---|---|---|---|---|---|
| POST | admin/op/unbindDevice | unBindDevice | Observable<BaseResponse<Object>> | Body Object body |  |
| GET | admin/op/queryMaintainRecord | checkExistUnCompleteCarOrder | Observable<BaseResponse<String>> | Query("cardNum") String cardNum; Query("vehicleSn") String vehicleSn |  |

### DeviceSearchOpsService.java

| Method | Path | MethodName | ReturnType | Params | Notes |
|---|---|---|---|---|---|
| GET | admin/device/commonSearch | getDeviceListSearchDataNew | Observable<BaseResponse<EquipmentDeviceSearchBeanNew>> | QueryMap Map<String, String> map |  |

### ManualreplaceOpsService.java

| Method | Path | MethodName | ReturnType | Params | Notes |
|---|---|---|---|---|---|
| POST | admin/swap/exchange | manualReplace | Observable<BaseResponse<String>> | Body Object body |  |