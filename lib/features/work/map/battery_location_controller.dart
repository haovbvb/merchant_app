import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class BatteryLocationState {
  final bool loading;
  final BatteryDetail? detail;

  const BatteryLocationState({
    this.loading = false,
    this.detail,
  });

  BatteryLocationState copyWith({
    bool? loading,
    BatteryDetail? detail,
  }) {
    return BatteryLocationState(
      loading: loading ?? this.loading,
      detail: detail ?? this.detail,
    );
  }
}

final batteryLocationProvider =
    NotifierProvider<BatteryLocationNotifier, BatteryLocationState>(
  BatteryLocationNotifier.new,
);

class BatteryLocationNotifier extends Notifier<BatteryLocationState> {
  final ApiService _api = ApiService();

  @override
  BatteryLocationState build() => const BatteryLocationState();

  Future<void> queryBattery(String sn) async {
    if (sn.isEmpty) return;
    state = state.copyWith(loading: true);
    final response = await _api.get<BatteryDetail>(
      ApiPath.batterySearchBySn,
      queryParameters: {'sn': sn},
      parser: (json) => BatteryDetail.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(loading: false, detail: response.result);
  }
}
