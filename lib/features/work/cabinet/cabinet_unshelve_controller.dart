import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/new_cabinet_bean.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class CabinetUnshelveState {
  final bool loadingCabinet;
  final bool submitting;
  final NewCabinetBean? cabinet;

  const CabinetUnshelveState({
    this.loadingCabinet = false,
    this.submitting = false,
    this.cabinet,
  });

  CabinetUnshelveState copyWith({
    bool? loadingCabinet,
    bool? submitting,
    NewCabinetBean? cabinet,
  }) {
    return CabinetUnshelveState(
      loadingCabinet: loadingCabinet ?? this.loadingCabinet,
      submitting: submitting ?? this.submitting,
      cabinet: cabinet ?? this.cabinet,
    );
  }
}

final cabinetUnshelveProvider =
    NotifierProvider<CabinetUnshelveNotifier, CabinetUnshelveState>(
  CabinetUnshelveNotifier.new,
);

class CabinetUnshelveNotifier extends Notifier<CabinetUnshelveState> {
  final ApiService _api = ApiService();

  @override
  CabinetUnshelveState build() => const CabinetUnshelveState();

  Future<void> queryCabinet(String code) async {
    if (code.isEmpty) return;
    state = state.copyWith(loadingCabinet: true);
    final response = await _api.get<NewCabinetBean>(
      '${ApiPath.stationGetTypeBySource}/1/$code',
      parser: (json) => NewCabinetBean.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingCabinet: false,
      cabinet: response.result,
    );
  }

  Future<bool> submit({required String sn, required String reason}) async {
    if (sn.isEmpty || reason.isEmpty) return false;
    state = state.copyWith(submitting: true);
    final response = await _api.post<Object>(
      ApiPath.stationTakeOff,
      data: {
        'sn': sn,
        'reason': reason,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(submitting: false);
    return response.isSuccess;
  }
}
