import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/city.dart';
import 'package:merchant_app/data/models/warehouse_info.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class TransportCreatePage extends ConsumerStatefulWidget {
  const TransportCreatePage({
    super.key,
    required this.deviceType,
    this.initialSns = const [],
  });

  final int deviceType;
  final List<String> initialSns;

  @override
  ConsumerState<TransportCreatePage> createState() =>
      _TransportCreatePageState();
}

class _TransportCreatePageState extends ConsumerState<TransportCreatePage> {
  final TextEditingController _trackingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(transportCreateProvider.notifier);
      notifier.setDeviceType(widget.deviceType);
      notifier.setInitialSns(widget.initialSns);
      notifier.loadMyWarehouse();
      notifier.loadInWarehouseList();
      notifier.loadCities();
    });
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(transportCreateProvider);
    final notifier = ref.read(transportCreateProvider.notifier);

    if (_trackingController.text != state.trackingNumber) {
      _trackingController.value = TextEditingValue(
        text: state.trackingNumber,
        selection: TextSelection.collapsed(offset: state.trackingNumber.length),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: Text(_getCreateTitle(l10n))),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 发出仓库
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.deviceIssueWarehouse,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/android/mipmap-xxhdpi/icon_warehouse.png',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getWarehouseName(state.myWarehouse),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.myWarehouse?.cityName ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
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
                  ),
                  // 接收仓库
                  _SectionCard(
                    child: _SelectField(
                      icon:
                          'assets/android/mipmap-xxhdpi/icon_receive_warehouse.png',
                      label: l10n.deviceReceiveWarehouse,
                      value: state.selectedInWarehouse != null
                          ? (state.selectedInWarehouse!.inWarehouseName ??
                                state.selectedInWarehouse!.warehouseName ??
                                '')
                          : l10n.deviceIssuePleaseSelectWarehouse,
                      valueColor: state.selectedInWarehouse != null
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF999999),
                      onTap: () =>
                          _showWarehousePicker(context, l10n, notifier),
                    ),
                  ),
                  // 物流单号
                  _SectionCard(
                    child: _InputField(
                      icon:
                          'assets/android/mipmap-xxhdpi/icon_edt_traknumber.png',
                      label: l10n.deviceIssueTrackingNumber,
                      hintText: l10n.deviceIssuePleaseEnterTracking,
                      controller: _trackingController,
                      onChanged: notifier.setTrackingNumber,
                    ),
                  ),
                  // 选择设备
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSelectDeviceLabel(l10n),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Color(0xFF666666),
                                ),
                                label: l10n.deviceIssueEnterSn,
                                outlined: true,
                                onTap: () =>
                                    _showSnInputDialog(context, l10n, notifier),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionButton(
                                icon: AppIcons.scanIcon(
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                label: l10n.deviceIssueScanQrCode,
                                outlined: false,
                                onTap: () => _scanAndAdd(context, notifier),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 设备列表
                  if (state.sns.isNotEmpty)
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: state.sns.asMap().entries.map((entry) {
                          final sn = entry.value;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        sn,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.black06Text,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => notifier.removeSn(sn),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.grey.shade400,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (entry.key < state.sns.length - 1)
                                const Divider(height: 1, indent: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // 底部栏
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.sns.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      l10n.deviceIssueTotalIssued,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 160,
                  height: 44,
                  child: FilledButton(
                    onPressed:
                        state.submitting ||
                            state.sns.isEmpty ||
                            state.selectedInWarehouse == null
                        ? null
                        : () => _submit(context, notifier),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      disabledBackgroundColor: const Color(0xFFCCE5C0),
                    ),
                    child: Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCreateTitle(AppLocalizations l10n) {
    switch (widget.deviceType) {
      case 1:
        return l10n.deviceIssueCreateBattery;
      case 2:
        return l10n.deviceIssueCreateVehicle;
      case 3:
        return l10n.deviceIssueCreateStation;
      default:
        return l10n.deviceIssueCreate;
    }
  }

  String _getSelectDeviceLabel(AppLocalizations l10n) {
    switch (widget.deviceType) {
      case 1:
        return l10n.deviceIssueSelectBattery;
      case 2:
        return l10n.deviceIssueSelectVehicle;
      case 3:
        return l10n.deviceIssueSelectStation;
      default:
        return l10n.deviceIssueSelectDevice;
    }
  }

  String _getWarehouseName(WarehouseInfo? info) {
    if (info == null) return '-';
    return info.warehouseName ?? info.outWarehouseName ?? '-';
  }

  Future<void> _showWarehousePicker(
    BuildContext context,
    AppLocalizations l10n,
    TransportCreateNotifier notifier,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          _WarehousePickerSheet(l10n: l10n, notifier: notifier, ref: ref),
    );
  }

  Future<void> _showSnInputDialog(
    BuildContext context,
    AppLocalizations l10n,
    TransportCreateNotifier notifier,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deviceIssueEnterDeviceSn),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.deviceIssueEnterDeviceSn,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await notifier.addSn(result);
    }
  }

  Future<void> _scanAndAdd(
    BuildContext context,
    TransportCreateNotifier notifier,
  ) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            QrScanPage(parseDeviceSn: true, deviceType: widget.deviceType),
      ),
    );
    if (result != null && result.isNotEmpty) {
      await notifier.addSn(result);
    }
  }

  Future<void> _submit(
    BuildContext context,
    TransportCreateNotifier notifier,
  ) async {
    final created = await notifier.createIssue();
    if (!context.mounted) return;
    if (created) {
      Navigator.of(context).pop(true);
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: child,
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.onTap,
  });

  final String icon;
  final String label;
  final String value;
  final Color valueColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(icon, width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black06Text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 14, color: valueColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.icon,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
  });

  final String icon;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(icon, width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.black06Text),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.outlined,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: outlined ? Colors.white : const Color(0xFFEEF7E9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: outlined ? const Color(0xFFE5E5E5) : primaryColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: outlined ? const Color(0xFF666666) : primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarehousePickerSheet extends StatefulWidget {
  const _WarehousePickerSheet({
    required this.l10n,
    required this.notifier,
    required this.ref,
  });

  final AppLocalizations l10n;
  final TransportCreateNotifier notifier;
  final WidgetRef ref;

  @override
  State<_WarehousePickerSheet> createState() => _WarehousePickerSheetState();
}

class _WarehousePickerSheetState extends State<_WarehousePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCityCode = '';
  String _selectedCityName = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.ref.watch(transportCreateProvider);
    final warehouses = state.inWarehouses;
    final selectedWarehouse = state.selectedInWarehouse;
    final cities = state.cities;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // 头部
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  widget.l10n.deviceIssueChooseWarehouse,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  widget.notifier.loadInWarehouseList(
                    keyword: value,
                    cityCode: _selectedCityCode,
                  );
                },
                decoration: InputDecoration(
                  hintText: widget.l10n.deviceIssueSearchWarehouse,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 城市筛选
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _showCitySheet(cities),
              child: Row(
                children: [
                  Text(
                    _selectedCityName.isEmpty
                        ? widget.l10n.deviceIssueAllCity
                        : _selectedCityName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black06Text,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Color(0xFF666666),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // 仓库列表
          Expanded(
            child: ListView.separated(
              itemCount: warehouses.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final warehouse = warehouses[index];
                final isSelected =
                    selectedWarehouse?.inWarehouseNo == warehouse.inWarehouseNo;
                return ListTile(
                  title: Text(
                    warehouse.inWarehouseName ?? warehouse.warehouseName ?? '-',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  subtitle: Text(
                    warehouse.cityName ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    widget.notifier.selectInWarehouse(warehouse);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCitySheet(List<City> cities) async {
    final selected = await showModalBottomSheet<City?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(widget.l10n.deviceIssueAllCity),
                trailing: _selectedCityCode.isEmpty
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(ctx).pop(null),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: cities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final city = cities[index];
                    final selected = city.code == _selectedCityCode;
                    return ListTile(
                      title: Text(city.name),
                      trailing: selected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.of(ctx).pop(city),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {
      if (selected == null) {
        _selectedCityCode = '';
        _selectedCityName = '';
      } else {
        _selectedCityCode = selected.code;
        _selectedCityName = selected.name;
      }
    });
    await widget.notifier.loadInWarehouseList(
      keyword: _searchController.text.trim(),
      cityCode: _selectedCityCode,
    );
  }
}
