import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/payment_order.dart';
import 'package:merchant_app/data/models/purchasing_user.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 保险申请状态
class InsuranceApplyState {
  final bool loading;
  final bool submitting;
  final PurchasingUser? user;
  final dynamic device;
  final Insurance? plan;

  const InsuranceApplyState({
    this.loading = false,
    this.submitting = false,
    this.user,
    this.device,
    this.plan,
  });

  InsuranceApplyState copyWith({
    bool? loading,
    bool? submitting,
    PurchasingUser? user,
    dynamic device,
    Insurance? plan,
  }) {
    return InsuranceApplyState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      user: user ?? this.user,
      device: device ?? this.device,
      plan: plan ?? this.plan,
    );
  }
}

final insuranceApplyProvider =
    NotifierProvider<InsuranceApplyNotifier, InsuranceApplyState>(
      InsuranceApplyNotifier.new,
    );

class InsuranceApplyNotifier extends Notifier<InsuranceApplyState> {
  final ApiService _api = ApiService();

  @override
  InsuranceApplyState build() => const InsuranceApplyState();

  /// 查询用户信息
  Future<bool> queryUser(String cardNum) async {
    if (cardNum.isEmpty) return false;
    state = state.copyWith(loading: true);
    final response = await _api.get<PurchasingUser>(
      ApiPath.insuranceQueryUser,
      queryParameters: {'cardNum': cardNum},
      parser: (json) =>
          PurchasingUser.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, user: response.result);
    return response.isSuccess && response.result != null;
  }

  /// 查询设备信息
  Future<bool> queryDevice(String sn) async {
    if (sn.isEmpty) return false;
    state = state.copyWith(loading: true);
    final response = await _api.get<Map<String, dynamic>>(
      ApiPath.insuranceQueryDevice,
      queryParameters: {'sn': sn},
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );
    state = state.copyWith(loading: false, device: response.result);
    return response.isSuccess && response.result != null;
  }

  /// 查询保险计划
  Future<bool> queryPlan({
    required String cardNum,
    required String sn,
    required int type,
  }) async {
    if (cardNum.isEmpty || sn.isEmpty) return false;
    state = state.copyWith(loading: true);
    final response = await _api.get<Insurance>(
      ApiPath.insuranceQueryPlan,
      queryParameters: {'cardNum': cardNum, 'sn': sn, 'type': type},
      parser: (json) =>
          Insurance.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, plan: response.result);
    return response.isSuccess && response.result != null;
  }

  /// 申请保险
  Future<bool> apply({
    required String cardNum,
    required String sn,
    required int type,
    String? remark,
  }) async {
    if (cardNum.isEmpty || sn.isEmpty) return false;
    state = state.copyWith(submitting: true);
    final data = <String, dynamic>{'cardNum': cardNum, 'sn': sn, 'type': type};
    if (remark != null && remark.isNotEmpty) {
      data['remark'] = remark;
    }
    final response = await _api.post<Object>(
      ApiPath.insuranceApply,
      data: data,
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(submitting: false);
    return response.isSuccess;
  }

  /// 清除
  void clear() {
    state = const InsuranceApplyState();
  }
}
