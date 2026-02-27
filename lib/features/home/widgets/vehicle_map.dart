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
    this.polylines = const <gmaps.Polyline>{},
    this.annotations = const <amaps.Annotation>{},
    this.onGoogleMapCreated,
    this.onAppleMapCreated,
    this.onMapTap,
    this.onGoogleCameraMove,
    this.onGoogleCameraIdle,
  });

  final double latitude;
  final double longitude;
  final Set<gmaps.Marker> markers;
    final Set<gmaps.Polyline> polylines;
  final Set<amaps.Annotation> annotations;
  final void Function(gmaps.GoogleMapController controller)?
      onGoogleMapCreated;
  final void Function(amaps.AppleMapController controller)?
      onAppleMapCreated;
    final VoidCallback? onMapTap;
    final void Function(gmaps.CameraPosition position)? onGoogleCameraMove;
    final VoidCallback? onGoogleCameraIdle;

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
        polylines: polylines,
        onMapCreated: onGoogleMapCreated,
        onMapTap: onMapTap,
        onCameraMove: onGoogleCameraMove,
        onCameraIdle: onGoogleCameraIdle,
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
    required this.polylines,
    this.onMapCreated,
    this.onMapTap,
    this.onCameraMove,
    this.onCameraIdle,
  });

  final gmaps.LatLng position;
  final Set<gmaps.Marker> markers;
  final Set<gmaps.Polyline> polylines;
  final void Function(gmaps.GoogleMapController controller)? onMapCreated;
  final VoidCallback? onMapTap;
  final void Function(gmaps.CameraPosition position)? onCameraMove;
  final VoidCallback? onCameraIdle;
  static const double _defaultZoom = 14;

  @override
  Widget build(BuildContext context) {
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: position,
        zoom: _defaultZoom,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: onMapCreated,
      onTap: (_) => onMapTap?.call(),
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
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
    return amaps.AppleMap(
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
    );
  }
}
