# power-square-android → Flutter 迁移方案（初版）

> 目标：将 Android 原生商户端（power-square-android）迁移到 Flutter（merchant_app）架构下，实现核心链路可用并逐步替代原生版本。

## 1. 项目现状速览（基于仓库结构与依赖）

- **模块结构**：`app` + `common` + `library`，大量 `BaseActivity` + DataBinding 体系。
- **网络/异步**：Retrofit + OkHttp + RxJava。
- **基础组件**：Room、EventBus、Glide/Fresco、权限库、图片选择/裁剪、ZXing 扫码、CameraX。
- **地图与定位**：Google Maps/Places/Location。
- **蓝牙**：FastBle。
- **统计与崩溃**：Firebase Analytics/Crashlytics。
- **图表**：MPAndroidChart。
- **权限**：蓝牙/定位/相机/存储/电话等较全。

> 结论：存在大量系统能力与业务模块，需**分阶段迁移**，不能自动一键转换。

---

## 2. 迁移总体路线图（7 步）

1. **清单盘点**
   - 输出 Activity/功能点/入口/权限/依赖 SDK 清单
   - 标记优先级（P0 主链路 / P1 重要 / P2 低频）

2. **API 与数据模型对齐**
   - 抽取 Retrofit 接口与模型
   - 与 Flutter `ApiService`/`models` 做映射
   - 梳理错误码、拦截器、token 刷新逻辑

3. **基础能力打底**
   - 登录态、会话、token 刷新、持久化
   - 权限管理、日志/埋点
   - 推送（FCM）、多语言、主题与通用组件

4. **主链路模块迁移**
   - 登录 → 首页 → 工作台主流程 → 设备详情 → 二维码
   - 确保“可用闭环”

5. **系统能力专项迁移**
   - 蓝牙/定位/相机/文件/扫码/地图逐个落地
   - 必要时封装原生插件

6. **报表与图表迁移**
   - 替换 MPAndroidChart
   - 校验图表展示一致性与性能

7. **回归与发布**
   - 对照测试、性能/稳定性测试
   - 灰度发布与 Crash/埋点观察

### 2.1 路线图执行清单（当前进度）

> 说明：以步骤为维度记录“已完成 / 进行中 / 待开始”的关键产出，便于持续推进。

1. **清单盘点**（进行中）
   - ✅ 已整理 Manifest Activity 清单（见第 4 节）
   - ⏳ 需补齐：入口/权限/依赖 SDK 的明细与优先级确认

2. **API 与数据模型对齐**（进行中）
   - ✅ 已抽取 OPSService 等接口清单（见第 8 节）
   - ✅ 已生成 P0/P1 模型清单与映射建议（见第 12 节）
   - ⏳ 需补齐：错误码、拦截器、token 刷新策略对照

3. **基础能力打底**（进行中）
   - ✅ 登录与会话基础链路已在 Flutter 侧存在
   - ✅ 多语言已具备基础框架
   - ✅ 已补齐：定位权限统一封装（Home/车辆搜索/地址选择）
   - ✅ 已补齐：蓝牙权限统一封装（蓝牙操作页）
   - ⏳ 需补齐：权限统一封装、日志/埋点、推送与崩溃上报

4. **主链路模块迁移**（进行中）
   - ✅ 已迁移：售后绑定（After-sale Bind）
   - ✅ 已迁移：仓库/调拨核心列表与详情（Inventory/Transport）
   - ✅ 已迁移：道路救援（Roadside Assistance）
   - ✅ 已迁移：线下用户注册（Offline User Register）
   - ✅ 已迁移：销售绑定（Sell Bind）
   - ✅ 已迁移：租赁绑定（Rent Bind）
   - ✅ 已迁移：换电绑定（Swap Bind）
   - ✅ 已迁移：押金退还（Deposit Refund）
   - ✅ 已迁移：分期缴纳（Installment Pay）
   - ✅ 已迁移：商户置换（Merchant Replace）
   - ✅ 已迁移：销售汇总（Sale Summary）
   - ✅ 已迁移：柜机/上架/授权（Cabinet Putaway/Unshelve/Authorization）
   - ✅ 已补齐：工作台扫码入口（扫码直达设备详情）、二维码列表连续扫码体验
   - ✅ 已补齐：设备搜索（扫码/搜索历史/直达设备详情）
   - ✅ 已补齐：首页/监控（地图/定位/附近车辆列表/搜索入口/筛选）
   - ✅ 已补齐：车辆搜索列表（扫码/搜索历史/定位距离/列表直达设备详情）
   - ✅ 已补齐：消息中心（系统消息列表/已读标记）
   - ✅ 已补齐：消息中心详情跳转（WebView）
   - ✅ 已补齐：用户搜索（扫码/搜索历史）
   - ✅ 已补齐：修改密码（Change Password）
   - ✅ 已补齐：用户协议/隐私政策（服务协议页 + WebView）
   - ✅ 已补齐：关于页面（版本信息展示）
   - ✅ 已补齐：语言设置（切换与选中态）
   - ✅ 已补齐：消息中心未读徽标（个人中心角标 + 列表已读）
   - ✅ 已补齐：主链路 P0 页面（工作台主入口、二维码、设备详情）
   - ✅ 已补齐：仓库/调拨剩余动作（盘点 start/scan/complete/revoke；调拨 createIssue/receive/withdraw）

5. **系统能力专项迁移**（进行中）
   - ✅ 已补齐：扫码相机权限处理（扫码/批量扫码）
   - ✅ 已补齐：iOS 使用原生地图（Apple Maps，用于地址选择/电池定位）
   - ✅ 已补齐：蓝牙运维基础能力（扫描/连接/授权/指令）

6. **报表与图表迁移**（待开始）
   - ⏳ 选型与替换（fl_chart / syncfusion_flutter_charts）

7. **回归与发布**（待开始）
   - ⏳ 回归测试计划、灰度策略、Crash/埋点观察

### 2.1.1 迁移备注（地址选择）

- Android 侧地址选择入口仅用于柜机上架与柜机基础信息编辑。
- 换电绑定、售后绑定模块不包含地址字段，无需接入地址选择。

### 2.2 下一步里程碑（建议顺序）

1. **系统能力优先落地**
   - 扫码（camera + mobile_scanner）、定位（geolocator）、地图（google_maps_flutter）

2. **基础能力完善**
   - 权限统一封装、埋点、推送/崩溃

---

## 3. Flutter 插件替代表（初选）

| Android 能力 | 原生依赖        | Flutter 候选                                                   | 备注                   |
| ------------ | --------------- | -------------------------------------------------------------- | ---------------------- |
| 网络         | Retrofit/OkHttp | dio                                                            | 已在 merchant_app 使用 |
| 图表         | MPAndroidChart  | fl_chart / syncfusion_flutter_charts                           | 选型需评估交互复杂度   |
| 蓝牙         | FastBle         | flutter_blue_plus / flutter_reactive_ble                       | 可能需二次开发         |
| 推送/崩溃    | Firebase        | firebase_messaging / firebase_crashlytics / firebase_analytics | 版本统一               |
| 地图         | Google Maps     | google_maps_flutter                                            | 需处理 key 与权限      |
| 定位         | Location        | geolocator                                                     | 结合权限库             |
| 相机         | CameraX         | camera                                                         | 需要兼容扫码           |
| 扫码         | ZXing           | mobile_scanner                                                 | 可替代多数场景         |
| 图片选择     | PictureSelector | image_picker                                                   | 若有裁剪需求需扩展     |
| 裁剪         | uCrop           | image_cropper                                                  | 兼容度验证             |
| 本地存储     | DataStore/Room  | hive / drift / shared_preferences                              | 视业务复杂度           |

---

## 4. 已识别 Activity 清单（来自 Manifest）

> 下面清单来自 Manifest 中已注册的 Activity，优先级为初步建议（需结合业务复核）。

**登录与主框架（P0）**

- CustomSplashActivity
- LoginActivity
- MainActivity

**我的/设置（P1）**

- LanguageSettingsActivity
- ServiceAgreementActivity
- AboutAppActivity
- ChangePSWActivity
- NotificationActivity

**工作台-入库/登记（P0/P1）**

- BatteryEntryActivity
- VehicleEntryActivity
- BatteryShipActivity
- StationEntryActivity
- ShipSucActivity

**工作台-设备与搜索（P0/P1）**

- DeviceDetailActivity
- EquipmentSearchActivityNew
- VehicleSearchListActivity

