import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/device/device_detail_page_new.dart';
import 'package:merchant_app/features/work/entry/shipping_entry_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/work_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

/// 角色枚举
enum WorkRole {
  sale('app_role_sales', 'Sale'),
  operations('app_role_op', 'Operations'),
  warehouseKeeper('app_role_store_man', 'Warehouse Keeper');

  const WorkRole(this.roleKey, this.displayName);
  final String roleKey;
  final String displayName;
}

/// 模块定义
class WorkModule {
  const WorkModule({
    required this.key,
    required this.titleKey,
    required this.iconPath,
    this.showAsBottomSheet = false,
  });

  final String key;
  final String titleKey;
  final String iconPath;
  final bool showAsBottomSheet;
}

/// 各角色基础模块（再结合角色/账号类型动态过滤）
const List<WorkModule> _warehousePlatformModules = [
  WorkModule(
    key: 'shipping_entry',
    titleKey: 'shippingEntry',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_ship_entry.webp',
    showAsBottomSheet: true,
  ),
  WorkModule(
    key: 'device_transport_issue',
    titleKey: 'deviceIssue',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_issue.png',
  ),
  WorkModule(
    key: 'device_transport_receive',
    titleKey: 'deviceReception',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_reception.webp',
  ),
  WorkModule(
    key: 'device_inventory',
    titleKey: 'inventoryCount',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_inventory_count.webp',
  ),
  WorkModule(
    key: 'vcu_control',
    titleKey: 'vcuControl',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_vcu_testing.png',
  ),
  WorkModule(
    key: 'device_search',
    titleKey: 'deviceQuery',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_query.webp',
  ),
];

const List<WorkModule> _warehouseDealerModules = [
  WorkModule(
    key: 'device_transport_issue',
    titleKey: 'deviceIssue',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_issue.png',
  ),
  WorkModule(
    key: 'device_transport_receive',
    titleKey: 'deviceReception',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_reception.webp',
  ),
  WorkModule(
    key: 'device_inventory',
    titleKey: 'inventoryCount',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_inventory_count.webp',
  ),
  WorkModule(
    key: 'device_search',
    titleKey: 'deviceQuery',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_query.webp',
  ),
];

const List<WorkModule> _warehouseShopModules = [
  WorkModule(
    key: 'device_transport_receive',
    titleKey: 'deviceReception',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_reception.webp',
  ),
  WorkModule(
    key: 'device_inventory',
    titleKey: 'inventoryCount',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_inventory_count.webp',
  ),
  WorkModule(
    key: 'device_search',
    titleKey: 'deviceQuery',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_query.webp',
  ),
];

const List<WorkModule> _salesModules = [
  WorkModule(
    key: 'sell_bind',
    titleKey: 'salesBinding',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_sale_bind.webp',
  ),
  WorkModule(
    key: 'rent_bind',
    titleKey: 'leaseBinding',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_lease_bind.png',
  ),
  WorkModule(
    key: 'swap_bind',
    titleKey: 'swapBinding',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_swap_bind.webp',
  ),
  WorkModule(
    key: 'merchant_replace',
    titleKey: 'manualSwap',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_manual_swap.png',
  ),
  WorkModule(
    key: 'sale_summary',
    titleKey: 'salesStatistics',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_sale_statistic.webp',
  ),
  WorkModule(
    key: 'deposit_refund',
    titleKey: 'depositRefund',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_deposit_refund.webp',
  ),
  WorkModule(
    key: 'offline_user_register',
    titleKey: 'offlineUserRegistration',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_offline_register.webp',
  ),
  WorkModule(
    key: 'installment_pay',
    titleKey: 'installmentPayment',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_installment.png',
  ),
  WorkModule(
    key: 'user_list',
    titleKey: 'userQuery',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_user_query.png',
  ),
  WorkModule(
    key: 'device_search',
    titleKey: 'deviceQuery',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_query.webp',
  ),
];

