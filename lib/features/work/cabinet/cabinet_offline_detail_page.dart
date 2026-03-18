import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/hud.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/data/models/cabinet_cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_ble_client.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class CabinetOfflineDetailPage extends ConsumerStatefulWidget {
  const CabinetOfflineDetailPage({
    super.key,
    this.initialSn,
    this.initialBaseInfo,
  });

  /// Optional initial SN to load on page open.
  final String? initialSn;

  /// Pre-fetched base info from the entry page (avoids duplicate API call).
  final CabinetDetailBaseInfoBean? initialBaseInfo;

  @override
  ConsumerState<CabinetOfflineDetailPage> createState() =>
      _CabinetOfflineDetailPageState();
}

class _CabinetOfflineDetailPageState
    extends ConsumerState<CabinetOfflineDetailPage> {
  static const Color _nativeMainBlue = AppColors.primaryColor;
  static const Color _nativeTitleColor = Color(0xE60C0C0D);
  static const Color _nativeBg = Color(0xFFF5F6F7);
  static const Color _nativeDisconnectColor = Color(0xFF6C7180);

  static const Color _onlineStatusColor = _nativeMainBlue;
  static const Color _offlineStatusColor = Color(0xFFFA4B51);

  final TextEditingController _snController = TextEditingController();
  late final CabinetBleClient _bleClient;
  bool _noPermissionHandled = false;
  String _bleBoundSn = '';
  String _bleBoundSecret = '';
  String? _pendingSuccessToast;
  String? _pendingFailedToast;
  VoidCallback? _pendingSuccessAction;
  CabinetBleConnectionPhase _blePhase = CabinetBleConnectionPhase.idle;
  bool _waitingDeviceInfoResponse = false;
  bool _waitingAllDataResponse = false;
  bool _waitingControlResponse = false;
  bool _waitingQueryLoadResponse = false;
  String _pendingQuerySn = '';
  Timer? _refreshHudTimer;

  @override
  void initState() {
    super.initState();
    _bleClient = CabinetBleClient(
      onConnectionChanged: (connected) {
        ref.read(cabinetOfflineProvider.notifier).setBleConnected(connected);
      },
      onPhaseChanged: (phase) {
        if (!mounted || _blePhase == phase) return;
        setState(() {
          _blePhase = phase;
        });
      },
      onAuthorized: () async {
        final l10n = context.l10n;
        ref
            .read(cabinetOfflineProvider.notifier)
            .updateRealtimeData(
              smokeAlarmStatus: l10n.cabinetOfflineNoAlarm,
              waterAlarmStatus: l10n.cabinetOfflineNoAlarm,
              chargerStatus: l10n.cabinetOfflineYes,
            );
        ref
            .read(cabinetOfflineProvider.notifier)
            .updateBackupPowerStatus(l10n.cabinetOfflineNo);

        await _queryDeviceInfoWithHud();
        await _queryAllDataWithHud();
      },
      onJsonData: _handleBleJsonData,
      onError: _handleBleError,
    );
    if (widget.initialSn != null && widget.initialSn!.isNotEmpty) {
      _snController.text = widget.initialSn!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _queryOrScan(initialBaseInfo: widget.initialBaseInfo);
    });
  }

  void _queryWithSn(String sn, {CabinetDetailBaseInfoBean? initialBaseInfo}) {
    final normalizedSn = sn.trim();
    if (normalizedSn.isEmpty) return;
    _showQueryHud(normalizedSn);
    final notifier = ref.read(cabinetOfflineProvider.notifier);
    notifier.load(normalizedSn, initialBaseInfo: initialBaseInfo);
  }

  void _showQueryHud(String sn) {
    _pendingQuerySn = sn;
    if (_waitingQueryLoadResponse) {
      return;
    }
    _waitingQueryLoadResponse = true;
    Hud.show();
  }

  void _dismissPendingQueryHud() {
    if (!_waitingQueryLoadResponse) return;
    _waitingQueryLoadResponse = false;
    _pendingQuerySn = '';
    Hud.dismiss();
  }

  void _onOfflineStateChanged(
    CabinetOfflineState? previous,
    CabinetOfflineState next,
  ) {
    if (!_waitingQueryLoadResponse) return;
    final prevLoading = previous?.loading ?? false;
    final finishedByLoading = prevLoading && !next.loading;
    final baseInfoArrived =
        previous?.baseInfo != next.baseInfo && next.baseInfo != null;
    final matchedSn =
        _pendingQuerySn.isNotEmpty &&
        (next.baseInfo?.stationSn?.trim() ?? '') == _pendingQuerySn;
    if (finishedByLoading || matchedSn || baseInfoArrived) {
      _dismissPendingQueryHud();
    }
  }

  Future<void> _restartCabinet() async {
    final l10n = context.l10n;
    final state = ref.read(cabinetOfflineProvider);
    if (!state.bleConnected) {
      showToast(l10n.cabinetOfflinePleaseConnectBle);
      return;
    }
    _setPendingControlToast(
      success: l10n.deviceDetailToggleSuccess,
      failed: l10n.deviceDetailToggleFailed,
    );
    _showControlHud();
    await _bleClient.sendRestart();
  }

  Future<void> _openBackDoor() async {
    final l10n = context.l10n;
    final state = ref.read(cabinetOfflineProvider);
    if (!state.bleConnected) {
      showToast(l10n.cabinetOfflinePleaseConnectBle);
      return;
    }
    _setPendingControlToast(
      success: l10n.cabinetOperateOpenDoorSuccess,
      failed: l10n.cabinetOperateOpenDoorFailed,
    );
    _showControlHud();
    await _bleClient.sendOpenBackDoor();
  }

  Future<void> _openCabinDoor(CabinetCabin cabin) async {
    final l10n = context.l10n;
    final state = ref.read(cabinetOfflineProvider);
    if (!state.bleConnected) {
      showToast(l10n.cabinetOfflinePleaseConnectBle);
      return;
    }
    _setPendingControlToast(
      success: l10n.deviceDetailCabinOpenDoorSuccess,
      failed: l10n.deviceDetailCabinOpenDoorFailed,
    );
    _showControlHud();
    await _bleClient.sendPortControl(port: cabin.portNo, type: 1);
  }

  Future<void> _toggleCabinEnable(CabinetCabin cabin) async {
    final l10n = context.l10n;
    final type = cabin.isEnabled ? 2 : 3;
    final state = ref.read(cabinetOfflineProvider);
    if (!state.bleConnected) {
      showToast(l10n.cabinetOfflinePleaseConnectBle);
      return;
    }
    _setPendingControlToast(
      success: l10n.deviceDetailToggleSuccess,
      failed: l10n.deviceDetailToggleFailed,
    );
    _pendingSuccessAction = () {
      final notifier = ref.read(cabinetOfflineProvider.notifier);
      notifier.updateCabinDoorStatus(cabin.portNo, type == 3 ? 1 : 0);
    };
    _showControlHud();
    await _bleClient.sendPortControl(port: cabin.portNo, type: type);
  }

  void _setPendingControlToast({
    required String success,
    required String failed,
  }) {
    _pendingSuccessToast = success;
    _pendingFailedToast = failed;
    _pendingSuccessAction = null;
  }

  void _handleBleError(String message) {
    if (!mounted) return;
    _dismissPendingControlHud();
    _dismissPendingBleHud();
    final l10n = context.l10n;
    if (_pendingSuccessToast != null || _pendingFailedToast != null) {
      showToast(_pendingFailedToast ?? l10n.deviceDetailToggleFailed);
      _pendingSuccessToast = null;
      _pendingFailedToast = null;
      _pendingSuccessAction = null;
      return;
    }

    switch (message) {
      case 'permission-denied':
        showToast(l10n.bluetoothPermissionDesc);
        break;
      case 'bluetooth-off':
        showToast(l10n.cabinetOfflineBleTurnOnHint);
        _tryStartBle(ref.read(cabinetOfflineProvider));
        break;
      case 'scan-timeout':
        showToast(l10n.cabinetOfflineBleScanTimeout);
        break;
      case 'scan-failed':
        showToast(l10n.cabinetOfflinePleaseConnectBle);
        break;
      case 'write-failed':
        showToast(l10n.cabinetOfflineBleDisconnectedHint);
        _tryStartBle(ref.read(cabinetOfflineProvider));
        break;
      case 'not-connected':
        showToast(l10n.cabinetOfflineBleDisconnectedHint);
        break;
      case 'not-authorized':
      case 'auth-failed':
        showToast(l10n.cabinetOfflineBleAuthFailed);
        break;
      default:
        break;
    }
  }

  void _handleBleJsonData(String jsonText) {
    if (!mounted) return;
    Map<String, dynamic> map;
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map<String, dynamic>) return;
      map = decoded;
    } catch (_) {
      return;
    }

    final notifier = ref.read(cabinetOfflineProvider.notifier);
    final l10n = context.l10n;
    final msgType = (map['msgType'] as num?)?.toInt();
    if (msgType == null) return;
    final resultList = map['resultList'];

    if (_waitingDeviceInfoResponse &&
        msgType == CabinetDataType.queryResponse &&
        resultList is List &&
        resultList.any((item) {
          if (item is! Map) return false;
          final id = item['id']?.toString() ?? '';
          return id == CabinetParamName.softVersion ||
              id == CabinetParamName.cabVolume ||
              id == CabinetParamName.cabSoc ||
              id == CabinetParamName.cabTcpPort ||
              id == CabinetParamName.apn;
        })) {
      _waitingDeviceInfoResponse = false;
      Hud.dismiss();
    }

    if (_waitingAllDataResponse &&
        (msgType == CabinetDataType.attributeRequest ||
            msgType == CabinetDataType.alarmRequest ||
            (msgType == CabinetDataType.queryResponse &&
                resultList is List &&
                resultList.any((item) {
                  if (item is! Map) return false;
                  final id = item['id']?.toString() ?? '';
                  return id == CabinetBleSignal.allData;
                })))) {
      _waitingAllDataResponse = false;
      Hud.dismiss();
    }

    if (msgType == CabinetDataType.controlResponse) {
      _dismissPendingControlHud();
      final ok = ((map['result'] as num?)?.toInt() ?? 0) == 1;
      showToast(
        ok
            ? (_pendingSuccessToast ?? l10n.deviceDetailToggleSuccess)
            : (_pendingFailedToast ?? l10n.deviceDetailToggleFailed),
      );
      if (ok) {
        _pendingSuccessAction?.call();
        _queryAllDataWithHud();
      }
      _pendingSuccessToast = null;
      _pendingFailedToast = null;
      _pendingSuccessAction = null;
      return;
    }

    if (msgType == CabinetDataType.queryResponse && resultList is List) {
      for (final item in resultList) {
        if (item is! Map) continue;
        final id = item['id']?.toString() ?? '';
        final value = item['value']?.toString() ?? '';
        if (id == CabinetParamName.softVersion) {
          notifier.updateSoftwareVersion(value);
        } else if (id == CabinetParamName.cabSoc) {
          final threshold = int.tryParse(value);
          if (threshold != null) {
            notifier.patchBaseInfo(swapThreshold: threshold);
          }
        } else if (id == CabinetParamName.cabVolume) {
          final volume = int.tryParse(value);
          if (volume != null) {
            notifier.patchBaseInfo(volume: volume);
          }
        } else if (id == CabinetParamName.apn) {
          notifier.patchBaseInfo(apn: value);
        } else if (id == CabinetParamName.cabTcpPort) {
          notifier.patchBaseInfo(platformUrl: value.replaceAll(',', ':'));
        }
      }
    }

    final alarmList = map['alarmList'];
    if (msgType == CabinetDataType.alarmRequest && alarmList is List) {
      var chargerAlarm = false;
      for (final item in alarmList) {
        if (item is! Map) continue;
        final id = item['id']?.toString() ?? '';
        final alarmFlag = (item['alarmFlag'] as num?)?.toInt();
        if (id == CabinetBleSignal.alarmSmoke) {
          notifier.updateRealtimeData(
            smokeAlarmStatus: alarmFlag == 1
                ? l10n.cabinetOfflineAlarm
                : alarmFlag == 0
                ? l10n.cabinetOfflineNoAlarm
                : l10n.cabinetOfflineUnknown,
          );
        } else if (id == CabinetBleSignal.alarmWater) {
          notifier.updateRealtimeData(
            waterAlarmStatus: alarmFlag == 1
                ? l10n.cabinetOfflineAlarm
                : alarmFlag == 0
                ? l10n.cabinetOfflineNoAlarm
                : l10n.cabinetOfflineUnknown,
          );
        } else if (id.contains(CabinetBleSignal.ctrlChargerPrefix)) {
          if (alarmFlag == 1) {
            chargerAlarm = true;
          }
        } else if (id == CabinetBleSignal.backupBatteryStatus) {
          notifier.updateBackupPowerStatus(
            alarmFlag == 1
                ? l10n.cabinetOfflineYes
                : alarmFlag == 0
                ? l10n.cabinetOfflineNo
                : l10n.cabinetOfflineUnknown,
          );
        }
      }
      notifier.updateRealtimeData(
        chargerStatus: chargerAlarm
            ? l10n.cabinetOfflineNo
            : l10n.cabinetOfflineYes,
      );
    }

    if (msgType == CabinetDataType.attributeRequest) {
      final attrList = map['attrList'];
      var batteryInSlot = 0;
      var ctrlSystemStatus = l10n.cabinetOfflineYes;
      if (attrList is List) {
        for (final item in attrList) {
          if (item is! Map) continue;
          final id = item['id']?.toString() ?? '';
          final value = item['value']?.toString() ?? '';
          final doorId = int.tryParse(item['doorId']?.toString() ?? '');

          if (id == CabinetBleSignal.gsm) {
            notifier.updateRealtimeData(gsmSignal: '$value dbm');
          } else if (id == CabinetBleSignal.cabinetMaintenanceDoor) {
            final intVal = int.tryParse(value);
            notifier.updateRealtimeData(
              omDoorStatus: intVal == 0
                  ? l10n.cabinetOfflineClose
                  : intVal == 1
                  ? l10n.cabinetOfflineOpen
                  : l10n.cabinetOfflineUnknown,
            );
          } else if (id == CabinetBleSignal.cabinetVoltage) {
            notifier.updateRealtimeData(totalVoltage: '$value V');
          } else if (id == CabinetBleSignal.cabinetCurrent) {
            notifier.updateRealtimeData(totalCurrent: '$value A');
          } else if (id == CabinetBleSignal.cabinetTemperature) {
            notifier.updateRealtimeData(temperature: '$value ℃');
          } else if (id == CabinetBleSignal.electricMeter) {
            notifier.updateRealtimeData(electricityMeter: '$value kWh');
          } else if (id == CabinetBleSignal.ctrlSystem) {
            final intVal = int.tryParse(value);
            if (intVal == 0) {
              ctrlSystemStatus = l10n.cabinetOfflineException;
            } else if (intVal == 1) {
              ctrlSystemStatus = l10n.cabinetOfflineYes;
            } else {
              ctrlSystemStatus = l10n.cabinetOfflineUnknown;
            }
          } else if (id == CabinetBleSignal.cabinetFanStatus) {
            final intVal = int.tryParse(value);
            notifier.updateRealtimeData(
              fanStatus: intVal == 0
                  ? l10n.cabinetOfflineClose
                  : intVal == 1
                  ? l10n.cabinetOfflineRunning
                  : intVal == 2
                  ? l10n.cabinetOfflineException
                  : l10n.cabinetOfflineUnknown,
            );
          } else if (doorId != null && doorId > 0) {
            if (id == CabinetBleSignal.batterySn) {
              notifier.updateCabinBatterySn(doorId, value);
            } else if (id == CabinetBleSignal.cabinetBatterySwapStatus) {
              final intVal = int.tryParse(value) ?? 0;
              notifier.updateCabinBatteryStatus(doorId, intVal);
              if (intVal != 0) {
                batteryInSlot++;
              }
            } else if (id == CabinetBleSignal.batterySoc) {
              final soc = int.tryParse(value);
              if (soc != null) {
                notifier.updateCabinBatterySoc(doorId, soc);
              }
            } else if (id == CabinetBleSignal.cabinetDoorStatus) {
              final intVal = int.tryParse(value);
              if (intVal != null) {
                notifier.updateCabinDoorStatus(doorId, intVal);
              }
            } else if (id == CabinetBleSignal.cabinetSwapStatus) {
              final intVal = int.tryParse(value) ?? 0;
              notifier.updateCabinSwapFlag(doorId, intVal > 0 ? 1 : 0);
            }
          }
        }
      }
      notifier.updateBatteryInSlot(batteryInSlot);
      notifier.updateRealtimeData(ctrlSystemStatus: ctrlSystemStatus);

      final cabList = map['cabList'];
      if (cabList is List && cabList.isNotEmpty && cabList.first is Map) {
        final cabinet = cabList.first as Map;
        final dbm = cabinet['dBM']?.toString();
        final cabVol = cabinet['cabVol']?.toString();
        final cabCur = cabinet['cabCur']?.toString();
        final cabT = cabinet['cabT']?.toString();
        final cabAlarm = cabinet['cabAlarm'];
        if (dbm != null && dbm.isNotEmpty) {
          notifier.updateRealtimeData(gsmSignal: '$dbm dbm');
        }
        if (cabVol != null && cabVol.isNotEmpty) {
          notifier.updateRealtimeData(totalVoltage: '$cabVol V');
        }
        if (cabCur != null && cabCur.isNotEmpty) {
          notifier.updateRealtimeData(totalCurrent: '$cabCur A');
        }
        if (cabT != null && cabT.isNotEmpty) {
          notifier.updateRealtimeData(temperature: '$cabT ℃');
        }
        if (cabAlarm is List) {
          var waterAlarm = false;
          var smokeAlarm = false;
          for (final item in cabAlarm) {
            final code = item?.toString() ?? '';
            if (code == '03') {
              waterAlarm = true;
            } else if (code == '04') {
              smokeAlarm = true;
            }
          }
          if (waterAlarm) {
            notifier.updateRealtimeData(
              waterAlarmStatus: l10n.cabinetOfflineAlarm,
            );
          }
          if (smokeAlarm) {
            notifier.updateRealtimeData(
              smokeAlarmStatus: l10n.cabinetOfflineAlarm,
            );
          }
        }
      }
    }
  }

  void _tryStartBle(CabinetOfflineState state) {
    final sn = state.baseInfo?.stationSn?.trim() ?? '';
    final secret = state.secretKey?.trim() ?? '';
    if (sn.isEmpty || secret.isEmpty) {
      return;
    }
    if (sn == _bleBoundSn && secret == _bleBoundSecret) {
      return;
    }
    _bleBoundSn = sn;
    _bleBoundSecret = secret;
    _bleClient.start(deviceSn: sn, secretKey: secret);
  }

  Future<void> _queryDeviceInfoWithHud() async {
    if (!_waitingDeviceInfoResponse) {
      _waitingDeviceInfoResponse = true;
      Hud.show();
    }
    await _bleClient.queryDeviceInfo();
  }

  Future<void> _queryAllDataWithHud() async {
    if (!_waitingAllDataResponse) {
      _waitingAllDataResponse = true;
      Hud.show();
    }
    await _bleClient.queryAllData();
  }

  void _onRefreshPressed() {
    // Match native behavior: tapping refresh always gives immediate loading feedback.
    Hud.show();
    _refreshHudTimer?.cancel();
    _refreshHudTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      Hud.dismiss();
      _refreshHudTimer = null;
    });

    if (!ref.read(cabinetOfflineProvider).bleConnected) {
      return;
    }

    _queryAllDataWithHudWithoutShow();
  }

  Future<void> _queryAllDataWithHudWithoutShow() async {
    if (!_waitingAllDataResponse) {
      _waitingAllDataResponse = true;
    }
    await _bleClient.queryAllData();
  }

  void _showControlHud() {
    if (_waitingControlResponse) return;
    _waitingControlResponse = true;
    Hud.show();
  }

  void _dismissPendingControlHud() {
    if (!_waitingControlResponse) return;
    _waitingControlResponse = false;
    Hud.dismiss();
  }

  @override
  void dispose() {
    _refreshHudTimer?.cancel();
    _refreshHudTimer = null;
    _dismissPendingQueryHud();
    _dismissPendingControlHud();
    _dismissPendingBleHud();
    _bleClient.stop();
    _snController.dispose();
    super.dispose();
  }

  void _dismissPendingBleHud() {
    if (_waitingDeviceInfoResponse) {
      _waitingDeviceInfoResponse = false;
      Hud.dismiss();
    }
    if (_waitingAllDataResponse) {
      _waitingAllDataResponse = false;
      Hud.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CabinetOfflineState>(
      cabinetOfflineProvider,
      _onOfflineStateChanged,
    );
    final l10n = context.l10n;
    final state = ref.watch(cabinetOfflineProvider);
    final info = state.baseInfo;
    final canOperate = (info?.hasPermission ?? 0) == 1;

    if (info != null && !canOperate && !_noPermissionHandled) {
      _noPermissionHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showToast(l10n.cabinetOfflineNoPermission);
        Navigator.of(context).maybePop();
      });
    }

    if (canOperate) {
      _tryStartBle(state);
    }

    return Scaffold(
      backgroundColor: _nativeBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _nativeTitleColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.cabinetOfflineDetailTitle),
        actions: [
          if (info != null)
            IconButton(
              icon: Image.asset(
                'assets/android/mipmap-xxhdpi/icon_flash.png',
                width: 30,
                height: 30,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.bolt_outlined, size: 20),
              ),
              onPressed: () {
                _onRefreshPressed();
              },
            ),
        ],
      ),
      body: _buildDetailView(state, info, canOperate),
    );
  }

  Future<void> _queryOrScan({
    CabinetDetailBaseInfoBean? initialBaseInfo,
  }) async {
    final sn = _snController.text.trim();

    if (sn.isNotEmpty) {
      _queryWithSn(sn, initialBaseInfo: initialBaseInfo);
      return;
    }
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(parseDeviceSn: true, deviceType: 3),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    _queryWithSn(result);
  }

  Widget _buildDetailView(
    CabinetOfflineState state,
    CabinetDetailBaseInfoBean? info,
    bool canOperate,
  ) {
    final l10n = context.l10n;
    final isPlaceholder = info == null;
    final safeInfo =
        info ?? CabinetDetailBaseInfoBean.fromJson(const <String, dynamic>{});
    final allowOperate = canOperate && !isPlaceholder;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildHeader(info, state, allowOperate),
          Material(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF333333),
              unselectedLabelColor: const Color(0x990C0C0D),
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              indicator: const _FixedWidthRoundedUnderlineIndicator(
                color: _onlineStatusColor,
                width: 16,
                thickness: 4,
                bottomOffset: 4,
                radius: 5,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              tabs: [
                Tab(text: l10n.cabinetOfflineDeviceInfoTab),
                Tab(text: l10n.cabinetOfflineWarehouseTab),
                Tab(text: l10n.cabinetOfflineRealtimeTab),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DeviceInfoTab(
                  info: safeInfo,
                  state: state,
                  isPlaceholder: isPlaceholder,
                  onEditSwapThreshold: isPlaceholder
                      ? () {}
                      : () => _showEditSwapThreshold(safeInfo),
                  onEditApn: isPlaceholder
                      ? () {}
                      : () => _showEditApn(safeInfo),
                  onEditVolume: isPlaceholder
                      ? () {}
                      : () => _showEditVolume(safeInfo),
                  onEditPlatformUrl: isPlaceholder
                      ? () {}
                      : () => _showEditPlatformUrl(safeInfo),
                ),
                _WarehouseTab(
                  state: state,
                  canOperate: allowOperate,
                  onOpenDoor: _openCabinDoor,
                  onToggleEnable: _toggleCabinEnable,
                ),
                _RealtimeInfoTab(isPlaceholder: isPlaceholder),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    CabinetDetailBaseInfoBean? info,
    CabinetOfflineState state,
    bool canOperate,
  ) {
    final l10n = context.l10n;
    final hasInfo = info != null;
    final isOnline =
        hasInfo &&
        (info.onlineStatus == 1 ||
            (info.onlineStatus == null && info.online == '1'));
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/android/mipmap-xxhdpi/bg_mine.webp',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.all(2),
                      child:
                          hasInfo &&
                              info.standardImg != null &&
                              info.standardImg!.isNotEmpty
                          ? Image.network(
                              info.standardImg!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.battery_charging_full,
                                size: 30,
                                color: _nativeMainBlue,
                              ),
                            )
                          : hasInfo
                          ? const Icon(
                              Icons.battery_charging_full,
                              size: 30,
                              color: _nativeMainBlue,
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasInfo
                                ? (info.stationName ??
                                      info.stationModelName ??
                                      '')
                                : '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19,
                              color: _nativeTitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (hasInfo)
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    4,
                                    3,
                                    4,
                                    3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isOnline
                                          ? _onlineStatusColor
                                          : _offlineStatusColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        isOnline
                                            ? 'assets/android/mipmap-xxhdpi/icon_signal_online.png'
                                            : 'assets/android/mipmap-xxhdpi/icon_signal_offline.webp',
                                        width: 14,
                                        height: 14,
                                        errorBuilder: (_, __, ___) => Icon(
                                          isOnline
                                              ? Icons.wifi
                                              : Icons.wifi_off,
                                          size: 14,
                                          color: isOnline
                                              ? _onlineStatusColor
                                              : _offlineStatusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        isOnline
                                            ? l10n.deviceDetailOnline
                                            : l10n.deviceDetailOffline,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isOnline
                                              ? _onlineStatusColor
                                              : _offlineStatusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(width: hasInfo ? 8 : 0),
                              Text(
                                hasInfo
                                    ? _bleStatusLabel(l10n, state.bleConnected)
                                    : '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: hasInfo
                                      ? _bleStatusColor(state.bleConnected)
                                      : _nativeDisconnectColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: _HeaderActionButton(
                        icon: Image.asset(
                          'assets/android/mipmap-xxhdpi/icon_restart.png',
                          width: 24,
                          height: 24,
                        ),

                        label: l10n.cabinetOfflineRestart,
                        enabled: canOperate && !state.operating,
                        onTap: _showRestartDialog,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _HeaderActionButton(
                        icon: Image.asset(
                          'assets/android/mipmap-xxhdpi/icon_open_door.png',
                          width: 24,
                          height: 24,
                        ),
                        label: l10n.cabinetOfflineOpenDoor,
                        enabled: canOperate && !state.operating,
                        onTap: _showOpenDoorDialog,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog() {
    final l10n = context.l10n;
    ConfirmDialog.show(
      context: context,
      message: l10n.cabinetOfflineRestartConfirm,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
    ).then((confirmed) async {
      if (!confirmed) return;
      await _restartCabinet();
    });
  }

  void _showOpenDoorDialog() {
    final l10n = context.l10n;
    ConfirmDialog.show(
      context: context,
      message: l10n.cabinetOfflineOpenDoorConfirm,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
    ).then((confirmed) async {
      if (!confirmed) return;
      await _openBackDoor();
    });
  }

  void _showEditSwapThreshold(CabinetDetailBaseInfoBean info) {
    final l10n = context.l10n;
    final currentValue = info.swapThreshold?.toString() ?? '';
    final maxChargeSoc = info.maxChargeSoc ?? 100;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditTextSheet(
        title: l10n.cabinetOfflineSwapThreshold,
        hintText: l10n.cabinetOfflineEnterSwapThreshold,
        currentValue: currentValue,
        keyboardType: TextInputType.number,
        onSave: (value) {
          if (value.isEmpty) {
            showToast(l10n.cabinetOfflineEnterSwapThreshold);
            return;
          }
          final intVal = int.tryParse(value);
          if (intVal == null || intVal > maxChargeSoc) {
            showToast(l10n.cabinetOfflineSwapThresholdExceed(maxChargeSoc));
            return;
          }
          final state = ref.read(cabinetOfflineProvider);
          if (!state.bleConnected) {
            showToast(l10n.cabinetOfflinePleaseConnectBle);
            return;
          }
          Navigator.of(ctx).pop();
          _setPendingControlToast(
            success: l10n.deviceDetailToggleSuccess,
            failed: l10n.deviceDetailToggleFailed,
          );
          _showControlHud();
          _pendingSuccessAction = () {
            ref
                .read(cabinetOfflineProvider.notifier)
                .patchBaseInfo(swapThreshold: intVal);
          };
          _bleClient.sendSwapThreshold(intVal);
        },
      ),
    );
  }

  void _showEditApn(CabinetDetailBaseInfoBean info) {
    final l10n = context.l10n;
    final currentValue = info.apn ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditTextSheet(
        title: l10n.cabinetOfflineApn,
        hintText: l10n.cabinetOfflineEnterApn,
        currentValue: currentValue,
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
        ],
        onSave: (value) {
          if (value.isEmpty) {
            showToast(l10n.cabinetOfflineEnterApn);
            return;
          }
          if (value.length > 200) {
            showToast(l10n.cabinetOfflineMaxLenError(200));
            return;
          }
          final state = ref.read(cabinetOfflineProvider);
          if (!state.bleConnected) {
            showToast(l10n.cabinetOfflinePleaseConnectBle);
            return;
          }
          Navigator.of(ctx).pop();
          _setPendingControlToast(
            success: l10n.deviceDetailToggleSuccess,
            failed: l10n.deviceDetailToggleFailed,
          );
          _showControlHud();
          _pendingSuccessAction = () {
            ref.read(cabinetOfflineProvider.notifier).patchBaseInfo(apn: value);
          };
          _bleClient.sendApn(value);
        },
      ),
    );
  }

  void _showEditVolume(CabinetDetailBaseInfoBean info) {
    final l10n = context.l10n;
    final currentValue = info.volume ?? 0;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditVolumeSheet(
        title: l10n.cabinetOfflineVolume,
        currentValue: currentValue,
        onSave: (value) {
          final state = ref.read(cabinetOfflineProvider);
          if (!state.bleConnected) {
            showToast(l10n.cabinetOfflinePleaseConnectBle);
            return;
          }
          Navigator.of(ctx).pop();
          _setPendingControlToast(
            success: l10n.deviceDetailToggleSuccess,
            failed: l10n.deviceDetailToggleFailed,
          );
          _showControlHud();
          _pendingSuccessAction = () {
            ref
                .read(cabinetOfflineProvider.notifier)
                .patchBaseInfo(volume: value);
          };
          _bleClient.sendVolume(value);
        },
      ),
    );
  }

  void _showEditPlatformUrl(CabinetDetailBaseInfoBean info) {
    final l10n = context.l10n;
    final currentValue = info.platformUrl ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditTextSheet(
        title: l10n.cabinetOfflinePlatformUrl,
        hintText: l10n.cabinetOfflineEnterPlatformUrl,
        currentValue: currentValue,
        keyboardType: TextInputType.url,
        onSave: (value) {
          if (value.isEmpty) {
            showToast(l10n.cabinetOfflineEnterPlatformUrl);
            return;
          }
          if (!value.contains(':')) {
            final isZh = Localizations.localeOf(context).languageCode == 'zh';
            showToast(
              isZh ? '请输入以 : 分隔的端口' : 'Please fill in the port separated by :',
            );
            return;
          }
          if (value.split(':').length > 2) {
            final isZh = Localizations.localeOf(context).languageCode == 'zh';
            showToast(isZh ? '输入格式错误' : 'Enter format error');
            return;
          }
          if (value.length > 200) {
            showToast(l10n.cabinetOfflineMaxLenError(200));
            return;
          }
          final state = ref.read(cabinetOfflineProvider);
          if (!state.bleConnected) {
            showToast(l10n.cabinetOfflinePleaseConnectBle);
            return;
          }
          Navigator.of(ctx).pop();
          _setPendingControlToast(
            success: l10n.deviceDetailToggleSuccess,
            failed: l10n.deviceDetailToggleFailed,
          );
          _showControlHud();
          _pendingSuccessAction = () {
            ref
                .read(cabinetOfflineProvider.notifier)
                .patchBaseInfo(platformUrl: value);
          };
          _bleClient.sendPlatformUrl(value);
        },
      ),
    );
  }

  String _bleStatusLabel(AppLocalizations l10n, bool bleConnected) {
    return bleConnected || _blePhase == CabinetBleConnectionPhase.connected
        ? l10n.cabinetOfflineBleConnected
        : l10n.cabinetOfflineBleDisconnected;
  }

  Color _bleStatusColor(bool bleConnected) {
    return bleConnected || _blePhase == CabinetBleConnectionPhase.connected
        ? Color(0x800C0C0D)
        : _nativeDisconnectColor;
  }
}

class _DeviceInfoTab extends StatelessWidget {
  const _DeviceInfoTab({
    required this.info,
    required this.state,
    required this.isPlaceholder,
    required this.onEditSwapThreshold,
    required this.onEditApn,
    required this.onEditVolume,
    required this.onEditPlatformUrl,
  });

  final CabinetDetailBaseInfoBean info;
  final CabinetOfflineState state;
  final bool isPlaceholder;
  final VoidCallback onEditSwapThreshold;
  final VoidCallback onEditApn;
  final VoidCallback onEditVolume;
  final VoidCallback onEditPlatformUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const SizedBox(height: 16),
        // First card: read-only info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineSoftwareVersion,
                value: isPlaceholder ? '' : state.softwareVersion,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineBackupPowerStatus,
                value: isPlaceholder ? '' : state.backupPowerStatus,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineSlotCount,
                value: isPlaceholder ? '' : info.storeNum?.toString(),
              ),
              _InfoTile(
                label: l10n.cabinetOfflineBatteryInSlot,
                value: isPlaceholder ? '' : state.batteryInSlot?.toString(),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Second card: editable items with right arrow
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineSwapThreshold,
                value: isPlaceholder ? '' : info.swapThreshold?.toString(),
                showArrow: !isPlaceholder,
                onTap: isPlaceholder ? null : onEditSwapThreshold,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineApn,
                value: isPlaceholder ? '' : info.apn,
                showArrow: !isPlaceholder,
                onTap: isPlaceholder ? null : onEditApn,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineVolume,
                value: isPlaceholder ? '' : info.volume?.toString(),
                showArrow: !isPlaceholder,
                onTap: isPlaceholder ? null : onEditVolume,
              ),
              _InfoTile(
                label: l10n.cabinetOfflinePlatformUrl,
                value: isPlaceholder ? '' : info.platformUrl,
                showArrow: !isPlaceholder,
                rowHeight: 40,
                labelFlex: 2,
                valueFlex: 3,
                showDivider: false,
                onTap: isPlaceholder ? null : onEditPlatformUrl,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RealtimeInfoTab extends ConsumerWidget {
  const _RealtimeInfoTab({required this.isPlaceholder});

  final bool isPlaceholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetOfflineProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const SizedBox(height: 16),
        // Card 1: 通讯相关
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineGsmSignal,
                value: isPlaceholder ? '' : state.gsmSignal,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineCharger,
                value: isPlaceholder
                    ? ''
                    : (state.chargerStatus ?? l10n.cabinetOfflineYes),
              ),
              _InfoTile(
                label: l10n.cabinetOfflineCtrlSystem,
                value: isPlaceholder
                    ? ''
                    : (state.ctrlSystemStatus ?? l10n.cabinetOfflineYes),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Card 2: 电气数据
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineOMDoor,
                value: isPlaceholder ? '' : state.omDoorStatus,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineTotalVoltage,
                value: isPlaceholder ? '' : state.totalVoltage,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineTotalCurrent,
                value: isPlaceholder ? '' : state.totalCurrent,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineTemperature,
                value: isPlaceholder ? '' : state.temperature,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineElectricityMeter,
                value: isPlaceholder ? '' : state.electricityMeter,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Card 3: 报警状态
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineSmokeAlarm,
                value: isPlaceholder
                    ? ''
                    : (state.smokeAlarmStatus ?? l10n.cabinetOfflineNoAlarm),
              ),
              _InfoTile(
                label: l10n.cabinetOfflineWaterAlarm,
                value: isPlaceholder
                    ? ''
                    : (state.waterAlarmStatus ?? l10n.cabinetOfflineNoAlarm),
              ),
              _InfoTile(
                label: l10n.cabinetOfflineFanStatus,
                value: isPlaceholder ? '' : state.fanStatus,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WarehouseTab extends StatelessWidget {
  const _WarehouseTab({
    required this.state,
    required this.canOperate,
    required this.onOpenDoor,
    required this.onToggleEnable,
  });

  final CabinetOfflineState state;
  final bool canOperate;
  final Future<void> Function(CabinetCabin cabin) onOpenDoor;
  final Future<void> Function(CabinetCabin cabin) onToggleEnable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cabins = state.cabins;
    if (cabins.isEmpty) {
      return Center(child: Text(l10n.cabinetOfflineWarehouseEmpty));
    }
    return Container(
      color: const Color(0xFFF5F6F7),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.84,
        ),
        itemCount: cabins.length,
        itemBuilder: (context, index) {
          final cabin = cabins[index];
          return _WarehouseCabinCard(
            cabin: cabin,
            l10n: l10n,
            canOperate: canOperate,
            onSetup: () => _showCabinOperateSheet(context, cabin),
          );
        },
      ),
    );
  }

  void _showCabinOperateSheet(BuildContext context, CabinetCabin cabin) {
    final l10n = context.l10n;
    final openActionColor = const Color(0xE60C0C0D);
    final enableActionColor = cabin.isEnabled
        ? const Color(0xFFFA4B51)
        : const Color(0xE60C0C0D);
    final openLabel = l10n.deviceDetailPortOpenShort;
    final enableLabel = cabin.isEnabled
        ? l10n.deviceDetailPortDisableShort
        : l10n.cabinetOfflineCabinEnable;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  l10n.cabinetOfflineCabinSlot(cabin.portNo),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0x800C0C0D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF8F8F8)),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: !canOperate || state.operating
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        final confirmed = await ConfirmDialog.show(
                          context: context,
                          message: l10n.deviceDetailPortOpenConfirm(
                            cabin.portNo,
                          ),
                          cancelText: l10n.cancel,
                          confirmText: l10n.confirm,
                        );
                        if (!confirmed) return;
                        await onOpenDoor(cabin);
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: const RoundedRectangleBorder(),
                  foregroundColor: openActionColor,
                ),
                child: Text(openLabel, style: const TextStyle(fontSize: 14)),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF8F8F8)),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: !canOperate || state.operating
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        final confirmed = await ConfirmDialog.show(
                          context: context,
                          message: cabin.isEnabled
                              ? l10n.deviceDetailPortDisableConfirm
                              : l10n.deviceDetailPortEnableConfirm,
                          cancelText: l10n.cancel,
                          confirmText: l10n.confirm,
                        );
                        if (!confirmed) return;
                        await onToggleEnable(cabin);
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: const RoundedRectangleBorder(),
                  foregroundColor: enableActionColor,
                ),
                child: Text(enableLabel, style: const TextStyle(fontSize: 14)),
              ),
            ),
            Container(height: 10, color: const Color(0xFFF0F2F5)),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: const RoundedRectangleBorder(),
                  foregroundColor: const Color(0xE60C0C0D),
                ),
                child: Text(l10n.cancel, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? const Color(0xCC0C0C0D) : const Color(0x660C0C0D);
    return TextButton.icon(
      onPressed: enabled ? onTap : null,
      icon: icon,
      label: Text(label, style: TextStyle(fontSize: 14, color: fg)),
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF2F5FA),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _WarehouseCabinCard extends StatelessWidget {
  const _WarehouseCabinCard({
    required this.cabin,
    required this.l10n,
    required this.canOperate,
    required this.onSetup,
  });

  final CabinetCabin cabin;
  final dynamic l10n;
  final bool canOperate;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    final isDisabled = cabin.status == 0;
    final hasBattery = cabin.batteryStatus != 0;
    final soc = cabin.batterySoc;
    final swapFlag = cabin.swapFlag;
    final portBadgeColor = isDisabled
        ? const Color(0x330C0C0D)
        : hasBattery
        ? const Color(0xE60C0C0D)
        : const Color(0x330C0C0D);
    final socColor = isDisabled
        ? const Color(0x330C0C0D)
        : (swapFlag == 0 ? const Color(0xFFFA4B51) : AppColors.primaryColor);

    final statusVisible =
        isDisabled || (!isDisabled && hasBattery && swapFlag == 1);
    final statusIcon = isDisabled
        ? 'assets/android/mipmap-xxhdpi/icon_cabin_unable.webp'
        : 'assets/android/mipmap-xxhdpi/icon_cabin_enable.webp';
    final statusText = isDisabled
        ? l10n.deviceDetailPortDisabled
        : l10n.deviceDetailPortReplaceable;
    final statusColor = isDisabled
        ? const Color(0xE60C0C0D)
        : AppColors.primaryColor;

    return Container(
      constraints: const BoxConstraints(minHeight: 194),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: portBadgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${cabin.portNo}',
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
                const Spacer(),
                if (statusVisible)
                  Row(
                    children: [
                      Image.asset(
                        statusIcon,
                        width: 14,
                        height: 14,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 1),
                      Text(
                        statusText,
                        style: TextStyle(fontSize: 12, color: statusColor),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (hasBattery)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CabinBatteryIcon(
                  soc: soc,
                  swapFlag: swapFlag,
                  isDisabled: isDisabled,
                ),
                const SizedBox(width: 2),
                Text('$soc%', style: TextStyle(fontSize: 17, color: socColor)),
              ],
            )
          else
            Center(
              child: Text(
                l10n.deviceDetailPortAvailable,
                style: const TextStyle(fontSize: 17, color: Color(0x800C0C0D)),
              ),
            ),
          const SizedBox(height: 12),
          if (hasBattery)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'SN: ${cabin.batterySn}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDisabled
                      ? const Color(0x330C0C0D)
                      : const Color(0x800C0C0D),
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Spacer(),
          if (canOperate)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: SizedBox(
                height: 36,
                child: TextButton.icon(
                  onPressed: onSetup,
                  icon: Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_setting.webp',
                    width: 15,
                    height: 15,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.settings_outlined,
                      size: 15,
                      color: Color(0xE60C0C0D),
                    ),
                  ),
                  label: Text(
                    l10n.deviceDetailPortSetup,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xE60C0C0D),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CabinBatteryIcon extends StatelessWidget {
  const _CabinBatteryIcon({
    required this.soc,
    required this.swapFlag,
    required this.isDisabled,
  });

  final int soc;
  final int swapFlag;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final bgImage = isDisabled
        ? 'assets/android/mipmap-xxhdpi/bg_battery_capacity_disable.webp'
        : 'assets/android/mipmap-xxhdpi/bg_battery_capacity.webp';
    final fillColor = isDisabled
        ? const Color(0x330C0C0D)
        : (swapFlag == 0 ? const Color(0xFFFA4B51) : const Color(0xFF0ABF83));
    final progress = (soc / 100.0).clamp(0.0, 1.0);

    return SizedBox(
      width: 22,
      height: 18,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final left = w * 0.2;
          final top = h * 0.3;
          final fillHeight = h * 0.4;
          final maxFillWidth = w * 0.5;

          return Stack(
            children: [
              Image.asset(bgImage, width: w, height: h, fit: BoxFit.fill),
              if (progress > 0)
                Positioned(
                  left: left,
                  top: top,
                  child: Container(
                    width: maxFillWidth * progress,
                    height: fillHeight,
                    color: fillColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FixedWidthRoundedUnderlineIndicator extends Decoration {
  const _FixedWidthRoundedUnderlineIndicator({
    required this.color,
    required this.width,
    required this.thickness,
    required this.bottomOffset,
    required this.radius,
  });

  final Color color;
  final double width;
  final double thickness;
  final double bottomOffset;
  final double radius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _FixedWidthRoundedUnderlinePainter(this);
  }
}

class _FixedWidthRoundedUnderlinePainter extends BoxPainter {
  _FixedWidthRoundedUnderlinePainter(this.decoration);

  final _FixedWidthRoundedUnderlineIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;
    final centerX = offset.dx + size.width / 2;
    final left = centerX - decoration.width / 2;
    final top =
        offset.dy +
        size.height -
        decoration.thickness -
        decoration.bottomOffset;
    final rect = Rect.fromLTWH(
      left,
      top,
      decoration.width,
      decoration.thickness,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(decoration.radius),
    );
    final paint = Paint()..color = decoration.color;
    canvas.drawRRect(rrect, paint);
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    this.value,
    this.showArrow = false,
    this.rowHeight = 26,
    this.labelFlex = 1,
    this.valueFlex = 1,
    this.showDivider = true,
    this.onTap,
  });

  final String label;
  final String? value;
  final bool showArrow;
  final double rowHeight;
  final int labelFlex;
  final int valueFlex;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: rowHeight,
        child: Row(
          children: [
            Expanded(
              flex: labelFlex,
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Color(0xE60C0C0D)),
              ),
            ),
            Expanded(
              flex: valueFlex,
              child: Text(
                value ?? '-',
                style: const TextStyle(fontSize: 15, color: Color(0x800C0C0D)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 6),
              Image.asset(
                'assets/android/mipmap-xxhdpi/arrow_next.png',
                width: 14,
                height: 14,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0x800C0C0D),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        onTap != null ? InkWell(onTap: onTap, child: content) : content,
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),
      ],
    );
  }
}

/// 文本编辑底部弹窗 (对标 Android dialog_edit_text1.xml)
class _EditTextSheet extends StatefulWidget {
  const _EditTextSheet({
    required this.title,
    required this.currentValue,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    required this.onSave,
  });

  final String title;
  final String currentValue;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String) onSave;

  @override
  State<_EditTextSheet> createState() => _EditTextSheetState();
}

class _EditTextSheetState extends State<_EditTextSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xE60C0C0D),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              decoration: InputDecoration(
                hintText: widget.hintText ?? '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => _controller.clear(),
                ),
              ),
            ),
          ),
          _buildButtons(l10n),
        ],
      ),
    );
  }

  Widget _buildButtons(dynamic l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F8FB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(
                    color: Color(0xB30C0C0D),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextButton(
                onPressed: () => widget.onSave(_controller.text),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 音量编辑底部弹窗 (对标 Android dialog_edit_volume.xml)
class _EditVolumeSheet extends StatefulWidget {
  const _EditVolumeSheet({
    required this.title,
    required this.currentValue,
    required this.onSave,
  });

  final String title;
  final int currentValue;
  final void Function(int) onSave;

  @override
  State<_EditVolumeSheet> createState() => _EditVolumeSheetState();
}

class _EditVolumeSheetState extends State<_EditVolumeSheet> {
  late int _volume;

  @override
  void initState() {
    super.initState();
    _volume = widget.currentValue.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 50,
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xE60C0C0D),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primaryColor,
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                      elevation: 2,
                    ),
                    overlayColor: AppColors.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Slider(
                    value: _volume.toDouble(),
                    min: 0,
                    max: 100,
                    onChanged: (v) => setState(() => _volume = v.round()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_volume',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xE60C0C0D),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F8FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        color: Color(0xB30C0C0D),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextButton(
                    onPressed: () => widget.onSave(_volume),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.save,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
