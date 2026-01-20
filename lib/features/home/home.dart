import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  double? _latitude;
  double? _longitude;
  int? _maintainFlag;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (_) {
      setState(() {
        _latitude = _fallbackLatitude;
        _longitude = _fallbackLongitude;
      });
    }
  }

  Future<void> _fetchVehicles() async {
    if (_loading) return;
    setState(() => _loading = true);
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
            onTap: () => _openDetail(item.sn),
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
            infoWindow: amaps.InfoWindow(
              title: item.sn ?? '-',
              snippet: item.cardNum,
            ),
            onTap: () => _openDetail(item.sn),
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
              },
              onAppleMapCreated: (controller) {
                _appleController = controller;
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.black09Text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onSearch,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                                ?.copyWith(color: AppColors.black05Text),
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                children: [
                  _CircleIconButton(
                    icon: Icons.my_location_outlined,
                    onPressed: onLocate,
                  ),
                  const SizedBox(height: 10),
                  _CircleIconButton(
                    icon: Icons.refresh,
                    onPressed: onRefresh,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                            ),
                          _StatusChip(
                            label:
                                '${context.l10n.vehicleSearchBindIdLabel}: ${info.cardNum ?? '-'}',
                            borderColor: AppColors.black02Text,
                            textColor: AppColors.black06Text,
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
  });

  final String label;
  final Color borderColor;
  final Color textColor;

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
        ),
      ),
    );
  }
}