const List<WorkModule> _operationsModules = [
  WorkModule(
    key: 'maintenance_book',
    titleKey: 'scheduleMaintenance',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_schedule_maintenance.png',
  ),
  WorkModule(
    key: 'repair_record',
    titleKey: 'repairRegistration',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_repair_registration.png',
  ),
  WorkModule(
    key: 'road_assist',
    titleKey: 'roadsideAssistance',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_roadside_assistance.png',
  ),
  WorkModule(
    key: 'unbind_device',
    titleKey: 'deviceUnbinding',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_unbinding.webp',
  ),
  WorkModule(
    key: 'after_sale_bind',
    titleKey: 'afterSalesBinding',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_aftersale_binding.webp',
  ),
  WorkModule(
    key: 'user_list',
    titleKey: 'userQuery',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_user_query.png',
  ),
  WorkModule(
    key: 'device_search',
    titleKey: 'deviceQuery',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_query.webp',
  ),
];

const List<WorkModule> _operationsDealerModules = [
  WorkModule(
    key: 'cabinet_putaway',
    titleKey: 'cabinetPutaway',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_release_station.png',
  ),
  WorkModule(
    key: 'cabinet_unshelve',
    titleKey: 'cabinetUnshelve',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_retire_station.png',
  ),
  WorkModule(
    key: 'cabinet_operate',
    titleKey: 'cabinetOperation',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_station_operation.png',
  ),
  WorkModule(
    key: 'station_repair_record',
    titleKey: 'stationRepairRegistration',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_repair_registration.png',
  ),
  WorkModule(
    key: 'station_search',
    titleKey: 'stationQuery',
    iconPath: 'assets/android/mipmap-xxhdpi/icon_device_query.webp',
  ),
];

class WorkTab extends ConsumerStatefulWidget {
  const WorkTab({super.key});

  @override
  ConsumerState<WorkTab> createState() => _WorkTabState();
}

