import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/new_cabinet_bean.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class CabinetPutawayState {
  final bool loadingCabinet;
  final bool uploading;
  final bool submitting;
  final NewCabinetBean? cabinet;
  final List<String> images;

  const CabinetPutawayState({
    this.loadingCabinet = false,
    this.uploading = false,
    this.submitting = false,
    this.cabinet,
    this.images = const [],
  });

  CabinetPutawayState copyWith({
    bool? loadingCabinet,
    bool? uploading,
    bool? submitting,
    NewCabinetBean? cabinet,
    List<String>? images,
  }) {
    return CabinetPutawayState(
      loadingCabinet: loadingCabinet ?? this.loadingCabinet,
      uploading: uploading ?? this.uploading,
      submitting: submitting ?? this.submitting,
      cabinet: cabinet ?? this.cabinet,
      images: images ?? this.images,
    );
  }
}

final cabinetPutawayProvider =
    NotifierProvider<CabinetPutawayNotifier, CabinetPutawayState>(
  CabinetPutawayNotifier.new,
);

class CabinetPutawayNotifier extends Notifier<CabinetPutawayState> {
  final ApiService _api = ApiService();

  @override
  CabinetPutawayState build() => const CabinetPutawayState();

  Future<void> queryCabinet(String code) async {
    if (code.isEmpty) return;
    state = state.copyWith(loadingCabinet: true);
    final response = await _api.get<NewCabinetBean>(
      '${ApiPath.stationGetTypeBySource}/1/$code',
      parser: (json) => NewCabinetBean.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingCabinet: false,
      cabinet: response.result,
    );
  }

  Future<String?> uploadImage(String path) async {
    state = state.copyWith(uploading: true);
    final data = await _compressImage(path);
    if (data == null || data.isEmpty) {
      state = state.copyWith(uploading: false);
      return null;
    }
    final fileName = _buildFileName(path);
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(data, filename: fileName),
    });
    final response = await _api.postForm<String>(
      ApiPath.stationUploadImage,
      data: form,
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(uploading: false);
    if (response.isSuccess && (response.result?.isNotEmpty ?? false)) {
      return response.result;
    }
    return null;
  }

  void addImage(String url) {
    final updated = List<String>.from(state.images)..add(url);
    state = state.copyWith(images: updated);
  }

  void removeImage(String url) {
    final updated = List<String>.from(state.images)..remove(url);
    state = state.copyWith(images: updated);
  }

  Future<bool> submit({
    required String sn,
    required double latitude,
    required double longitude,
    required int swapTime,
    required int storeNum,
    required String address,
  }) async {
    final cabinet = state.cabinet;
    if (cabinet == null || sn.isEmpty || address.isEmpty) return false;
    if (state.images.isEmpty) return false;
    state = state.copyWith(submitting: true);
    final response = await _api.post<Object>(
      ApiPath.stationInstall,
      data: {
        'pid': cabinet.pid ?? '',
        'sn': sn,
        'latitude': latitude,
        'longitude': longitude,
        'name': cabinet.stationName ?? '',
        'model': cabinet.stationModel ?? '',
        'label': 0,
        'imgList': state.images.join(','),
        'standardSwapTime': swapTime,
        'storeNum': storeNum,
        'address': address,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(submitting: false);
    return response.isSuccess;
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
