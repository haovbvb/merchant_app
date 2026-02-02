import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/payment_plan.dart';
import 'package:merchant_app/data/models/purchasing_user.dart';
import 'package:merchant_app/data/models/service_plan.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class SellBindState {
  final bool loadingUser;
  final bool loadingDevice;
  final bool loadingPlans;
  final bool loadingPaymentPlans;
  final bool submitting;
  final bool submitSuccess;
  final String? documentNo;
  final PurchasingUser? user;
  final BatterOrVehicleInfo? deviceInfo;
  final List<ServicePlanBean> plans;
  final ServicePlanBean? selectedPlan;
  final List<PaymentPlan> paymentPlans;
  final PaymentPlan? selectedPaymentPlan;
  final int paySource;
  final int payType;
  final String? cardImgUrl;
  final String? personImgUrl;

  const SellBindState({
    this.loadingUser = false,
    this.loadingDevice = false,
    this.loadingPlans = false,
    this.loadingPaymentPlans = false,
    this.submitting = false,
    this.submitSuccess = false,
    this.documentNo,
    this.user,
    this.deviceInfo,
    this.plans = const [],
    this.selectedPlan,
    this.paymentPlans = const [],
    this.selectedPaymentPlan,
    this.paySource = 2,
    this.payType = 1,
    this.cardImgUrl,
    this.personImgUrl,
  });

  SellBindState copyWith({
    bool? loadingUser,
    bool? loadingDevice,
    bool? loadingPlans,
    bool? loadingPaymentPlans,
    bool? submitting,
    bool? submitSuccess,
    String? documentNo,
    PurchasingUser? user,
    BatterOrVehicleInfo? deviceInfo,
    List<ServicePlanBean>? plans,
    ServicePlanBean? selectedPlan,
    List<PaymentPlan>? paymentPlans,
    PaymentPlan? selectedPaymentPlan,
    int? paySource,
    int? payType,
    String? cardImgUrl,
    String? personImgUrl,
  }) {
    return SellBindState(
      loadingUser: loadingUser ?? this.loadingUser,
      loadingDevice: loadingDevice ?? this.loadingDevice,
      loadingPlans: loadingPlans ?? this.loadingPlans,
      loadingPaymentPlans: loadingPaymentPlans ?? this.loadingPaymentPlans,
      submitting: submitting ?? this.submitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      documentNo: documentNo ?? this.documentNo,
      user: user ?? this.user,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      plans: plans ?? this.plans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      paymentPlans: paymentPlans ?? this.paymentPlans,
      selectedPaymentPlan: selectedPaymentPlan ?? this.selectedPaymentPlan,
      paySource: paySource ?? this.paySource,
      payType: payType ?? this.payType,
      cardImgUrl: cardImgUrl ?? this.cardImgUrl,
      personImgUrl: personImgUrl ?? this.personImgUrl,
    );
  }
}

final sellBindProvider = NotifierProvider<SellBindNotifier, SellBindState>(
  SellBindNotifier.new,
);

class SellBindNotifier extends Notifier<SellBindState> {
  final ApiService _api = ApiService();

  @override
  SellBindState build() => const SellBindState();

  Future<void> queryUser(String cardNum) async {
    if (cardNum.isEmpty) return;
    state = state.copyWith(loadingUser: true);
    final response = await _api.get<PurchasingUser>(
      ApiPath.queryUserForSell,
      queryParameters: {'cardNum': cardNum},
      parser: (json) =>
          PurchasingUser.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loadingUser: false, user: response.result);
  }

  Future<void> queryDevice(String sn) async {
    if (sn.isEmpty) return;
    final plan = state.selectedPlan;
    state = state.copyWith(loadingDevice: true);
    final params = <String, dynamic>{'sn': sn};
    if ((plan?.batteryType ?? '').isNotEmpty) {
      params['batteryType'] = plan?.batteryType;
    }
    if ((plan?.carType ?? '').isNotEmpty) {
      params['carType'] = plan?.carType;
    }
    final response = await _api.get<BatterOrVehicleInfo>(
      ApiPath.querySaleDeviceInfo,
      queryParameters: params,
      parser: (json) =>
          BatterOrVehicleInfo.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loadingDevice: false, deviceInfo: response.result);
  }

