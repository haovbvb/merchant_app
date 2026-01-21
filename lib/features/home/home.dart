import 'dart:math';
import 'dart:ui' as ui;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/location_permission.dart';
import 'package:merchant_app/data/models/near_by_vehicle.dart';
import 'package:merchant_app/features/home/widgets/vehicle_map.dart';
import 'package:merchant_app/features/work/device/device_detail_page.dart';
import 'package:merchant_app/features/work/device/vehicle_search_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  static const double _fallbackLatitude = 22.543099;
  static const double _fallbackLongitude = 114.057868;
  static const int _vehicleCount = 1000;
  static const int _vehicleRadius = 30000;

  final ApiService _api = ApiService();
  final List<NearByVehicle> _vehicles = [];
  final Map<String, String> _addressCache = {};

  gmaps.GoogleMapController? _googleController;
  amaps.AppleMapController? _appleController;
  bool _loading = false;
  bool _pendingCenterOnLocation = true;
  final bool _useMockData = true;
  double? _latitude;
  double? _longitude;
  int? _maintainFlag;
  NearByVehicle? _selectedVehicle;
  gmaps.BitmapDescriptor? _markerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
    _loadInitialData();
  }

  Future<void> _loadMarkerIcon() async {
    final bytes = await rootBundle.load('assets/android/mipmap-xxhdpi/icon_marker_vehicle.png');
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: 120,
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    if (data != null && mounted) {
      setState(() {
        _markerIcon = gmaps.BitmapDescriptor.bytes(data.buffer.asUint8List());
      });
    }
  }

  Future<void> _loadInitialData() async {
    await _ensureLocation();
    if (mounted) {
      await _fetchVehicles();
    }
  }

  Future<void> _ensureLocation() async {
    try {
      final permission = await ensureLocationPermission();
      if (!permission.granted) {
        setState(() {
          _latitude = _fallbackLatitude;
          _longitude = _fallbackLongitude;
        });
        _maybeCenterMap();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      _maybeCenterMap();
    } catch (_) {
      setState(() {
        _latitude = _fallbackLatitude;
        _longitude = _fallbackLongitude;
      });
      _maybeCenterMap();
    }
  }

  Future<void> _fetchVehicles() async {
    if (_loading) return;
    setState(() => _loading = true);

    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final centerLat = _latitude ?? _fallbackLatitude;
      final centerLng = _longitude ?? _fallbackLongitude;
      final mockList = _buildMockVehicles(centerLat, centerLng);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _vehicles
          ..clear()
          ..addAll(mockList);
      });
      return;
    }

    final response = await _api.get<List<NearByVehicle>>(
      ApiPath.monitorNearByVehicle,
      queryParameters: {
        'latitude': _latitude ?? _fallbackLatitude,
        'longitude': _longitude ?? _fallbackLongitude,
        'count': _vehicleCount,
        'radius': _vehicleRadius,
        if (_maintainFlag != null) 'maintainFlag': _maintainFlag,
      },
      parser: (json) => (json as List<dynamic>?)
              ?.map(
                (item) => NearByVehicle.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const <NearByVehicle>[],
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _vehicles
        ..clear()
        ..addAll(response.result ?? const []);
    });
    await _prefetchAddresses();
  }

  List<NearByVehicle> _buildMockVehicles(double centerLat, double centerLng) {
    final random = Random(1);
    final items = <NearByVehicle>[];
    for (var i = 0; i < 20; i++) {
      final latOffset = (random.nextDouble() - 0.5) * 0.04;
      final lngOffset = (random.nextDouble() - 0.5) * 0.04;
      final needMaintenance = i % 3 == 0;
      if (_maintainFlag == 1 && !needMaintenance) continue;
      if (_maintainFlag == 0 && needMaintenance) continue;
      items.add(
        NearByVehicle(
          sn: 'SN-TEST-${1000 + i}',
          cardNum: 'PB${(100000 + i)}',
          latitude: centerLat + latOffset,
          longitude: centerLng + lngOffset,
          needMaintenance: needMaintenance,
          mile: random.nextDouble() * 80,
          img: null,
        ),
      );
    }
    return items;
  }

  Future<void> _prefetchAddresses() async {
    for (final vehicle in _vehicles) {
      final lat = vehicle.latitude;
      final lng = vehicle.longitude;
      if (lat == null || lng == null || lat == 0 || lng == 0) continue;
      final key = _addressKey(lat, lng);
      if (_addressCache.containsKey(key)) continue;
      final address = await _resolveAddress(lat, lng);
      if (!mounted) return;
      setState(() => _addressCache[key] = address);
    }
  }

  Future<String> _resolveAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return _formatCoordinates(lat, lng);
      final place = placemarks.first;
      final parts = [
        place.name,
        place.thoroughfare,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((part) => part != null && part.trim().isNotEmpty).toList();
      if (parts.isEmpty) return _formatCoordinates(lat, lng);
      return parts.join(' ');
    } catch (_) {
      return _formatCoordinates(lat, lng);
    }
  }

  String _formatCoordinates(double lat, double lng) {
    return '${lng.toStringAsFixed(6)} ${lat.toStringAsFixed(6)}';
  }

  String _addressKey(double lat, double lng) => '$lat,$lng';

  String _distanceLabel(NearByVehicle vehicle) {
    final lat = vehicle.latitude;
    final lng = vehicle.longitude;
    final centerLat = _latitude;
    final centerLng = _longitude;
    if (lat == null || lng == null || centerLat == null || centerLng == null) {
      return '-';
    }
    final meters = Geolocator.distanceBetween(centerLat, centerLng, lat, lng);
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    }
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  String _addressFor(NearByVehicle vehicle) {
    final lat = vehicle.latitude;
    final lng = vehicle.longitude;
    if (lat == null || lng == null || lat == 0 || lng == 0) return '-';
    return _addressCache[_addressKey(lat, lng)] ?? _formatCoordinates(lat, lng);
  }

  Future<void> _openSearch() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VehicleSearchPage()),
    );
  }

  void _selectVehicle(NearByVehicle? vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
    });
  }

  Future<void> _openDetail(String? sn) async {
    if (sn == null || sn.trim().isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeviceDetailPage(initialSn: sn)),
    );
  }

  Future<void> _centerMap() async {
    final lat = _latitude ?? _fallbackLatitude;
    final lng = _longitude ?? _fallbackLongitude;
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final controller = _googleController;
      if (controller == null) return;
      await controller.animateCamera(
        gmaps.CameraUpdate.newLatLng(gmaps.LatLng(lat, lng)),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final controller = _appleController;
      if (controller == null) return;
      await controller.animateCamera(
        amaps.CameraUpdate.newLatLng(amaps.LatLng(lat, lng)),
      );
    }
  }

  void _maybeCenterMap() {
    if (!_pendingCenterOnLocation) return;
    if (_googleController == null && _appleController == null) return;
    _pendingCenterOnLocation = false;
    _centerMap();
  }

  Future<void> _showFilterSheet() async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<int?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.homeFilterAll),
                onTap: () => Navigator.of(context).pop(null),
                trailing: _maintainFlag == null
                    ? const Icon(Icons.check, color: AppColors.primaryColor)
                    : null,
              ),
              ListTile(
                title: Text(l10n.homeFilterNeedMaintenance),
                onTap: () => Navigator.of(context).pop(1),
                trailing: _maintainFlag == 1
                    ? const Icon(Icons.check, color: AppColors.primaryColor)
                    : null,
              ),
              ListTile(
                title: Text(l10n.homeFilterNormal),
                onTap: () => Navigator.of(context).pop(0),
                trailing: _maintainFlag == 0
                    ? const Icon(Icons.check, color: AppColors.primaryColor)
                    : null,
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    if (selected != _maintainFlag) {
      setState(() => _maintainFlag = selected);
      await _fetchVehicles();
    }
  }

  Set<gmaps.Marker> _buildGoogleMarkers() {
    return _vehicles
        .where((item) =>
            item.latitude != null &&
            item.longitude != null &&
            item.latitude != 0 &&
            item.longitude != 0)
        .map(
          (item) => gmaps.Marker(
            markerId: gmaps.MarkerId(
              item.sn ?? item.cardNum ?? '${item.latitude}-${item.longitude}',
            ),
            position: gmaps.LatLng(item.latitude!, item.longitude!),
            icon: _markerIcon ?? gmaps.BitmapDescriptor.defaultMarker,
            onTap: () => _selectVehicle(item),
          ),
        )
        .toSet();
  }

  Set<amaps.Annotation> _buildAppleAnnotations() {
    return _vehicles
        .where((item) =>
            item.latitude != null &&
            item.longitude != null &&
            item.latitude != 0 &&
            item.longitude != 0)
        .map(
          (item) => amaps.Annotation(
            annotationId: amaps.AnnotationId(
              item.sn ?? item.cardNum ?? '${item.latitude}-${item.longitude}',
            ),
            position: amaps.LatLng(item.latitude!, item.longitude!),
            onTap: () => _selectVehicle(item),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final centerLat = _latitude ?? _fallbackLatitude;
    final centerLng = _longitude ?? _fallbackLongitude;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: VehicleMap(
              latitude: centerLat,
              longitude: centerLng,
              markers: _buildGoogleMarkers(),
              annotations: _buildAppleAnnotations(),
              onGoogleMapCreated: (controller) {
                _googleController = controller;
                _maybeCenterMap();
              },
              onAppleMapCreated: (controller) {
                _appleController = controller;
                _maybeCenterMap();
              },
            ),
          ),
          _HomeOverlays(
            title: l10n.homeTitle,
            searchHint: l10n.homeSearchHint,
            onSearch: _openSearch,
            onFilter: _showFilterSheet,
            onLocate: _centerMap,
            onRefresh: _fetchVehicles,
          ),
          if (_selectedVehicle != null)
            _VehicleDetailPopup(
              vehicle: _selectedVehicle!,
              address: _addressFor(_selectedVehicle!),
              distance: _distanceLabel(_selectedVehicle!),
              onClose: () => _selectVehicle(null),
              onViewMore: () async {
                _selectVehicle(null);
                await _openDetail(_selectedVehicle?.sn);
              },
            )
          else if (_vehicles.isNotEmpty)
            _VehicleDraggableSheet(
              vehicles: _vehicles,
              loading: _loading,
              addressFor: _addressFor,
              distanceFor: _distanceLabel,
              onSelected: _openDetail,
              emptyText: l10n.homeEmpty,
            ),
        ],
      ),
    );
  }
}

