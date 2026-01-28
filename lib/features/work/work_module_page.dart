import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/after_sale/after_sale_bind_page.dart';
import 'package:merchant_app/features/work/after_sale/unbind_device_page.dart';
import 'package:merchant_app/features/work/bluetooth/bluetooth_auth_page.dart';
import 'package:merchant_app/features/work/bluetooth/bluetooth_operate_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_authorization_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_detail_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_fault_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_operate_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_putaway_page.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_unshelve_page.dart';
import 'package:merchant_app/features/work/device/device_detail_page.dart';
import 'package:merchant_app/features/work/device/device_search_page.dart';
import 'package:merchant_app/features/work/entry/battery_ship_page.dart';
import 'package:merchant_app/features/work/entry/shipping_entry_page.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_book_page.dart';
import 'package:merchant_app/features/work/maintenance/repair_record_create_page.dart';
import 'package:merchant_app/features/work/maintenance/repair_record_page.dart';
import 'package:merchant_app/features/work/map/battery_location_page.dart';
import 'package:merchant_app/features/work/promote/promote_web_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_batch_scan_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/roadside/roadside_deal_page.dart';
import 'package:merchant_app/features/work/roadside/roadside_detail_page.dart';
import 'package:merchant_app/features/work/roadside/roadside_list_page.dart';
import 'package:merchant_app/features/work/sales/deposit_refund_page.dart';
import 'package:merchant_app/features/work/sales/installment_pay_page.dart';
import 'package:merchant_app/features/work/sales/merchant_replace_page.dart';
import 'package:merchant_app/features/work/sales/offline_register_page.dart';
import 'package:merchant_app/features/work/sales/rent_bind_page.dart';
import 'package:merchant_app/features/work/sales/sale_summary_page.dart';
import 'package:merchant_app/features/work/sales/sell_bind_page.dart';
import 'package:merchant_app/features/work/sales/swap_bind_page.dart';
import 'package:merchant_app/features/work/user/user_detail_page.dart';
import 'package:merchant_app/features/work/user/user_list_page.dart';
import 'package:merchant_app/features/work/vcu/vcu_control_page.dart';
import 'package:merchant_app/features/work/vcu/vcu_search_page.dart';
import 'package:merchant_app/features/work/warehouse/inventory_detail_page_new.dart';
import 'package:merchant_app/features/work/warehouse/inventory_list_page_new.dart';
import 'package:merchant_app/features/work/warehouse/inventory_search_page.dart';
import 'package:merchant_app/features/work/warehouse/receive_list_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';
import 'package:merchant_app/features/work/warehouse/transport_detail_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_list_page.dart';

class WorkModulePage extends StatelessWidget {
  const WorkModulePage({
    super.key,
    required this.moduleKey,
    this.moduleTitle,
    this.recordNo,
  });

  final String moduleKey;
  final String? moduleTitle;
  final String? recordNo;

  factory WorkModulePage.fromState(GoRouterState state) {
    final key = state.pathParameters['moduleKey'] ?? 'module';
    final title = state.extra is String ? state.extra as String : null;
    final recordNo = state.uri.queryParameters['recordNo'];
    return WorkModulePage(
      moduleKey: key,
      moduleTitle: title,
      recordNo: recordNo,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (moduleKey) {
      case 'after_sale_bind':
        return const AfterSaleBindPage();
      case 'after_sale_unbind':
      case 'unbind_device':
        return const UnbindDevicePage();
      case 'battery_entry':
      case 'vehicle_entry':
      case 'station_entry':
      case 'shipping_entry':
        return const ShippingEntryPage();
      case 'battery_ship':
        return const BatteryShipPage();
      case 'user_list':
        return const UserListPage();
      case 'user_search':
        return const UserListPage();
      case 'user_detail':
        return UserDetailPage(cardNum: recordNo ?? '');
      case 'device_detail':
        return DeviceDetailPage(initialSn: recordNo);
      case 'device_search':
        return const DeviceSearchPage();
      case 'maintenance_book':
        return const MaintenanceBookPage();
      case 'repair_record':
        return const RepairRecordCreatePage();
      case 'repair_record_list':
        return const RepairRecordPage();
      case 'road_assist':
        return const RoadSideListPage();
      case 'road_order_detail':
        return RoadSideDetailPage(recordNo: recordNo ?? '');
      case 'road_order_deal':
        return RoadSideDealPage(recordNo: recordNo ?? '');
      case 'offline_user_register':
        return const OfflineUserRegisterPage();
      case 'sell_bind':
        return const SellBindPage();
      case 'rent_bind':
        return const RentBindPage();
      case 'swap_bind':
        return const SwapBindPage();
      case 'deposit_refund':
        return const DepositRefundPage();
      case 'installment_pay':
        return const InstallmentPayPage();
      case 'merchant_replace':
        return const MerchantReplacePage();
      case 'sale_summary':
        return const SaleSummaryPage();
      case 'qrcode_scan':
        return const QrScanPage();
      case 'qrcode_list':
        return const QrBatchScanPage();
      case 'cabinet_scan':
        return const QrScanPage();
      case 'cabinet_putaway':
        return const CabinetPutawayPage();
      case 'cabinet_unshelve':
        return const CabinetUnshelvePage();
      case 'cabinet_operate':
        return const CabinetOperatePage();
      case 'cabinet_auth_operate':
        return const CabinetAuthorizationPage();
      case 'cabinet_offline_detail':
        return const CabinetOfflineDetailPage();
      case 'cabinet_offline_fault':
        return const CabinetOfflineFaultPage();
      case 'bluetooth_auth':
        return const BluetoothAuthPage();
      case 'bluetooth_operate':
        return const BluetoothOperatePage();
      case 'device_inventory':
        return const InventoryListPageNew();
      case 'device_inventory_detail':
        return InventoryDetailPageNew(inventoryNo: recordNo ?? '');
      case 'device_inventory_search':
        return const InventorySearchPage();
      case 'device_transport_issue':
        return const TransportListPage(
          initialTabIndex: 0,
          mode: TransportMode.issue,
        );
      case 'device_transport_issue_list':
        return const TransportListPage(
          initialTabIndex: 0,
          mode: TransportMode.issue,
        );
      case 'device_transport_receive':
        return const ReceiveListPage();
      case 'device_transport_detail':
        return TransportDetailPage(transferNo: recordNo ?? '');
      case 'vcu_search':
        return const VcuSearchPage();
      case 'vcu_control':
        return const VcuControlPage();
      case 'promote_web':
        return const PromoteWebPage();
      case 'battery_loc':
        return const BatteryLocationPage();
      default:
        final title = moduleTitle ?? moduleKey;
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.l10n.workInProgress,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }
}
