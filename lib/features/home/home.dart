import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:merchant_app/app/ui.dart';
import 'package:merchant_app/core/utils/location_permission.dart';
import 'package:merchant_app/data/models/near_by_vehicle.dart';
import 'package:merchant_app/features/home/widgets/vehicle_map.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/device/device_detail_page_new.dart';
import 'package:merchant_app/features/work/device/device_search_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> with WidgetsBindingObserver {
  static const double _fallbackLatitude = 22.543099;
  static const double _fallbackLongitude = 114.057868;
  static const int _vehicleCount = 1000;
  static const int _vehicleRadius = 30000;

  final ApiService _api = ApiService();
  final List<NearByVehicle> _vehicles = [];
  final Map<String, String> _addressCache = {};
  Set<gmaps.Polyline> _routePolylines = const <gmaps.Polyline>{};

  gmaps.GoogleMapController? _googleController;
  amaps.AppleMapController? _appleController;
  bool _loading = false;
  bool _pendingCenterOnLocation = true;
  final bool _useMockData = false;
  double? _latitude;
  double? _longitude;
  int? _maintainFlag;
  String? _vehicleSnFilter;
  NearByVehicle? _selectedVehicle;
  gmaps.BitmapDescriptor? _markerIcon;
  gmaps.BitmapDescriptor? _maintenanceMarkerIcon;
  gmaps.BitmapDescriptor? _selectedMarkerIcon;
  amaps.BitmapDescriptor? _appleMarkerIcon;
  amaps.BitmapDescriptor? _appleMaintenanceMarkerIcon;
  amaps.BitmapDescriptor? _appleSelectedMarkerIcon;
  gmaps.BitmapDescriptor? _locationMarkerIcon;
  bool _appleIconLoaded = false;
  bool _hasLocationPermission = false;
  gmaps.LatLng? _cameraTarget;
  DateTime? _lastCameraIdleFetchAt;
  bool _suppressNextCameraIdle = false;
  int _routeRequestSeq = 0;
  double _refreshTurns = 0;
  double _locateTurns = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMarkerIcon();
    _loadInitialData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用从后台恢复时，检查位置权限是否发生变化
    if (state == AppLifecycleState.resumed) {
      _checkPermissionChange();
    }
  }

  Future<void> _checkPermissionChange() async {
    final permission = await ensureLocationPermission(requestPermission: false);
    if (permission.granted && !_hasLocationPermission) {
      // 权限从无到有，重新获取位置并刷新数据
      _hasLocationPermission = true;
      await _ensureLocation();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appleIconLoaded) return;
    _appleIconLoaded = true;
    _loadAppleMarkerIcon();
  }

  Future<void> _loadMarkerIcon() async {
    final configuration = createLocalImageConfiguration(
      context,
      size: const Size(108, 110),
    );
    // 加载正常车辆标记图标
    final icon = await gmaps.BitmapDescriptor.fromAssetImage(
      configuration,
      'assets/android/mipmap-xxhdpi/icon_marker_vehicle.png',
    );
    if (mounted) {
      setState(() {
        _markerIcon = icon;
      });
    }
    // 加载需要保养的标记图标
    final maintenanceIcon = await gmaps.BitmapDescriptor.fromAssetImage(
      configuration,
      'assets/android/mipmap-xxhdpi/icon_marker_need_maintenance.png',
    );
    if (mounted) {
      setState(() {
        _maintenanceMarkerIcon = maintenanceIcon;
      });
    }
    // 加载位置标记图标
    final locationIcon = await gmaps.BitmapDescriptor.fromAssetImage(
      configuration,
      'assets/android/mipmap-xxhdpi/icon_location.webp',
    );
    if (mounted) {
      setState(() {
        _locationMarkerIcon = locationIcon;
      });
    }
    // 加载选中车辆标记图标
    final selectedIcon = await gmaps.BitmapDescriptor.fromAssetImage(
      configuration,
      'assets/android/mipmap-xxhdpi/car_map_selected.png',
    );
    if (mounted) {
      setState(() {
        _selectedMarkerIcon = selectedIcon;
      });
    }
  }

  Future<void> _loadAppleMarkerIcon() async {
    // 加载正常车辆标记图标（按像素缩放，确保 iOS 生效）
    final icon = await _loadAppleBitmapDescriptor(
      'assets/android/mipmap-xxhdpi/3.0x/icon_marker_vehicle.png',
      // targetWidth: targetWidth,
      // targetHeight: targetHeight,
    );
    if (mounted) {
      setState(() {
        _appleMarkerIcon = icon;
      });
    }
    // 加载需要保养的标记图标
    final maintenanceIcon = await _loadAppleBitmapDescriptor(
      'assets/android/mipmap-xxhdpi/3.0x/icon_marker_need_maintenance.png',
      // targetWidth: targetWidth,
      // targetHeight: targetHeight,
    );
    if (mounted) {
      setState(() {
        _appleMaintenanceMarkerIcon = maintenanceIcon;
      });
    }
    // 加载选中车辆标记图标
    final selectedIcon = await _loadAppleBitmapDescriptor(
      'assets/android/mipmap-xxhdpi/car_map_selected.png',
      // targetWidth: targetWidth,
      // targetHeight: targetHeight,
    );
    if (mounted) {
      setState(() {
        _appleSelectedMarkerIcon = selectedIcon;
      });
    }
    // iOS 系统已有蓝色位置标记，无需手动加载
  }

  Future<amaps.BitmapDescriptor> _loadAppleBitmapDescriptor(
    String assetPath, {
    int? targetWidth,
    int? targetHeight,
  }) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
    final frameInfo = await codec.getNextFrame();
    final byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return amaps.BitmapDescriptor.fromBytes(
      byteData!.buffer.asUint8List(),
    );
  }

  Future<void> _loadInitialData() async {
    await _ensureLocation(isInitial: true);
    if (mounted) {
      await _fetchVehicles();
    }
  }

  Future<void> _ensureLocation({bool isInitial = false}) async {
    try {
      final permission = await ensureLocationPermission();
      _hasLocationPermission = permission.granted;
      if (!permission.granted) {
        setState(() {
          _latitude = _fallbackLatitude;
          _longitude = _fallbackLongitude;
        });
        _maybeCenterMap();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final latChanged = _latitude != position.latitude;
      final lngChanged = _longitude != position.longitude;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      
      // 如果位置发生变化，居中地图并刷新数据（非初始化时）
      if (!isInitial && (latChanged || lngChanged)) {
        _pendingCenterOnLocation = true;
        _maybeCenterMap();
        await _fetchVehicles();
      } else {
        _maybeCenterMap();
      }
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
      final selectedId =
          _selectedVehicle == null ? null : _vehicleMarkerId(_selectedVehicle!);
      NearByVehicle? selected;
      if (selectedId != null) {
        for (final item in mockList) {
          if (_vehicleMarkerId(item) == selectedId) {
            selected = item;
            break;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _loading = false;
        _vehicles
          ..clear()
          ..addAll(mockList);
        _selectedVehicle = selected;
        _routePolylines = _buildRoutePolylines(selected);
      });
      final requestId = ++_routeRequestSeq;
      unawaited(_refreshRoutePolylines(selected, requestId: requestId));
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
        if (_vehicleSnFilter != null && _vehicleSnFilter!.isNotEmpty)
          'vehicleSn': _vehicleSnFilter,
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
    final nextVehicles = response.result ?? const <NearByVehicle>[];
    final selectedId =
        _selectedVehicle == null ? null : _vehicleMarkerId(_selectedVehicle!);
    NearByVehicle? selected;
    if (selectedId != null) {
      for (final item in nextVehicles) {
        if (_vehicleMarkerId(item) == selectedId) {
          selected = item;
          break;
        }
      }
    }
    setState(() {
      _loading = false;
      _vehicles
        ..clear()
        ..addAll(nextVehicles);
      _selectedVehicle = selected;
      _routePolylines = _buildRoutePolylines(selected);
    });
    final requestId = ++_routeRequestSeq;
    unawaited(_refreshRoutePolylines(selected, requestId: requestId));
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
      final address = (vehicle.address ?? '').trim();
      if (address.isNotEmpty) continue;
      final lat = vehicle.latitude;
      final lng = vehicle.longitude;
      if (lat == null || lng == null || lat == 0 || lng == 0) continue;
      final key = _addressKey(lat, lng);
      if (_addressCache.containsKey(key)) continue;
      final resolvedAddress = await _resolveAddress(lat, lng);
      if (!mounted) return;
      setState(() => _addressCache[key] = resolvedAddress);
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

  String _vehicleMarkerId(NearByVehicle vehicle) {
    final lat = vehicle.latitude;
    final lng = vehicle.longitude;
    return vehicle.sn ?? vehicle.cardNum ?? '$lat-$lng';
  }

  bool _isSelectedVehicle(NearByVehicle vehicle) {
    final selected = _selectedVehicle;
    if (selected == null) return false;
    return _vehicleMarkerId(selected) == _vehicleMarkerId(vehicle);
  }

  String _distanceLabel(NearByVehicle vehicle) {
    final lat = vehicle.latitude;
    final lng = vehicle.longitude;
    final centerLat = _latitude;
    final centerLng = _longitude;
    final mile = vehicle.mile;
    if (mile != null && mile > 0) {
      if (mile < 1) {
        return '${(mile * 1000).toStringAsFixed(0)}m';
      }
      return '${mile.toStringAsFixed(1)}km';
    }
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
    final address = (vehicle.address ?? '').trim();
    if (address.isNotEmpty) return address;
    final lat = vehicle.latitude;
    final lng = vehicle.longitude;
    if (lat == null || lng == null || lat == 0 || lng == 0) return '-';
    return _addressCache[_addressKey(lat, lng)] ?? _formatCoordinates(lat, lng);
  }

  Future<void> _openSearch() async {
    final lat = _latitude ?? _fallbackLatitude;
    final lng = _longitude ?? _fallbackLongitude;
    final sn = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => DeviceSearchPage(
          returnResult: true,
          latitude: lat,
          longitude: lng,
        ),
      ),
    );
    if (!mounted) return;
    if (sn != null && sn.trim().isNotEmpty) {
      setState(() => _vehicleSnFilter = sn.trim());
      await _fetchVehicles();
    }
  }

  void _selectVehicle(NearByVehicle? vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
      _routePolylines = _buildRoutePolylines(vehicle);
    });
    final requestId = ++_routeRequestSeq;
    unawaited(_refreshRoutePolylines(vehicle, requestId: requestId));
    if (vehicle != null) {
      unawaited(_centerOnVehicle(vehicle));
    }
  }

  Set<gmaps.Polyline> _buildRoutePolylines(NearByVehicle? vehicle) {
    final fromLat = _latitude;
    final fromLng = _longitude;
    final toLat = vehicle?.latitude;
    final toLng = vehicle?.longitude;
    if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
      return const <gmaps.Polyline>{};
    }
    return <gmaps.Polyline>{
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('selected_route'),
        points: <gmaps.LatLng>[
          gmaps.LatLng(fromLat, fromLng),
          gmaps.LatLng(toLat, toLng),
        ],
        color: AppColors.primaryColor,
        width: 5,
      ),
    };
  }

  Future<void> _refreshRoutePolylines(
    NearByVehicle? vehicle, {
    required int requestId,
  }) async {
    if (!mounted || requestId != _routeRequestSeq) return;
    if (vehicle == null || kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    const directionApiKey = String.fromEnvironment(
      'DIRECTION_API_KEY',
      defaultValue: '',
    );
    if (directionApiKey.isEmpty) return;

    final fromLat = _latitude;
    final fromLng = _longitude;
    final toLat = vehicle.latitude;
    final toLng = vehicle.longitude;
    if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
      return;
    }

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://maps.googleapis.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final response = await dio.get<Map<String, dynamic>>(
        '/maps/api/directions/json',
        queryParameters: {
          'origin': '$fromLat,$fromLng',
          'destination': '$toLat,$toLng',
          'avoid': 'highways',
          'mode': 'WALKING',
          'key': directionApiKey,
        },
      );
      final data = response.data;
      if (data == null) return;
      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return;
      final firstRoute = Map<String, dynamic>.from(routes.first as Map);
      final overview = firstRoute['overview_polyline'];
      if (overview is! Map) return;
      final encoded = (overview['points'] ?? '').toString();
      if (encoded.isEmpty) return;
      final points = _decodePolyline(encoded);
      if (points.length < 2) return;
      if (!mounted || requestId != _routeRequestSeq) return;

      setState(() {
        _routePolylines = <gmaps.Polyline>{
          gmaps.Polyline(
            polylineId: const gmaps.PolylineId('selected_route'),
            points: points,
            color: AppColors.primaryColor,
            width: 5,
          ),
        };
      });
    } catch (_) {
      // 使用直线回退
    }
  }

  List<gmaps.LatLng> _decodePolyline(String encoded) {
    final points = <gmaps.LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length + 1);
      final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length + 1);
      final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(gmaps.LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Future<void> _centerOnVehicle(NearByVehicle vehicle) async {
    final lat = vehicle.latitude;
    final lng = vehicle.longitude;
    if (lat == null || lng == null || kIsWeb) return;
    _suppressNextCameraIdle = true;
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

  Future<void> _openDetail(String? sn) async {
    if (sn == null || sn.trim().isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailPageNew(
          initialSn: sn,
          readOnly: true,
        ),
      ),
    );
  }

  Future<void> _centerMap() async {
    final lat = _latitude ?? _fallbackLatitude;
    final lng = _longitude ?? _fallbackLongitude;
    if (kIsWeb) return;
    _suppressNextCameraIdle = true;
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
    // 确保位置数据已获取后再居中地图
    if (_latitude == null || _longitude == null) return;
    _pendingCenterOnLocation = false;
    _centerMap();
  }

  Future<void> _onGoogleCameraIdle() async {
    if (_suppressNextCameraIdle) {
      _suppressNextCameraIdle = false;
      return;
    }
    if (_selectedVehicle != null) return;
    final target = _cameraTarget;
    if (target == null) return;

    final now = DateTime.now();
    if (_lastCameraIdleFetchAt != null &&
        now.difference(_lastCameraIdleFetchAt!) <
            const Duration(milliseconds: 700)) {
      return;
    }
    _lastCameraIdleFetchAt = now;

    final oldLat = _latitude;
    final oldLng = _longitude;
    if (oldLat != null && oldLng != null) {
      final moved = Geolocator.distanceBetween(
        oldLat,
        oldLng,
        target.latitude,
        target.longitude,
      );
      if (moved < 50) {
        return;
      }
    }

    setState(() {
      _latitude = target.latitude;
      _longitude = target.longitude;
    });
    await _fetchVehicles();
  }

  Future<void> _showFilterSheet() async {
    final l10n = context.l10n;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final topPadding = MediaQuery.of(context).padding.top;
    
    // 计算弹窗位置：右上角筛选按钮下方
    final RelativeRect position = RelativeRect.fromLTRB(
      overlay.size.width - 16 - 200, // 右边距16，弹窗宽度200
      topPadding + 8 + 44 + 8, // 状态栏 + 顶部padding + 搜索栏高度 + 间距
      16, // 右边距
      0,
    );

    final selected = await showMenu<int?>(
      context: context,
      position: position,
      color: const Color(0xFF1E2A3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        PopupMenuItem<int?>(
          value: null,
          child: _FilterMenuItem(
            label: l10n.homeFilterAll,
            isSelected: _maintainFlag == null,
          ),
        ),
        PopupMenuItem<int?>(
          value: 0,
          child: _FilterMenuItem(
            label: l10n.homeFilterNormal,
            dotColor: AppColors.primaryColor,
            isSelected: _maintainFlag == 0,
          ),
        ),
        PopupMenuItem<int?>(
          value: 1,
          child: _FilterMenuItem(
            label: l10n.homeFilterNeedMaintenance,
            dotColor: const Color(0xFFF44336),
            isSelected: _maintainFlag == 1,
          ),
        ),
      ],
    );
    if (!mounted) return;
    if (selected != _maintainFlag) {
      setState(() => _maintainFlag = selected);
      await _fetchVehicles();
    }
  }

  Set<gmaps.Marker> _buildGoogleMarkers() {
    final markers = _vehicles
        .where((item) =>
            item.latitude != null &&
            item.longitude != null &&
            item.latitude != 0 &&
            item.longitude != 0)
        .map(
          (item) {
            // 根据是否需要保养选择不同的图标
            final markerIcon = item.needMaintenance == true
                ? (_maintenanceMarkerIcon ?? gmaps.BitmapDescriptor.defaultMarker)
                : (_markerIcon ?? gmaps.BitmapDescriptor.defaultMarker);
            final isSelected = _isSelectedVehicle(item);
            final selectedIcon = _selectedMarkerIcon ?? markerIcon;
            final baseMarkerId = _vehicleMarkerId(item);
            final renderMarkerId = isSelected ? '${baseMarkerId}_selected' : baseMarkerId;
            return gmaps.Marker(
              markerId: gmaps.MarkerId(renderMarkerId),
              position: gmaps.LatLng(item.latitude!, item.longitude!),
              icon: isSelected ? selectedIcon : markerIcon,
              zIndex: isSelected ? 1000 : 0,
              onTap: () => _selectVehicle(item),
            );
          },
        )
        .toSet();
    
    // 添加用户当前位置标记
    final lat = _latitude;
    final lng = _longitude;
    if (lat != null && lng != null) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('user_location'),
          position: gmaps.LatLng(lat, lng),
          icon: _locationMarkerIcon ?? gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueAzure),
          zIndex: 999,
        ),
      );
    }
    return markers;
  }

  Set<amaps.Annotation> _buildAppleAnnotations() {
    final annotations = _vehicles
        .where((item) =>
            item.latitude != null &&
            item.longitude != null &&
            item.latitude != 0 &&
            item.longitude != 0)
        .map(
          (item) {
            // 根据是否需要保养选择不同的图标
            final markerIcon = item.needMaintenance == true
                ? (_appleMaintenanceMarkerIcon ?? amaps.BitmapDescriptor.defaultAnnotation)
                : (_appleMarkerIcon ?? amaps.BitmapDescriptor.defaultAnnotation);
            final isSelected = _isSelectedVehicle(item);
            final selectedIcon = _appleSelectedMarkerIcon ?? markerIcon;
            final baseMarkerId = _vehicleMarkerId(item);
            final renderMarkerId = isSelected ? '${baseMarkerId}_selected' : baseMarkerId;
            return amaps.Annotation(
              annotationId: amaps.AnnotationId(
                renderMarkerId,
              ),
              position: amaps.LatLng(item.latitude!, item.longitude!),
              icon: isSelected ? selectedIcon : markerIcon,
              onTap: () => _selectVehicle(item),
            );
          },
        )
        .toSet();
    
    // iOS 系统已有蓝色位置标记，无需手动添加
    return annotations;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasLocation = _latitude != null && _longitude != null;
    final centerLat = hasLocation ? _latitude! : _fallbackLatitude;
    final centerLng = hasLocation ? _longitude! : _fallbackLongitude;
    final areaCode = AuthSession.instance.current?.areaCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: hasLocation
                ? VehicleMap(
                    latitude: centerLat,
                    longitude: centerLng,
                    markers: _buildGoogleMarkers(),
                    polylines: _routePolylines,
                    annotations: _buildAppleAnnotations(),
                    onMapTap: () => _selectVehicle(null),
                    onGoogleCameraMove: (position) {
                      _cameraTarget = position.target;
                    },
                    onGoogleCameraIdle: _onGoogleCameraIdle,
                    onGoogleMapCreated: (controller) {
                      _googleController = controller;
                      _maybeCenterMap();
                    },
                    onAppleMapCreated: (controller) {
                      _appleController = controller;
                      _maybeCenterMap();
                    },
                  )
                : const Center(child: SizedBox.shrink()),
          ),
          _HomeOverlays(
            title: l10n.homeTitle,
            searchHint: l10n.homeSearchHint,
            onSearch: _openSearch,
            onFilter: _showFilterSheet,
            onLocate: () {
              setState(() => _locateTurns += 1);
              _centerMap();
            },
            onRefresh: () {
              setState(() => _refreshTurns += 1);
              _fetchVehicles();
            },
            isFilterActive: _maintainFlag != null,
            vehicleSnFilter: _vehicleSnFilter,
            maintenanceLabel: _maintainFlag == null
                ? null
                : _maintainFlag == 1
                    ? l10n.homeFilterNeedMaintenance
                    : l10n.homeFilterNormal,
            onClearSnFilter: () async {
              setState(() => _vehicleSnFilter = null);
              await _fetchVehicles();
            },
            onClearMaintenance: () async {
              setState(() => _maintainFlag = null);
              await _fetchVehicles();
            },
            onClearAllFilters: () async {
              setState(() {
                _vehicleSnFilter = null;
                _maintainFlag = null;
              });
              await _fetchVehicles();
            },
            refreshTurns: _refreshTurns,
            locateTurns: _locateTurns,
          ),
          if (_vehicles.isNotEmpty && _selectedVehicle == null)
            _VehicleDraggableSheet(
              vehicles: _vehicles,
              loading: _loading,
              addressFor: _addressFor,
              distanceFor: _distanceLabel,
              onSelected: _openDetail,
              emptyText: l10n.homeEmpty,
            ),
          if (_selectedVehicle != null)
            _VehicleDetailSheet(
              vehicle: _selectedVehicle!,
              address: _addressFor(_selectedVehicle!),
              distance: _distanceLabel(_selectedVehicle!),
              originLat: _latitude,
              originLng: _longitude,
              areaCode: areaCode,
              onClose: () => _selectVehicle(null),
              onViewMore: () async {
                final sn = _selectedVehicle?.sn;
                _selectVehicle(null);
                await _openDetail(sn);
              },
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
    this.isFilterActive = false,
    this.vehicleSnFilter,
    this.maintenanceLabel,
    this.onClearSnFilter,
    this.onClearMaintenance,
    this.onClearAllFilters,
    required this.refreshTurns,
    required this.locateTurns,
  });

  final String title;
  final String searchHint;
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final VoidCallback onLocate;
  final VoidCallback onRefresh;
  final bool isFilterActive;
  final String? vehicleSnFilter;
  final String? maintenanceLabel;
  final VoidCallback? onClearSnFilter;
  final VoidCallback? onClearMaintenance;
  final VoidCallback? onClearAllFilters;
  final double refreshTurns;
  final double locateTurns;

  @override
  Widget build(BuildContext context) {
    final hasSnFilter = (vehicleSnFilter ?? '').trim().isNotEmpty;
    final hasMaintenance = (maintenanceLabel ?? '').trim().isNotEmpty;
    final hasFilters = hasSnFilter || hasMaintenance;

    return Column(
      children: [
        // 白色导航条
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onSearch,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(8),
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
                    iconWidget: Image.asset(
                      'assets/android/mipmap-xxhdpi/home_filter.png',
                      color: isFilterActive ? AppColors.primaryColor : null,
                    ),
                    showShadow: false,
                    onPressed: onFilter,
                  ),
                ],
              ),
              if (hasFilters) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (hasSnFilter)
                      _FilterChip(
                        label: 'SN: ${vehicleSnFilter!}',
                        onClear: onClearSnFilter,
                      ),
                    if (hasMaintenance)
                      _FilterChip(
                        label: maintenanceLabel!,
                        onClear: onClearMaintenance,
                      ),
                    if (onClearAllFilters != null)
                      GestureDetector(
                        onTap: onClearAllFilters,
                        child: Text(
                          context.l10n.deviceSearchHistoryClear,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        // 底部按钮
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 155),
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CircleIconButton(
                  iconWidget: AnimatedRotation(
                    turns: refreshTurns,
                    duration: const Duration(milliseconds: 800),
                    child: Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_refresh.png',
                    ),
                  ),
                  onPressed: onRefresh,
                ),
                const SizedBox(height: 10),
                _CircleIconButton(
                  iconWidget: AnimatedRotation(
                    turns: locateTurns,
                    duration: const Duration(milliseconds: 800),
                    child: Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_location1.png',
                    ),
                  ),
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
      minChildSize: 0.15,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.15, 0.35, 0.85],
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: loading
                    ? const Center(child: SizedBox.shrink())
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
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
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
                                const SizedBox(height: 10),
                            itemCount: vehicles.length,
                          ),
              ),
            ],
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
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
                        spacing: 6,
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
                                'ID: ${info.cardNum ?? '-'}',
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
                Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_location_item.webp',
                  width: 18,
                  height: 18,
                ),
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
                Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_monitor_distination.png',
                  width: 18,
                  height: 18,
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
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 60,
        height: 60,
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
      color: AppColors.bgColor,
      child: Image.asset(
        'assets/android/mipmap-xxhdpi/icon_transport_vehicel.png',
        width: 30,
        height: 30,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.onPressed,
    required this.iconWidget,
    this.showShadow = true,
  });

  final Widget iconWidget;
  final VoidCallback onPressed;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: iconWidget,
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
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

