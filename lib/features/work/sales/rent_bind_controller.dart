import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/pack.dart';
import 'package:merchant_app/data/models/purchasing_user.dart';
import 'package:merchant_app/data/models/rent_device_info_bean.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class RentBindState {
  static const Object _sentinel = Object();

  final bool loadingUser;
  final bool loadingDevice;
  final bool submitting;
  final bool submitSuccess;
  final String? documentNo;
  final PurchasingUser? user;
  final RentDeviceInfoBean? deviceInfo;
  final Pack? selectedPack;
  final int paySource;
  final String? cardImgUrl;
  final String? personImgUrl;

  const RentBindState({
    this.loadingUser = false,
    this.loadingDevice = false,
    this.submitting = false,
    this.submitSuccess = false,
    this.documentNo,
    this.user,
    this.deviceInfo,
    this.selectedPack,
    this.paySource = 2,
    this.cardImgUrl,
    this.personImgUrl,
  });

  RentBindState copyWith({
    bool? loadingUser,
    bool? loadingDevice,
    bool? submitting,
    bool? submitSuccess,
    Object? documentNo = _sentinel,
    Object? user = _sentinel,
    Object? deviceInfo = _sentinel,
    Object? selectedPack = _sentinel,
    int? paySource,
    Object? cardImgUrl = _sentinel,
    Object? personImgUrl = _sentinel,
  }) {
    return RentBindState(
      loadingUser: loadingUser ?? this.loadingUser,
      loadingDevice: loadingDevice ?? this.loadingDevice,
      submitting: submitting ?? this.submitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      documentNo: documentNo == _sentinel ? this.documentNo : documentNo as String?,
      user: user == _sentinel ? this.user : user as PurchasingUser?,
      deviceInfo: deviceInfo == _sentinel ? this.deviceInfo : deviceInfo as RentDeviceInfoBean?,
      selectedPack: selectedPack == _sentinel ? this.selectedPack : selectedPack as Pack?,
      paySource: paySource ?? this.paySource,
      cardImgUrl: cardImgUrl == _sentinel ? this.cardImgUrl : cardImgUrl as String?,
      personImgUrl: personImgUrl == _sentinel ? this.personImgUrl : personImgUrl as String?,
    );
  }
}

final rentBindProvider =
    NotifierProvider<RentBindNotifier, RentBindState>(RentBindNotifier.new);

class RentBindNotifier extends Notifier<RentBindState> {
  final ApiService _api = ApiService();

  @override
  RentBindState build() => const RentBindState();

  Future<void> queryUser(String cardNum) async {
    if (cardNum.isEmpty) return;
    state = state.copyWith(loadingUser: true);
    final response = await _api.get<PurchasingUser>(
      ApiPath.queryUserForRent,
      queryParameters: {'cardNum': cardNum},
      parser: (json) => PurchasingUser.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingUser: false,
      user: response.result,
    );
  }

  Future<bool> queryDevice(String sn) async {
    if (sn.isEmpty) return false;
    state = state.copyWith(loadingDevice: true, selectedPack: null);
    try {
      final response = await _api.get<RentDeviceInfoBean>(
        ApiPath.queryRentDeviceInfo,
        queryParameters: {'deviceSn': sn},
        parser: (json) => RentDeviceInfoBean.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );
      state = state.copyWith(
        loadingDevice: false,
        deviceInfo: response.result,
        selectedPack: null,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        loadingDevice: false,
        deviceInfo: null,
        selectedPack: null,
      );
      return false;
    }
  }

  void clearDeviceAndPack() {
    state = state.copyWith(
      loadingDevice: false,
      deviceInfo: null,
      selectedPack: null,
    );
  }

  void selectPack(Pack pack) {
    state = state.copyWith(selectedPack: pack);
  }

  void updatePaySource(int value) {
    state = state.copyWith(paySource: value);
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
    required String deviceSn,
    String? cardImgUrl,
    String? personImgUrl,
  }) async {
    final pack = state.selectedPack;
    if (pack == null) return false;
    final deviceInfo = state.deviceInfo;
    final deviceType = _deviceType(deviceInfo);
    state = state.copyWith(submitting: true);
    final response = await _api.post<String>(
      ApiPath.rentBind,
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
        'payType': 1,
        'personImg': personImgUrl ?? state.personImgUrl ?? '',
        'infoCode': pack.infoCode ?? '',
        'paySource': state.paySource,
        'deviceSn': deviceSn,
        'type': deviceType,
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
    state = const RentBindState();
  }

  int _deviceType(RentDeviceInfoBean? info) {
    if (info?.batteryVo != null) return 1;
    if (info?.carVo != null) return 2;
    return 0;
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
