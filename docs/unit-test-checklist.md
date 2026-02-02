# Flutter 商户端单元测试清单

> 生成日期：2026-02-02  
> 最后更新：2026-02-02  
> 状态说明：⬜ 待开始 | 🔄 进行中 | ✅ 已完成

---

## 一、测试统计

| 优先级   | 模块数 | 测试文件数 | 已完成 | 完成率  |
| -------- | ------ | ---------- | ------ | ------- |
| P0       | 4      | 10         | 10     | 100%    |
| P1       | 11     | 28         | 6      | 21%     |
| P2       | 3      | 5          | 0      | 0%      |
| **总计** | **18** | **43**     | **16** | **37%** |

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

| 状态 | 测试文件                       | Controller/Model                                | 测试点                        |
| ---- | ------------------------------ | ----------------------------------------------- | ----------------------------- |
| ✅   | `inventory_state_test.dart`    | `InventoryListState/DetailState`                | State copyWith、分页逻辑      |
| ✅   | `transport_state_test.dart`    | `TransportListState`                            | State copyWith、TransportMode |
| ⬜   | `receive_controller_test.dart` | `ReceiveListNotifier` / `ReceiveDetailNotifier` | 收货列表、收货确认、拒收      |

### 6. 销售/租赁/换电

| 状态 | 测试文件                              | Controller/Model      | 测试点                          |
| ---- | ------------------------------------- | --------------------- | ------------------------------- |
| ✅   | `sell_bind_state_test.dart`           | `SellBindState`       | State copyWith、多种loading状态 |
| ✅   | `purchasing_user_model_test.dart`     | `PurchasingUser`      | JSON解析                        |
| ✅   | `service_plan_model_test.dart`        | `ServicePlan`         | JSON解析                        |
| ✅   | `payment_plan_model_test.dart`        | `PaymentPlan`         | JSON解析                        |
| ⬜   | `sale_summary_controller_test.dart`   | `SaleSummaryNotifier` | 销售统计、图表数据、12个月数据  |
| ⬜   | `deposit_refund_controller_test.dart` | -                     | 押金退款查询、退款提交          |
| ⬜   | `swap_bind_controller_test.dart`      | -                     | 换电绑定信息查询、订单创建      |
| ⬜   | `installment_controller_test.dart`    | -                     | 分期付款查询、支付提交          |

### 7. 售后/维修

| 状态 | 测试文件                                | Controller/Model                                      | 测试点                                   |
| ---- | --------------------------------------- | ----------------------------------------------------- | ---------------------------------------- |
| ⬜   | `after_sale_bind_controller_test.dart`  | `AfterSaleBindNotifier`                               | 用户查询、可绑定订单、设备查询、售后绑定 |
| ⬜   | `unbind_device_controller_test.dart`    | `UnbindDeviceNotifier`                                | 未完成订单检查、解绑提交                 |
| ⬜   | `maintenance_book_controller_test.dart` | `MaintenanceBookNotifier`                             | 预约列表、预约详情、生成维保记录         |
| ⬜   | `repair_record_controller_test.dart`    | `RepairRecordNotifier` / `RepairRecordCreateNotifier` | 维修记录列表、添加记录、图片上传         |
| ⬜   | `device_fix_model_test.dart`            | `DeviceFix`                                           | JSON解析                                 |

### 8. 道路救援

| 状态 | 测试文件                         | Controller/Model      | 测试点                             |
| ---- | -------------------------------- | --------------------- | ---------------------------------- |
| ⬜   | `roadside_controller_test.dart`  | -                     | 救援列表、救援详情、支付、处理完成 |
| ⬜   | `roadside_order_model_test.dart` | `RoadsideOrderDetail` | JSON解析                           |

### 9. 用户管理

| 状态 | 测试文件                           | Controller/Model     | 测试点                                 |
| ---- | ---------------------------------- | -------------------- | -------------------------------------- |
| ⬜   | `user_list_controller_test.dart`   | `UserListNotifier`   | 用户列表、分页、搜索                   |
| ⬜   | `user_detail_controller_test.dart` | `UserDetailNotifier` | 用户详情、订单列表、支付记录、换电记录 |
| ⬜   | `user_detail_model_test.dart`      | `UserDetail`         | JSON解析                               |

### 10. 柜机操作

