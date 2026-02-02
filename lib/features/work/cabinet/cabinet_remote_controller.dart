import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/cabinet_version_bean.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 电柜远程操作状态
class CabinetRemoteState {
  final bool operating;
  final String? result;
  final CabinetVersionBean? version;
  final String? androidTime;

  const CabinetRemoteState({
    this.operating = false,
    this.result,
    this.version,
    this.androidTime,
  });

  CabinetRemoteState copyWith({
    bool? operating,
    String? result,
    CabinetVersionBean? version,
    String? androidTime,
  }) {
    return CabinetRemoteState(
      operating: operating ?? this.operating,
      result: result ?? this.result,
      version: version ?? this.version,
      androidTime: androidTime ?? this.androidTime,
    );
  }
}

final cabinetRemoteProvider =
    NotifierProvider<CabinetRemoteNotifier, CabinetRemoteState>(
      CabinetRemoteNotifier.new,
    );

class CabinetRemoteNotifier extends Notifier<CabinetRemoteState> {
  final ApiService _api = ApiService();

  @override
  CabinetRemoteState build() => const CabinetRemoteState();

  /// 重启整机
  /// [type]: 1-安卓机 2-充电器 3-整机
  /// [shutDown]: 1=关机 其他=重启
  Future<bool> restart({
    required String pId,
    int type = 3,
    int shutDown = 0,
  }) async {
    if (pId.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.post<String>(
      ApiPath.cabinetRestart,
      data: {'pID': pId, 'shutDown': shutDown, 'type': type},
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }

  /// 关机
  /// [sleep]: 0=关机后不重启 1-60=延迟x秒重启
  Future<bool> shutdown({required String pId, int sleep = 0}) async {
    if (pId.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.post<String>(
      ApiPath.cabinetShutDown,
      data: {'pID': pId, 'sleep': sleep},
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }

  /// 开仓门
  Future<bool> openDoor({required String pId, required int nId}) async {
    if (pId.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.post<String>(
      ApiPath.cabinetOpenDoor,
      data: {'pID': pId, 'nID': nId},
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }

  /// 开电子锁
  Future<bool> openLock({required String pId, required String nId}) async {
    if (pId.isEmpty || nId.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.post<String>(
      ApiPath.cabinetOpenLock,
      data: {'pID': pId, 'nID': nId},
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }

  /// 查询版本信息
  Future<bool> queryVersion(String pId) async {
    if (pId.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.get<CabinetVersionBean>(
      ApiPath.cabinetQueryVersion,
      queryParameters: {'pID': pId},
      parser: (json) =>
          CabinetVersionBean.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(operating: false, version: response.result);
    return response.isSuccess;
  }

  /// 查询安卓时间
  Future<bool> queryAndroidTime(String pId) async {
    if (pId.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.get<String>(
      ApiPath.cabinetQueryAndroidTime,
      queryParameters: {'pID': pId},
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, androidTime: response.result);
    return response.isSuccess;
  }

  /// 设置仓位状态
  /// [ports]: 仓位列表 [{nID: 1, status: 1}]
  Future<bool> setPorts({
    required String pId,
    required List<Map<String, dynamic>> ports,
  }) async {
    if (pId.isEmpty || ports.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.post<String>(
      ApiPath.cabinetSetPorts,
      data: {'pID': pId, 'ports': ports},
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }

  /// 设置充电电流
  Future<bool> setElectricCurrent({
    required String pId,
    required int current,
  }) async {
    if (pId.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.post<String>(
      ApiPath.cabinetSetElectricCurrent,
      data: {'pID': pId, 'current': current},
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }

  /// 查询快照数据
  Future<Map<String, dynamic>?> querySnapshotData(String pId) async {
    if (pId.isEmpty) return null;
    state = state.copyWith(operating: true);
    final response = await _api.get<Map<String, dynamic>>(
      ApiPath.cabinetQuerySnapshotData,
      queryParameters: {'pID': pId},
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );
    state = state.copyWith(operating: false);
    return response.result;
  }

  /// 清除结果
  void clearResult() {
    state = state.copyWith(result: null);
  }

  /// 获取禁止入仓原因列表
  Future<List<Map<String, dynamic>>> getForbiddenStorageReasons() async {
    state = state.copyWith(operating: true);
    final response = await _api.get<List<dynamic>>(
      ApiPath.cabinetForbiddenStorageReason,
      parser: (json) => (json as List<dynamic>?) ?? [],
    );
    state = state.copyWith(operating: false);
    return response.result
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
  }

  /// 设置单个仓位状态
  Future<bool> setPortStatus({
    required String pId,
    required int port,
    required int enable,
    required String nId,
    String? remark,
    String? reasonCode,
  }) async {
    if (pId.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.post<String>(
      ApiPath.cabinetSetPorts,
      data: {
        'pID': pId,
        'port': port,
        'enable': enable,
        'nID': nId,
        'remark': remark ?? '',
        'reasonCode': reasonCode ?? '',
      },
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }

  /// 修改电柜信息
  Future<bool> modifyInfo({
    required String sn,
    required String address,
    required String location,
    String? imgs,
    String? label,
  }) async {
    if (sn.isEmpty) return false;
    state = state.copyWith(operating: true);
    final path = ApiPath.cabinetModifyInfo.replaceAll('{sn}', sn);
    final response = await _api.post<String>(
      path,
      data: {
        'address': address,
        'location': location,
        if (imgs != null) 'imgs': imgs,
        if (label != null) 'label': label,
      },
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }

  /// 添加电柜管理员
  Future<bool> addManager({
    required String sn,
    required List<Map<String, dynamic>> details,
  }) async {
    if (sn.isEmpty || details.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.post<String>(
      ApiPath.cabinetAddManager,
      data: {'sn': sn, 'details': details},
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }

  /// 获取电柜账户信息
  Future<Map<String, dynamic>?> getAccountInfo(String sn) async {
    if (sn.isEmpty) return null;
    state = state.copyWith(operating: true);
    final response = await _api.get<Map<String, dynamic>>(
      ApiPath.cabinetAccountInfo,
      queryParameters: {'sn': sn},
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );
    state = state.copyWith(operating: false);
    return response.result;
  }

  /// 获取电柜配置
  Future<Map<String, dynamic>?> getConfig(String pid) async {
    if (pid.isEmpty) return null;
    state = state.copyWith(operating: true);
    final path = ApiPath.cabinetGetConfig.replaceAll('{pid}', pid);
    final response = await _api.get<Map<String, dynamic>>(
      path,
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );
    state = state.copyWith(operating: false);
    return response.result;
  }

  /// 获取主副柜关系
  Future<List<Map<String, dynamic>>> getRelation(String pid) async {
    if (pid.isEmpty) return [];
    state = state.copyWith(operating: true);
    final path = ApiPath.cabinetRelation.replaceAll('{pid}', pid);
    final response = await _api.get<List<dynamic>>(
      path,
      parser: (json) => (json as List<dynamic>?) ?? [],
    );
    state = state.copyWith(operating: false);
    return response.result
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
  }

  /// 配置电柜
  Future<bool> configCabinet({
    required String stationPid,
    required int type,
    required int value,
    String? startTime,
    String? stopTime,
  }) async {
    if (stationPid.isEmpty) return false;
    state = state.copyWith(operating: true);
    final response = await _api.post<Object>(
      ApiPath.cabinetConfig,
      data: {
        'stationPid': stationPid,
        'type': type,
        'value': value,
        if (startTime != null) 'startTime': startTime,
        if (stopTime != null) 'stopTime': stopTime,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(operating: false);
    return response.isSuccess;
  }

  /// 更新电柜设置信息 - 对应 Android 的 updateCabinetSettingInfo
  Future<bool> updateCabinetSettingInfo({
    required String pid,
    required Map<String, dynamic> settings,
  }) async {
    if (pid.isEmpty) return false;
    state = state.copyWith(operating: true);
    final path = ApiPath.cabinetUpdateConfig.replaceAll('{pid}', pid);
    final response = await _api.put<String>(
      path,
      data: settings,
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(operating: false, result: response.result);
    return response.isSuccess;
  }
}
