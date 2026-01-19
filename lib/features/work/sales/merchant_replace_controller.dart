import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class MerchantReplaceState {
  final bool submitting;

  const MerchantReplaceState({this.submitting = false});

  MerchantReplaceState copyWith({bool? submitting}) {
    return MerchantReplaceState(submitting: submitting ?? this.submitting);
  }
}

final merchantReplaceProvider =
    NotifierProvider<MerchantReplaceNotifier, MerchantReplaceState>(
  MerchantReplaceNotifier.new,
);

class MerchantReplaceNotifier extends Notifier<MerchantReplaceState> {
  final ApiService _api = ApiService();

  @override
  MerchantReplaceState build() => const MerchantReplaceState();

  Future<bool> submit({
    required String cardNum,
    required String oldSn,
    required String newSn,
    required String reason,
  }) async {
    if (cardNum.isEmpty || oldSn.isEmpty || newSn.isEmpty || reason.isEmpty) {
      return false;
    }
    state = state.copyWith(submitting: true);
    final response = await _api.post<Object>(
      ApiPath.manualReplace,
      data: {
        'cardNum': cardNum,
        'outSn': oldSn,
        'inSn': newSn,
        'reason': reason,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(submitting: false);
    return response.isSuccess;
  }
}
