import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/after_sale/after_sale_bind_page.dart';
import 'package:merchant_app/features/work/after_sale/unbind_device_page.dart';
import 'package:merchant_app/features/work/device/device_detail_page.dart';
import 'package:merchant_app/features/work/device/device_search_page.dart';
import 'package:merchant_app/features/work/device/vehicle_search_page.dart';
import 'package:merchant_app/features/work/entry/battery_entry_page.dart';
import 'package:merchant_app/features/work/entry/battery_ship_page.dart';
import 'package:merchant_app/features/work/entry/station_entry_page.dart';
import 'package:merchant_app/features/work/entry/vehicle_entry_page.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_book_page.dart';
import 'package:merchant_app/features/work/maintenance/repair_record_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_code_list_page.dart';
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
import 'package:merchant_app/features/work/warehouse/inventory_detail_page.dart';
import 'package:merchant_app/features/work/warehouse/inventory_list_page.dart';
import 'package:merchant_app/features/work/warehouse/inventory_search_page.dart';
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
        return const UnbindDevicePage();
      case 'battery_entry':
        return const BatteryEntryPage();
      case 'vehicle_entry':
        return const VehicleEntryPage();
      case 'station_entry':
        return const StationEntryPage();
      case 'battery_ship':
        return const BatteryShipPage();
      case 'user_list':
        return const UserListPage();
      case 'user_search':
        return const UserListPage();
      case 'user_detail':
        return const UserDetailPage(cardNum: '');
      case 'device_detail':
        return const DeviceDetailPage();
      case 'device_search':
        return const DeviceSearchPage();
      case 'vehicle_search':
        return const VehicleSearchPage();
      case 'maintenance_book':
        return const MaintenanceBookPage();
      case 'repair_record':
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
        return const QrCodeListPage();
      case 'cabinet_scan':
        return const QrScanPage();
      case 'device_inventory':
        return const InventoryListPage();
      case 'device_inventory_detail':
        return const InventoryDetailPage();
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
        return const TransportListPage(
          initialTabIndex: 2,
          mode: TransportMode.receive,
        );
      case 'device_transport_detail':
        return const TransportDetailPage();
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
