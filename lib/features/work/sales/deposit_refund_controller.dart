import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/deposit_refund_info_bean.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class DepositRefundState {
  final bool loading;
  final bool submitting;
  final bool submitSuccess;
  final DepositRefundInfoBean? info;
  final Deposit? selectedDeposit;
  final bool voucherConfirmed;

  const DepositRefundState({
    this.loading = false,
    this.submitting = false,
    this.submitSuccess = false,
    this.info,
    this.selectedDeposit,
    this.voucherConfirmed = true,
  });

  DepositRefundState copyWith({
    bool? loading,
    bool? submitting,
    bool? submitSuccess,
    DepositRefundInfoBean? info,
    Deposit? selectedDeposit,
    bool? voucherConfirmed,
  }) {
    return DepositRefundState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      info: info ?? this.info,
      selectedDeposit: selectedDeposit ?? this.selectedDeposit,
      voucherConfirmed: voucherConfirmed ?? this.voucherConfirmed,
    );
  }
}

final depositRefundProvider =
    NotifierProvider<DepositRefundNotifier, DepositRefundState>(
  DepositRefundNotifier.new,
);

class DepositRefundNotifier extends Notifier<DepositRefundState> {
  final ApiService _api = ApiService();

  @override
  DepositRefundState build() => const DepositRefundState();

  Future<void> queryUser(String cardNum) async {
    if (cardNum.isEmpty) return;
    state = state.copyWith(loading: true, selectedDeposit: null);
    final response = await _api.get<DepositRefundInfoBean>(
      ApiPath.queryUserForRefundDeposit,
      queryParameters: {'cardNum': cardNum},
      parser: (json) => DepositRefundInfoBean.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(loading: false, info: response.result);
  }

  void selectDeposit(Deposit? deposit) {
    state = state.copyWith(selectedDeposit: deposit);
  }

  void setVoucherConfirmed(bool value) {
    state = state.copyWith(voucherConfirmed: value);
  }

  Future<bool> submit({
    required String cardNum,
    required String remark,
  }) async {
    final selected = state.selectedDeposit;
    if (selected?.orderNo == null || selected!.orderNo!.isEmpty) {
      return false;
    }
    state = state.copyWith(submitting: true);
    final response = await _api.post<Object>(
      ApiPath.refundDeposit,
      data: {
        'cardNum': cardNum,
        'orderNo': selected.orderNo,
        if (remark.trim().isNotEmpty) 'remark': remark.trim(),
        'recoveryFlag': state.voucherConfirmed ? 1 : 0,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(submitting: false);
    if (response.isSuccess) {
      state = state.copyWith(submitSuccess: true);
    }
    return response.isSuccess;
  }

  void reset() {
    state = const DepositRefundState();
  }
}
