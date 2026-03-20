import 'dart:convert';

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

class VcuSendResult {
  final bool success;
  final String message;

  const VcuSendResult({required this.success, this.message = ''});
}

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

  Future<VcuSendResult> sendCommand({
    required int cmd,
    String? label,
    String? deviceSn,
  }) async {
    final ctrlId = state.searchResult?.deviceInfo?.ctrlId?.trim() ?? '';
    if (ctrlId.isEmpty) {
      return const VcuSendResult(success: false);
    }
    final commandLabel = label?.trim().isNotEmpty == true
        ? label!.trim()
        : 'CMD $cmd';
    final displayId = (deviceSn ?? '').trim().isNotEmpty
        ? deviceSn!.trim()
        : ctrlId;
    _appendHistory(
      VcuHistoryItem(
        vin: displayId,
        command: commandLabel,
        data: jsonEncode({'cmd': cmd, 'devId': ctrlId}),
        type: VcuHistoryType.request,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    state = state.copyWith(sending: true);
    try {
      final response = await _api.post<Object>(
        ApiPath.vcuSendCommand,
        data: {'cmd': cmd, 'devId': ctrlId},
        parser: (json) => json ?? Object(),
        notifyOnError: false,
        toastOnBusinessError: false,
      );
      final success = response.isSuccess;
      final responseData = success
          ? 'success'
          : (response.message.isNotEmpty ? response.message : 'failed');
      _appendHistory(
        VcuHistoryItem(
          vin: displayId,
          command: commandLabel,
          data: responseData,
          type: VcuHistoryType.response,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          success: success,
        ),
      );
      return VcuSendResult(success: success, message: response.message);
    } catch (error) {
      final message = error.toString().trim();
      _appendHistory(
        VcuHistoryItem(
          vin: displayId,
          command: commandLabel,
          data: message.isNotEmpty ? message : 'failed',
          type: VcuHistoryType.response,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          success: false,
        ),
      );
      return VcuSendResult(success: false, message: message);
    } finally {
      state = state.copyWith(sending: false);
    }
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
