# Flutter 商户端单元测试清单

> 生成日期：2026-02-02  
> 最后更新：2026-02-03  
> 状态说明：⬜ 待开始 | 🔄 进行中 | ✅ 已完成
> 当前测试总数：**484 个测试通过** ✅

---

## 一、测试统计

| 优先级   | 模块数 | 测试文件数 | 已完成 | 完成率   |
| -------- | ------ | ---------- | ------ | -------- |
| P0       | 4      | 10         | 10     | 100%     |
| P1       | 11     | 28         | 28     | 100%     |
| P2       | 3      | 5          | 5      | 100%     |
| **总计** | **18** | **43**     | **43** | **100%** |

---

## 二、P0 核心链路（必须覆盖）

### 1. 登录与认证

| 状态 | 测试文件                 | Controller/Model | 测试点                        |
| ---- | ------------------------ | ---------------- | ----------------------------- |
| ✅   | `auth_result_test.dart`  | `AuthResult`     | JSON序列化/反序列化、字段解析 |
| ✅   | `user_state_test.dart`   | `UserState`      | 认证状态、copyWith            |
| ✅   | `auth_session_test.dart` | `AuthSession`    | 单例、update/clear            |

### 2. 工作台

| 状态 | 测试文件                    | Controller/Model | 测试点   |
| ---- | --------------------------- | ---------------- | -------- |
| ✅   | `sale_data_model_test.dart` | `SaleData`       | JSON解析 |

### 3. 设备管理

| 状态 | 测试文件                         | Controller/Model    | 测试点                 |
| ---- | -------------------------------- | ------------------- | ---------------------- |
| ✅   | `device_detail_state_test.dart`  | `DeviceDetailState` | State copyWith、默认值 |
| ✅   | `battery_detail_model_test.dart` | `BatteryDetail`     | JSON解析               |
| ✅   | `vehicle_detail_model_test.dart` | `VehicleDetail`     | JSON解析               |

### 4. 二维码/扫码

| 状态 | 测试文件                       | Controller/Model  | 测试点                 |
| ---- | ------------------------------ | ----------------- | ---------------------- |
| ✅   | `qr_code_list_state_test.dart` | `QrCodeListState` | State copyWith、默认值 |
| ✅   | `scan_utils_test.dart`         | `ScanUtils`       | 各种格式二维码解析     |

---

## 三、P1 重要功能

### 5. 仓库/调拨

| 状态 | 测试文件                    | Controller/Model                          | 测试点                        |
| ---- | --------------------------- | ----------------------------------------- | ----------------------------- |
| ✅   | `inventory_state_test.dart` | `InventoryListState/DetailState`          | State copyWith、分页逻辑      |
| ✅   | `transport_state_test.dart` | `TransportListState`                      | State copyWith、TransportMode |
| ✅   | `receive_state_test.dart`   | `ReceiveListState` / `ReceiveDetailState` | State copyWith、分页          |

### 6. 销售/租赁/换电

| 状态 | 测试文件                          | Controller/Model      | 测试点                          |
| ---- | --------------------------------- | --------------------- | ------------------------------- |
| ✅   | `sell_bind_state_test.dart`       | `SellBindState`       | State copyWith、多种loading状态 |
| ✅   | `purchasing_user_model_test.dart` | `PurchasingUser`      | JSON解析                        |
| ✅   | `service_plan_model_test.dart`    | `ServicePlan`         | JSON解析                        |
| ✅   | `payment_plan_model_test.dart`    | `PaymentPlan`         | JSON解析                        |
| ✅   | `sale_summary_state_test.dart`    | `SaleSummaryState`    | State copyWith、默认值          |
| ✅   | `deposit_refund_state_test.dart`  | `DepositRefundState`  | State copyWith、默认值          |
| ✅   | `swap_bind_state_test.dart`       | `SwapBindState`       | State copyWith、默认值          |
| ✅   | `installment_pay_state_test.dart` | `InstallmentPayState` | State copyWith、默认值          |

### 7. 售后/维修

| 状态 | 测试文件                          | Controller/Model       | 测试点                         |
| ---- | --------------------------------- | ---------------------- | ------------------------------ |
| ✅   | `after_sale_bind_state_test.dart` | `AfterSaleBindState`   | State copyWith、默认值         |
| ✅   | `unbind_device_state_test.dart`   | `UnbindDeviceState`    | State copyWith、默认值         |
| ✅   | `maintenance_state_test.dart`     | `MaintenanceBookState` | State copyWith、canConfirmCost |
| ✅   | `device_fix_model_test.dart`      | `DeviceFix`            | JSON解析                       |

