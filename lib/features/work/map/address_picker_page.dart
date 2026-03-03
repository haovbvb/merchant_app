import 'dart:async';
import 'dart:math' as math;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/location_permission.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/map/address_result.dart';

class AddressPickerPage extends StatefulWidget {
  const AddressPickerPage({super.key, this.initial});

  final AddressResult? initial;

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  _MapCenter? _center;
  _MapCenter? _userLocation;
  String _address = '';
  String _placeName = '';
  bool _loading = false;

  gmaps.GoogleMapController? _googleMapController;
  amaps.AppleMapController? _appleMapController;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _center = _MapCenter(widget.initial!.latitude, widget.initial!.longitude);
      _address = widget.initial!.address;
    }
    unawaited(_ensureLocation());
  }

  Future<void> _ensureLocation() async {
    final permission = await ensureLocationPermission();
    if (permission.status == LocationPermissionStatus.serviceDisabled) {
      showToast('请开启定位服务');
      return;
    }
    if (permission.status == LocationPermissionStatus.deniedForever) {
      showToast('定位权限被拒绝');
      return;
    }
    if (!permission.granted) return;

    final pos = await Geolocator.getCurrentPosition();
    _userLocation = _MapCenter(pos.latitude, pos.longitude);

    if (_center == null) {
      setState(() => _center = _userLocation);
      await _reverseGeocode(_center!, showError: false);
    }
  }

  Future<void> _reverseGeocode(
    _MapCenter target, {
    bool showError = true,
  }) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        target.latitude,
        target.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // 地点名称
        _placeName = place.name ?? place.street ?? '';
        // 详细地址
        final parts =
            [
                  place.street,
                  place.subLocality,
                  place.locality,
                  place.administrativeArea,
                  place.country,
                ]
                .whereType<String>()
                .where((value) => value.trim().isNotEmpty)
                .toList();
        setState(() => _address = parts.join(' '));
      }
    } catch (_) {
      if (showError && mounted) {
        showToast(context.l10n.addressPickerFetchFailed);
      }
      if (mounted && _address.isEmpty) {
        setState(() => _address = '--');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _formatDistance() {
    if (_userLocation == null || _center == null) return '';
    final distance = _calculateDistance(
      _userLocation!.latitude,
      _userLocation!.longitude,
      _center!.latitude,
      _center!.longitude,
    );
    if (distance < 1000) {
      return '${distance.toInt()} m';
    }
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // 地球半径（米）
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) => degree * math.pi / 180;

  Future<void> _openSearch() async {
    final result = await Navigator.of(context).push<AddressResult>(
      MaterialPageRoute(
        builder: (_) => _AddressSearchPage(userLocation: _userLocation),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _center = _MapCenter(result.latitude, result.longitude);
        _address = result.address;
        _placeName = result.name ?? '';
      });
      _moveCamera(result.latitude, result.longitude);
    }
  }

  void _moveCamera(double lat, double lng) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _googleMapController?.animateCamera(
        gmaps.CameraUpdate.newLatLng(gmaps.LatLng(lat, lng)),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _appleMapController?.animateCamera(
        amaps.CameraUpdate.newLatLng(amaps.LatLng(lat, lng)),
      );
    }
  }

  void _relocate() {
    if (_userLocation != null) {
      _moveCamera(_userLocation!.latitude, _userLocation!.longitude);
      setState(() => _center = _userLocation);
      _reverseGeocode(_center!, showError: false);
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
          l10n.addressPickerTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: _center == null
          ? const Center(child: SizedBox.shrink())
          : Stack(
              children: [
                // 地图
                Positioned.fill(child: _buildMap()),

                // 中心大头针
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 36),
                    child: Icon(
                      Icons.location_on,
                      size: 48,
                      color: AppColors.black06Text,
                    ),
                  ),
                ),

                // 右下角按钮
                Positioned(
                  right: 16,
                  bottom: 240,
                  child: Column(
                    children: [
                      _MapButton(
                        icon: Icons.refresh,
                        onTap: () => _reverseGeocode(_center!, showError: true),
                      ),
                      const SizedBox(height: 8),
                      _MapButton(icon: Icons.my_location, onTap: _relocate),
                    ],
                  ),
                ),

                // 底部地址卡片
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: _AddressCard(
                    placeName: _placeName.isNotEmpty ? _placeName : _address,
                    address: _address,
                    latitude: _center!.latitude,
                    longitude: _center!.longitude,
                    distance: _formatDistance(),
                    loading: _loading,
                    onConfirm: () => Navigator.of(context).pop(
                      AddressResult(
                        address: _address,
                        latitude: _center!.latitude,
                        longitude: _center!.longitude,
                        name: _placeName,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMap() {
    if (kIsWeb) {
      return const Center(child: Text('Web 平台暂不支持地图展示'));
    }
    final center = _center!;
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.android) {
      return gmaps.GoogleMap(
        initialCameraPosition: gmaps.CameraPosition(
          target: gmaps.LatLng(center.latitude, center.longitude),
          zoom: 16,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (controller) => _googleMapController = controller,
        onCameraIdle: () {
          if (_center != null) {
            _reverseGeocode(_center!, showError: false);
          }
        },
        onCameraMove: (position) {
          _center = _MapCenter(
            position.target.latitude,
            position.target.longitude,
          );
        },
      );
    }
    if (platform == TargetPlatform.iOS) {
      return amaps.AppleMap(
        initialCameraPosition: amaps.CameraPosition(
          target: amaps.LatLng(center.latitude, center.longitude),
          zoom: 16,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: (controller) => _appleMapController = controller,
        onCameraIdle: () {
          if (_center != null) {
            _reverseGeocode(_center!, showError: false);
          }
        },
        onCameraMove: (position) {
          _center = _MapCenter(
            position.target.latitude,
            position.target.longitude,
          );
        },
      );
    }
    return const Center(child: Text('当前平台暂不支持地图展示'));
  }
}

class _MapCenter {
  const _MapCenter(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

/// 地图操作按钮
class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}

/// 底部地址卡片
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.placeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.loading,
    required this.onConfirm,
  });

  final String placeName;
  final String address;
  final double latitude;
  final double longitude;
  final String distance;
  final bool loading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 地点名称
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF4A90D9), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: SizedBox.shrink(),
                      )
                    : Text(
                        placeName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 详细地址
          Text(
            address,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // 坐标和距离
          Row(
            children: [
              Text(
                '${l10n.addressPickerCoordinates}: ${longitude.toStringAsFixed(6)}  ${latitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
              ),
              const Spacer(),
              if (distance.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: Color(0xFFEEEEEE))),
                  ),
                  child: Text(
                    distance,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 确认按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7CB342),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.addressPickerConfirm,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 地址搜索页面
class _AddressSearchPage extends StatefulWidget {
  const _AddressSearchPage({this.userLocation});

  final _MapCenter? userLocation;

  @override
  State<_AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<_AddressSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<_SearchResult> _results = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _search(query.trim());
      } else {
        setState(() => _results = []);
      }
    });
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final locations = await locationFromAddress(query);
      final results = <_SearchResult>[];

      for (final loc in locations.take(10)) {
        final placemarks = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final name = place.name ?? place.street ?? query;
          final parts = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ].whereType<String>().where((v) => v.trim().isNotEmpty).toList();

          double? distance;
          if (widget.userLocation != null) {
            distance = _calculateDistance(
              widget.userLocation!.latitude,
              widget.userLocation!.longitude,
              loc.latitude,
              loc.longitude,
            );
          }

          results.add(
            _SearchResult(
              name: name,
              address: parts.join(' '),
              latitude: loc.latitude,
              longitude: loc.longitude,
              distance: distance,
            ),
          );
        }
      }

      setState(() => _results = results);
    } catch (_) {
      setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  String _formatDistance(double? distance) {
    if (distance == null) return '';
    if (distance < 1000) {
      return '${distance.toInt()} m';
    }
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Container(
          height: 36,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF999999), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: l10n.addressPickerSearchHint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 15),
                  onChanged: _onSearchChanged,
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _results = []);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCCCCCC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: SizedBox.shrink())
          : _results.isEmpty
          ? Center(
              child: Text(
                _searchController.text.trim().isEmpty
                    ? l10n.addressPickerEmpty
                    : l10n.addressPickerSearchNotFound,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 12),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 1),
              itemBuilder: (context, index) {
                final item = _results[index];
                return _SearchResultItem(
                  name: item.name,
                  address: item.address,
                  latitude: item.latitude,
                  longitude: item.longitude,
                  distance: _formatDistance(item.distance),
                  onTap: () => Navigator.of(context).pop(
                    AddressResult(
                      address: item.address,
                      latitude: item.latitude,
                      longitude: item.longitude,
                      name: item.name,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _SearchResult {
  const _SearchResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distance,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? distance;
}

/// 搜索结果项
class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.onTap,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Color(0xFF4A90D9), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black06Text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${l10n.addressPickerCoordinates}: ${longitude.toStringAsFixed(6)}  ${latitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const Spacer(),
                      if (distance.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(left: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Color(0xFFEEEEEE)),
                            ),
                          ),
                          child: Text(
                            distance,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}