  Future<void> queryPlans(String keyword) async {
    state = state.copyWith(loadingPlans: true);
    final response = await _api.get<ServicePlanInfo>(
      ApiPath.queryServicePlanByName,
      queryParameters: {'keyword': keyword, 'pageNum': 1, 'pageSize': 50},
      parser: (json) =>
          ServicePlanInfo.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(
      loadingPlans: false,
      plans: response.result?.list ?? const [],
    );
  }

  void selectPlan(ServicePlanBean plan) {
    state = state.copyWith(selectedPlan: plan);
    if (plan.packageAmount != null) {
      queryPaymentPlans(plan.packageAmount!);
    }
  }

  Future<void> queryPaymentPlans(double amount) async {
    state = state.copyWith(loadingPaymentPlans: true);
    final response = await _api.get<List<PaymentPlan>>(
      ApiPath.queryPaymentPlanList,
      queryParameters: {'packageAmount': amount},
      parser: (json) =>
          (json as List<dynamic>?)
              ?.map(
                (item) => PaymentPlan.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const <PaymentPlan>[],
    );
    state = state.copyWith(
      loadingPaymentPlans: false,
      paymentPlans: response.result ?? const [],
    );
  }

  void selectPaymentPlan(PaymentPlan plan) {
    state = state.copyWith(selectedPaymentPlan: plan);
  }

  void updatePaySource(int value) {
    state = state.copyWith(paySource: value);
  }

  void updatePayType(int value) {
    state = state.copyWith(payType: value);
  }

  Future<String?> uploadCardImage(String path) async {
    final data = await _compressImage(path);
    if (data == null || data.isEmpty) return null;
    final fileName = _buildFileName(path);
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(data, filename: fileName),
    });
    final response = await _api.postForm<String>(
      ApiPath.uploadCardImg,
      data: form,
      parser: (json) => json?.toString() ?? '',
    );
    if (response.isSuccess && (response.result?.isNotEmpty ?? false)) {
      return response.result;
    }
    return null;
  }

  void setCardImgUrl(String? url) {
    state = state.copyWith(cardImgUrl: url);
  }

  void setPersonImgUrl(String? url) {
    state = state.copyWith(personImgUrl: url);
  }

  Future<bool> submit({
    required String address,
    required String birthday,
    required String cardNum,
    required String email,
    required String firstName,
    required String lastName,
    required String idNumber,
    required String phone,
    String? cardImgUrl,
    String? personImgUrl,
  }) async {
    final plan = state.selectedPlan;
    final device = state.deviceInfo;
    if (plan == null || device == null) return false;
    state = state.copyWith(submitting: true);
    final response = await _api.post<String>(
      ApiPath.sellBind,
      data: {
        'address': address,
        'birthday': birthday,
        'cardImg': cardImgUrl ?? state.cardImgUrl ?? '',
        'cardNum': cardNum,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'idNumber': idNumber,
        'phone': phone,
        'payType': state.payType,
        'planNo': state.selectedPaymentPlan?.planNo ?? '',
        'personImg': personImgUrl ?? state.personImgUrl ?? '',
        'infoCode': plan.infoCode ?? '',
        'paySource': state.paySource,
        'deviceSn': device.batteryVo?.sn ?? device.carVo?.sn ?? '',
        'type': device.deviceType,
      },
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(
      submitting: false,
      submitSuccess: response.isSuccess,
      documentNo: response.result,
    );
    return response.isSuccess;
  }

  void reset() {
    state = const SellBindState();
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

  /// 查询门店支付配置 - 对应 Android 的 getShopPaymentMethod
  Future<Map<String, dynamic>?> queryShopPayConfig(String shopId) async {
    if (shopId.isEmpty) return null;
    final response = await _api.get<Map<String, dynamic>>(
      ApiPath.queryShopPayConfig,
      queryParameters: {'shopId': shopId},
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );
    return response.result;
  }
}