### 8. 道路救援

| 状态 | 测试文件                        | Controller/Model        | 测试点                        |
| ---- | ------------------------------- | ----------------------- | ----------------------------- |
| ✅   | `roadside_state_test.dart`      | `RoadSideListState`     | State copyWith、分页、hasMore |
| ✅   | `roadside_list_model_test.dart` | `RoadSideListResp/Info` | JSON解析                      |

### 9. 用户管理

| 状态 | 测试文件                      | Controller/Model | 测试点                               |
| ---- | ----------------------------- | ---------------- | ------------------------------------ |
| ✅   | `user_list_state_test.dart`   | `UserListState`  | State copyWith、hasMore、clearStatus |
| ✅   | `user_detail_model_test.dart` | `UserDetail`     | JSON解析                             |
| ✅   | `user_info_model_test.dart`   | `UserInfo`       | JSON解析                             |

### 10. 柜机操作

| 状态 | 测试文件                                | Controller/Model            | 测试点                 |
| ---- | --------------------------------------- | --------------------------- | ---------------------- |
| ✅   | `cabinet_remote_state_test.dart`        | `CabinetRemoteState`        | State copyWith、默认值 |
| ✅   | `cabinet_authorization_state_test.dart` | `CabinetAuthorizationState` | State copyWith、默认值 |
| ✅   | `cabinet_putaway_state_test.dart`       | `CabinetPutawayState`       | State copyWith、默认值 |
| ✅   | `cabin_model_test.dart`                 | `Cabin`                     | JSON解析               |
| ✅   | `cabinet_detail_model_test.dart`        | `CabinetDetailBaseInfoBean` | JSON解析               |

### 11. 蓝牙操作

| 状态 | 测试文件                         | Controller/Model     | 测试点                 |
| ---- | -------------------------------- | -------------------- | ---------------------- |
| ✅   | `bluetooth_auth_state_test.dart` | `BluetoothAuthState` | State copyWith、默认值 |
| ✅   | `ble_command_test.dart`          | `BleCommandBuilder`  | 指令构建、响应解析     |

### 12. 门店/库存

| 状态 | 测试文件                      | Controller/Model                      | 测试点                  |
| ---- | ----------------------------- | ------------------------------------- | ----------------------- |
| ✅   | `shop_state_test.dart`        | `ShopListState` / `ShopDetailState`   | State copyWith、hasMore |
| ✅   | `stock_state_test.dart`       | `StockListState` / `StockDetailState` | State copyWith、hasMore |
| ✅   | `shop_static_state_test.dart` | `ShopStaticListState`                 | State copyWith、hasMore |

### 13. 支付确认

| 状态 | 测试文件                        | Controller/Model                           | 测试点                  |
| ---- | ------------------------------- | ------------------------------------------ | ----------------------- |
| ✅   | `payment_state_test.dart`       | `PaymentListState` / `PaymentConfirmState` | State copyWith、hasMore |
| ✅   | `payment_order_model_test.dart` | `PaymentOrder`                             | JSON解析                |

### 14. 保险

| 状态 | 测试文件                    | Controller/Model      | 测试点                 |
| ---- | --------------------------- | --------------------- | ---------------------- |
| ✅   | `insurance_state_test.dart` | `InsuranceApplyState` | State copyWith、默认值 |

### 15. 个人中心

| 状态 | 测试文件                      | Controller/Model   | 测试点                             |
| ---- | ----------------------------- | ------------------ | ---------------------------------- |
| ✅   | `profile_state_test.dart`     | `ProfileState`     | State copyWith、unreadMessageCount |
| ✅   | `message_state_test.dart`     | `MessageListState` | State copyWith、hasMore            |
| ✅   | `language_notifier_test.dart` | `LanguageNotifier` | Locale 创建、比较                  |

---

## 四、P2 低频功能

### 16. VCU控制

| 状态 | 测试文件                      | Controller/Model | 测试点                 |
| ---- | ----------------------------- | ---------------- | ---------------------- |
| ✅   | `vcu_state_test.dart`         | `VcuState`       | State copyWith、默认值 |
| ✅   | `vcu_version_model_test.dart` | `VcuVersion`     | JSON解析               |

### 17. 系统配置

