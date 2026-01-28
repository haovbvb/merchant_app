import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/area_country.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class OfflineRegisterState {
  final bool loading;
  final bool sending;
  final bool registering;
  final int countdown;
  final List<AreaCountry> areas;
  final AreaCountry? selectedArea;

  const OfflineRegisterState({
    this.loading = false,
    this.sending = false,
    this.registering = false,
    this.countdown = 0,
    this.areas = const [],
    this.selectedArea,
  });

  OfflineRegisterState copyWith({
    bool? loading,
    bool? sending,
    bool? registering,
    int? countdown,
    List<AreaCountry>? areas,
    AreaCountry? selectedArea,
  }) {
    return OfflineRegisterState(
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      registering: registering ?? this.registering,
      countdown: countdown ?? this.countdown,
      areas: areas ?? this.areas,
      selectedArea: selectedArea ?? this.selectedArea,
    );
  }
}

final offlineRegisterProvider =
    NotifierProvider<OfflineRegisterNotifier, OfflineRegisterState>(
  OfflineRegisterNotifier.new,
);

class OfflineRegisterNotifier extends Notifier<OfflineRegisterState> {
  final ApiService _api = ApiService();
  Timer? _countdownTimer;

  @override
  OfflineRegisterState build() => const OfflineRegisterState();

  void _startCountdown() {
    _countdownTimer?.cancel();
    state = state.copyWith(countdown: 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown <= 1) {
        timer.cancel();
        state = state.copyWith(countdown: 0);
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  Future<void> loadAreas() async {
    if (state.loading) return;
    state = state.copyWith(loading: true);
    final response = await _api.get<AreaCountryResp>(
      ApiPath.areaCodeConfig,
      parser: (json) => AreaCountryResp.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    final list = response.result?.list ?? const <AreaCountry>[];
    state = state.copyWith(
      loading: false,
      areas: list,
      selectedArea: list.isNotEmpty ? list.first : null,
    );
  }

  void selectArea(AreaCountry? area) {
    if (area == null) return;
    state = state.copyWith(selectedArea: area);
  }

  Future<bool> sendSms(String phone) async {
    if (state.sending || state.countdown > 0) return false;
    state = state.copyWith(sending: true);
    final response = await _api.post<Object>(
      ApiPath.sendSms,
      data: {
        'phone': phone,
        'type': 1,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(sending: false);
    if (response.isSuccess) {
      _startCountdown();
    }
    return response.isSuccess;
  }

  Future<bool> register({
    required String phone,
    required String smsCode,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    String? birthday,
    String? email,
    String? referId,
  }) async {
    if (state.registering) return false;
    state = state.copyWith(registering: true);

    final form = FormData.fromMap({
      'phone': phone,
      'smsCode': smsCode,
      'password': _md5(password),
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      if (birthday != null && birthday.isNotEmpty) 'birthDay': birthday,
      if (email != null && email.isNotEmpty) 'email': email,
      if (referId != null && referId.isNotEmpty) 'referId': referId,
    });

    final response = await _api.postForm<Object>(
      ApiPath.offlineRegister,
      data: form,
      parser: (json) => json ?? Object(),
    );

    state = state.copyWith(registering: false);
    return response.isSuccess;
  }

  String _md5(String input) {
    final bytes = input.codeUnits;
    return md5.convert(bytes).toString();
  }
}
