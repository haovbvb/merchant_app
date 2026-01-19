import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class QrCodeListState {
  final bool loading;
  final int? deviceType;
  final List<String> items;

  const QrCodeListState({
    this.loading = false,
    this.deviceType,
    this.items = const [],
  });

  QrCodeListState copyWith({
    bool? loading,
    int? deviceType,
    List<String>? items,
  }) {
    return QrCodeListState(
      loading: loading ?? this.loading,
      deviceType: deviceType ?? this.deviceType,
      items: items ?? this.items,
    );
  }
}

final qrCodeListProvider =
    NotifierProvider<QrCodeListNotifier, QrCodeListState>(
  QrCodeListNotifier.new,
);

class QrCodeListNotifier extends Notifier<QrCodeListState> {
  final ApiService _api = ApiService();

  @override
  QrCodeListState build() => const QrCodeListState();

  void setDeviceType(int? value) {
    state = state.copyWith(deviceType: value);
  }

  Future<String?> resolveDeviceSn(String content) async {
    if (content.trim().isEmpty) return null;
    state = state.copyWith(loading: true);
    final response = await _api.post<String>(
      ApiPath.deviceGetDeviceSn,
      data: {
        if (state.deviceType != null) 'type': state.deviceType,
        'content': content.trim(),
      },
      parser: (json) => json?.toString() ?? '',
      showHud: false,
    );
    state = state.copyWith(loading: false);
    if (!response.isSuccess) return null;
    final sn = response.result?.trim() ?? '';
    if (sn.isEmpty) return null;
    if (!state.items.contains(sn)) {
      state = state.copyWith(items: [...state.items, sn]);
    }
    return sn;
  }

  void removeAt(int index) {
    final updated = [...state.items]..removeAt(index);
    state = state.copyWith(items: updated);
  }
}
