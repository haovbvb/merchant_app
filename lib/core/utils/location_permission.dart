import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationPermissionResult {
  const LocationPermissionResult(this.status);

  final LocationPermissionStatus status;

  bool get granted => status == LocationPermissionStatus.granted;
}

Future<LocationPermissionResult> ensureLocationPermission({
  bool requestPermission = true,
}) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return const LocationPermissionResult(
      LocationPermissionStatus.serviceDisabled,
    );
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied && requestPermission) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    return const LocationPermissionResult(LocationPermissionStatus.denied);
  }
  if (permission == LocationPermission.deniedForever) {
    return const LocationPermissionResult(
      LocationPermissionStatus.deniedForever,
    );
  }

  return const LocationPermissionResult(LocationPermissionStatus.granted);
}
