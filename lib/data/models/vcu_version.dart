import 'package:flutter/foundation.dart';

@immutable
class VcuVersion {
  final String? version;
  final String? name;
  final String? url;

  const VcuVersion({this.version, this.name, this.url});

  factory VcuVersion.fromJson(Map<String, dynamic> json) {
    return VcuVersion(
      version: json['version']?.toString(),
      name: json['name']?.toString(),
      url: json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'name': name,
        'url': url,
      };
}