| 状态 | 测试文件                                     | Controller/Model               | 测试点                                             |
| ---- | -------------------------------------------- | ------------------------------ | -------------------------------------------------- |
| ⬜   | `cabinet_remote_controller_test.dart`        | `CabinetRemoteNotifier`        | 柜机详情、舱位列表、开门、重启、设置电流、更新配置 |
| ⬜   | `cabinet_authorization_controller_test.dart` | `CabinetAuthorizationNotifier` | 授权列表、添加授权、取消授权                       |
| ⬜   | `cabinet_putaway_controller_test.dart`       | -                              | 柜机上架、位置验证、相机绑定                       |
| ⬜   | `cabin_model_test.dart`                      | `Cabin`                        | JSON解析                                           |
| ⬜   | `cabinet_detail_model_test.dart`             | `CabinetDetailBaseInfoBean`    | JSON解析                                           |

### 11. 蓝牙操作

| 状态 | 测试文件                              | Controller/Model        | 测试点                         |
| ---- | ------------------------------------- | ----------------------- | ------------------------------ |
| ⬜   | `bluetooth_auth_controller_test.dart` | `BluetoothAuthNotifier` | 锁ID查询、蓝牙加解密、授权添加 |
| ⬜   | `ble_command_test.dart`               | `BleCommand`            | 指令构建、响应解析             |

### 12. 门店/库存

| 状态 | 测试文件                           | Controller/Model                              | 测试点                       |
| ---- | ---------------------------------- | --------------------------------------------- | ---------------------------- |
| ⬜   | `shop_controller_test.dart`        | `ShopListNotifier` / `ShopDetailNotifier`     | 门店列表、门店详情、门店编辑 |
| ⬜   | `stock_controller_test.dart`       | `StockListNotifier` / `StockTransferNotifier` | 库存列表、库存调拨           |
| ⬜   | `shop_static_controller_test.dart` | `ShopStaticListNotifier`                      | 门店销售统计                 |

### 13. 支付确认

| 状态 | 测试文件                        | Controller/Model                                 | 测试点                   |
| ---- | ------------------------------- | ------------------------------------------------ | ------------------------ |
| ⬜   | `payment_controller_test.dart`  | `PaymentListNotifier` / `PaymentConfirmNotifier` | 待确认订单列表、支付确认 |
| ⬜   | `payment_order_model_test.dart` | `PaymentOrder`                                   | JSON解析                 |

### 14. 保险

| 状态 | 测试文件                         | Controller/Model         | 测试点                                 |
| ---- | -------------------------------- | ------------------------ | -------------------------------------- |
| ⬜   | `insurance_controller_test.dart` | `InsuranceApplyNotifier` | 用户查询、设备查询、保险方案、申请提交 |

### 15. 个人中心

| 状态 | 测试文件                       | Controller/Model      | 测试点                                     |
| ---- | ------------------------------ | --------------------- | ------------------------------------------ |
| ⬜   | `profile_controller_test.dart` | `ProfileNotifier`     | 个人信息加载、头像上传、昵称修改、密码修改 |
| ⬜   | `message_controller_test.dart` | `MessageListNotifier` | 消息列表、标记已读、未读数量               |
| ⬜   | `language_notifier_test.dart`  | `LanguageNotifier`    | 语言切换、持久化                           |

---

## 四、P2 低频功能

### 16. VCU控制

| 状态 | 测试文件                      | Controller/Model | 测试点                          |
| ---- | ----------------------------- | ---------------- | ------------------------------- |
| ⬜   | `vcu_controller_test.dart`    | `VcuNotifier`    | VCU设备搜索、版本列表、指令发送 |
| ⬜   | `vcu_version_model_test.dart` | `VcuVersion`     | JSON解析                        |

### 17. 系统配置

| 状态 | 测试文件                          | Controller/Model    | 测试点             |
| ---- | --------------------------------- | ------------------- | ------------------ |
| ⬜   | `sys_config_controller_test.dart` | `SysConfigNotifier` | 区号配置、城市列表 |

### 18. 相机操作

| 状态 | 测试文件                      | Controller/Model          | 测试点       |
| ---- | ----------------------------- | ------------------------- | ------------ |
| ⬜   | `camera_controller_test.dart` | `CameraOperationNotifier` | 相机控制指令 |

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