class _HomeOverlays extends StatelessWidget {
  const _HomeOverlays({
    required this.title,
    required this.searchHint,
    required this.onSearch,
    required this.onFilter,
    required this.onLocate,
    required this.onRefresh,
  });

  final String title;
  final String searchHint;
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final VoidCallback onLocate;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 白色导航条
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onSearch,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: AppColors.black04Text,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          searchHint,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.black05Text,
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _CircleIconButton(
                icon: Icons.filter_alt_outlined,
                onPressed: onFilter,
              ),
            ],
          ),
        ),
        const Spacer(),
        // 底部按钮
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 100),
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CircleIconButton(
                  icon: Icons.refresh,
                  onPressed: onRefresh,
                ),
                const SizedBox(height: 10),
                _CircleIconButton(
                  icon: Icons.my_location_outlined,
                  onPressed: onLocate,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleDraggableSheet extends StatelessWidget {
  const _VehicleDraggableSheet({
    required this.vehicles,
    required this.loading,
    required this.addressFor,
    required this.distanceFor,
    required this.onSelected,
    required this.emptyText,
  });

  final List<NearByVehicle> vehicles;
  final bool loading;
  final String Function(NearByVehicle vehicle) addressFor;
  final String Function(NearByVehicle vehicle) distanceFor;
  final ValueChanged<String?> onSelected;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (context, controller) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 14,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : vehicles.isEmpty
                          ? Center(
                              child: Text(
                                emptyText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.black05Text),
                              ),
                            )
                          : ListView.separated(
                              controller: controller,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemBuilder: (context, index) {
                                final vehicle = vehicles[index];
                                return _VehicleCard(
                                  info: vehicle,
                                  address: addressFor(vehicle),
                                  distance: distanceFor(vehicle),
                                  onSelected: () => onSelected(vehicle.sn),
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemCount: vehicles.length,
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.info,
    required this.address,
    required this.distance,
    required this.onSelected,
  });

  final NearByVehicle info;
  final String address;
  final String distance;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VehicleImage(url: info.img),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SN: ${info.sn ?? '-'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.black09Text,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (info.needMaintenance == true)
                            _StatusChip(
                              label: context.l10n.homeFilterNeedMaintenance,
                              borderColor: AppColors.danger,
                              textColor: AppColors.danger,
                              fontSize: 12,
                            ),
                          _StatusChip(
                            label:
                                '${context.l10n.vehicleSearchBindIdLabel}: ${info.cardNum ?? '-'}',
                            borderColor: AppColors.black02Text,
                            textColor: AppColors.black06Text,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: AppColors.black04Text),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.black06Text,
                      height: 1.3,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.campaign_outlined,
                  size: 18,
                  color: AppColors.black04Text,
                ),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.black06Text,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleImage extends StatelessWidget {
  const _VehicleImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        height: 72,
        color: Colors.white,
        child: (url ?? '').isEmpty
            ? _fallbackIcon()
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.electric_scooter,
        size: 36,
        color: Colors.grey,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: AppColors.black07Text,
        onPressed: onPressed,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.borderColor,
    required this.textColor,
    this.fontSize = 12,
  });

  final String label;
  final Color borderColor;
  final Color textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class _VehicleDetailPopup extends StatelessWidget {
  const _VehicleDetailPopup({
    required this.vehicle,
    required this.address,
    required this.distance,
    required this.onClose,
    required this.onViewMore,
  });

  final NearByVehicle vehicle;
  final String address;
  final String distance;
  final VoidCallback onClose;
  final VoidCallback onViewMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: GestureDetector(
            onTap: () {}, // 阻止点击穿透
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 关闭按钮
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  // 车辆信息
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _VehicleImage(url: vehicle.img),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SN: ${vehicle.sn ?? '-'}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: AppColors.black09Text,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      if (vehicle.needMaintenance == true)
                                        _StatusChip(
                                          label: l10n.homeFilterNeedMaintenance,
                                          borderColor: AppColors.danger,
                                          textColor: AppColors.danger,
                                          fontSize: 12,
                                        ),
                                      _StatusChip(
                                        label: 'Binding ID: ${vehicle.cardNum ?? '-'}',
                                        borderColor: AppColors.black02Text,
                                        textColor: AppColors.black06Text,
                                        fontSize: 12,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 用户手机（如果有）
                        Row(
                          children: [
                            Icon(Icons.phone, size: 18, color: AppColors.black04Text),
                            const SizedBox(width: 6),
                            Text(
                              'User phone: +86 12312231520',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 地址
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 18, color: AppColors.black04Text),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                address,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.black06Text,
                                  height: 1.3,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.campaign_outlined,
                              size: 18,
                              color: AppColors.black04Text,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.black06Text,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 车牌和里程信息
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Plate Number',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'V1490',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
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
                                      'Mileage',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${vehicle.mile?.toStringAsFixed(0) ?? '0'}km',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // View More Bound Vehicles 按钮
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: onViewMore,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'View More Bound Vehicles',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.black07Text,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
