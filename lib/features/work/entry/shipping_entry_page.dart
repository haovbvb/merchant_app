import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/battery_type.dart';
import 'package:merchant_app/data/models/car_type.dart';
import 'package:merchant_app/data/models/station_type.dart';
import 'package:merchant_app/features/work/entry/battery_entry_page_new.dart';
import 'package:merchant_app/features/work/entry/station_entry_page_new.dart';
import 'package:merchant_app/features/work/entry/vehicle_entry_page_new.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 入库入口页面
/// 选择设备类型和型号后，跳转到对应的入库页面
class ShippingEntryPage extends StatefulWidget {
  const ShippingEntryPage({super.key});

  /// 显示为底部弹窗
  static Future<void> showAsBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ShippingEntryBottomSheet(),
    );
  }

  @override
  State<ShippingEntryPage> createState() => _ShippingEntryPageState();
}

class _ShippingEntryPageState extends State<ShippingEntryPage>
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
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.shippingEntryTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 副标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.shippingEntrySubtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ),

          // Tab 栏
          TabBar(
            controller: _tabController,
            labelColor: AppColors.black06Text,
            unselectedLabelColor: const Color(0xFF999999),
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 15),
            indicatorColor: AppColors.primaryColor,
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
      return const Center(child: const SizedBox.shrink());
    }
    if (_vehicleTypes.isEmpty) {
      return _buildEmptyState();
    }
    return _buildModelGrid<CarType>(
      types: _vehicleTypes,
      imageGetter: (type) => type.img,
      nameGetter: (type) => type.modelName ?? type.model ?? '-',
      specGetter: (type) => type.remark ?? '',
      onSelected: (type) => _goToVehicleEntry(type),
    );
  }

  Widget _buildBatteryTab() {
    if (_loadingBattery) {
      return const Center(child: const SizedBox.shrink());
    }
    if (_batteryTypes.isEmpty) {
      return _buildEmptyState();
    }
    return _buildModelGrid<BatteryType>(
      types: _batteryTypes,
      imageGetter: (type) => type.img,
      nameGetter: (type) => '${type.model ?? '-'} (${type.voltage ?? 0}V)',
      specGetter: (type) => type.remark ?? type.modelName ?? '',
      onSelected: (type) => _goToBatteryEntry(type),
    );
  }

  Widget _buildStationTab() {
    if (_loadingStation) {
      return const Center(child: const SizedBox.shrink());
    }
    if (_stationTypes.isEmpty) {
      return _buildEmptyState();
    }
    return _buildModelGrid<StationType>(
      types: _stationTypes,
      imageGetter: (type) => type.img,
      nameGetter: (type) => '${type.model ?? '-'} ${type.storeNum ?? 0}-Port',
      specGetter: (type) => type.dimension ?? '',
      onSelected: (type) => _goToStationEntry(type),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '暂无设备型号',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
    required void Function(T) onSelected,
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
        final imageUrl = imageGetter(type);

        return GestureDetector(
          onTap: () => onSelected(type),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 型号图片
                Expanded(
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(height: 8),

                // 型号名称
                Text(
                  nameGetter(type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // 规格
                Text(
                  specGetter(type),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        child: Icon(Icons.ev_station, size: 40, color: AppColors.primaryColor),
      ),
    );
  }

  void _goToVehicleEntry(CarType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VehicleEntryPageNew(selectedType: type),
      ),
    );
  }

  void _goToBatteryEntry(BatteryType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BatteryEntryPageNew(selectedType: type),
      ),
    );
  }

  void _goToStationEntry(StationType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StationEntryPageNew(selectedType: type),
      ),
    );
  }
}

/// 底部弹窗版本
class _ShippingEntryBottomSheet extends StatefulWidget {
  const _ShippingEntryBottomSheet();

  @override
  State<_ShippingEntryBottomSheet> createState() =>
      _ShippingEntryBottomSheetState();
}

class _ShippingEntryBottomSheetState extends State<_ShippingEntryBottomSheet>
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
    // 默认选中 Station (index 2) 以匹配截图
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖动手柄
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              l10n.shippingEntryTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black06Text,
              ),
            ),
          ),

          // 副标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.shippingEntrySubtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ),

          const SizedBox(height: 16),

          // Tab 栏
          TabBar(
            controller: _tabController,
            labelColor: AppColors.black06Text,
            unselectedLabelColor: const Color(0xFF999999),
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 15),
            indicatorColor: AppColors.primaryColor,
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
      return const Center(child: const SizedBox.shrink());
    }
    if (_vehicleTypes.isEmpty) {
      return _buildEmptyState();
    }
    return _buildModelGrid<CarType>(
      types: _vehicleTypes,
      imageGetter: (type) => type.img,
      nameGetter: (type) => type.model ?? '-',
      specGetter: (type) => type.remark ?? '',
      onSelected: (type) => _goToVehicleEntry(type),
    );
  }

  Widget _buildBatteryTab() {
    if (_loadingBattery) {
      return const Center(child: const SizedBox.shrink());
    }
    if (_batteryTypes.isEmpty) {
      return _buildEmptyState();
    }
    return _buildModelGrid<BatteryType>(
      types: _batteryTypes,
      imageGetter: (type) => type.img,
      nameGetter: (type) => type.model ?? '-',
      specGetter: (type) => '${type.voltage ?? 0}V',
      onSelected: (type) => _goToBatteryEntry(type),
    );
  }

  Widget _buildStationTab() {
    if (_loadingStation) {
      return const Center(child: const SizedBox.shrink());
    }
    if (_stationTypes.isEmpty) {
      return _buildEmptyState();
    }
    return _buildModelGrid<StationType>(
      types: _stationTypes,
      imageGetter: (type) => type.img,
      nameGetter: (type) => type.model ?? '-',
      specGetter: (type) => '${type.storeNum ?? 0}-Port',
      onSelected: (type) => _goToStationEntry(type),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '暂无设备型号',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
    required void Function(T) onSelected,
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
        final imageUrl = imageGetter(type);

        return GestureDetector(
          onTap: () => onSelected(type),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 型号图片
                Expanded(
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(height: 8),

                // 型号名称
                Text(
                  nameGetter(type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // 规格
                Text(
                  specGetter(type),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        child: Icon(Icons.ev_station, size: 40, color: AppColors.primaryColor),
      ),
    );
  }

  void _goToVehicleEntry(CarType type) {
    Navigator.of(context).pop(); // 关闭弹窗
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VehicleEntryPageNew(selectedType: type),
      ),
    );
  }

  void _goToBatteryEntry(BatteryType type) {
    Navigator.of(context).pop(); // 关闭弹窗
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BatteryEntryPageNew(selectedType: type),
      ),
    );
  }

  void _goToStationEntry(StationType type) {
    Navigator.of(context).pop(); // 关闭弹窗
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StationEntryPageNew(selectedType: type),
      ),
    );
  }
}