**工作台-售后/维修（P1）**

- AfterSaleBindActivity
- MaintenanceBookActivity
- MaintenanceSuccessActivity
- RepairRecordActivity
- UnbindDeviceActivity

**工作台-道路救援（P1）**

- RoadSideAssistantActivity
- RoadSideOrderDetailActivity
- RoadSideOrderDealActivity

**工作台-用户（P1）**

- UserListActivity
- UserSearchActivity
- UserDetailActivity

**工作台-二维码/扫码（P0）**

- QRCodeListActivity
- QRCodeActivity

**工作台-仓库/调拨（P1）**

- DeviceTransportReceiveActivity
- DeviceTransportIssueActivity
- DeviceTransportDetailActivity
- DeviceInventoryActivity
- DeviceInventoryDetailActivity
- DeviceTransorInVentorySearchActivity

**工作台-销售（P1）**

- OfflineUserRegisterActivity
- SellBindActivity
- RentBindActivity
- DepositRefundActivity
- SwapBindActivity
- InstallmentPayActivity
- SaleSummaryActivity
- MerchantReplaceActivityNew

**工作台-柜机/上架/授权（P1）**

- PutawayCabinetActivityNew
- UnshelveActivityNew
- CabinetOperateActivity
- CabinetAuthorizationOperateActivity
- CabinetOfflineDetailActivity
- CabinetOfflineFaultListActivity
- CabinetScanQrcodeActivity
- BluetoothAuthorizationActivity
- BluetoothAuthorizationActivityNew
- BluetoothOperateActivity
- BluetoothOperateActivityNew

**工作台-VCU（P2）**

- VcuDeviceSearchActivity
- VcuControlActivity

**地图/推广（P2）**

- PromoteWebActivity
- BatteryLocActivity

**被注释的 Activity（Manifest 中暂未启用）**

- BatteryRegisterActivity
- ShopCreateActivity / StockActivity / ShopListActivity
- DeviceSearchActivity / MileageActivity
- PaymentActivity / CollectionAuditActivity
- StaticSaleActivity
- UnbindActivityNew

## 4.1 未迁移清单（复核：2026-01-20）

> 说明：基于 Android 侧模块与 Flutter 现有页面对比，以下功能点尚未发现明确对应实现。

**设备详情（子分页/分栏）**

- 维修记录（DeviceFixRecord）
- 维保记录（MaintenanceRecord）
- 仓库信息（DeviceWarehouse）

**设备-电池充电列表/关键电池 SOC**

- 电池充电列表（BatteryChargeList）
- 关键电池 SOC 视图（KeyBatterySoc）

**柜机离线详情（子分页/分栏）**

- 实时信息（CabinetOfflineRealTime）
- 仓库信息（CabinetOfflineWarehouse）

**VCU**

- 历史记录（VcuHistory）
- 列表视图（VcuListView）

**维修记录（新增/录入流程）**

- 维修记录新增/提交流程（RepairRecordActivity：扫描/选择设备或站点、维修项目与结果、备注提交）

**待确认（可能已被合并为现有页面）**

- 设备综合搜索（EquipmentSearchActivityNew）

---

## 5. 已识别 API 服务与网络基建

**网络基建（common/library）**

- ServiceGenerator.java（Retrofit/OkHttp 构建与拦截器）
- BaseResponse / BaseListResponse / BaseObserver / NullAbleObserver
- ErrorMessageFactory

**业务接口（app）**

- OPSService.java：核心业务接口（登录、用户、交易、仓库、工单、蓝牙、站点、统计等）
- RepairRecordOpsService.java
- AfterSaleBindOpsService.java
- UnbindOpsService.java
- DeviceSearchOpsService.java
- ManualreplaceOpsService.java

> 说明：已扫描出大量 Retrofit 接口（GET/POST/PUT/Multipart/Streaming），后续需导出完整 API 对照表并与 Flutter `ApiService` 对齐。

---

## 6. 下一步建议（执行项）

1. **补齐 Activity → Flutter 页面映射表**：添加入口、权限、业务依赖与优先级。
2. **导出 API 对照表**：按接口分组（登录/用户/仓库/售后/蓝牙/站点/统计）。
3. **梳理系统能力清单**：蓝牙/定位/相机/扫码/地图/文件，明确插件或原生封装策略。

> 若确认继续，我会生成“页面映射表 + API 对照表”并输出迭代计划草案。

---

## 7. 页面映射表（草案）

| 模块     | Android Activity              | Flutter 目标页面（建议） | 关键能力       | 优先级 |
| -------- | ----------------------------- | ------------------------ | -------------- | ------ |
| 登录     | CustomSplashActivity          | SplashPage               | 本地缓存/路由  | P0     |
| 登录     | LoginActivity                 | LoginPage                | 网络/存储      | P0     |
| 主框架   | MainActivity                  | MainShell + Tabs         | 网络/路由      | P0     |
| 工作台   | WorkbenchFragmentNew          | WorkbenchPage            | 网络/权限      | P0     |
| 二维码   | QRCodeActivity                | QrScanPage               | 相机/扫码      | P0     |
| 设备详情 | DeviceDetailActivity          | DeviceDetailPage         | 网络/蓝牙      | P0     |
| 入库     | BatteryEntryActivity          | BatteryEntryPage         | 网络/扫码      | P1     |
| 入库     | VehicleEntryActivity          | VehicleEntryPage         | 网络/扫码      | P1     |
| 入库     | StationEntryActivity          | StationEntryPage         | 网络/扫码      | P1     |
| 出货     | BatteryShipActivity           | BatteryShipPage          | 网络/扫码      | P1     |
| 仓库     | DeviceInventoryActivity       | InventoryListPage        | 网络           | P1     |
| 仓库     | DeviceInventoryDetailActivity | InventoryDetailPage      | 网络/扫码      | P1     |
| 仓库     | DeviceTransport\*             | TransportPages           | 网络           | P1     |
| 售后     | AfterSaleBindActivity         | AfterSaleBindPage        | 网络           | P1     |
| 维修     | MaintenanceBookActivity       | MaintenanceBookPage      | 网络/图片      | P1     |
| 维修     | RepairRecordActivity          | RepairRecordPage         | 网络/图片      | P1     |
| 救援     | RoadSideAssistantActivity     | RoadSideListPage         | 网络/支付      | P1     |
| 用户     | UserListActivity              | UserListPage             | 网络           | P1     |
| 用户     | UserDetailActivity            | UserDetailPage           | 网络           | P1     |
| 销售     | SellBindActivity              | SellBindPage             | 网络/图片      | P1     |
| 销售     | RentBindActivity              | RentBindPage             | 网络           | P1     |
| 销售     | DepositRefundActivity         | DepositRefundPage        | 网络           | P1     |
| 销售     | SwapBindActivity              | SwapBindPage             | 网络           | P1     |
| 销售     | InstallmentPayActivity        | InstallmentPayPage       | 网络/支付      | P1     |
| 站点     | Cabinet\*                     | CabinetPages             | 网络/蓝牙/图片 | P1     |
| 蓝牙授权 | BluetoothAuthorization\*      | BluetoothAuthPages       | 蓝牙/权限      | P1     |
| VCU      | VcuDeviceSearchActivity       | VcuSearchPage            | 网络           | P2     |
| VCU      | VcuControlActivity            | VcuControlPage           | 网络/指令      | P2     |
| 地图     | BatteryLocActivity            | BatteryLocationPage      | 地图/定位      | P2     |
| 我的     | LanguageSettingsActivity      | LanguageSettingsPage     | 本地缓存       | P1     |
| 我的     | ChangePSWActivity             | ChangePasswordPage       | 网络           | P1     |
| 我的     | NotificationActivity          | NotificationPage         | 网络           | P1     |

---

## 8. API 对照表（分组草案）

> 仅列出核心分组与典型接口，完整清单将从 `OPSService` 与各子模块 service 中导出。

**登录与账号**

- `POST admin/sys/user/login`
- `POST admin/sys/account/refreshToken`
- `POST admin/sys/user/logout`
- `GET admin/sys/account/detail`
- `POST admin/sys/account/changePassword`
- `POST admin/sys/account/changeNickName`
- `POST admin/sys/account/changeAvatar` (Multipart)

**基础字典/配置**

- `GET admin/tenant/city/list`
- `GET admin/getAreaCodeConfig`
- `GET admin/citys`

**设备与录入**