| 状态 | 测试文件                     | Controller/Model | 测试点                 |
| ---- | ---------------------------- | ---------------- | ---------------------- |
| ✅   | `sys_config_state_test.dart` | `SysConfigState` | State copyWith、默认值 |

### 18. 相机操作

| 状态 | 测试文件                 | Controller/Model       | 测试点                 |
| ---- | ------------------------ | ---------------------- | ---------------------- |
| ✅   | `camera_state_test.dart` | `CameraOperationState` | State copyWith、默认值 |

---

## 五、测试目录结构

```
test/
├── widget_test.dart                 # 现有 Widget 测试
├── data/
│   └── models/
│       ├── user_model_test.dart
│       ├── sale_data_model_test.dart
│       ├── battery_detail_model_test.dart
│       ├── vehicle_detail_model_test.dart
│       ├── device_transport_model_test.dart
│       ├── device_inventory_model_test.dart
│       ├── purchasing_user_model_test.dart
│       ├── service_plan_model_test.dart
│       ├── payment_plan_model_test.dart
│       ├── device_fix_model_test.dart
│       ├── roadside_order_model_test.dart
│       ├── user_detail_model_test.dart
│       ├── cabin_model_test.dart
│       ├── cabinet_detail_model_test.dart
│       ├── payment_order_model_test.dart
│       └── vcu_version_model_test.dart
├── features/
│   ├── login/
│   │   └── auth_controller_test.dart
│   ├── work/
│   │   ├── work_controller_test.dart
│   │   ├── device/
│   │   │   └── device_detail_controller_test.dart
│   │   ├── qrcode/
│   │   │   └── qr_code_list_controller_test.dart
│   │   ├── warehouse/
│   │   │   ├── inventory_list_controller_test.dart
│   │   │   ├── inventory_detail_controller_test.dart
│   │   │   ├── transport_list_controller_test.dart
│   │   │   ├── transport_detail_controller_test.dart
│   │   │   └── receive_controller_test.dart
│   │   ├── sales/
│   │   │   ├── sell_bind_controller_test.dart
│   │   │   ├── sale_summary_controller_test.dart
│   │   │   ├── deposit_refund_controller_test.dart
│   │   │   ├── swap_bind_controller_test.dart
│   │   │   └── installment_controller_test.dart
│   │   ├── after_sale/
│   │   │   ├── after_sale_bind_controller_test.dart
│   │   │   └── unbind_device_controller_test.dart
│   │   ├── maintenance/
│   │   │   ├── maintenance_book_controller_test.dart
│   │   │   └── repair_record_controller_test.dart
│   │   ├── roadside/
│   │   │   └── roadside_controller_test.dart
│   │   ├── user/
│   │   │   ├── user_list_controller_test.dart
│   │   │   └── user_detail_controller_test.dart
│   │   ├── cabinet/
│   │   │   ├── cabinet_remote_controller_test.dart
│   │   │   ├── cabinet_authorization_controller_test.dart
│   │   │   └── cabinet_putaway_controller_test.dart
│   │   ├── bluetooth/
│   │   │   ├── bluetooth_auth_controller_test.dart
│   │   │   └── ble_command_test.dart
│   │   ├── shop/
│   │   │   ├── shop_controller_test.dart
│   │   │   └── shop_static_controller_test.dart
│   │   ├── stock/
│   │   │   └── stock_controller_test.dart
│   │   ├── payment/
│   │   │   └── payment_controller_test.dart
│   │   ├── insurance/
│   │   │   └── insurance_controller_test.dart
│   │   ├── vcu/
│   │   │   └── vcu_controller_test.dart
│   │   └── camera/
│   │       └── camera_controller_test.dart
│   ├── me/
│   │   ├── profile_controller_test.dart
│   │   ├── message_controller_test.dart
│   │   └── language_notifier_test.dart
│   └── common/
│       └── sys_config_controller_test.dart
└── mocks/
    ├── mock_api_service.dart
    └── mock_providers.dart
```

---

## 六、执行说明

### 运行全部测试

```bash
flutter test
```

### 运行指定模块测试

```bash
# 运行登录模块测试
flutter test test/features/login/

# 运行仓库模块测试
flutter test test/features/work/warehouse/

# 运行 Model 测试
flutter test test/data/models/
```

### 运行单个测试文件

```bash
flutter test test/features/login/auth_controller_test.dart
```

### 生成覆盖率报告

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 七、更新日志

| 日期       | 更新内容       | 操作人  |
| ---------- | -------------- | ------- |
| 2026-02-02 | 初始化测试清单 | Copilot |
