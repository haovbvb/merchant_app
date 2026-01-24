import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/battery_type.dart';
import 'package:merchant_app/data/models/car_type.dart';
import 'package:merchant_app/data/models/station_type.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 设备类型选择弹窗
/// 用于选择 Vehicle / Battery / Station 及其具体型号
class DeviceModelPickerSheet extends StatefulWidget {
  const DeviceModelPickerSheet({
    super.key,
    this.initialTab = 2, // 默认 Station
  });

  final int initialTab;

  @override
  State<DeviceModelPickerSheet> createState() => _DeviceModelPickerSheetState();
}

class _DeviceModelPickerSheetState extends State<DeviceModelPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  List<CarType> _vehicleTypes = [];
  List<BatteryType> _batteryTypes = [];
  List<StationType> _stationTypes = [];

  bool _loadingVehicle = true;
  bool _loadingBattery = true;
  bool _loadingStation = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadAllTypes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllTypes() async {
    await Future.wait([
      _loadVehicleTypes(),
      _loadBatteryTypes(),
      _loadStationTypes(),
    ]);
  }

  Future<void> _loadVehicleTypes() async {
    final response = await _api.get<List<CarType>>(
      ApiPath.vehicleModelList,
      parser: (json) =>
          (json as List<dynamic>?)
              ?.map(
                (item) =>
                    CarType.fromJson(Map<String, dynamic>.from(item as Map)),
              )
              .toList() ??
          const <CarType>[],
    );
    if (mounted) {
      setState(() {
        _loadingVehicle = false;
        _vehicleTypes = response.result ?? [];
      });
    }
  }

  Future<void> _loadBatteryTypes() async {
    final response = await _api.get<List<BatteryType>>(
      ApiPath.batteryModelList,
      parser: (json) =>
          (json as List<dynamic>?)
              ?.map(
                (item) => BatteryType.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const <BatteryType>[],
    );
    if (mounted) {
      setState(() {
        _loadingBattery = false;
        _batteryTypes = response.result ?? [];
      });
    }
  }

  Future<void> _loadStationTypes() async {
    final response = await _api.get<List<StationType>>(
      ApiPath.stationModelList,
      parser: (json) =>
          (json as List<dynamic>?)
              ?.map(
                (item) => StationType.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const <StationType>[],
    );
    if (mounted) {
      setState(() {
        _loadingStation = false;
        _stationTypes = response.result ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              children: [
                Text(
                  l10n.shippingEntryTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.shippingEntrySubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),

          // Tab 栏
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF333333),
            unselectedLabelColor: const Color(0xFF999999),
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 15),
            indicatorColor: const Color(0xFF4CAF50),
            indicatorWeight: 3,
            tabs: [
              Tab(text: l10n.deviceTypeVehicle),
              Tab(text: l10n.deviceTypeBattery),
              Tab(text: l10n.deviceTypeStation),
            ],
          ),

          // Tab 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVehicleTab(),
                _buildBatteryTab(),
                _buildStationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTab() {
    if (_loadingVehicle) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_vehicleTypes.isEmpty) {
      return _buildEmptyState();
    }
    return _buildModelGrid<CarType>(
      types: _vehicleTypes,
      imageGetter: (t) => t.img,
      nameGetter: (t) => t.model ?? '-',
      specGetter: (t) => t.modelName ?? '',
      onTap: (t) => Navigator.of(context).pop(_SelectedModel(type: 0, data: t)),
    );
  }

  Widget _buildBatteryTab() {
    if (_loadingBattery) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_batteryTypes.isEmpty) {
      return _buildEmptyState();
    }
    return _buildModelGrid<BatteryType>(
      types: _batteryTypes,
      imageGetter: (t) => t.img,
      nameGetter: (t) => t.model ?? '-',
      specGetter: (t) => t.modelName ?? '',
      onTap: (t) => Navigator.of(context).pop(_SelectedModel(type: 1, data: t)),
    );
  }

  Widget _buildStationTab() {
    if (_loadingStation) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_stationTypes.isEmpty) {
      return _buildEmptyState();
    }
    return _buildModelGrid<StationType>(
      types: _stationTypes,
      imageGetter: (t) => t.img,
      nameGetter: (t) => t.model ?? '-',
      specGetter: (t) => '${t.storeNum ?? 0}-Port',
      onTap: (t) => Navigator.of(context).pop(_SelectedModel(type: 2, data: t)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No models available',
            style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildModelGrid<T>({
    required List<T> types,
    required String? Function(T) imageGetter,
    required String Function(T) nameGetter,
    required String Function(T) specGetter,
    required void Function(T) onTap,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final img = imageGetter(type);

        return GestureDetector(
          onTap: () => onTap(type),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图片
                Expanded(
                  child: img != null && img.isNotEmpty
                      ? Image.network(
                          img,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(height: 8),

                // 型号名
                Text(
                  nameGetter(type),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),

                // 规格
                Text(
                  specGetter(type),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.ev_station, size: 40, color: Color(0xFF4CAF50)),
      ),
    );
  }
}

/// 选中的型号结果
class _SelectedModel {
  final int type; // 0: Vehicle, 1: Battery, 2: Station
  final dynamic data;

  const _SelectedModel({required this.type, required this.data});
}

/// 显示设备型号选择弹窗的便捷方法
Future<dynamic> showDeviceModelPicker(
  BuildContext context, {
  int initialTab = 2,
}) async {
  final result = await showModalBottomSheet<_SelectedModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DeviceModelPickerSheet(initialTab: initialTab),
  );

  return result?.data;
}