- `GET admin/battery/getModelList`
- `POST admin/battery/register`
- `GET admin/station/getModelList`
- `POST admin/station/register`
- `GET admin/vehicle/getModelList`
- `POST admin/vehicle/register`

**销售/租赁/换电**

- `GET admin/trade/queryInfoPage`
- `GET admin/trade/queryPaymentPlanList`
- `GET admin/trade/queryUserForSell`
- `POST admin/trade/sellDevice`
- `GET admin/trade/queryUserForRent`
- `POST admin/trade/rentDevice`
- `GET admin/trade/queryUserForSwap`
- `POST admin/trade/genSwapOrder`
- `POST admin/trade/refundDeposit`
- `POST admin/trade/payPeriod`

**库存/仓库/调拨**

- `GET admin/shop/stock/index`
- `GET admin/shop/stock/queryList`
- `GET admin/shop/stock/queryTransferBatteryBySn`
- `POST admin/shop/stock/transfer`
- `GET admin/transfer/checkDeviceSn`
- `POST admin/transfer/receive`
- `POST admin/transfer/withdraw`
- `GET admin/inventory/queryDeviceInventoryPage`
- `POST admin/inventory/start`
- `POST admin/inventory/scan`
- `POST admin/inventory/complete`

**售后/维修/救援**

- `GET admin/op/queryCanBindOrderList`
- `POST admin/op/bindOrderDevice`
- `GET admin/maintenance/queryFixList`
- `POST admin/maintenance/addRecord`
- `GET admin/op/queryRoadSavePage`
- `POST admin/op/payRoadSave`
- `POST admin/op/saveRoadSaveResponse`
- `POST admin/op/uploadRoadSaveImg` (Multipart)

**用户与消息**

- `GET admin/user/queryList`
- `GET admin/user/searchList`
- `GET admin/user/getDetail`
- `GET admin/user/queryUserOrderList`
- `GET admin/sys/msg/getSysMessage`
- `POST admin/sys/msg/updateMsgFlag`

**站点/柜机/蓝牙**

- `GET admin/station/queryStationDetail`
- `POST admin/station/remote/openDoor`
- `POST admin/station/ctrlPort`
- `POST admin/station/remote/openLock`
- `GET admin/blueTooth/getLockIdBySn`
- `POST admin/blueTooth/authAdd`
- `POST admin/blueTooth/enOrDecrypt` (Form)

**地图/定位**

- `GET maps/api/directions/json`
- `GET admin/monitor/vehicle/monitorOnMap`

---

## 8.1 完整接口清单（自动抽取）

### OPSService.java

