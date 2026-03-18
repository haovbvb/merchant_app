import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  // Maintenance cost dialog fields
  final String amount;
  final int paySource; // 1=Cash, 2=Online
  final List<String> voucherImages;

  const MaintenanceBookState({
    this.loading = false,
    this.submitting = false,
    this.sn = '',
    this.note = '',
    this.appointment,
    this.amount = '',
    this.paySource = 2, // default Online
    this.voucherImages = const [],
  });

  bool get canConfirmCost {
    // Cash requires amount, voucher images optional
    // Online requires just amount
    final hasAmount = amount.trim().isNotEmpty;
    if (paySource == 1) {
      // Cash
      return hasAmount;
    }
    return hasAmount;
  }

  MaintenanceBookState copyWith({
    bool? loading,
    bool? submitting,
    String? sn,
    String? note,
    BookMaintenanceBean? appointment,
    bool clearAppointment = false,
    String? amount,
    int? paySource,
    List<String>? voucherImages,
  }) {
    return MaintenanceBookState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      sn: sn ?? this.sn,
      note: note ?? this.note,
      appointment: clearAppointment ? null : (appointment ?? this.appointment),
      amount: amount ?? this.amount,
      paySource: paySource ?? this.paySource,
      voucherImages: voucherImages ?? this.voucherImages,
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

  void updateAmount(String value) {
    state = state.copyWith(amount: value);
  }

  void updatePaySource(int value) {
    state = state.copyWith(paySource: value);
  }

  void addVoucherImage(String url) {
    if (state.voucherImages.length >= 5) return;
    state = state.copyWith(voucherImages: [...state.voucherImages, url]);
  }

  void removeVoucherImage(int index) {
    final list = List<String>.from(state.voucherImages);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      state = state.copyWith(voucherImages: list);
    }
  }

  void replaceVoucherImages(List<String> urls) {
    state = state.copyWith(voucherImages: List<String>.from(urls));
  }

  void clearCostDialog() {
    state = state.copyWith(amount: '', paySource: 2, voucherImages: []);
  }

  void clearAll() {
    state = state.copyWith(
      clearAppointment: true,
      sn: '',
      note: '',
      amount: '',
      paySource: 2,
      voucherImages: [],
    );
  }

  Future<void> fetchAppointment() async {
    final sn = state.sn.trim();
    if (sn.isEmpty) return;
    state = state.copyWith(loading: true);

    final response = await _api.get<BookMaintenanceBean>(
      ApiPath.maintenanceQueryAppointment,
      queryParameters: {'code': sn},
      parser: (json) =>
          BookMaintenanceBean.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    state = state.copyWith(
      loading: false,
      clearAppointment: response.result == null,
      appointment: response.result,
      note: '',
      amount: '',
      paySource: 2,
      voucherImages: [],
    );
  }

  Future<bool> submitMaintenance() async {
    final appointment = state.appointment;
    if (appointment == null) return false;
    final cardNum = appointment.cardNum ?? '';
    final vehicleSn = appointment.sn ?? '';
    if (cardNum.isEmpty || vehicleSn.isEmpty) return false;
    state = state.copyWith(submitting: true);
    try {
      final attachment = state.voucherImages.join(',');
      final response = await _api.post<Object>(
        ApiPath.maintenanceGenRecord,
        data: {
          'cardNum': cardNum,
          'vehicleSn': vehicleSn,
          'attachment': attachment,
          'remark': state.note.trim(),
          'paySource': state.paySource,
          'price': state.amount.trim().isEmpty ? '0' : state.amount.trim(),
        },
        parser: (json) => json ?? Object(),
      );
      return response.isSuccess;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(submitting: false);
    }
  }

  Future<String?> uploadVoucher(String filePath) async {
    final data = await _compressImage(filePath);
    if (data == null || data.isEmpty) return null;
    final fileName = _buildFileName(filePath);
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(data, filename: fileName),
    });
    try {
      final response = await _api.postForm<String>(
        ApiPath.tradeUploadAttachment,
        data: formData,
        parser: (json) => json?.toString() ?? '',
      );
      if (response.isSuccess && response.result != null) {
        return response.result;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<Uint8List?> _compressImage(String path) async {
    return FlutterImageCompress.compressWithFile(
      path,
      quality: 80,
      minWidth: 612,
      minHeight: 816,
      format: CompressFormat.jpeg,
    );
  }

  String _buildFileName(String path) {
    final segments = path.split('/');
    final last = segments.isEmpty ? '' : segments.last;
    final extIndex = last.lastIndexOf('.');
    final ext = extIndex == -1 ? 'jpg' : last.substring(extIndex + 1);
    return '${DateTime.now().millisecondsSinceEpoch}.$ext';
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
    Object? deviceFix = _unset,
    Object? selectedProject = _unset,
    Object? selectedResult = _unset,
  }) {
    return RepairRecordCreateState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      sn: sn ?? this.sn,
      remark: remark ?? this.remark,
      deviceFix: deviceFix == _unset ? this.deviceFix : deviceFix as DeviceFix?,
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
      queryParameters: {'sn': sn, 'pageNum': 1, 'pageSize': _pageSize},
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
  static const int _remarkMaxLength = 500;

  @override
  RepairRecordCreateState build() => const RepairRecordCreateState();

  void updateSn(String value) {
    state = state.copyWith(sn: value);
  }

  void resetForNewSnInput(String value) {
    state = state.copyWith(
      sn: value,
      deviceFix: null,
      selectedProject: null,
      selectedResult: null,
      remark: '',
    );
  }

  void updateRemark(String value) {
    final limited = value.length > _remarkMaxLength
        ? value.substring(0, _remarkMaxLength)
        : value;
    state = state.copyWith(remark: limited);
  }

  void selectProject(DeviceFixProject? project) {
    state = state.copyWith(selectedProject: project);
  }

  void selectResult(DeviceFixResult? result) {
    state = state.copyWith(selectedResult: result);
  }

  void resetForm() {
    state = const RepairRecordCreateState();
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
      parser: (json) =>
          DeviceFix.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    state = state.copyWith(loading: false, deviceFix: response.result);
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

  /// 上传维修图片 - 对应 Android 的 uploadFixImg
  Future<String?> uploadFixImage(String filePath) async {
    final data = await _compressImage(filePath);
    if (data == null || data.isEmpty) return null;
    final fileName = _buildFileName(filePath);
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(data, filename: fileName),
    });
    final response = await _api.postForm<String>(
      ApiPath.repairRecordUploadImg,
      data: formData,
      parser: (json) => json?.toString() ?? '',
    );
    if (response.isSuccess && response.result != null) {
      return response.result;
    }
    return null;
  }

  Future<Uint8List?> _compressImage(String path) async {
    return FlutterImageCompress.compressWithFile(
      path,
      quality: 80,
      minWidth: 612,
      minHeight: 816,
      format: CompressFormat.jpeg,
    );
  }

  String _buildFileName(String path) {
    final segments = path.split('/');
    final last = segments.isEmpty ? '' : segments.last;
    final extIndex = last.lastIndexOf('.');
    final ext = extIndex == -1 ? 'jpg' : last.substring(extIndex + 1);
    return '${DateTime.now().millisecondsSinceEpoch}.$ext';
  }
}
