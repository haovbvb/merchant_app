import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
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
  String _address = '';
  bool _loading = false;

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
    if (_center == null) {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _center = _MapCenter(pos.latitude, pos.longitude));
      await _reverseGeocode(_center!);
    }
  }

  Future<void> _reverseGeocode(_MapCenter target) async {
    setState(() => _loading = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        target.latitude,
        target.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
        setState(() => _address = parts.join(' '));
      }
    } catch (_) {
      showToast('获取地址失败');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addressPickerTitle),
        actions: [
          TextButton(
            onPressed: _center == null
                ? null
                : () => Navigator.of(context).pop(
                      AddressResult(
                        address: _address,
                        latitude: _center!.latitude,
                        longitude: _center!.longitude,
                      ),
                    ),
            child: Text(l10n.addressPickerConfirm),
          ),
        ],
      ),
      body: _center == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildMap(),
                Center(
                  child: Icon(Icons.location_on,
                      size: 36, color: Theme.of(context).colorScheme.primary),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _address.isEmpty
                                  ? l10n.addressPickerEmpty
                                  : _address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_loading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
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
        myLocationButtonEnabled: true,
        onCameraIdle: () {
          if (_center != null) {
            _reverseGeocode(_center!);
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
        myLocationButtonEnabled: true,
        onCameraIdle: () {
          if (_center != null) {
            _reverseGeocode(_center!);
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
