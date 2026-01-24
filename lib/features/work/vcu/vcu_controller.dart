import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/vcu_device_search.dart';
import 'package:merchant_app/data/models/vcu_history.dart';
import 'package:merchant_app/data/models/vcu_version.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class VcuState {
  final bool loading;
  final bool searching;
  final bool sending;
  final List<VcuVersion> versions;
  final List<VcuHistoryItem> history;
  final VcuHistoryFilter historyFilter;
  final VcuDeviceSearchResult? searchResult;

  const VcuState({
    this.loading = false,
    this.searching = false,
    this.sending = false,
    this.versions = const [],
    this.history = const [],
    this.historyFilter = VcuHistoryFilter.all,
    this.searchResult,
  });

  VcuState copyWith({
    bool? loading,
    bool? searching,
    bool? sending,
    List<VcuVersion>? versions,
    List<VcuHistoryItem>? history,
    VcuHistoryFilter? historyFilter,
    VcuDeviceSearchResult? searchResult,
  }) {
    return VcuState(
      loading: loading ?? this.loading,
      searching: searching ?? this.searching,
      sending: sending ?? this.sending,
      versions: versions ?? this.versions,
      history: history ?? this.history,
      historyFilter: historyFilter ?? this.historyFilter,
      searchResult: searchResult ?? this.searchResult,
    );
  }
}

final vcuProvider = NotifierProvider<VcuNotifier, VcuState>(VcuNotifier.new);

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

  Future<VcuDeviceSearchResult?> searchDeviceBySn(String sn) async {
    final value = sn.trim();
    if (value.isEmpty) return null;
    state = state.copyWith(searching: true);
    final response = await _api.get<VcuDeviceSearchResult?>(
      ApiPath.deviceCommonSearch,
      queryParameters: {'deviceSn': value},
      parser: (json) => json == null
          ? null
          : VcuDeviceSearchResult.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
    );
    state = state.copyWith(searching: false, searchResult: response.result);
    return response.result;
  }

  Future<bool> sendCommand({
    required String devId,
    required int cmd,
    String? label,
    String? deviceSn,
  }) async {
    final trimmedDevId = devId.trim();
    if (trimmedDevId.isEmpty) return false;
    final commandLabel = label?.trim().isNotEmpty == true
        ? label!.trim()
        : 'CMD $cmd';
    final displayId = (deviceSn ?? '').trim().isNotEmpty
        ? deviceSn!.trim()
        : trimmedDevId;
    _appendHistory(
      VcuHistoryItem(
        vin: displayId,
        command: commandLabel,
        type: VcuHistoryType.request,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    state = state.copyWith(sending: true);
    final response = await _api.post<Object>(
      ApiPath.vcuSendCommand,
      data: {'cmd': cmd, 'devId': trimmedDevId},
      parser: (json) => json ?? Object(),
    );
    _appendHistory(
      VcuHistoryItem(
        vin: displayId,
        command: commandLabel,
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

  void addHistory(VcuHistoryItem item) {
    _appendHistory(item);
  }

  void _appendHistory(VcuHistoryItem item) {
    final updated = [item, ...state.history];
    state = state.copyWith(history: updated);
  }
}
