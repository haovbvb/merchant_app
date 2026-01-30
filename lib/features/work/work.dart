import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
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

/// 各角色对应的模块
const Map<WorkRole, List<WorkModule>> _roleModules = {
  WorkRole.warehouseKeeper: [
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
      key: 'device_search',
      titleKey: 'deviceQuery',
      iconPath: 'assets/android/mipmap-xxhdpi/icon_device_query.webp',
    ),
  ],
  WorkRole.sale: [
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
  ],
  WorkRole.operations: [
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
      key: 'cabinet_operate',
      titleKey: 'cabinetOperation',
      iconPath: 'assets/android/mipmap-xxhdpi/icon_station_operation.png',
    ),
    WorkModule(
      key: 'cabinet_putaway',
      titleKey: 'cabinetPutaway',
      iconPath: 'assets/android/mipmap-xxhdpi/icon_release_station.png',
    ),
    WorkModule(
      key: 'cabinet_unshelve',
      titleKey: 'cabinetUnshelve',
      iconPath: 'assets/android/mipmap-xxhdpi/icon_unshelve.png',
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
    WorkModule(
      key: 'vcu_control',
      titleKey: 'vcuControl',
      iconPath: 'assets/android/mipmap-xxhdpi/icon_vcu_testing.png',
    ),
  ],
};

class WorkTab extends ConsumerStatefulWidget {
  const WorkTab({super.key});

  @override
  ConsumerState<WorkTab> createState() => _WorkTabState();
}

class _WorkTabState extends ConsumerState<WorkTab> {
  WorkRole _currentRole = WorkRole.sale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workbenchProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workbenchProvider);
    final modules = _roleModules[_currentRole] ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          // 深绿色渐变顶部
          _buildHeader(context, state),
          // 模块列表区域
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                color: AppColors.bgColor,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: _buildModulesCard(context, modules),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WorkbenchState state) {
    final l10n = context.l10n;
    final saleData = state.saleData;
    final isSalesRole = _currentRole == WorkRole.sale;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B3D2F), Color(0xFF2D5A45)],
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
                    onTap: () => _showRoleSelector(context),
                    child: Row(
                      children: [
                        Text(
                          _currentRole.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _scanAndOpenDetail,
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      child: Image.asset(
                        'assets/android/mipmap-xxhdpi/icon_scan.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 销售角色显示本月销售卡片
            if (isSalesRole) ...[
              const SizedBox(height: 8),
              _buildSalesCard(l10n, saleData),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesCard(AppLocalizations l10n, dynamic saleData) {
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM d.yyyy').format(now);
    final orderIncome = saleData?.orderIncome ?? 0;
    final orderNum = saleData?.orderNum ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 18,
                color: AppColors.black06Text,
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
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
                        fontSize: 12,
                        color: Color(0xFF999999),
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
                        fontSize: 12,
                        color: Color(0xFF999999),
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
      
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            width: 56,
            height: 56,
            child: ClipRRect(
              child: Image.asset(
                module.iconPath,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 56,
                    height: 56,
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
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.black06Text,
            ),
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

  void _showRoleSelector(BuildContext context) {
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
                  children: WorkRole.values.map((role) {
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
      BuildContext context, WorkRole role, AppLocalizations l10n) {
    final isSelected = _currentRole == role;
    final iconData = _getRoleIcon(role);
    final color = _getRoleColor(role);
    final displayName = _getRoleDisplayName(role, l10n);

    return GestureDetector(
      onTap: () {
        setState(() => _currentRole = role);
        Navigator.of(context).pop();
        // 切换到销售角色时刷新数据
        if (role == WorkRole.sale) {
          ref.read(workbenchProvider.notifier).refresh();
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 1) : null,
        ),
        child: Column(
          children: [
            Icon(iconData, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : const Color(0xFF666666),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(WorkRole role) {
    switch (role) {
      case WorkRole.sale:
        return Icons.shopping_bag_outlined;
      case WorkRole.operations:
        return Icons.apartment;
      case WorkRole.warehouseKeeper:
        return Icons.home_outlined;
    }
  }

  Color _getRoleColor(WorkRole role) {
    switch (role) {
      case WorkRole.sale:
        return const Color(0xFFFF9800);
      case WorkRole.operations:
        return const Color(0xFF2196F3);
      case WorkRole.warehouseKeeper:
        return AppColors.primaryColor;
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
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (!mounted || result == null || result.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeviceDetailPageNew(initialSn: result)),
    );
  }
}