| Method | Path                                         | MethodName                            | Notes     |
| ------ | -------------------------------------------- | ------------------------------------- | --------- |
| GET    | maps/api/directions/json                     | getRoutes                             |           |
| GET    | admin/tenant/city/list                       | getCityList                           |           |
| POST   | admin/sys/user/login                         | login                                 |           |
| POST   | admin/sys/account/refreshToken               | refreshToken                          |           |
| POST   | admin/sys/user/logout                        | logout                                |           |
| GET    | admin/sys/account/detail                     | getPersonalInfo                       |           |
| POST   | admin/sys/account/changePassword             | changePSWNew                          |           |
| POST   | admin/sys/account/changeNickName             | editNickname                          |           |
| POST   | admin/sys/account/changeAvatar               | editAvatar                            | Multipart |
| GET    | admin/battery/getModelList                   | getBatteryTypeList                    |           |
| POST   | admin/battery/register                       | registerBattery                       |           |
| GET    | admin/station/getModelList                   | getStationTypeList                    |           |
| POST   | admin/station/register                       | registerStation                       |           |
| GET    | admin/vehicle/getModelList                   | getCarTypeList                        |           |
| POST   | admin/vehicle/register                       | registerCar                           |           |
| GET    | admin/trade/staticMonthlyIncome              | getSaleData                           |           |
| GET    | admin/trade/querySaleDeviceInfo              | querySaleDeviceInfo                   |           |
| GET    | admin/trade/queryInfoPage                    | queryServicePlanByName                |           |
| GET    | admin/trade/queryPaymentPlanList             | getPaymantPlanList                    |           |
| GET    | admin/trade/queryUserForSell                 | queryUserForSell                      |           |
| GET    | admin/op/queryUserForBindOrder               | queryUserForAfterSaleBind             |           |
| GET    | admin/trade/queryUserForRent                 | queryUserForRent                      |           |
| POST   | admin/trade/genSwapOrder                     | createSwapBindOrder                   |           |
| GET    | admin/trade/queryShopPayConfig               | getShopPaymentMethod                  |           |
| POST   | admin/sell/uploadCardImg                     | uploadCardImg                         | Multipart |
| POST   | admin/trade/uploadAttachment                 | uploadAttachment                      | Multipart |
| POST   | admin/user/uploadAttachment                  | userUploadAttachment                  | Multipart |
| POST   | admin/trade/confirmPayOrder                  | userConfirmPayOrder                   |           |
| POST   | admin/battery/sell                           | sellBattery                           |           |
| POST   | admin/trade/sellDevice                       | sellBind                              |           |
| POST   | admin/trade/rentDevice                       | rentBind                              |           |
| GET    | admin/monitor/vehicle/monitorOnMap           | getNearByVehicleList                  |           |
| GET    | admin/monitor/vehicle/queryRiderPhone        | getPhoneByCardNum                     |           |
| POST   | admin/shop/create                            | createShop                            |           |
| GET    | admin/shop/stock/index                       | getStockNum                           |           |
| GET    | admin/shop/stock/queryList                   | getStockList                          |           |
| GET    | admin/shop/stock/queryShopByName             | queryShopByName                       |           |
| GET    | admin/shop/stock/queryTransferBatteryBySn    | queryTransferBatteryBySn              |           |
| POST   | admin/shop/stock/transfer                    | stockTransfer                         |           |
| GET    | admin/shop/stock/queryDetail                 | queryStockDetailByTransferNo          |           |
| GET    | admin/shop/index                             | getShopNum                            |           |
| GET    | admin/shop/queryList                         | getShopList                           |           |
| GET    | admin/shop/queryDetail                       | queryShopDetail                       |           |
| POST   | admin/shop/turn                              | turnShopStatus                        |           |
| POST   | admin/shop/edit                              | editShop                              |           |
| GET    | admin/battery/searchBySn                     | searchBatteryBySn                     |           |
| POST   | admin/battery/turnDischargeStatus            | turnDischargeStatus                   | Form      |
| GET    | admin/battery/queryDeviceChargeRecord        | queryDeviceChargeRecord               |           |
| GET    | admin/battery/staticBatteryMile              | staticBatteryMile                     |           |
| GET    | admin/payment/queryOrderByNo                 | queryOrderByNo                        |           |
| POST   | admin/payment/confirm                        | confirmPayment                        |           |
| GET    | admin/payment/queryList                      | queryPaymentOrderList                 |           |
| GET    | admin/manager/queryUserForInsurance          | queryUserForInsurance                 |           |
| GET    | admin/manager/queryDeviceForInsurance        | queryDeviceForInsurance               |           |
| GET    | admin/manager/queryInsurancePlan             | queryInsurancePlan                    |           |
| POST   | admin/manager/applyInsurance                 | applyInsurance                        |           |
| GET    | admin/shop/static/index                      | getStaticSaleNum                      |           |
| GET    | admin/shop/static/queryList                  | queryStaticShopList                   |           |
| GET    | admin/shop/static/queryDetail                | getSellStaticDetail                   |           |
| GET    | admin/trade/staticLast12MonthOrderData       | get12MonthOrderDate                   |           |
| GET    | admin/trade/staticShopIncomeRank             | getSellPageRankData                   |           |
| GET    | admin/trade/queryShopSaleData                | getShopSaleData                       |           |
| GET    | admin/trade/queryAfterSaleData               | getAfterSaleData                      |           |
| GET    | admin/user/queryList                         | getUserList                           |           |
| GET    | admin/user/searchList                        | getUserListByKeyWord                  |           |
| GET    | admin/user/getDetail                         | getUserDetail                         |           |
| GET    | admin/vehicle/getDetail                      | getVehicleDetail                      |           |
| GET    | admin/user/queryUserOrderList                | getUserOrderList                      |           |
| GET    | admin/user/queryUserPayList                  | getUserPayList                        |           |
| GET    | admin/user/queryUserSwapPage                 | getBatterySwapRecord                  |           |
| GET    | admin/transfer/checkDeviceSn                 | checkDeviceSn                         |           |
| POST   | admin/transfer/receive                       | receiveDevice                         |           |
| POST   | admin/transfer/withdraw                      | withdrawDevice                        |           |
| GET    | admin/inventory/queryDeviceInventoryPage     | queryDeviceInventoryPage              |           |
| GET    | admin/inventory/queryInventoryHouseList      | queryDeviceInventoryPage              |           |
| POST   | admin/inventory/start                        | startInventory                        |           |
| GET    | admin/inventory/queryInventoryDetail         | queryInventoryDetail                  |           |
| POST   | admin/inventory/scan                         | scanInventory                         |           |
| POST   | admin/inventory/revoke                       | revokeInventory                       |           |
| POST   | admin/inventory/complete                     | completeInventory                     |           |
| GET    | admin/transfer/queryIssueDetail              | queryOutTransportDetail               |           |
| GET    | admin/transfer/queryDeviceIssuePage          | queryDeviceIssuePage                  |           |
| POST   | admin/transfer/editTrackingNumber            | editTrackingNumber                    |           |
| GET    | admin/transfer/queryMyWarehouseInfo          | queryMyWarehouseInfo                  |           |
| GET    | admin/transfer/queryDeviceReceivePage        | queryDeviceReceivePage                |           |
| GET    | admin/transfer/queryInWarehouseList          | queryInWarehouseList                  |           |
| POST   | admin/transfer/createIssue                   | createIssue                           |           |
| GET    | admin/op/queryRoadSavePage                   | queryRoadSideList                     |           |
| GET    | admin/op/queryRoadSaveInfo                   | queryRoadOrderDetail                  |           |
| POST   | admin/op/payRoadSave                         | payRoadSide                           |           |
| POST   | admin/op/saveRoadSaveResponse                | dealRoadSide                          |           |
| POST   | admin/op/uploadRoadSaveImg                   | uploadRoadSideImage                   | Multipart |
| GET    | admin/getAreaCodeConfig                      | getAreaCodeConfig                     |           |
| POST   | /admin/register                              | offlineRegister                       | Multipart |
| POST   | admin/sendSms                                | sendSms                               |           |
| POST   | user/sendChangePhoneSms                      | changePhoneSendSms                    |           |
| POST   | admin/device/getDeviceSn                     | getDeviceSn                           |           |
| GET    | admin/op/queryVehicleForMaintain             | queryAppointment                      |           |
| GET    | admin/maintenance/queryFixList               | queryRepairRecordList                 |           |
| POST   | admin/maintenance/addRecord                  | addRepairRecord                       |           |
| GET    | admin/car/queryMaintainList                  | getDeviceMaintenanceRecordList        |           |
| GET    | admin/battery/queryFixList                   | getBatteryFixRecordList               |           |
| GET    | admin/car/queryFixList                       | getCarFixRecordList                   |           |
| GET    | maps/api/directions/json                     | getPolyLine                           |           |
| POST   | admin/op/genMaintainRecord                   | genMaintainRecord                     |           |
| GET    | /admin/trade/queryRentDeviceInfo             | getRentInfo                           |           |
| GET    | admin/trade/queryUserForSwap                 | getSwapBindInfo                       |           |
| GET    | admin/trade/querySwapPackList                | getSwapPackInfo                       |           |
| GET    | admin/trade/queryUserForRefundDeposit        | getDepositRefundInfo                  |           |
| POST   | admin/trade/refundDeposit                    | refundDeposit                         |           |
| GET    | admin/trade/queryUserForPayPeriod            | getInstallmentPayInfo                 |           |
| POST   | admin/trade/payPeriod                        | payPeriod                             |           |
| GET    | admin/sys/msg/getSysMessage                  | getMsgList                            |           |
| POST   | admin/sys/msg/updateMsgFlag                  | setMsgRead                            |           |
| GET    | admin/sys/msg/getUnReadMsgNum                | getUnReadMsgCount                     |           |
| GET    | admin/station/getPortDetail                  | getCabinList                          |           |
| GET    | admin/faultReport/queryBySnAndPort           | getFaultList                          |           |
| GET    | admin/station/remote/forbiddenStorageReason  | getForbiddenStorageReason             |           |
| POST   | admin/station/remote/setPorts                | setCabinPorts                         |           |
| POST   | admin/station/remote/openDoor                | openCabinDoor                         |           |
| POST   | admin/station/ctrlPort                       | openCabinDoorNew                      |           |
| POST   | admin/station/openBackDoor                   | openCabinBackDoor                     | Form      |
| GET    | admin/station/queryFixList                   | getCabinFixRecordList                 |           |
| PUT    | admin/stations/{sn}                          | modifyCabinetInfo                     |           |
| GET    | admin/sys/accounts                           | getOpsAndMaintenaceList               |           |
| POST   | admin/station/manager/add                    | addPersonLiable                       |           |
| POST   | admin/sys/upload                             | updateCabinetImage                    | Multipart |
| POST   | admin/station/upload                         | updateCabinetImage                    | Multipart |
| GET    | admin/sys/config/location                    | getCurrentAndPoints                   |           |
| GET    | admin/station/queryStationDetail             | getCabinetBaseInfo                    |           |
| GET    | admin/station/relation/{pid}                 | getDeputyCabinet                      |           |
| POST   | admin/station/remote/setElectricCurrent      | setChargingCurrent                    |           |
| GET    | admin/stations/{sn}/history                  | getLayouCabinetInfo                   |           |
| GET    | admin/stations/{pid}/config                  | getCabinetSettingInfo                 |           |
| PUT    | admin/stations/{pid}/config                  | updateCabinetSettingInfo              |           |
| POST   | admin/station/remote/restart                 | restartCompleteMachine                |           |
| GET    | admin/station/accountInfo                    | getTemporyPSW                         |           |
| GET    | admin/station/remote/queryAndroidTime        | getCabinetTime                        |           |
| POST   | admin/station/remote/openLock                | openElectronicLock                    |           |
| POST   | admin/station/remote/shutDown                | shutDaownMachine                      |           |
| GET    | admin/station/remote/queryVersion            | getCabinetVersion                     |           |
| GET    | admin/station/remote/querySnapshotData       | getLocalStatus                        |           |
| POST   | admin/station/takeOff                        | unshelveNew                           |           |
| GET    | admin/station/getStationType/{source}/{code} | getStationSource                      |           |
| GET    | admin/blueTooth/getLockIdBySn                | getLockIdBySn                         |           |
| POST   | admin/blueTooth/authAdd                      | authAdd                               |           |
| GET    | admin/station/queryStationPermission         | getAuthorizationRecordListData        |           |
| GET    | admin/blueTooth/getUidByPhone                | getUidByPhone                         |           |
| POST   | admin/station/stationPermission              | stationPermission                     |           |
| POST   | admin/blueTooth/enOrDecrypt                  | blueToothEnOrDecrypt                  | Form      |
| POST   | admin/station/cancelPermission               | cancelPermission                      |           |
| GET    | admin/station/queryListBySn                  | getCabinetAuthorizationListSearchData |           |
| GET    | admin/sys/account/queryBePermissionList      | getUserAuthorizationListSearchData    |           |
| GET    | admin/station/queryStationSecretKey          | getStationSecretKey                   |           |
| POST   | admin/station/config                         | configCabinet                         |           |
| POST   | admin/station/install                        | putawayCabinetNew                     |           |
| GET    | admin/citys                                  | getCityCodeList                       |           |
| POST   | admin/operations/location                    | putawayCabinet                        |           |
| GET    | admin/operations/verifyStationLocation       | checkCabinetAndCameraBound            |           |
| POST   | admin/operations/unBindDevice                | unbindCabinetAndCamera                | Form      |
| POST   | admin/car/ctrlVehicle                        | sendCommandToCar                      |           |
| GET    | admin/car/queryVceVersionList                | getVcuVersionList                     |           |

### RepairRecordOpsService.java

| Method | Path                         | MethodName                 | Notes     |
| ------ | ---------------------------- | -------------------------- | --------- |
| GET    | admin/op/queryDeviceForFix   | getFixDeviceInfo           |           |
| POST   | admin/op/saveDeviceFixRecord | addFixDeviceRecord         |           |
| POST   | admin/op/uploadImg           | uploadFixImg               | Multipart |
| GET    | admin/device/commonSearch    | getDeviceListSearchDataNew |           |

### AfterSaleBindOpsService.java

