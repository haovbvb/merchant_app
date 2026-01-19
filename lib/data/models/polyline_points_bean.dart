import 'package:flutter/foundation.dart';

@immutable
class PolylinePointsBean {
  final String status;
  final List<Map<String, dynamic>> geocodedWaypoints;
  final List<Map<String, dynamic>> routes;

  const PolylinePointsBean({
    required this.status,
    required this.geocodedWaypoints,
    required this.routes,
  });

  factory PolylinePointsBean.fromJson(Map<String, dynamic> json) {
    return PolylinePointsBean(
      status: (json['status'] ?? '').toString(),
      geocodedWaypoints: (json['geocoded_waypoints'] as List<dynamic>?)
              ?.map((item) => Map<String, dynamic>.from(item as Map))
              .toList() ??
          const <Map<String, dynamic>>[],
      routes: (json['routes'] as List<dynamic>?)
              ?.map((item) => Map<String, dynamic>.from(item as Map))
              .toList() ??
          const <Map<String, dynamic>>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'geocoded_waypoints': geocodedWaypoints,
        'routes': routes,
      };
}
