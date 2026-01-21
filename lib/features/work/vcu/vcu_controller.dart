import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/vcu_history.dart';
import 'package:merchant_app/data/models/vcu_version.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class VcuState {
  final bool loading;
  final bool sending;
  final List<VcuVersion> versions;
  final List<VcuHistoryItem> history;
  final VcuHistoryFilter historyFilter;

  const VcuState({
    this.loading = false,
    this.sending = false,
    this.versions = const [],
    this.history = const [],
    this.historyFilter = VcuHistoryFilter.all,
  });

  VcuState copyWith({
    bool? loading,
    bool? sending,
    List<VcuVersion>? versions,
    List<VcuHistoryItem>? history,
    VcuHistoryFilter? historyFilter,
  }) {
    return VcuState(
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      versions: versions ?? this.versions,
      history: history ?? this.history,
      historyFilter: historyFilter ?? this.historyFilter,
    );
  }
}

final vcuProvider = NotifierProvider<VcuNotifier, VcuState>(
  VcuNotifier.new,
);

class VcuNotifier extends Notifier<VcuState> {
  final ApiService _api = ApiService();

  @override
  VcuState build() => const VcuState();

  Future<void> loadVersions() async {
    state = state.copyWith(loading: true);
    final response = await _api.get<List<VcuVersion>>(
      ApiPath.vcuVersionList,
      parser: (json) => (json as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(VcuVersion.fromJson)
          .toList(),
    );
    state = state.copyWith(loading: false, versions: response.result ?? []);
  }

  Future<bool> sendCommand({
    required String vin,
    required String command,
    String? version,
  }) async {
    final trimmedVin = vin.trim();
    final trimmedCommand = command.trim();
    if (trimmedVin.isEmpty || trimmedCommand.isEmpty) return false;
    _appendHistory(
      VcuHistoryItem(
        vin: trimmedVin,
        command: trimmedCommand,
        version: version,
        type: VcuHistoryType.request,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    state = state.copyWith(sending: true);
    final response = await _api.post<Object>(
      ApiPath.vcuSendCommand,
      data: {
        'vin': trimmedVin,
        'command': trimmedCommand,
        if (version != null && version.isNotEmpty) 'version': version,
      },
      parser: (json) => json ?? Object(),
    );
    _appendHistory(
      VcuHistoryItem(
        vin: trimmedVin,
        command: trimmedCommand,
        version: version,
        type: VcuHistoryType.response,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        success: response.isSuccess,
      ),
    );
    state = state.copyWith(sending: false);
    return response.isSuccess;
  }

  void setHistoryFilter(VcuHistoryFilter filter) {
    if (state.historyFilter == filter) return;
    state = state.copyWith(historyFilter: filter);
  }

  void _appendHistory(VcuHistoryItem item) {
    final updated = [item, ...state.history];
    state = state.copyWith(history: updated);
  }
}
