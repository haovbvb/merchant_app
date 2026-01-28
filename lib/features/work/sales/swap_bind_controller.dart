import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/pack.dart';
import 'package:merchant_app/data/models/swap_bind_info.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class SwapBindState {
  final bool loadingUser;
  final bool loadingPack;
  final bool submitting;
  final SwapBindInfo? info;
  final CarVo? selectedCar;
  final BatteryVo? selectedBattery;
  final List<BatteryVo> selectedBatteries;
  final List<Pack> packs;
  final Pack? selectedPack;
  final int paySource;
  final bool submitSuccess;
  final String? documentNo;

  const SwapBindState({
    this.loadingUser = false,
    this.loadingPack = false,
    this.submitting = false,
    this.info,
    this.selectedCar,
    this.selectedBattery,
    this.selectedBatteries = const [],
    this.packs = const [],
    this.selectedPack,
    this.paySource = 2,
    this.submitSuccess = false,
    this.documentNo,
  });

  SwapBindState copyWith({
    bool? loadingUser,
    bool? loadingPack,
    bool? submitting,
    SwapBindInfo? info,
    CarVo? selectedCar,
    BatteryVo? selectedBattery,
    List<BatteryVo>? selectedBatteries,
    List<Pack>? packs,
    Pack? selectedPack,
    int? paySource,
    bool? submitSuccess,
    String? documentNo,
  }) {
    return SwapBindState(
      loadingUser: loadingUser ?? this.loadingUser,
      loadingPack: loadingPack ?? this.loadingPack,
      submitting: submitting ?? this.submitting,
      info: info ?? this.info,
      selectedCar: selectedCar ?? this.selectedCar,
      selectedBattery: selectedBattery ?? this.selectedBattery,
      selectedBatteries: selectedBatteries ?? this.selectedBatteries,
      packs: packs ?? this.packs,
      selectedPack: selectedPack ?? this.selectedPack,
      paySource: paySource ?? this.paySource,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      documentNo: documentNo ?? this.documentNo,
    );
  }
}

final swapBindProvider =
    NotifierProvider<SwapBindNotifier, SwapBindState>(SwapBindNotifier.new);

class SwapBindNotifier extends Notifier<SwapBindState> {
  final ApiService _api = ApiService();

  @override
  SwapBindState build() => const SwapBindState();

  Future<void> queryUser(String cardNum) async {
    if (cardNum.isEmpty) return;
    state = state.copyWith(loadingUser: true);
    final response = await _api.get<SwapBindInfo>(
      ApiPath.queryUserForSwap,
      queryParameters: {'cardNum': cardNum},
      parser: (json) => SwapBindInfo.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingUser: false,
      info: response.result,
      selectedCar: null,
      selectedBatteries: const [],
      packs: const [],
      selectedPack: null,
    );
  }

  void selectCar(CarVo? car) {
    state = state.copyWith(selectedCar: car, selectedPack: null, packs: const []);
  }

  void selectBattery(BatteryVo? battery) {
    state = state.copyWith(
      selectedBattery: battery,
      selectedBatteries: battery != null ? [battery] : const [],
      selectedPack: null,
    );
  }

  void toggleBattery(BatteryVo battery) {
    final list = [...state.selectedBatteries];
    final exists = list.any((item) => item.sn == battery.sn);
    if (exists) {
      list.removeWhere((item) => item.sn == battery.sn);
    } else {
      list.add(battery);
    }
    state = state.copyWith(selectedBatteries: list, selectedPack: null);
  }

  Future<void> queryPackList() async {
    final car = state.selectedCar;
    if (car == null || state.selectedBatteries.isEmpty) return;
    final batteryTypes = state.selectedBatteries
        .map((e) => e.model ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    final carType = car.model;
    final minDay = _minRentDay([car.rentDay, ...state.selectedBatteries.map((e) => e.rentDay)]);
    state = state.copyWith(loadingPack: true);
    final response = await _api.get<List<Pack>>(
      ApiPath.querySwapPackList,
      queryParameters: {
        'batteryType': batteryTypes.join(','),
        'carType': carType,
        if (minDay != null) 'minDay': minDay,
      },
      parser: (json) => (json as List<dynamic>?)
              ?.map((item) => Pack.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <Pack>[],
    );
    state = state.copyWith(
      loadingPack: false,
      packs: response.result ?? const [],
    );
  }

  void selectPack(Pack pack) {
    state = state.copyWith(selectedPack: pack);
  }

  void updatePaySource(int value) {
    state = state.copyWith(paySource: value);
  }

  Future<bool> submit(String cardNum) async {
    final pack = state.selectedPack;
    if (pack == null) return false;
    state = state.copyWith(submitting: true);
    final response = await _api.post<Map<String, dynamic>>(
      ApiPath.createSwapBindOrder,
      data: {
        'infoCode': pack.infoCode ?? '',
        'paySource': state.paySource,
        'cardNum': cardNum,
      },
      parser: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
    if (response.isSuccess) {
      final docNo = response.result?['documentNo'] as String?;
      state = state.copyWith(
        submitting: false,
        submitSuccess: true,
        documentNo: docNo,
      );
      return true;
    }
    state = state.copyWith(submitting: false);
    return false;
  }

  void reset() {
    state = const SwapBindState();
  }

  int? _minRentDay(List<int?> values) {
    final valid = values.whereType<int>().toList();
    if (valid.isEmpty) return null;
    valid.sort();
    return valid.first;
  }
}
