class AreaCountryResp {
  final List<AreaCountry> list;

  const AreaCountryResp({required this.list});

  factory AreaCountryResp.fromJson(Map<String, dynamic> json) {
    final items = (json['list'] as List?)
            ?.map((e) => AreaCountry.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        const <AreaCountry>[];
    return AreaCountryResp(list: items);
  }
}

class AreaCountry {
  final String? areaCode;
  final String? country;
  final String? countrySimpleName;
  final String? tenantId;

  const AreaCountry({
    this.areaCode,
    this.country,
    this.countrySimpleName,
    this.tenantId,
  });

  factory AreaCountry.fromJson(Map<String, dynamic> json) {
    return AreaCountry(
      areaCode: json['areaCode']?.toString(),
      country: json['country']?.toString(),
      countrySimpleName: json['countrySimpleName']?.toString(),
      tenantId: json['tenantId']?.toString(),
    );
  }
}
