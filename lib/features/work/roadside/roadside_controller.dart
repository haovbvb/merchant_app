import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/roadside_list.dart';
import 'package:merchant_app/data/models/roadside_order_detail.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

const _pageSize = 20;

class RoadSideListState {
  final bool loading;
  final bool loadingMore;
  final int page;
  final int? status;
  final List<RoadSideInfo> items;
  final int total;

  const RoadSideListState({
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.status,
    this.items = const [],
    this.total = 0,
  });

  bool get hasMore => items.length < total;

  static const _unset = Object();

  RoadSideListState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    Object? status = _unset,
    List<RoadSideInfo>? items,
    int? total,
  }) {
    return RoadSideListState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      status: status == _unset ? this.status : status as int?,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

final roadSideListProvider =
    NotifierProvider<RoadSideListNotifier, RoadSideListState>(
      RoadSideListNotifier.new,
    );

class RoadSideListNotifier extends Notifier<RoadSideListState> {
  final ApiService _api = ApiService();
  int _refreshRequestId = 0;

  @override
  RoadSideListState build() => const RoadSideListState();

  Future<void> refresh({int? status, bool showHud = true}) async {
    final targetStatus = status;
    final requestId = ++_refreshRequestId;
    state = state.copyWith(loading: true, page: 1, status: targetStatus);
    try {
      final response = await _api.get<RoadSideListResp>(
        ApiPath.roadSaveQueryPage,
        queryParameters: {
          if (targetStatus != null) 'status': targetStatus,
          'pageNum': 1,
          'pageSize': _pageSize,
        },
        showHud: showHud,
        parser: (json) =>
            RoadSideListResp.fromJson(Map<String, dynamic>.from(json as Map)),
      );
      if (requestId != _refreshRequestId) {
        return;
      }
      final result = response.result;
      state = state.copyWith(
        loading: false,
        items: result?.list ?? const [],
        total: result?.total ?? 0,
      );
    } catch (_) {
      if (requestId != _refreshRequestId) {
        return;
      }
      state = state.copyWith(loading: false, items: const [], total: 0);
    }
  }

  Future<void> loadMore({int? status}) async {
    if (state.loadingMore || state.loading || !state.hasMore) return;
    final targetStatus = status ?? state.status;
    final nextPage = state.page + 1;
    state = state.copyWith(loadingMore: true);
    try {
      final response = await _api.get<RoadSideListResp>(
        ApiPath.roadSaveQueryPage,
        queryParameters: {
          if (targetStatus != null) 'status': targetStatus,
          'pageNum': nextPage,
          'pageSize': _pageSize,
        },
        parser: (json) =>
            RoadSideListResp.fromJson(Map<String, dynamic>.from(json as Map)),
      );
      final result = response.result;
      state = state.copyWith(
        loadingMore: false,
        status: targetStatus,
        page: nextPage,
        items: [...state.items, ...?result?.list],
        total: result?.total ?? state.total,
      );
    } catch (_) {
      state = state.copyWith(loadingMore: false);
    }
  }
}

class RoadSideDetailState {
  final bool loading;
  final RoadSideOrderDetail? detail;

  const RoadSideDetailState({this.loading = false, this.detail});

  RoadSideDetailState copyWith({bool? loading, RoadSideOrderDetail? detail}) {
    return RoadSideDetailState(
      loading: loading ?? this.loading,
      detail: detail ?? this.detail,
    );
  }
}

final roadSideDetailProvider =
    NotifierProvider<RoadSideDetailNotifier, RoadSideDetailState>(
      RoadSideDetailNotifier.new,
    );

class RoadSideDetailNotifier extends Notifier<RoadSideDetailState> {
  final ApiService _api = ApiService();

  @override
  RoadSideDetailState build() => const RoadSideDetailState();

  Future<void> loadDetail(String recordNo) async {
    if (recordNo.trim().isEmpty) return;
    state = state.copyWith(loading: true);
    final response = await _api.get<RoadSideOrderDetail>(
      ApiPath.roadSaveQueryInfo,
      queryParameters: {'recordNo': recordNo.trim()},
      parser: (json) =>
          RoadSideOrderDetail.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, detail: response.result);
  }

  Future<bool> payRoadSide({
    required String recordNo,
    required String fee,
    required int payType,
    required String attachment,
  }) async {
    try {
      final response = await _api.post<Object>(
        ApiPath.roadSavePay,
        data: {
          'recordNo': recordNo,
          'fee': fee,
          'payType': payType,
          'attachment': attachment,
        },
        parser: (json) => json ?? Object(),
      );
      return response.isSuccess;
    } catch (_) {
      return false;
    }
  }
}

class RoadSideDealState {
  final bool submitting;
  final List<String> imageUrls;

  const RoadSideDealState({this.submitting = false, this.imageUrls = const []});

  RoadSideDealState copyWith({bool? submitting, List<String>? imageUrls}) {
    return RoadSideDealState(
      submitting: submitting ?? this.submitting,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

final roadSideDealProvider =
    NotifierProvider<RoadSideDealNotifier, RoadSideDealState>(
      RoadSideDealNotifier.new,
    );

class RoadSideDealNotifier extends Notifier<RoadSideDealState> {
  final ApiService _api = ApiService();

  @override
  RoadSideDealState build() => const RoadSideDealState();

  void clearImages() {
    state = state.copyWith(imageUrls: []);
  }

  Future<String?> uploadImage(String path) async {
    final data = await _compressImage(path);
    if (data == null || data.isEmpty) return null;
    final fileName = _buildFileName(path);
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(data, filename: fileName),
    });
    try {
      final response = await _api.postForm<String>(
        ApiPath.roadSaveUploadImg,
        data: formData,
        parser: (json) => json?.toString() ?? '',
      );
      final url = response.result ?? '';
      if (response.isSuccess && url.isNotEmpty) {
        state = state.copyWith(imageUrls: [...state.imageUrls, url]);
        return url;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void removeImageAt(int index) {
    final updated = [...state.imageUrls]..removeAt(index);
    state = state.copyWith(imageUrls: updated);
  }

  Future<bool> submitReport({
    required String recordNo,
    required int result,
    required String desc,
  }) async {
    state = state.copyWith(submitting: true);
    try {
      final response = await _api.post<Object>(
        ApiPath.roadSaveDeal,
        data: {
          'imgList': state.imageUrls.join(','),
          'opResponse': desc,
          'result': result,
          'recordNo': recordNo,
          'payFlag': 0,
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