| Method | Path                             | MethodName                 | Notes |
| ------ | -------------------------------- | -------------------------- | ----- |
| GET    | admin/op/queryCanBindOrderList   | queryCanBindOrderByUserId  |       |
| GET    | admin/op/queryDeviceForBindOrder | getAfterSaleBindDeviceInfo |       |
| POST   | admin/op/bindOrderDevice         | afterSellBind              |       |

### UnbindOpsService.java

| Method | Path                         | MethodName                   | Notes |
| ------ | ---------------------------- | ---------------------------- | ----- |
| POST   | admin/op/unbindDevice        | unBindDevice                 |       |
| GET    | admin/op/queryMaintainRecord | checkExistUnCompleteCarOrder |       |

### DeviceSearchOpsService.java

| Method | Path                      | MethodName                 | Notes |
| ------ | ------------------------- | -------------------------- | ----- |
| GET    | admin/device/commonSearch | getDeviceListSearchDataNew |       |

### ManualreplaceOpsService.java

| Method | Path                | MethodName    | Notes |
| ------ | ------------------- | ------------- | ----- |
| POST   | admin/swap/exchange | manualReplace |       |

## 8.2 接口明细（含参数/返回）

> 来源：Retrofit Service 接口自动抽取。

### OPSService.java

| Method | Path                                         | MethodName                            | ReturnType                                                    | Params                                                                                                                                                                                     | Notes     |
| ------ | -------------------------------------------- | ------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------- |
| GET    | maps/api/directions/json                     | getRoutes                             | Observable<PolylinePoints>                                    | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/tenant/city/list                       | getCityList                           | Observable<BaseResponse<List<City>>>                          |                                                                                                                                                                                            |           |
| POST   | admin/sys/user/login                         | login                                 | Observable<BaseResponse<User>>                                | Body Object body                                                                                                                                                                           |           |
| POST   | admin/sys/account/refreshToken               | refreshToken                          | Observable<BaseResponse<User>>                                |                                                                                                                                                                                            |           |
| POST   | admin/sys/user/logout                        | logout                                | Observable<BaseResponse<Object>>                              |                                                                                                                                                                                            |           |
| GET    | admin/sys/account/detail                     | getPersonalInfo                       | Observable<BaseResponse<Personal>>                            |                                                                                                                                                                                            |           |
| POST   | admin/sys/account/changePassword             | changePSWNew                          | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/sys/account/changeNickName             | editNickname                          | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/sys/account/changeAvatar               | editAvatar                            | Observable<BaseResponse<Object>>                              | Part MultipartBody.Part file                                                                                                                                                               | Multipart |
| GET    | admin/battery/getModelList                   | getBatteryTypeList                    | Observable<BaseResponse<List<BatteryType>>>                   |                                                                                                                                                                                            |           |
| POST   | admin/battery/register                       | registerBattery                       | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/station/getModelList                   | getStationTypeList                    | Observable<BaseResponse<List<StationType>>>                   |                                                                                                                                                                                            |           |
| POST   | admin/station/register                       | registerStation                       | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/vehicle/getModelList                   | getCarTypeList                        | Observable<BaseResponse<List<CarType>>>                       |                                                                                                                                                                                            |           |
| POST   | admin/vehicle/register                       | registerCar                           | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/trade/staticMonthlyIncome              | getSaleData                           | Observable<BaseResponse<SaleData>>                            |                                                                                                                                                                                            |           |
| GET    | admin/trade/querySaleDeviceInfo              | querySaleDeviceInfo                   | Observable<BaseResponse<BatterOrVehicleInfo>>                 | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/trade/queryInfoPage                    | queryServicePlanByName                | Observable<BaseResponse<ServicePlanInfo>>                     | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/trade/queryPaymentPlanList             | getPaymantPlanList                    | Observable<BaseResponse<List<PaymentPlan>>>                   | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/trade/queryUserForSell                 | queryUserForSell                      | Observable<BaseResponse<PurchasingUser>>                      | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/op/queryUserForBindOrder               | queryUserForAfterSaleBind             | Observable<BaseResponse<UserDetail>>                          | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/trade/queryUserForRent                 | queryUserForRent                      | Observable<BaseResponse<PurchasingUser>>                      | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/trade/genSwapOrder                     | createSwapBindOrder                   | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/trade/queryShopPayConfig               | getShopPaymentMethod                  | Observable<BaseResponse<ShopPaymentMethod>>                   | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/sell/uploadCardImg                     | uploadCardImg                         | Observable<BaseResponse<String>>                              | Part MultipartBody.Part file                                                                                                                                                               | Multipart |
| POST   | admin/trade/uploadAttachment                 | uploadAttachment                      | Observable<BaseResponse<String>>                              | Part MultipartBody.Part file                                                                                                                                                               | Multipart |
| POST   | admin/user/uploadAttachment                  | userUploadAttachment                  | Observable<BaseResponse<String>>                              | Part MultipartBody.Part file                                                                                                                                                               | Multipart |
| POST   | admin/trade/confirmPayOrder                  | userConfirmPayOrder                   | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/battery/sell                           | sellBattery                           | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/trade/sellDevice                       | sellBind                              | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/trade/rentDevice                       | rentBind                              | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/monitor/vehicle/monitorOnMap           | getNearByVehicleList                  | Observable<BaseResponse<List<NearByVehicle>>>                 | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/monitor/vehicle/queryRiderPhone        | getPhoneByCardNum                     | Observable<BaseResponse<Object>>                              | Query("cardNum") String cardNum                                                                                                                                                            |           |
| POST   | admin/shop/create                            | createShop                            | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/shop/stock/index                       | getStockNum                           | Observable<BaseResponse<StockNum>>                            | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/shop/stock/queryList                   | getStockList                          | Observable<BaseResponse<BaseListResponse<Stock>>>             | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/shop/stock/queryShopByName             | queryShopByName                       | Observable<BaseResponse<List<Shop>>>                          | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/shop/stock/queryTransferBatteryBySn    | queryTransferBatteryBySn              | Observable<BaseResponse<BatteryTransfer>>                     | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/shop/stock/transfer                    | stockTransfer                         | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/shop/stock/queryDetail                 | queryStockDetailByTransferNo          | Observable<BaseResponse<StockDetail>>                         | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/shop/index                             | getShopNum                            | Observable<BaseResponse<Shop1Num>>                            | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/shop/queryList                         | getShopList                           | Observable<BaseResponse<BaseListResponse<Shop1>>>             | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/shop/queryDetail                       | queryShopDetail                       | Observable<BaseResponse<ShopDetail>>                          | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/shop/turn                              | turnShopStatus                        | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/shop/edit                              | editShop                              | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/battery/searchBySn                     | searchBatteryBySn                     | Observable<BaseResponse<BatteryDetail>>                       | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/battery/turnDischargeStatus            | turnDischargeStatus                   | Observable<BaseResponse<Object>>                              | FieldMap Map<String, Object> map                                                                                                                                                           | Form      |
| GET    | admin/battery/queryDeviceChargeRecord        | queryDeviceChargeRecord               | Observable<BaseResponse<BaseListResponse<ChargeHistory>>>     | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/battery/staticBatteryMile              | staticBatteryMile                     | Observable<BaseResponse<StaticBatteryMile>>                   | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/payment/queryOrderByNo                 | queryOrderByNo                        | Observable<BaseResponse<PaymentOrder>>                        | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/payment/confirm                        | confirmPayment                        | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/payment/queryList                      | queryPaymentOrderList                 | Observable<BaseResponse<TotalListResponse<PaymentOrder>>>     | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/manager/queryUserForInsurance          | queryUserForInsurance                 | Observable<BaseResponse<PurchasingUser>>                      | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/manager/queryDeviceForInsurance        | queryDeviceForInsurance               | Observable<BaseResponse<Battery>>                             | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/manager/queryInsurancePlan             | queryInsurancePlan                    | Observable<BaseResponse<Insurance>>                           | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/manager/applyInsurance                 | applyInsurance                        | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/shop/static/index                      | getStaticSaleNum                      | Observable<BaseResponse<StaticSaleNum>>                       |                                                                                                                                                                                            |           |
| GET    | admin/shop/static/queryList                  | queryStaticShopList                   | Observable<BaseResponse<BaseListResponse<StaticSaleShop>>>    | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/shop/static/queryDetail                | getSellStaticDetail                   | Observable<BaseResponse<StaticSaleShopDetail>>                | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/trade/staticLast12MonthOrderData       | get12MonthOrderDate                   | Observable<BaseResponse<SalesBarData>>                        |                                                                                                                                                                                            |           |
| GET    | admin/trade/staticShopIncomeRank             | getSellPageRankData                   | Observable<BaseResponse<SaleSumPageData>>                     | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/trade/queryShopSaleData                | getShopSaleData                       | Observable<BaseResponse<SellDataListResponse>>                | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/trade/queryAfterSaleData               | getAfterSaleData                      | Observable<BaseResponse<SellDataListResponse>>                | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/user/queryList                         | getUserList                           | Observable<BaseResponse<BaseListResponse<UserInfo>>>          | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/user/searchList                        | getUserListByKeyWord                  | Observable<BaseResponse<BaseListResponse<UserInfo>>>          | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/user/getDetail                         | getUserDetail                         | Observable<BaseResponse<UserDetail>>                          | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/vehicle/getDetail                      | getVehicleDetail                      | Observable<BaseResponse<VehicleDetailBean>>                   | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/user/queryUserOrderList                | getUserOrderList                      | Observable<BaseResponse<UserOrderResponse>>                   | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/user/queryUserPayList                  | getUserPayList                        | Observable<BaseResponse<BaseListResponse<UserPaymentRecord>>> | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/user/queryUserSwapPage                 | getBatterySwapRecord                  | Observable<BaseResponse<PowerChangeBeanNew>>                  | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/transfer/checkDeviceSn                 | checkDeviceSn                         | Observable<BaseResponse<Object>>                              | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/transfer/receive                       | receiveDevice                         | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/transfer/withdraw                      | withdrawDevice                        | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/inventory/queryDeviceInventoryPage     | queryDeviceInventoryPage              | Observable<BaseResponse<DeviceInventoryResp>>                 | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/inventory/queryInventoryHouseList      | queryDeviceInventoryPage              | Observable<BaseResponse<List<WarehouseBean>>>                 |                                                                                                                                                                                            |           |
| POST   | admin/inventory/start                        | startInventory                        | Observable<BaseResponse<DeviceInventoryDetail>>               | Body Object body                                                                                                                                                                           |           |
| GET    | admin/inventory/queryInventoryDetail         | queryInventoryDetail                  | Observable<BaseResponse<DeviceInventoryDetail>>               | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/inventory/scan                         | scanInventory                         | Observable<BaseResponse<DeviceInventoryScanResult>>           | Body Object body                                                                                                                                                                           |           |
| POST   | admin/inventory/revoke                       | revokeInventory                       | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/inventory/complete                     | completeInventory                     | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/transfer/queryIssueDetail              | queryOutTransportDetail               | Observable<BaseResponse<DeviceTransportDetail>>               | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/transfer/queryDeviceIssuePage          | queryDeviceIssuePage                  | Observable<BaseResponse<DeviceTransportResp>>                 | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/transfer/editTrackingNumber            | editTrackingNumber                    | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/transfer/queryMyWarehouseInfo          | queryMyWarehouseInfo                  | Observable<BaseResponse<WarehouseBean>>                       |                                                                                                                                                                                            |           |
| GET    | admin/transfer/queryDeviceReceivePage        | queryDeviceReceivePage                | Observable<BaseResponse<DeviceTransportResp>>                 | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/transfer/queryInWarehouseList          | queryInWarehouseList                  | Observable<BaseResponse<List<WarehouseBean>>>                 | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/transfer/createIssue                   | createIssue                           | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/op/queryRoadSavePage                   | queryRoadSideList                     | Observable<BaseResponse<RoadSideListResp>>                    | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/op/queryRoadSaveInfo                   | queryRoadOrderDetail                  | Observable<BaseResponse<RoadSideOrderDetail>>                 | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/op/payRoadSave                         | payRoadSide                           | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/op/saveRoadSaveResponse                | dealRoadSide                          | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/op/uploadRoadSaveImg                   | uploadRoadSideImage                   | Observable<BaseResponse<String>>                              | Part MultipartBody.Part file                                                                                                                                                               | Multipart |
| GET    | admin/getAreaCodeConfig                      | getAreaCodeConfig                     | Observable<BaseResponse<AreaCountryResp>>                     |                                                                                                                                                                                            |           |
| POST   | /admin/register                              | offlineRegister                       | Observable<BaseResponse<Object>>                              | Part List<MultipartBody.Part> data                                                                                                                                                         | Multipart |
| POST   | admin/sendSms                                | sendSms                               | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | user/sendChangePhoneSms                      | changePhoneSendSms                    | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/device/getDeviceSn                     | getDeviceSn                           | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/op/queryVehicleForMaintain             | queryAppointment                      | Observable<BaseResponse<BookMaintenanceBean>>                 | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/maintenance/queryFixList               | queryRepairRecordList                 | Observable<BaseResponse<VehicleRepairListResp>>               | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| POST   | admin/maintenance/addRecord                  | addRepairRecord                       | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/car/queryMaintainList                  | getDeviceMaintenanceRecordList        | Observable<BaseResponse<DeviceMaintenanceResponse>>           | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn                                                                                                        |           |
| GET    | admin/battery/queryFixList                   | getBatteryFixRecordList               | Observable<BaseResponse<DeviceFixRecordResponse>>             | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn                                                                                                        |           |
| GET    | admin/car/queryFixList                       | getCarFixRecordList                   | Observable<BaseResponse<DeviceFixRecordResponse>>             | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn                                                                                                        |           |
| GET    | maps/api/directions/json                     | getPolyLine                           | Observable<BaseResponse<PolylinePointsBean>>                  | Query("origin") String origin; Query("destination") String destination; Query("avoid") String avoid; Query("mode") String mode; Query("key") String key                                    |           |
| POST   | admin/op/genMaintainRecord                   | genMaintainRecord                     | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | /admin/trade/queryRentDeviceInfo             | getRentInfo                           | Observable<BaseResponse<RentDeviceInfoBean>>                  | Query("deviceSn") String deviceSn                                                                                                                                                          |           |
| GET    | admin/trade/queryUserForSwap                 | getSwapBindInfo                       | Observable<BaseResponse<SwapBindInfo>>                        | Query("cardNum") String cardNum                                                                                                                                                            |           |
| GET    | admin/trade/querySwapPackList                | getSwapPackInfo                       | Observable<BaseResponse<List<Pack>>>                          | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/trade/queryUserForRefundDeposit        | getDepositRefundInfo                  | Observable<BaseResponse<DepositRefundInfoBean>>               | Query("cardNum") String cardNum                                                                                                                                                            |           |
| POST   | admin/trade/refundDeposit                    | refundDeposit                         | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/trade/queryUserForPayPeriod            | getInstallmentPayInfo                 | Observable<BaseResponse<InstallmentPaymentResponse>>          | Query("cardNum") String cardNum                                                                                                                                                            |           |
| POST   | admin/trade/payPeriod                        | payPeriod                             | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/sys/msg/getSysMessage                  | getMsgList                            | Observable<BaseResponse<MessageListResponse>>                 | QueryMap HashMap<String, Object> map                                                                                                                                                       |           |
| POST   | admin/sys/msg/updateMsgFlag                  | setMsgRead                            | Observable<BaseResponse<Object>>                              | Body Object object                                                                                                                                                                         |           |
| GET    | admin/sys/msg/getUnReadMsgNum                | getUnReadMsgCount                     | Observable<BaseResponse<Integer>>                             |                                                                                                                                                                                            |           |
| GET    | admin/station/getPortDetail                  | getCabinList                          | Observable<BaseResponse<List<Cabin>>>                         | Query("sn") String sn                                                                                                                                                                      |           |
| GET    | admin/faultReport/queryBySnAndPort           | getFaultList                          | Observable<BaseResponse<CabinFaultBean>>                      | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn; Query("port") int port/_; Query("nID") String nID_/                                                   |           |
| GET    | admin/station/remote/forbiddenStorageReason  | getForbiddenStorageReason             | Observable<BaseResponse<List<ForbiddenReasonBean>>>           |                                                                                                                                                                                            |           |
| POST   | admin/station/remote/setPorts                | setCabinPorts                         | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/station/remote/openDoor                | openCabinDoor                         | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/station/ctrlPort                       | openCabinDoorNew                      | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/station/openBackDoor                   | openCabinBackDoor                     | Observable<BaseResponse<Object>>                              | FieldMap Map<String, Object> map                                                                                                                                                           | Form      |
| GET    | admin/station/queryFixList                   | getCabinFixRecordList                 | Observable<BaseResponse<DeviceFixRecordResponse>>             | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("sn") String sn                                                                                                        |           |
| PUT    | admin/stations/{sn}                          | modifyCabinetInfo                     | Observable<BaseResponse<String>>                              | Path("sn") String sn; Body Object body                                                                                                                                                     |           |
| GET    | admin/sys/accounts                           | getOpsAndMaintenaceList               | Observable<BaseResponse<OpsAndMaintenaceBean>>                | Query("pageNum") int pageNum; Query("pageSize") int pageSize; Query("phone") String phone; Query("userName") String userName; Query("platform") int platform; Query("enabled") int enabled |           |
| POST   | admin/station/manager/add                    | addPersonLiable                       | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/sys/upload                             | updateCabinetImage                    | Observable<BaseResponse<List<String>>>                        | Query("pid") String pid; Part List<MultipartBody.Part> files                                                                                                                               | Multipart |
| POST   | admin/station/upload                         | updateCabinetImage                    | Observable<BaseResponse<String>>                              | Part MultipartBody.Part file                                                                                                                                                               | Multipart |
| GET    | admin/sys/config/location                    | getCurrentAndPoints                   | Observable<BaseResponse<List<CurrentPointBean>>>              |                                                                                                                                                                                            |           |
| GET    | admin/station/queryStationDetail             | getCabinetBaseInfo                    | Observable<BaseResponse<CabinetDetailBaseInfoBean>>           | Query("sn") String sn                                                                                                                                                                      |           |
| GET    | admin/station/relation/{pid}                 | getDeputyCabinet                      | Observable<BaseResponse<List<DeputyCabinetBean>>>             | Path("pid") String pid                                                                                                                                                                     |           |
| POST   | admin/station/remote/setElectricCurrent      | setChargingCurrent                    | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/stations/{sn}/history                  | getLayouCabinetInfo                   | Observable<BaseResponse<LayoutCabinetInfoBean>>               | Path("sn") String sn; Query("pageNum") int pageNum; Query("pageSize") int pageSize                                                                                                         |           |
| GET    | admin/stations/{pid}/config                  | getCabinetSettingInfo                 | Observable<BaseResponse<SettingInfoBean>>                     | Path("pid") String pid                                                                                                                                                                     |           |
| PUT    | admin/stations/{pid}/config                  | updateCabinetSettingInfo              | Observable<BaseResponse<String>>                              | Path("pid") String pid; Body Object body                                                                                                                                                   |           |
| POST   | admin/station/remote/restart                 | restartCompleteMachine                | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/station/accountInfo                    | getTemporyPSW                         | Observable<BaseResponse<TemporyPSWbean>>                      | Query("stationId") String stationId                                                                                                                                                        |           |
| GET    | admin/station/remote/queryAndroidTime        | getCabinetTime                        | Observable<BaseResponse<Long>>                                | Query("pID") String pID                                                                                                                                                                    |           |
| POST   | admin/station/remote/openLock                | openElectronicLock                    | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/station/remote/shutDown                | shutDaownMachine                      | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/station/remote/queryVersion            | getCabinetVersion                     | Observable<BaseResponse<CabinetVersionBean>>                  | Query("pID") String pID                                                                                                                                                                    |           |
| GET    | admin/station/remote/querySnapshotData       | getLocalStatus                        | Observable<BaseResponse<String>>                              | Query("pID") String pID                                                                                                                                                                    |           |
| POST   | admin/station/takeOff                        | unshelveNew                           | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/station/getStationType/{source}/{code} | getStationSource                      | Observable<BaseResponse<NewCabinetBean>>                      | Path("source") String type; Path("code") String code                                                                                                                                       |           |
| GET    | admin/blueTooth/getLockIdBySn                | getLockIdBySn                         | Observable<BaseResponse<SNBean>>                              | Query("sn") String sn                                                                                                                                                                      |           |
| POST   | admin/blueTooth/authAdd                      | authAdd                               | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/station/queryStationPermission         | getAuthorizationRecordListData        | Observable<BaseResponse<AuthorizationRecordList>>             | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/blueTooth/getUidByPhone                | getUidByPhone                         | Observable<BaseResponse<Long>>                                | Query("phone") String phone                                                                                                                                                                |           |
| POST   | admin/station/stationPermission              | stationPermission                     | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/blueTooth/enOrDecrypt                  | blueToothEnOrDecrypt                  | Observable<BaseResponse<String>>                              | FieldMap Map<String, Object> map                                                                                                                                                           | Form      |
| POST   | admin/station/cancelPermission               | cancelPermission                      | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/station/queryListBySn                  | getCabinetAuthorizationListSearchData | Observable<BaseResponse<CabinetAuthorizationList>>            | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/sys/account/queryBePermissionList      | getUserAuthorizationListSearchData    | Observable<BaseResponse<UserAuthorizationList>>               | QueryMap Map<String, Object> map                                                                                                                                                           |           |
| GET    | admin/station/queryStationSecretKey          | getStationSecretKey                   | Observable<BaseResponse<String>>                              | Query("sn") String sn                                                                                                                                                                      |           |
| POST   | admin/station/config                         | configCabinet                         | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| POST   | admin/station/install                        | putawayCabinetNew                     | Observable<BaseResponse<Object>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/citys                                  | getCityCodeList                       | Observable<BaseResponse<List<CityCode>>>                      |                                                                                                                                                                                            |           |
| POST   | admin/operations/location                    | putawayCabinet                        | Observable<BaseResponse<String>>                              | Body Object body                                                                                                                                                                           |           |
| GET    | admin/operations/verifyStationLocation       | checkCabinetAndCameraBound            | Observable<BaseResponse<CabinetAndCameraBoundBean>>           | Query("cameraSn") String cameraSn; Query("sn") String sn                                                                                                                                   |           |
| POST   | admin/operations/unBindDevice                | unbindCabinetAndCamera                | Observable<BaseResponse<String>>                              | FieldMap Map<String, String> body                                                                                                                                                          | Form      |
| POST   | admin/car/ctrlVehicle                        | sendCommandToCar                      | Observable<BaseResponse<Object>>                              | Body Object object                                                                                                                                                                         |           |
| GET    | admin/car/queryVceVersionList                | getVcuVersionList                     | Observable<BaseResponse<List<VcuVersion>>>                    |                                                                                                                                                                                            |           |

