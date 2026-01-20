import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/device_fix.dart';
import 'package:merchant_app/data/models/maintenance.dart';
import 'package:merchant_app/data/models/vehicle_repair_list_resp.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

const _pageSize = 20;

class MaintenanceBookState {
  final bool loading;
  final bool submitting;
  final String sn;
  final String note;
  final BookMaintenanceBean? appointment;

  const MaintenanceBookState({
    this.loading = false,
    this.submitting = false,
    this.sn = '',
    this.note = '',
    this.appointment,
  });

  MaintenanceBookState copyWith({
    bool? loading,
    bool? submitting,
    String? sn,
    String? note,
    BookMaintenanceBean? appointment,
  }) {
    return MaintenanceBookState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      sn: sn ?? this.sn,
      note: note ?? this.note,
      appointment: appointment ?? this.appointment,
    );
  }
}

final maintenanceBookProvider =
    NotifierProvider<MaintenanceBookNotifier, MaintenanceBookState>(
  MaintenanceBookNotifier.new,
);

class MaintenanceBookNotifier extends Notifier<MaintenanceBookState> {
  final ApiService _api = ApiService();

  @override
  MaintenanceBookState build() => const MaintenanceBookState();

  void updateSn(String value) {
    state = state.copyWith(sn: value);
  }

  void updateNote(String value) {
    state = state.copyWith(note: value);
  }

  Future<void> fetchAppointment() async {
    final sn = state.sn.trim();
    if (sn.isEmpty) return;
    state = state.copyWith(loading: true);

    final response = await _api.get<BookMaintenanceBean>(
      ApiPath.maintenanceQueryAppointment,
      queryParameters: {'code': sn},
      parser: (json) => BookMaintenanceBean.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    state = state.copyWith(
      loading: false,
      appointment: response.result,
    );
  }

  Future<bool> submitMaintenance() async {
    final appointmentNo = state.appointment?.reservationNo ?? '';
    if (appointmentNo.trim().isEmpty) return false;
    state = state.copyWith(submitting: true);

    final response = await _api.post<Object>(
      ApiPath.maintenanceAddRecord,
      data: {
        'appointmentNo': appointmentNo,
        'maintenanceNote': state.note.trim(),
      },
      parser: (json) => json ?? Object(),
    );

    state = state.copyWith(submitting: false);
    return response.isSuccess;
  }
}

class RepairRecordState {
  final bool loading;
  final bool loadingMore;
  final int page;
  final String sn;
  final List<VehicleRepair> items;
  final int total;

  const RepairRecordState({
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.sn = '',
    this.items = const [],
    this.total = 0,
  });

  bool get hasMore => items.length < total;

  RepairRecordState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    String? sn,
    List<VehicleRepair>? items,
    int? total,
  }) {
    return RepairRecordState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      sn: sn ?? this.sn,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

class RepairRecordCreateState {
  final bool loading;
  final bool submitting;
  final String sn;
  final String remark;
  final DeviceFix? deviceFix;
  final DeviceFixProject? selectedProject;
  final DeviceFixResult? selectedResult;

  const RepairRecordCreateState({
    this.loading = false,
    this.submitting = false,
    this.sn = '',
    this.remark = '',
    this.deviceFix,
    this.selectedProject,
    this.selectedResult,
  });

  bool get canSubmit {
    return !submitting &&
        sn.trim().isNotEmpty &&
        deviceFix != null &&
        selectedProject != null &&
        selectedResult != null &&
        remark.trim().isNotEmpty;
  }

  static const _unset = Object();

  RepairRecordCreateState copyWith({
    bool? loading,
    bool? submitting,
    String? sn,
    String? remark,
    DeviceFix? deviceFix,
    Object? selectedProject = _unset,
    Object? selectedResult = _unset,
  }) {
    return RepairRecordCreateState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      sn: sn ?? this.sn,
      remark: remark ?? this.remark,
      deviceFix: deviceFix ?? this.deviceFix,
      selectedProject: selectedProject == _unset
          ? this.selectedProject
          : selectedProject as DeviceFixProject?,
      selectedResult: selectedResult == _unset
          ? this.selectedResult
          : selectedResult as DeviceFixResult?,
    );
  }
}

final repairRecordProvider =
    NotifierProvider<RepairRecordNotifier, RepairRecordState>(
  RepairRecordNotifier.new,
);

class RepairRecordNotifier extends Notifier<RepairRecordState> {
  final ApiService _api = ApiService();

  @override
  RepairRecordState build() => const RepairRecordState();

  Future<void> refresh(String sn) async {
    if (sn.trim().isEmpty) return;
    state = state.copyWith(loading: true, page: 1, sn: sn);

    final response = await _api.get<VehicleRepairListResp>(
      ApiPath.maintenanceQueryFixList,
      queryParameters: {
        'sn': sn,
        'pageNum': 1,
        'pageSize': _pageSize,
      },
      parser: (json) => VehicleRepairListResp.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    state = state.copyWith(
      loading: false,
      items: response.result?.list ?? const [],
      total: response.result?.total ?? 0,
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.hasMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(loadingMore: true);

    final response = await _api.get<VehicleRepairListResp>(
      ApiPath.maintenanceQueryFixList,
      queryParameters: {
        'sn': state.sn,
        'pageNum': nextPage,
        'pageSize': _pageSize,
      },
      parser: (json) => VehicleRepairListResp.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    state = state.copyWith(
      loadingMore: false,
      page: nextPage,
      items: [...state.items, ...?response.result?.list],
      total: response.result?.total ?? state.total,
    );
  }
}

final repairRecordCreateProvider =
    NotifierProvider<RepairRecordCreateNotifier, RepairRecordCreateState>(
  RepairRecordCreateNotifier.new,
);

class RepairRecordCreateNotifier extends Notifier<RepairRecordCreateState> {
  final ApiService _api = ApiService();

  @override
  RepairRecordCreateState build() => const RepairRecordCreateState();

  void updateSn(String value) {
    state = state.copyWith(sn: value);
  }

  void updateRemark(String value) {
    state = state.copyWith(remark: value);
  }

  void selectProject(DeviceFixProject? project) {
    state = state.copyWith(selectedProject: project);
  }

  void selectResult(DeviceFixResult? result) {
    state = state.copyWith(selectedResult: result);
  }

  Future<void> fetchDeviceInfo() async {
    final sn = state.sn.trim();
    if (sn.isEmpty) return;
    state = state.copyWith(
      loading: true,
      selectedProject: null,
      selectedResult: null,
      remark: '',
    );

    final response = await _api.get<DeviceFix>(
      ApiPath.repairRecordQueryDeviceForFix,
      queryParameters: {'sn': sn},
      parser: (json) => DeviceFix.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    state = state.copyWith(
      loading: false,
      deviceFix: response.result,
    );
  }

  Future<bool> submitFixRecord() async {
    if (!state.canSubmit) return false;
    final fix = state.deviceFix;
    if (fix == null) return false;
    final cardNum = fix.carVo?.cardNum ?? fix.batteryVo?.cardNum ?? '';
    state = state.copyWith(submitting: true);

    final response = await _api.post<Object>(
      ApiPath.repairRecordAddFixRecord,
      data: {
        'cardNum': cardNum,
        'deviceSn': state.sn.trim(),
        'deviceType': fix.deviceType,
        'fixItem': state.selectedProject?.itemNo ?? '',
        'remark': state.remark.trim(),
        'fixResult': state.selectedResult?.code ?? '',
      },
      parser: (json) => json ?? Object(),
    );

    state = state.copyWith(submitting: false);
    return response.isSuccess;
  }
}