class _FilterMenuItem extends StatelessWidget {
  const _FilterMenuItem({
    required this.label,
    required this.isSelected,
    this.dotColor,
  });

  final String label;
  final bool isSelected;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (dotColor != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        if (isSelected)
          const Icon(
            Icons.check,
            color: AppColors.primaryColor,
            size: 20,
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.onClear,
  });

  final String label;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close,
                size: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VehicleDetailSheet extends StatefulWidget {
  const _VehicleDetailSheet({
    required this.vehicle,
    required this.address,
    required this.distance,
    required this.onClose,
    required this.onViewMore,
    this.originLat,
    this.originLng,
    this.areaCode,
  });

  final NearByVehicle vehicle;
  final String address;
  final String distance;
  final VoidCallback onClose;
  final VoidCallback onViewMore;
  final double? originLat;
  final double? originLng;
  final String? areaCode;

  @override
  State<_VehicleDetailSheet> createState() => _VehicleDetailSheetState();
}

class _VehicleDetailSheetState extends State<_VehicleDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final ApiService _api = ApiService();
  String? _phone;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
    _fetchPhone();
  }

  Future<void> _fetchPhone() async {
    final cardNum = widget.vehicle.cardNum;
    if (cardNum == null || cardNum.isEmpty) return;
    try {
      final response = await _api.get<String>(
        ApiPath.queryRiderPhone,
        queryParameters: {'cardNum': cardNum},
        parser: (json) => json?.toString() ?? '',
      );
      if (mounted) {
        setState(() {
          _phone = response.result;
        });
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    await _controller.reverse();
    widget.onClose();
  }

  String _formatPhone(String? phone) {
    final value = (phone ?? '').trim();
    if (value.isEmpty) return '-';
    final code = (widget.areaCode ?? '').trim();
    if (code.isEmpty) return value;
    if (value.startsWith(code)) return value;
    return '$code $value';
  }

  Future<void> _openNavigation() async {
    final lat = widget.vehicle.latitude;
    final lng = widget.vehicle.longitude;
    if (lat == null || lng == null) return;
    final originLat = widget.originLat;
    final originLng = widget.originLng;
    Uri uri;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final params = originLat != null && originLng != null
          ? 'saddr=$originLat,$originLng&daddr=$lat,$lng'
          : 'daddr=$lat,$lng';
      uri = Uri.parse('http://maps.apple.com/?$params');
    } else {
      final params = originLat != null && originLng != null
          ? 'origin=$originLat,$originLng&destination=$lat,$lng&travelmode=driving'
          : 'destination=$lat,$lng&travelmode=driving';
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&$params');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            // 下滑关闭
            if (details.velocity.pixelsPerSecond.dy > 100) {
              _handleClose();
            }
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0,0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动指示条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 车辆信息
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VehicleImage(url: widget.vehicle.img),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SN: ${widget.vehicle.sn ?? '-'}',
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
                              if (widget.vehicle.needMaintenance == true)
                                _StatusChip(
                                  label: l10n.homeFilterNeedMaintenance,
                                  borderColor: AppColors.danger,
                                  textColor: AppColors.danger,
                                  fontSize: 12,
                                ),
                              _StatusChip(
                                label: 'ID: ${widget.vehicle.cardNum ?? '-'}',
                                borderColor: AppColors.borderColor,
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
                // 用户手机
                Row(
                  children: [
                    Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_grey_phone.png',
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${l10n.vehicleDetailUserPhone}:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.black06Text,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _phone != null && _phone!.isNotEmpty
                          ? () => _callPhone(_phone!)
                          : null,
                      child: Text(
                        _formatPhone(_phone),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _phone != null && _phone!.isNotEmpty
                              ? Colors.blue
                              : AppColors.black06Text,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 地址和距离
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_location_item.webp',
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.address,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.black06Text,
                          height: 1.4,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _openNavigation,
                      child: Column(
                        children: [
                          Icon(
                            Icons.navigation,
                            size: 20,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.distance,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.black06Text,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 车牌和里程信息卡片
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/android/mipmap-xxhdpi/car_map_info_bg.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.vehicleDetailPlateNumber,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.vehicle.carNumber?.isNotEmpty == true
                                  ? widget.vehicle.carNumber!
                                  : '-',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
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
                              l10n.vehicleDetailMileage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.vehicle.mile?.toStringAsFixed(0) ?? '0'} km',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // View More 按钮
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _controller.reverse();
                      widget.onViewMore();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.vehicleDetailViewMore,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.black07Text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
    );
  }
}
