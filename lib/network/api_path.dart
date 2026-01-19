class ApiPath {

  static const String proBaseUrl = 'https://okla-admin-app.esquare-global.com';
  static const String testBaseUrl = 'https://okla-admin-app.esquare-global.com';

  static const String posts = '/posts';
  static const String user = '/users';
  static const String login = '/admin/sys/user/login';
  static const String logout = '/admin/sys/user/logout';
  static const String refreshToken = '/admin/sys/account/refreshToken';

  // 入库/登记
  static const String batteryModelList = '/admin/battery/getModelList';
  static const String batteryRegister = '/admin/battery/register';
  static const String vehicleModelList = '/admin/vehicle/getModelList';
  static const String vehicleRegister = '/admin/vehicle/register';
  static const String stationModelList = '/admin/station/getModelList';
  static const String stationRegister = '/admin/station/register';

  // 售后绑定
  static const String afterSaleQueryUserForBindOrder =
      '/admin/op/queryUserForBindOrder';
  static const String afterSaleQueryCanBindOrderList =
      '/admin/op/queryCanBindOrderList';
  static const String afterSaleQueryDeviceForBindOrder =
      '/admin/op/queryDeviceForBindOrder';
  static const String afterSaleBindOrderDevice = '/admin/op/bindOrderDevice';

  // 用户
  static const String userQueryList = '/admin/user/queryList';
  static const String userSearchList = '/admin/user/searchList';
  static const String userGetDetail = '/admin/user/getDetail';
  static const String userQueryOrderList = '/admin/user/queryUserOrderList';
  static const String userUploadAttachment = '/admin/user/uploadAttachment';
  static const String tradeUploadAttachment = '/admin/trade/uploadAttachment';
  static const String userConfirmPayOrder = '/admin/trade/confirmPayOrder';

  // 维修/保养
  static const String maintenanceQueryAppointment =
      '/admin/op/queryVehicleForMaintain';
  static const String maintenanceQueryFixList =
      '/admin/maintenance/queryFixList';
  static const String maintenanceAddRecord = '/admin/maintenance/addRecord';

  // 设备/二维码
  static const String deviceGetDeviceSn = '/admin/device/getDeviceSn';
  static const String batterySearchBySn = '/admin/battery/searchBySn';
  static const String batteryQueryDeviceChargeRecord =
      '/admin/battery/queryDeviceChargeRecord';
  static const String batteryTurnDischargeStatus =
      '/admin/battery/turnDischargeStatus';

  // 工作台
  static const String workbenchMonthlyIncome =
      '/admin/trade/staticMonthlyIncome';
  static const String workbenchShopIndex = '/admin/shop/index';

  // 销售统计
  static const String saleSummaryLast12MonthOrderData =
      '/admin/trade/staticLast12MonthOrderData';
  static const String saleSummaryRank = '/admin/trade/staticShopIncomeRank';
  static const String saleSummaryQueryShopSaleData =
      '/admin/trade/queryShopSaleData';
  static const String saleSummaryQueryAfterSaleData =
      '/admin/trade/queryAfterSaleData';

    // 销售/注册
    static const String areaCodeConfig = '/admin/getAreaCodeConfig';
    static const String offlineRegister = '/admin/register';
    static const String sendSms = '/admin/sendSms';
  static const String querySaleDeviceInfo = '/admin/trade/querySaleDeviceInfo';
  static const String queryServicePlanByName = '/admin/trade/queryInfoPage';
  static const String queryPaymentPlanList =
      '/admin/trade/queryPaymentPlanList';
  static const String queryUserForSell = '/admin/trade/queryUserForSell';
  static const String queryUserForRent = '/admin/trade/queryUserForRent';
  static const String sellBind = '/admin/trade/sellDevice';
  static const String rentBind = '/admin/trade/rentDevice';
  static const String uploadCardImg = '/admin/sell/uploadCardImg';
  static const String queryRentDeviceInfo = '/admin/trade/queryRentDeviceInfo';
  static const String queryUserForSwap = '/admin/trade/queryUserForSwap';
  static const String querySwapPackList = '/admin/trade/querySwapPackList';
  static const String createSwapBindOrder = '/admin/trade/genSwapOrder';
  static const String queryShopPayConfig = '/admin/trade/queryShopPayConfig';
  static const String queryUserForRefundDeposit =
      '/admin/trade/queryUserForRefundDeposit';
  static const String refundDeposit = '/admin/trade/refundDeposit';
    static const String queryUserForPayPeriod = '/admin/trade/queryUserForPayPeriod';
    static const String payPeriod = '/admin/trade/payPeriod';
    static const String manualReplace = '/admin/swap/exchange';

    // 道路救援
    static const String roadSaveQueryPage = '/admin/op/queryRoadSavePage';
    static const String roadSaveQueryInfo = '/admin/op/queryRoadSaveInfo';
    static const String roadSavePay = '/admin/op/payRoadSave';
    static const String roadSaveDeal = '/admin/op/saveRoadSaveResponse';
    static const String roadSaveUploadImg = '/admin/op/uploadRoadSaveImg';

  // 设备解绑
  static const String unbindDevice = '/admin/op/unbindDevice';
  static const String unbindCheckMaintainRecord =
      '/admin/op/queryMaintainRecord';

  // 仓库/盘点
  static const String inventoryQueryDeviceInventoryPage =
      '/admin/inventory/queryDeviceInventoryPage';
  static const String inventoryQueryInventoryDetail =
      '/admin/inventory/queryInventoryDetail';
  static const String inventoryStart = '/admin/inventory/start';
  static const String inventoryScan = '/admin/inventory/scan';
  static const String inventoryRevoke = '/admin/inventory/revoke';
  static const String inventoryComplete = '/admin/inventory/complete';
  static const String inventoryQueryInventoryHouseList =
      '/admin/inventory/queryInventoryHouseList';

  // 调拨
  static const String transportQueryDeviceIssuePage =
      '/admin/transfer/queryDeviceIssuePage';
  static const String transportQueryDeviceReceivePage =
      '/admin/transfer/queryDeviceReceivePage';
  static const String transportQueryIssueDetail =
      '/admin/transfer/queryIssueDetail';
  static const String transportQueryMyWarehouseInfo =
      '/admin/transfer/queryMyWarehouseInfo';
  static const String transportQueryInWarehouseList =
      '/admin/transfer/queryInWarehouseList';
  static const String transportCreateIssue = '/admin/transfer/createIssue';
  static const String transportReceive = '/admin/transfer/receive';
  static const String transportWithdraw = '/admin/transfer/withdraw';
  static const String transportEditTrackingNumber =
      '/admin/transfer/editTrackingNumber';
  static const String transportCheckDeviceSn =
      '/admin/transfer/checkDeviceSn';
}