class _WorkTabState extends ConsumerState<WorkTab> {
  WorkRole _currentRole = WorkRole.sale;
  bool _didInitialRefresh = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workbenchProvider);
    final availableRoles = _resolveAvailableRoles();
    final activeRole = _resolveActiveRole(availableRoles);
    final warehouseRole = AuthSession.instance.current?.role ?? 0;
    final serviceTypes = _parseServiceTypes(
      AuthSession.instance.current?.serviceType,
    );
    final modules = _resolveModules(activeRole, warehouseRole, serviceTypes);

    _syncRoleIfNeeded(activeRole);
    _maybeInitialRefresh(activeRole);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          // 深绿色渐变顶部
          _buildHeader(context, state, activeRole, availableRoles),
          // 模块列表区域
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 0),
              decoration: BoxDecoration(color: AppColors.bgColor),
              child: _buildModuleSection(context, modules, activeRole),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WorkbenchState state,
    WorkRole currentRole,
    List<WorkRole> availableRoles,
  ) {
    final l10n = context.l10n;
    final saleData = state.saleData;
    final isSalesRole = currentRole == WorkRole.sale;
    final canSelectRole = availableRoles.length > 1;
    final roleName = _getRoleDisplayName(currentRole, l10n);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/android/mipmap-xxhdpi/icon_workbench_topbg.webp',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 顶部栏：角色选择 + 扫码按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: canSelectRole
                        ? () => _showRoleSelector(context, availableRoles)
                        : null,
                    child: Row(
                      children: [
                        Text(
                          roleName,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (canSelectRole) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _scanAndOpenDetail,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Image.asset(
                        'assets/android/mipmap-xxhdpi/icon_scan.png',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 销售角色显示本月销售卡片
            if (isSalesRole) ...[
              const SizedBox(height: 8),
              _buildSalesCard(context, l10n, saleData),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesCard(
    BuildContext context,
    AppLocalizations l10n,
    dynamic saleData,
  ) {
    final dateStr = _formatSaleDate(context, saleData?.today);
    final orderIncome = saleData?.orderIncome ?? 0;
    final orderNum = saleData?.orderNum ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF8F0), Colors.white],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/android/mipmap-xxhdpi/icon_thismonth_sale.png',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.workbenchThisMonthSales,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black06Text,
                ),
              ),
              const Spacer(),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEBEBEB)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${orderIncome.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black06Text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.workbenchTransactionAmount,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xA6000000),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$orderNum',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black06Text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.workbenchOrderQuantity,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xA6000000),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModulesCard(BuildContext context, List<WorkModule> modules) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 4,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return _buildModuleItem(context, module);
        },
      ),
    );
  }

  Widget _buildModuleItem(BuildContext context, WorkModule module) {
    final title = _getModuleTitle(context, module.titleKey);

    return GestureDetector(
      onTap: () => _onModuleTap(module),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 55,
            height: 55,
            child: ClipRRect(
              child: Image.asset(
                module.iconPath,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.apps,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0x99000000)),
          ),
        ],
      ),
    );
  }

  String _getModuleTitle(BuildContext context, String titleKey) {
    final l10n = context.l10n;
    switch (titleKey) {
      case 'shippingEntry':
        return l10n.workbenchShippingEntry;
      case 'deviceIssue':
        return l10n.workbenchDeviceIssue;
      case 'deviceReception':
        return l10n.workbenchDeviceReception;
      case 'inventoryCount':
        return l10n.workbenchInventoryCount;
      case 'deviceQuery':
        return l10n.workbenchDeviceQuery;
      case 'salesBinding':
        return l10n.workbenchSalesBinding;
      case 'leaseBinding':
        return l10n.workbenchLeaseBinding;
      case 'swapBinding':
        return l10n.workbenchSwapBinding;
      case 'manualSwap':
        return l10n.workbenchManualSwap;
      case 'salesStatistics':
        return l10n.workbenchSalesStatistics;
      case 'depositRefund':
        return l10n.workbenchDepositRefund;
      case 'offlineUserRegistration':
        return l10n.workbenchOfflineUserRegistration;
      case 'installmentPayment':
        return l10n.workbenchInstallmentPayment;
      case 'userQuery':
        return l10n.workbenchUserQuery;
      case 'scheduleMaintenance':
        return l10n.workbenchScheduleMaintenance;
      case 'repairRegistration':
        return l10n.workbenchRepairRegistration;
      case 'roadsideAssistance':
        return l10n.workbenchRoadsideAssistance;
      case 'deviceUnbinding':
        return l10n.workbenchDeviceUnbinding;
      case 'afterSalesBinding':
        return l10n.workbenchAfterSalesBinding;
      case 'cabinetOperation':
        return l10n.workbenchCabinetOperation;
      case 'cabinetPutaway':
        return l10n.workbenchCabinetPutaway;
      case 'cabinetUnshelve':
        return l10n.workbenchCabinetUnshelve;
      case 'stationRepairRegistration':
        return l10n.workbenchStationRepairRegistration;
      case 'stationQuery':
        return l10n.workbenchStationQuery;
      case 'vcuControl':
        return l10n.vcuControlTitle;
      default:
        return titleKey;
    }
  }

  void _onModuleTap(WorkModule module) {
    if (module.showAsBottomSheet) {
      ShippingEntryPage.showAsBottomSheet(context);
    } else {
      AppRouter.router.push(
        '${AppRouter.workModulePath}/${module.key}',
        extra: module.key,
      );
    }
  }

  void _showRoleSelector(BuildContext context, List<WorkRole> roles) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.workbenchChooseYourRole,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: roles.map((role) {
                    return _buildRoleOption(context, role, l10n);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    WorkRole role,
    AppLocalizations l10n,
  ) {
    final isSelected = _currentRole == role;
    final iconPath = _getRoleIconPath(role);
    final iconSize = _getRoleIconSize(role);
    final displayName = _getRoleDisplayName(role, l10n);

    return GestureDetector(
      onTap: () {
        setState(() => _currentRole = role);
        Navigator.of(context).pop();
        // 切换到销售角色时刷新数据
        if (role == WorkRole.sale) {
          _didInitialRefresh = true;
          ref.read(workbenchProvider.notifier).refresh();
        }
      },
      child: Container(
        width: 108,
        height: 130,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF2FF) : const Color(0xFFF5F8FB),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFFB8D3FF), width: 1)
              : null,
        ),
        child: Column(
          children: [
            Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF606166),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleIconPath(WorkRole role) {
    switch (role) {
      case WorkRole.sale:
        return 'assets/android/mipmap-xxhdpi/icon_role_sale.png';
      case WorkRole.operations:
        return 'assets/android/mipmap-xxhdpi/icon_onm.png';
      case WorkRole.warehouseKeeper:
        return 'assets/android/mipmap-xxhdpi/img_sales_summary.png';
    }
  }

  double _getRoleIconSize(WorkRole role) {
    switch (role) {
      // icon_role_sale视觉主体偏大，按安卓效果缩小到与其他角色一致。
      case WorkRole.sale:
        return 48;
      case WorkRole.operations:
      case WorkRole.warehouseKeeper:
        return 54;
    }
  }

  String _getRoleDisplayName(WorkRole role, AppLocalizations l10n) {
    switch (role) {
      case WorkRole.sale:
        return l10n.workbenchRoleSale;
      case WorkRole.operations:
        return l10n.workbenchRoleOperations;
      case WorkRole.warehouseKeeper:
        return l10n.workbenchRoleWarehouseKeeper;
    }
  }

  Future<void> _scanAndOpenDetail() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(allowManualInput: true, parseDeviceSn: true)),
    );
    if (!mounted || result == null || result.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailPageNew(initialSn: result, readOnly: true),
      ),
    );
  }

  Widget _buildModuleSection(
    BuildContext context,
    List<WorkModule> modules,
    WorkRole currentRole,
  ) {
    final content = SingleChildScrollView(
      physics: currentRole == WorkRole.sale
          ? const AlwaysScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: _buildModulesCard(context, modules),
    );
    if (currentRole != WorkRole.sale) {
      return content;
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(workbenchProvider.notifier).refresh(),
      child: content,
    );
  }

  void _maybeInitialRefresh(WorkRole activeRole) {
    if (_didInitialRefresh || activeRole != WorkRole.sale) return;
    _didInitialRefresh = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(workbenchProvider.notifier).refresh();
    });
  }

  void _syncRoleIfNeeded(WorkRole activeRole) {
    if (_currentRole == activeRole) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _currentRole = activeRole);
    });
  }

  List<WorkRole> _resolveAvailableRoles() {
    final raw = AuthSession.instance.current?.appRole ?? '';
    if (raw.trim().isEmpty) {
      return WorkRole.values;
    }
    final roles = <WorkRole>[];
    for (final part in raw.split(',')) {
      final token = part.trim();
      switch (token) {
        case '1':
          if (!roles.contains(WorkRole.warehouseKeeper)) {
            roles.add(WorkRole.warehouseKeeper);
          }
          break;
        case '2':
          if (!roles.contains(WorkRole.operations)) {
            roles.add(WorkRole.operations);
          }
          break;
        case '3':
          if (!roles.contains(WorkRole.sale)) {
            roles.add(WorkRole.sale);
          }
          break;
      }
    }
    if (roles.isEmpty) {
      return WorkRole.values;
    }

    const roleOrder = <WorkRole, int>{
      WorkRole.sale: 0,
      WorkRole.operations: 1,
      WorkRole.warehouseKeeper: 2,
    };
    roles.sort(
      (a, b) => (roleOrder[a] ?? 999).compareTo(roleOrder[b] ?? 999),
    );
    return roles;
  }

  WorkRole _resolveActiveRole(List<WorkRole> roles) {
    if (roles.isEmpty) return _currentRole;
    if (roles.contains(_currentRole)) return _currentRole;
    return roles.first;
  }

  Set<int> _parseServiceTypes(String? raw) {
    if (raw == null) return {};
    var value = raw.trim();
    if (value.isEmpty) return {};
    value = value.replaceAll('"', '');
    value = value.replaceAll('[', '').replaceAll(']', '');
    if (value.trim().isEmpty) return {};
    return value
        .split(',')
        .map((item) => int.tryParse(item.trim()))
        .whereType<int>()
        .toSet();
  }

  List<WorkModule> _resolveModules(
    WorkRole role,
    int warehouseRole,
    Set<int> serviceTypes,
  ) {
    switch (role) {
      case WorkRole.sale:
        return _resolveSalesModules(warehouseRole, serviceTypes);
      case WorkRole.operations:
        return _resolveOperationsModules(warehouseRole, serviceTypes);
      case WorkRole.warehouseKeeper:
        return _resolveWarehouseModules(warehouseRole);
    }
  }

  List<WorkModule> _resolveSalesModules(
    int warehouseRole,
    Set<int> serviceTypes,
  ) {
    final modules = List<WorkModule>.from(_salesModules);
    if (warehouseRole == 3 && serviceTypes.isNotEmpty) {
      modules.removeWhere((module) {
        switch (module.key) {
          case 'offline_user_register':
            return !serviceTypes.contains(1);
          case 'sell_bind':
          case 'installment_pay':
            return !serviceTypes.contains(2);
          case 'rent_bind':
          case 'deposit_refund':
            return !serviceTypes.contains(3);
          case 'swap_bind':
          case 'merchant_replace':
            return !serviceTypes.contains(4);
          case 'sale_summary':
            final hasSalesService =
                serviceTypes.contains(2) ||
                serviceTypes.contains(3) ||
                serviceTypes.contains(4);
            final hasOtherService =
                serviceTypes.contains(1) || serviceTypes.contains(5);
            return hasOtherService && !hasSalesService;
          default:
            return false;
        }
      });
    }
    return modules;
  }

  List<WorkModule> _resolveOperationsModules(
    int warehouseRole,
    Set<int> serviceTypes,
  ) {
    if (warehouseRole == 2) {
      return List<WorkModule>.from(_operationsDealerModules);
    }
    final modules = List<WorkModule>.from(_operationsModules);
    if (warehouseRole == 3 && serviceTypes.isNotEmpty) {
      modules.removeWhere((module) {
        switch (module.key) {
          case 'maintenance_book':
          case 'repair_record':
          case 'road_assist':
          case 'unbind_device':
          case 'after_sale_bind':
            return !serviceTypes.contains(5);
          default:
            return false;
        }
      });
    }
    return modules;
  }

  List<WorkModule> _resolveWarehouseModules(int warehouseRole) {
    switch (warehouseRole) {
      case 1:
        return List<WorkModule>.from(_warehousePlatformModules);
      case 2:
        return List<WorkModule>.from(_warehouseDealerModules);
      case 3:
        return List<WorkModule>.from(_warehouseShopModules);
      default:
        return const <WorkModule>[];
    }
  }

  String _formatSaleDate(BuildContext context, String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return DateFormatUtils.format(DateTime.now(), pattern: 'MMM dd,yyyy');
    }
    final timestamp = double.tryParse(raw);
    if (timestamp != null) {
      return DateFormatUtils.formatTimestamp(
        timestamp.toInt(),
        pattern: 'MMM dd,yyyy',
      );
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return DateFormatUtils.format(parsed, pattern: 'MMM dd,yyyy');
    }
    return DateFormatUtils.format(DateTime.now(), pattern: 'MMM dd,yyyy');
  }
}
