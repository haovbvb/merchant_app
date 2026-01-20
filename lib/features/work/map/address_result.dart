import 'package:flutter/foundation.dart';

@immutable
class AddressResult {
  final String address;
  final double latitude;
  final double longitude;

  const AddressResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}
