import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// 展示车辆所在位置的地图：Android 使用 Google Maps，iOS 使用 Apple Maps。
class VehicleMap extends StatelessWidget {
  const VehicleMap({
    super.key,
    this.latitude = 22.543099,
    this.longitude = 114.057868,
    this.markers = const <gmaps.Marker>{},
    this.annotations = const <amaps.Annotation>{},
    this.onGoogleMapCreated,
    this.onAppleMapCreated,
  });

  final double latitude;
  final double longitude;
  final Set<gmaps.Marker> markers;
  final Set<amaps.Annotation> annotations;
  final void Function(gmaps.GoogleMapController controller)?
      onGoogleMapCreated;
  final void Function(amaps.AppleMapController controller)?
      onAppleMapCreated;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(child: Text('Web 平台暂不支持地图展示'));
    }

    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.android) {
      return _AndroidVehicleMap(
        position: gmaps.LatLng(latitude, longitude),
        markers: markers,
        onMapCreated: onGoogleMapCreated,
      );
    }

    if (platform == TargetPlatform.iOS) {
      return _IosVehicleMap(
        position: amaps.LatLng(latitude, longitude),
        annotations: annotations,
        onMapCreated: onAppleMapCreated,
      );
    }

    return const Center(child: Text('当前平台暂不支持地图展示'));
  }
}

class _AndroidVehicleMap extends StatelessWidget {
  const _AndroidVehicleMap({
    required this.position,
    required this.markers,
    this.onMapCreated,
  });

  final gmaps.LatLng position;
  final Set<gmaps.Marker> markers;
  final void Function(gmaps.GoogleMapController controller)? onMapCreated;
  static const double _defaultZoom = 14;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: gmaps.GoogleMap(
        initialCameraPosition: gmaps.CameraPosition(
          target: position,
          zoom: _defaultZoom,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: onMapCreated,
      ),
    );
  }
}

class _IosVehicleMap extends StatelessWidget {
  const _IosVehicleMap({
    required this.position,
    required this.annotations,
    this.onMapCreated,
  });

  final amaps.LatLng position;
  final Set<amaps.Annotation> annotations;
  final void Function(amaps.AppleMapController controller)? onMapCreated;
  static const double _defaultZoom = 14;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: amaps.AppleMap(
        initialCameraPosition: amaps.CameraPosition(
          target: position,
          zoom: _defaultZoom,
        ),
        annotations: annotations,
        compassEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        mapType: amaps.MapType.standard,
        onMapCreated: onMapCreated,
      ),
    );
  }
}