### RepairRecordOpsService.java

| Method | Path                         | MethodName                 | ReturnType                                             | Params                           | Notes     |
| ------ | ---------------------------- | -------------------------- | ------------------------------------------------------ | -------------------------------- | --------- |
| GET    | admin/op/queryDeviceForFix   | getFixDeviceInfo           | Observable<BaseResponse<DeviceFix>>                    | QueryMap Map<String, Object> map |           |
| POST   | admin/op/saveDeviceFixRecord | addFixDeviceRecord         | Observable<BaseResponse<Object>>                       | Body Object body                 |           |
| POST   | admin/op/uploadImg           | uploadFixImg               | Observable<BaseResponse<String>>                       | Part MultipartBody.Part file     | Multipart |
| GET    | admin/device/commonSearch    | getDeviceListSearchDataNew | Observable<BaseResponse<EquipmentDeviceSearchBeanNew>> | QueryMap Map<String, String> map |           |

### AfterSaleBindOpsService.java

| Method | Path                             | MethodName                 | ReturnType                                                | Params                          | Notes |
| ------ | -------------------------------- | -------------------------- | --------------------------------------------------------- | ------------------------------- | ----- |
| GET    | admin/op/queryCanBindOrderList   | queryCanBindOrderByUserId  | Observable<BaseResponse<List<AfterSaleCanBindOrderBean>>> | Query("cardNum") String userId  |       |
| GET    | admin/op/queryDeviceForBindOrder | getAfterSaleBindDeviceInfo | Observable<BaseResponse<BatterOrVehicleInfo>>             | QueryMap Map<String,Object> map |       |
| POST   | admin/op/bindOrderDevice         | afterSellBind              | Observable<BaseResponse<String>>                          | Body Object body                |       |

