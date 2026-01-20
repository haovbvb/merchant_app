import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';

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
  @override
  QrCodeListState build() => const QrCodeListState();

  void reset() {
    state = const QrCodeListState();
  }

  void setDeviceType(int? value) {
    state = state.copyWith(deviceType: value);
  }

  void setInitialItems(List<String> items) {
    if (items.isEmpty) return;
    final merged = <String>{...state.items, ...items}.toList();
    state = state.copyWith(items: merged);
  }

  void addItem(String sn) {
    if (sn.trim().isEmpty || state.items.contains(sn)) return;
    state = state.copyWith(items: [...state.items, sn]);
  }

  Future<String?> resolveDeviceSn(String content) async {
    if (content.trim().isEmpty) return null;
    state = state.copyWith(loading: true);
    final sn = ScanUtils.parseSnByDeviceType(
      content.trim(),
      state.deviceType,
    ).trim();
    state = state.copyWith(loading: false);
    if (sn.isEmpty) return null;
    return sn;
  }

  void removeAt(int index) {
    final updated = [...state.items]..removeAt(index);
    state = state.copyWith(items: updated);
  }
}
