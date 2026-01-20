import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/vcu_version.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class VcuState {
  final bool loading;
  final bool sending;
  final List<VcuVersion> versions;

  const VcuState({
    this.loading = false,
    this.sending = false,
    this.versions = const [],
  });

  VcuState copyWith({
    bool? loading,
    bool? sending,
    List<VcuVersion>? versions,
  }) {
    return VcuState(
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      versions: versions ?? this.versions,
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
    if (vin.isEmpty || command.isEmpty) return false;
    state = state.copyWith(sending: true);
    final response = await _api.post<Object>(
      ApiPath.vcuSendCommand,
      data: {
        'vin': vin,
        'command': command,
        if (version != null && version.isNotEmpty) 'version': version,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(sending: false);
    return response.isSuccess;
  }
}