### UnbindOpsService.java

| Method | Path                         | MethodName                   | ReturnType                       | Params                                                               | Notes |
| ------ | ---------------------------- | ---------------------------- | -------------------------------- | -------------------------------------------------------------------- | ----- |
| POST   | admin/op/unbindDevice        | unBindDevice                 | Observable<BaseResponse<Object>> | Body Object body                                                     |       |
| GET    | admin/op/queryMaintainRecord | checkExistUnCompleteCarOrder | Observable<BaseResponse<String>> | Query("cardNum") String cardNum; Query("vehicleSn") String vehicleSn |       |

### DeviceSearchOpsService.java

| Method | Path                      | MethodName                 | ReturnType                                             | Params                           | Notes |
| ------ | ------------------------- | -------------------------- | ------------------------------------------------------ | -------------------------------- | ----- |
| GET    | admin/device/commonSearch | getDeviceListSearchDataNew | Observable<BaseResponse<EquipmentDeviceSearchBeanNew>> | QueryMap Map<String, String> map |       |

### ManualreplaceOpsService.java

| Method | Path                | MethodName    | ReturnType                       | Params           | Notes |
| ------ | ------------------- | ------------- | -------------------------------- | ---------------- | ----- |
| POST   | admin/swap/exchange | manualReplace | Observable<BaseResponse<String>> | Body Object body |       |

