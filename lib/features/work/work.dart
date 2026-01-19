import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/sale_data.dart';
import 'package:merchant_app/data/models/shop1_num.dart';
import 'package:merchant_app/features/work/work_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class WorkTab extends ConsumerStatefulWidget {
  const WorkTab({super.key});

  @override
  ConsumerState<WorkTab> createState() => _WorkTabState();
}

class _WorkTabState extends ConsumerState<WorkTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workbenchProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final state = ref.watch(workbenchProvider);
    final notifier = ref.read(workbenchProvider.notifier);
    final sections = const [
      _WorkSection(
        title: '入库/登记',
        modules: [
          _WorkModule(
            key: 'battery_entry',
            title: '电池入库',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_ship_entry.webp',
          ),
          _WorkModule(
            key: 'vehicle_entry',
            title: '车辆入库',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_ship_entry.webp',
          ),
          _WorkModule(
            key: 'station_entry',
            title: '站点入库',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_ship_entry.webp',
          ),
          _WorkModule(
            key: 'battery_ship',
            title: '电池出库',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_device_issue.png',
          ),
          _WorkModule(
            key: 'device_transport_issue_list',
            title: '出库列表',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_device_issue.png',
          ),
        ],
      ),
      _WorkSection(
        title: '设备与搜索',
        modules: [
          _WorkModule(
            key: 'device_detail',
            title: '设备详情',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_device_query.webp',
          ),
          _WorkModule(
            key: 'device_search',
            title: '设备搜索',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_device_query.webp',
          ),
          _WorkModule(
            key: 'vehicle_search',
            title: '车辆搜索',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_search.webp',
          ),
        ],
      ),
      _WorkSection(
        title: '售后/维修',
        modules: [
          _WorkModule(
            key: 'after_sale_bind',
            title: '售后绑定',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_aftersale_binding.webp',
          ),
          _WorkModule(
            key: 'maintenance_book',
            title: '维修预约',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_schedule_maintenance.png',
          ),
          _WorkModule(
            key: 'repair_record',
            title: '维修记录',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_repair_registration.png',
          ),
          _WorkModule(
            key: 'unbind_device',
            title: '设备解绑',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_device_unbinding.webp',
          ),
        ],
      ),
      _WorkSection(
        title: '道路救援',
        modules: [
          _WorkModule(
            key: 'road_assist',
            title: '道路救援',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_roadside_assistance.png',
          ),
          _WorkModule(
            key: 'road_order_detail',
            title: '救援订单详情',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_request.png',
          ),
          _WorkModule(
            key: 'road_order_deal',
            title: '救援订单处理',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_response.png',
          ),
        ],
      ),
      _WorkSection(
        title: '用户',
        modules: [
          _WorkModule(
            key: 'user_list',
            title: '用户列表',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_user_query.png',
          ),
          _WorkModule(
            key: 'user_search',
            title: '用户搜索',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_user_query.png',
          ),
          _WorkModule(
            key: 'user_detail',
            title: '用户详情',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_user_query.png',
          ),
        ],
      ),
      _WorkSection(
        title: '二维码/扫码',
        modules: [
          _WorkModule(
            key: 'qrcode_list',
            title: '二维码列表',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_scan.png',
          ),
          _WorkModule(
            key: 'qrcode_scan',
            title: '扫码',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_scan.png',
          ),
        ],
      ),
      _WorkSection(
        title: '仓库/调拨',
        modules: [
          _WorkModule(
            key: 'device_transport_receive',
            title: '设备调拨-接收',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_device_reception.webp',
          ),
          _WorkModule(
            key: 'device_transport_issue',
            title: '设备调拨-出库',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_device_issue.png',
          ),
          _WorkModule(
            key: 'device_transport_detail',
            title: '调拨详情',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_warehouse.png',
          ),
          _WorkModule(
            key: 'device_inventory',
            title: '设备盘点',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_inventory_count.webp',
          ),
          _WorkModule(
            key: 'device_inventory_detail',
            title: '盘点详情',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_inventory_count.webp',
          ),
          _WorkModule(
            key: 'device_inventory_search',
            title: '盘点搜索',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_search.webp',
          ),
        ],
      ),
      _WorkSection(
        title: '销售',
        modules: [
          _WorkModule(
            key: 'offline_user_register',
            title: '线下用户注册',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_offline_register.webp',
          ),
          _WorkModule(
            key: 'sell_bind',
            title: '销售绑定',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_sale_bind.webp',
          ),
          _WorkModule(
            key: 'rent_bind',
            title: '租赁绑定',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_lease_bind.png',
          ),
          _WorkModule(
            key: 'deposit_refund',
            title: '押金退还',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_deposit_refund.webp',
          ),
          _WorkModule(
            key: 'swap_bind',
            title: '换电绑定',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_swap_bind.webp',
          ),
          _WorkModule(
            key: 'installment_pay',
            title: '分期付款',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_installment.png',
          ),
          _WorkModule(
            key: 'sale_summary',
            title: '销售汇总',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_sale_statistic.webp',
          ),
          _WorkModule(
            key: 'merchant_replace',
            title: '商户置换',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_manual_change.webp',
          ),
        ],
      ),
      _WorkSection(
        title: '柜机/上架/授权',
        modules: [
          _WorkModule(
            key: 'cabinet_putaway',
            title: '柜机上架',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_putaway.png',
          ),
          _WorkModule(
            key: 'cabinet_unshelve',
            title: '柜机下架',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_unshelve.png',
          ),
          _WorkModule(
            key: 'cabinet_operate',
            title: '柜机运维',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_station_operation.png',
          ),
          _WorkModule(
            key: 'cabinet_auth_operate',
            title: '柜机授权运维',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_blue_key_autho.png',
          ),
          _WorkModule(
            key: 'cabinet_offline_detail',
            title: '离线柜机详情',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_signal_offline.webp',
          ),
          _WorkModule(
            key: 'cabinet_offline_fault',
            title: '离线故障列表',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_fix.png',
          ),
          _WorkModule(
            key: 'cabinet_scan',
            title: '柜机扫码',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_scan.png',
          ),
          _WorkModule(
            key: 'bluetooth_auth',
            title: '蓝牙授权',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_blue_key_autho.png',
          ),
          _WorkModule(
            key: 'bluetooth_operate',
            title: '蓝牙运维',
            iconPath: 'assets/android/mipmap-xxhdpi/img_bluetooth_operate_icon.webp',
          ),
        ],
      ),
      _WorkSection(
        title: 'VCU',
        modules: [
          _WorkModule(
            key: 'vcu_search',
            title: 'VCU 搜索',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_vcu_testing.png',
          ),
          _WorkModule(
            key: 'vcu_control',
            title: 'VCU 控制',
            iconPath: 'assets/android/mipmap-xxhdpi/img_vcu.png',
          ),
        ],
      ),
      _WorkSection(
        title: '地图/推广',
        modules: [
          _WorkModule(
            key: 'promote_web',
            title: '推广页面',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_sale_statistic.webp',
          ),
          _WorkModule(
            key: 'battery_loc',
            title: '电池定位',
            iconPath: 'assets/android/mipmap-xxhdpi/icon_battery_loc.png',
          ),
        ],
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WorkbenchHeader(
          l10n: l10n,
          loading: state.loading,
          onRefresh: notifier.refresh,
          saleData: state.saleData,
          shopNum: state.shopNum,
        ),
        const SizedBox(height: 16),
        ...sections.map(
          (section) => _WorkSectionCard(
            section: section,
            titleStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkbenchHeader extends StatelessWidget {
  const _WorkbenchHeader({
    required this.l10n,
    required this.loading,
    required this.onRefresh,
    required this.saleData,
    required this.shopNum,
  });

  final AppLocalizations l10n;
  final bool loading;
  final VoidCallback onRefresh;
  final SaleData? saleData;
  final Shop1Num? shopNum;

  @override
  Widget build(BuildContext context) {
    final sale = saleData;
    final shop = shopNum;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.workbenchMonthlyIncomeTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: loading ? null : onRefresh,
              icon: loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: Text(l10n.workbenchRefresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _MetricTile(
                  label: l10n.workbenchMonthlyIncomeAmount,
                  value: _formatAmount(sale?.orderIncome),
                ),
                _MetricTile(
                  label: l10n.workbenchOrderCount,
                  value: (sale?.orderNum ?? 0).toString(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.workbenchShopSummary,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _MetricTile(
                  label: l10n.workbenchShopAll,
                  value: (shop?.all ?? 0).toString(),
                ),
                _MetricTile(
                  label: l10n.workbenchShopDirect,
                  value: (shop?.direct ?? 0).toString(),
                ),
                _MetricTile(
                  label: l10n.workbenchShopFranchise,
                  value: (shop?.franchise ?? 0).toString(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(num? value) {
    final amount = value ?? 0;
    return amount.toStringAsFixed(2);
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _WorkSectionCard extends StatelessWidget {
  const _WorkSectionCard({
    required this.section,
    required this.titleStyle,
  });

  final _WorkSection section;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title, style: titleStyle),
          const SizedBox(height: 12),
          ...section.modules.map((module) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: module.iconPath == null
                    ? null
                    : Image.asset(
                        module.iconPath!,
                        width: 24,
                        height: 24,
                      ),
                title: Text(module.title),
                subtitle: null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => AppRouter.router.push(
                  '${AppRouter.workModulePath}/${module.key}',
                  extra: module.title,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WorkSection {
  const _WorkSection({required this.title, required this.modules});

  final String title;
  final List<_WorkModule> modules;
}

class _WorkModule {
  const _WorkModule({
    required this.key,
    required this.title,
    this.iconPath,
  });

  final String key;
  final String title;
  final String? iconPath;
}


