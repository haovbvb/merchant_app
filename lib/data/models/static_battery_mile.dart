/// 电池里程统计
class StaticBatteryMile {
  final double? mile;
  final double? todayMile;
  final double? avgSpeed;
  final List<double>? miles;
  final List<String>? xvalue;

  const StaticBatteryMile({
    this.mile,
    this.todayMile,
    this.avgSpeed,
    this.miles,
    this.xvalue,
  });

  factory StaticBatteryMile.fromJson(Map<String, dynamic> json) {
    return StaticBatteryMile(
      mile: (json['mile'] as num?)?.toDouble(),
      todayMile: (json['todayMile'] as num?)?.toDouble(),
      avgSpeed: (json['avgSpeed'] as num?)?.toDouble(),
      miles: (json['miles'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      xvalue: (json['xvalue'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mile': mile,
      'todayMile': todayMile,
      'avgSpeed': avgSpeed,
      'miles': miles,
      'xvalue': xvalue,
    };
  }
}

/// 每日里程信息
class MileageInfoListResp {
  final String? time;
  final double? todayMile;

  const MileageInfoListResp({this.time, this.todayMile});

  factory MileageInfoListResp.fromJson(Map<String, dynamic> json) {
    return MileageInfoListResp(
      time: json['time'] as String?,
      todayMile: (json['todayMile'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'time': time, 'todayMile': todayMile};
  }
}