## 9. 迭代计划草案（节奏建议）

- **第 1 迭代（2-3 周）**：登录/主框架/工作台主入口/二维码/设备详情
- **第 2 迭代（3-4 周）**：仓库/调拨/用户/售后维修
- **第 3 迭代（3-4 周）**：柜机/蓝牙授权/销售与报表/地图

> 具体排期需结合页面数量、蓝牙协议复杂度、测试资源。

---

## 10. 页面 → 接口映射（首批 P0/P1）

> 先覆盖主链路页面，后续可继续补齐所有页面。

### 登录/启动

- SplashPage：无接口（本地缓存/路由）
- LoginPage：`POST admin/sys/user/login`、`POST admin/sys/account/refreshToken`
- MainShell：`GET admin/sys/account/detail`、`GET admin/sys/msg/getUnReadMsgNum`

### 工作台（主入口）

- WorkbenchPage：`GET admin/trade/staticMonthlyIncome`、`GET admin/shop/index`
- QRCodeListPage：`POST admin/device/getDeviceSn`
- QrScanPage：`POST admin/device/getDeviceSn`

### 设备详情

- DeviceDetailPage：`GET admin/battery/searchBySn`、`GET admin/battery/queryDeviceChargeRecord`、`POST admin/battery/turnDischargeStatus`

### 入库/登记

- BatteryEntryPage：`GET admin/battery/getModelList`、`POST admin/battery/register`
- VehicleEntryPage：`GET admin/vehicle/getModelList`、`POST admin/vehicle/register`
- StationEntryPage：`GET admin/station/getModelList`、`POST admin/station/register`

### 仓库/调拨

- InventoryListPage：`GET admin/inventory/queryDeviceInventoryPage`
- InventoryDetailPage：`GET admin/inventory/queryInventoryDetail`、`POST admin/inventory/scan`、`POST admin/inventory/complete`
- TransportPages：`GET admin/transfer/queryDeviceIssuePage`、`GET admin/transfer/queryDeviceReceivePage`、`POST admin/transfer/createIssue`

### 售后/维修

- AfterSaleBindPage：`GET admin/op/queryCanBindOrderList`、`GET admin/op/queryDeviceForBindOrder`、`POST admin/op/bindOrderDevice`
- RepairRecordPage：`GET admin/maintenance/queryFixList`、`POST admin/maintenance/addRecord`、`POST admin/op/uploadImg`

### 用户/消息

- UserListPage：`GET admin/user/queryList`、`GET admin/user/searchList`
- UserDetailPage：`GET admin/user/getDetail`、`GET admin/user/queryUserOrderList`
- NotificationPage：`GET admin/sys/msg/getSysMessage`、`POST admin/sys/msg/updateMsgFlag`

### 销售/租赁/换电

- SellBindPage：`GET admin/trade/queryUserForSell`、`GET admin/trade/querySaleDeviceInfo`、`POST admin/trade/sellDevice`
- RentBindPage：`GET admin/trade/queryUserForRent`、`GET /admin/trade/queryRentDeviceInfo`、`POST admin/trade/rentDevice`
- SwapBindPage：`GET admin/trade/queryUserForSwap`、`GET admin/trade/querySwapPackList`、`POST admin/trade/genSwapOrder`
- DepositRefundPage：`GET admin/trade/queryUserForRefundDeposit`、`POST admin/trade/refundDeposit`
- InstallmentPayPage：`GET admin/trade/queryUserForPayPeriod`、`POST admin/trade/payPeriod`、`POST admin/trade/uploadAttachment`
- SaleSummaryPage：`GET admin/trade/staticLast12MonthOrderData`、`GET admin/trade/queryShopSaleData`、`GET admin/trade/queryAfterSaleData`

### 柜机/站点/蓝牙授权

- CabinetBaseInfoPage：`GET admin/station/queryStationDetail`、`GET admin/station/getPortDetail`
- CabinetControlPage：`POST admin/station/remote/openDoor`、`POST admin/station/ctrlPort`、`POST admin/station/remote/openLock`
- CabinetSettingsPage：`GET admin/stations/{pid}/config`、`PUT admin/stations/{pid}/config`
- CabinetMaintenancePage：`GET admin/station/queryFixList`、`GET admin/station/remote/queryVersion`
- BluetoothAuthPage：`GET admin/blueTooth/getLockIdBySn`、`POST admin/blueTooth/authAdd`、`POST admin/blueTooth/enOrDecrypt`
- PermissionManagePage：`GET admin/station/queryStationPermission`、`POST admin/station/stationPermission`、`POST admin/station/cancelPermission`

### 地图/定位

- BatteryLocationPage：`GET maps/api/directions/json`、`GET admin/monitor/vehicle/monitorOnMap`

---

## 11. 本地存储键位迁移（SharedPreferences → Flutter）

> 来源：`common/Preferences.java`。Flutter 侧建议使用 `shared_preferences` 或 `hive` 统一封装。

| Key                           | 含义         | 备注                           |
| ----------------------------- | ------------ | ------------------------------ |
| area_code                     | 手机区号     |                                |
| phone                         | 手机号       |                                |
| account                       | 登录账号     |                                |
| roles                         | 用户角色     |                                |
| servicetypes                  | 服务类型     |                                |
| name                          | 用户名       |                                |
| user_code                     | 用户编码     |                                |
| avator                        | 头像 URL     |                                |
| <phone>\_user_psw             | 用户密码     | 与手机号拼接                   |
| <phone>\_token                | Token        | 与手机号拼接                   |
| language                      | 语言         | 默认 `en`                      |
| language_country              | 语言国家     |                                |
| language_name                 | 语言名称     | 默认 `United States - English` |
| latitude                      | 纬度         | 默认 `0.0`                     |
| lontitude                     | 经度         | 默认 `0.0`                     |
| logout                        | 登出状态     | 0:登录中 1:登出                |
| select                        | 用户协议勾选 |                                |
| app_server                    | 服务节点     | 0:新加坡 1:开普敦              |
| search_name                   | 用户搜索历史 |                                |
| search*device*<account>       | 设备搜索历史 | 与账号拼接                     |
| danger_region_list            | 危险区域列表 | JSON 字符串                    |
| danger*region*<regionNo>      | 危险区域详情 | 与区域编号拼接                 |
| detect*vehicle_ble*<username> | 车辆蓝牙检测 | 默认 true                      |
| vcu*history*<username>        | VCU 历史     | JSON 字符串                    |

---

## 12. 数据模型清单（beans）

完整列表已生成：
[docs/model-list.generated.md](docs/model-list.generated.md)

**迁移建议**

- 以接口为入口建立 Dart `models/`，优先覆盖 P0/P1 页面对应的响应模型。
- Java/Kotlin Bean → Dart `freezed`/`json_serializable`（建议统一风格）。
- 与 `BaseResponse`/分页结构保持一致（可复用现有 Flutter `base_response`）。

## 12.1 P0/P1 页面模型清单（优先）

自动抽取清单：
[docs/p0-p1-models.generated.md](docs/p0-p1-models.generated.md)

## 12.2 P0/P1 模型落地映射表

自动生成文件路径建议：
[docs/p0-p1-models-mapping.generated.md](docs/p0-p1-models-mapping.generated.md)

已生成导出文件：
[lib/data/models/models.dart](lib/data/models/models.dart)

## 12.3 P0/P1 模型字段清单

自动抽取字段清单：
[docs/p0-p1-model-fields.generated.md](docs/p0-p1-model-fields.generated.md)
