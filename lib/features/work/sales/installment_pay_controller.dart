import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/installment_payment_response.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class InstallmentPayState {
  final bool loadingUser;
  final bool uploading;
  final bool submitting;
  final InstallmentPaymentResponse? info;
  final List<PeriodOrder> orders;
  final PeriodOrder? selectedOrder;
  final List<String> attachments;

  const InstallmentPayState({
    this.loadingUser = false,
    this.uploading = false,
    this.submitting = false,
    this.info,
    this.orders = const [],
    this.selectedOrder,
    this.attachments = const [],
  });

  InstallmentPayState copyWith({
    bool? loadingUser,
    bool? uploading,
    bool? submitting,
    InstallmentPaymentResponse? info,
    List<PeriodOrder>? orders,
    PeriodOrder? selectedOrder,
    List<String>? attachments,
  }) {
    return InstallmentPayState(
      loadingUser: loadingUser ?? this.loadingUser,
      uploading: uploading ?? this.uploading,
      submitting: submitting ?? this.submitting,
      info: info ?? this.info,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      attachments: attachments ?? this.attachments,
    );
  }
}

final installmentPayProvider =
    NotifierProvider<InstallmentPayNotifier, InstallmentPayState>(
  InstallmentPayNotifier.new,
);

class InstallmentPayNotifier extends Notifier<InstallmentPayState> {
  final ApiService _api = ApiService();

  @override
  InstallmentPayState build() => const InstallmentPayState();

  Future<void> queryUser(String cardNum) async {
    if (cardNum.isEmpty) return;
    state = state.copyWith(loadingUser: true);
    final response = await _api.get<InstallmentPaymentResponse>(
      ApiPath.queryUserForPayPeriod,
      queryParameters: {'cardNum': cardNum},
      parser: (json) => InstallmentPaymentResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingUser: false,
      info: response.result,
      orders: response.result?.periodOrderList ?? const [],
      selectedOrder: null,
      attachments: const [],
    );
  }

  void selectOrder(PeriodOrder order) {
    state = state.copyWith(selectedOrder: order);
  }

  void removeAttachment(String url) {
    final updated = List<String>.from(state.attachments)..remove(url);
    state = state.copyWith(attachments: updated);
  }

  Future<String?> uploadAttachment(String path) async {
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
      ApiPath.tradeUploadAttachment,
      data: form,
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(uploading: false);
    if (response.isSuccess && (response.result?.isNotEmpty ?? false)) {
      return response.result;
    }
    return null;
  }

  void addAttachment(String url) {
    final updated = List<String>.from(state.attachments)..add(url);
    state = state.copyWith(attachments: updated);
  }

  Future<bool> submit(String cardNum) async {
    final order = state.selectedOrder;
    if (cardNum.isEmpty || order == null || state.attachments.isEmpty) {
      return false;
    }
    state = state.copyWith(submitting: true);
    final response = await _api.post<Object>(
      ApiPath.payPeriod,
      data: {
        'cardNum': cardNum,
        'attachment': state.attachments.join(','),
        'orderNo': order.orderNo ?? '',
        'period': order.period ?? 0,
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
