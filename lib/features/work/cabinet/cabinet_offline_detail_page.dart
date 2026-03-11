import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/data/models/cabinet_cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_ble_client.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_controller.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_fault_page.dart';
import 'package:merchant_app/features/work/device/widgets/cabinet_port_detail_section.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class CabinetOfflineDetailPage extends ConsumerStatefulWidget {
  const CabinetOfflineDetailPage({super.key, this.initialSn});

  /// Optional initial SN to load on page open.
  final String? initialSn;

  @override
  ConsumerState<CabinetOfflineDetailPage> createState() =>
      _CabinetOfflineDetailPageState();
}

class _CabinetOfflineDetailPageState
    extends ConsumerState<CabinetOfflineDetailPage> {
  final TextEditingController _snController = TextEditingController();
  late final CabinetBleClient _bleClient;
  bool _noPermissionHandled = false;
  String _warehousePortFilter = 'all';
  String _bleBoundSn = '';
  String _bleBoundSecret = '';
  String? _pendingSuccessToast;
  String? _pendingFailedToast;
  VoidCallback? _pendingSuccessAction;
  CabinetBleConnectionPhase _blePhase = CabinetBleConnectionPhase.idle;

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
        await _bleClient.queryDeviceInfo();
        await _bleClient.queryAllData();
      },
      onJsonData: _handleBleJsonData,
      onError: _handleBleError,
    );
    if (widget.initialSn != null && widget.initialSn!.isNotEmpty) {
      _snController.text = widget.initialSn!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queryWithSn(widget.initialSn!);
      });
    }
  }

  void _showNotManagerDialog(CabinetDetailBaseInfoBean info) {
    final l10n = context.l10n;
    String managerName = '';
    String managerPhone = '';
    final rawList = info.stationManagerList;
    if (rawList.isNotEmpty) {
      managerName = rawList.first['showName']?.toString() ?? '';
      managerPhone = rawList.first['phone']?.toString() ?? '';
    }
    final areaCode = AuthSession.instance.current?.areaCode ?? '';
    if (areaCode.isNotEmpty && managerPhone.isNotEmpty) {
      managerPhone = '$areaCode $managerPhone';
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 310,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    l10n.cabinetNotManagerTips,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.deviceDetailResponsibleLabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          managerName,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.cabinetNotManagerPhone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          managerPhone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0B61D9),
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 24),
                const Divider(height: 1),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      final navigator = Navigator.of(context);
                      if (navigator.canPop()) {
                        navigator.pop();
                      } else {
                        AppRouter.goHome();
                      }
                    },
                    child: Text(
                      l10n.confirm,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _queryWithSn(String sn) {
    final notifier = ref.read(cabinetOfflineProvider.notifier);
    notifier.load(sn);
    notifier.loadLayout(sn);
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

    if (msgType == CabinetDataType.controlResponse) {
      final ok = ((map['result'] as num?)?.toInt() ?? 0) == 1;
      showToast(
        ok
            ? (_pendingSuccessToast ?? l10n.deviceDetailToggleSuccess)
            : (_pendingFailedToast ?? l10n.deviceDetailToggleFailed),
      );
      if (ok) {
        _pendingSuccessAction?.call();
        _bleClient.queryAllData();
      }
      _pendingSuccessToast = null;
      _pendingFailedToast = null;
      _pendingSuccessAction = null;
      return;
    }

    final resultList = map['resultList'];
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

  @override
  void dispose() {
    _bleClient.stop();
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetOfflineProvider);
    final info = state.baseInfo;
    final canOperate = (info?.hasPermission ?? 0) == 1;

    _tryStartBle(state);

    if (info != null && !canOperate && !_noPermissionHandled) {
      _noPermissionHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showNotManagerDialog(info);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(l10n.cabinetOfflineDetailTitle),
        actions: [
          if (info != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final sn = _snController.text.trim();
                if (sn.isNotEmpty) _queryWithSn(sn);
              },
            ),
        ],
      ),
      body: info == null
          ? _buildInputView(state)
          : _buildDetailView(state, info, canOperate),
    );
  }

  Widget _buildInputView(CabinetOfflineState state) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: l10n.cabinetOfflineSnLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.loading
                ? null
                : () {
                    final sn = _snController.text.trim();
                    final notifier = ref.read(cabinetOfflineProvider.notifier);
                    notifier.load(sn);
                    notifier.loadLayout(sn);
                  },
            child: Text(l10n.cabinetOfflineQueryAction),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView(
    CabinetOfflineState state,
    CabinetDetailBaseInfoBean info,
    bool canOperate,
  ) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildHeader(info, state, canOperate),
          Material(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.black05Text,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
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
                  info: info,
                  state: state,
                  onEditSwapThreshold: () => _showEditSwapThreshold(info),
                  onEditApn: () => _showEditApn(info),
                  onEditVolume: () => _showEditVolume(info),
                  onEditPlatformUrl: () => _showEditPlatformUrl(info),
                ),
                _WarehouseTab(
                  state: state,
                  canOperate: canOperate,
                  selectedFilter: _warehousePortFilter,
                  onFilterChanged: (value) {
                    setState(() => _warehousePortFilter = value);
                  },
                  onOpenDoor: _openCabinDoor,
                  onToggleEnable: _toggleCabinEnable,
                ),
                _RealtimeInfoTab(info: info),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    CabinetDetailBaseInfoBean info,
    CabinetOfflineState state,
    bool canOperate,
  ) {
    final l10n = context.l10n;
    final isOnline = info.online == '1';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF2F2F2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                clipBehavior: Clip.antiAlias,
                child: info.standardImg != null && info.standardImg!.isNotEmpty
                    ? Image.network(
                        info.standardImg!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.battery_charging_full,
                          size: 32,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : const Icon(
                        Icons.battery_charging_full,
                        size: 32,
                        color: AppColors.primaryColor,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.stationName ?? info.stationModelName ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isOnline
                                  ? AppColors.primaryColor
                                  : const Color(0xFFFA4B51),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOnline ? Icons.wifi : Icons.wifi_off,
                                size: 14,
                                color: isOnline
                                    ? AppColors.primaryColor
                                    : const Color(0xFFFA4B51),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isOnline
                                      ? AppColors.primaryColor
                                      : const Color(0xFFFA4B51),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _bleStatusColor(state.bleConnected),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _bleStatusLabel(l10n, state.bleConnected),
                            style: TextStyle(
                              fontSize: 12,
                              color: _bleStatusColor(state.bleConnected),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: !canOperate || state.operating
                      ? null
                      : () => _showRestartDialog(),
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: Text(l10n.cabinetOfflineRestart),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: const Color(0xFFF6F8FC),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: !canOperate || state.operating
                      ? null
                      : () => _showOpenDoorDialog(),
                  icon: const Icon(Icons.door_front_door_outlined, size: 18),
                  label: Text(l10n.cabinetOfflineOpenDoor),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: const Color(0xFFF6F8FC),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
            ],
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
        currentValue: currentValue,
        keyboardType: TextInputType.text,
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
        currentValue: currentValue,
        keyboardType: TextInputType.url,
        onSave: (value) {
          if (value.isEmpty) {
            showToast(l10n.cabinetOfflineEnterPlatformUrl);
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
    if (bleConnected || _blePhase == CabinetBleConnectionPhase.connected) {
      return l10n.cabinetOfflineBleConnected;
    }
    switch (_blePhase) {
      case CabinetBleConnectionPhase.scanning:
        return l10n.cabinetOfflineBleScanning;
      case CabinetBleConnectionPhase.connecting:
        return l10n.cabinetOfflineBleConnecting;
      case CabinetBleConnectionPhase.reconnecting:
        return l10n.cabinetOfflineBleReconnecting;
      case CabinetBleConnectionPhase.connected:
        return l10n.cabinetOfflineBleConnected;
      case CabinetBleConnectionPhase.idle:
        return l10n.cabinetOfflineBleDisconnected;
    }
  }

  Color _bleStatusColor(bool bleConnected) {
    if (bleConnected || _blePhase == CabinetBleConnectionPhase.connected) {
      return const Color(0xFF0B61D9);
    }
    switch (_blePhase) {
      case CabinetBleConnectionPhase.scanning:
      case CabinetBleConnectionPhase.connecting:
      case CabinetBleConnectionPhase.reconnecting:
        return const Color(0xFFFA8C16);
      case CabinetBleConnectionPhase.connected:
        return const Color(0xFF0B61D9);
      case CabinetBleConnectionPhase.idle:
        return const Color(0xFF6C7180);
    }
  }
}

class _DeviceInfoTab extends StatelessWidget {
  const _DeviceInfoTab({
    required this.info,
    required this.state,
    required this.onEditSwapThreshold,
    required this.onEditApn,
    required this.onEditVolume,
    required this.onEditPlatformUrl,
  });

  final CabinetDetailBaseInfoBean info;
  final CabinetOfflineState state;
  final VoidCallback onEditSwapThreshold;
  final VoidCallback onEditApn;
  final VoidCallback onEditVolume;
  final VoidCallback onEditPlatformUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const SizedBox(height: 4),
        // First card: read-only info
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineSoftwareVersion,
                value: state.softwareVersion,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineBackupPowerStatus,
                value: state.backupPowerStatus,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineSlotCount,
                value: info.storeNum?.toString(),
              ),
              _InfoTile(
                label: l10n.cabinetOfflineBatteryInSlot,
                value: state.batteryInSlot?.toString(),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Second card: editable items with right arrow
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineSwapThreshold,
                value: info.swapThreshold?.toString(),
                showArrow: true,
                onTap: onEditSwapThreshold,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineApn,
                value: info.apn,
                showArrow: true,
                onTap: onEditApn,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineVolume,
                value: info.volume?.toString(),
                showArrow: true,
                onTap: onEditVolume,
              ),
              _InfoTile(
                label: l10n.cabinetOfflinePlatformUrl,
                value: info.platformUrl,
                showArrow: true,
                showDivider: false,
                onTap: onEditPlatformUrl,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RealtimeInfoTab extends ConsumerWidget {
  const _RealtimeInfoTab({required this.info});

  final CabinetDetailBaseInfoBean info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetOfflineProvider);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const SizedBox(height: 4),
        // Card 1: 通讯相关
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineGsmSignal,
                value: state.gsmSignal,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineCharger,
                value: state.chargerStatus ?? l10n.cabinetOfflineYes,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineCtrlSystem,
                value: state.ctrlSystemStatus ?? l10n.cabinetOfflineYes,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Card 2: 电气数据
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineOMDoor,
                value: state.omDoorStatus,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineTotalVoltage,
                value: state.totalVoltage,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineTotalCurrent,
                value: state.totalCurrent,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineTemperature,
                value: state.temperature,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineElectricityMeter,
                value: state.electricityMeter,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Card 3: 报警状态
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineSmokeAlarm,
                value: state.smokeAlarmStatus ?? l10n.cabinetOfflineNoAlarm,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineWaterAlarm,
                value: state.waterAlarmStatus ?? l10n.cabinetOfflineNoAlarm,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineFanStatus,
                value: state.fanStatus,
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
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onOpenDoor,
    required this.onToggleEnable,
  });

  final CabinetOfflineState state;
  final bool canOperate;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final Future<void> Function(CabinetCabin cabin) onOpenDoor;
  final Future<void> Function(CabinetCabin cabin) onToggleEnable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // 优先显示蓝牙获取的仓位数据
    if (state.cabins.isNotEmpty) {
      final viewPorts = state.cabins
          .map(
            (c) => CabinetPortViewItem(
              portNo: c.portNo,
              status: c.status,
              batteryStatus: c.batteryStatus,
              batterySoc: c.batterySoc,
              swapFlag: c.swapFlag,
              batterySn: c.batterySn,
            ),
          )
          .toList();
      return CabinetPortDetailSection(
        l10n: l10n,
        ports: viewPorts,
        selectedFilter: selectedFilter,
        onFilterChanged: onFilterChanged,
        emptyText: l10n.cabinetOfflineCabinEmpty,
        loading: false,
        showSetup: canOperate,
        onSetup: (item) {
          final target = state.cabins.where((c) => c.portNo == item.portNo);
          if (target.isEmpty) return;
          _showCabinOperateSheet(context, target.first);
        },
      );
    }

    // 否则显示布局历史信息
    if (state.layoutLoading) {
      return const Center(child: SizedBox.shrink());
    }
    final items = state.layoutInfo?.list ?? const [];
    if (items.isEmpty) {
      return Center(child: Text(l10n.cabinetOfflineWarehouseEmpty));
    }
    return ListView(
      children: [
        _InfoTile(
          label: l10n.cabinetOfflineWarehouseTotal,
          value: state.layoutInfo?.total.toString(),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoTile(label: l10n.cabinetOfflineSnLabel, value: item.sn),
                  _InfoTile(
                    label: l10n.cabinetOfflinePidLabel,
                    value: item.pid,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineStatusLabel,
                    value: item.status,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseCityCodeLabel,
                    value: item.cityCode?.toString(),
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseLatLabel,
                    value: item.latitude,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseLngLabel,
                    value: item.longitude,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseOpPhoneLabel,
                    value: item.opPhone,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseOpNameLabel,
                    value: item.opName,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseCreateTimeLabel,
                    value: item.createTime?.toString(),
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineAddressLabel,
                    value: item.address,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCabinOperateSheet(BuildContext context, CabinetCabin cabin) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.cabinetOfflineCabinSlot(cabin.portNo),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: Center(child: Text(l10n.deviceDetailPortOpenShort)),
              onTap: !canOperate || state.operating
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      final confirmed = await ConfirmDialog.show(
                        context: context,
                        message: l10n.deviceDetailPortOpenConfirm(cabin.portNo),
                        cancelText: l10n.cancel,
                        confirmText: l10n.confirm,
                      );
                      if (!confirmed) return;
                      await onOpenDoor(cabin);
                    },
            ),
            ListTile(
              title: Center(
                child: Text(
                cabin.isEnabled
                    ? l10n.deviceDetailPortDisableShort
                    : l10n.cabinetOfflineCabinEnable,
                ),
              ),
              onTap: !canOperate || state.operating
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
            ),
            ListTile(
              title: Center(child: Text(l10n.cabinetOfflineCabinCheckFault)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CabinetOfflineFaultPage(
                      sn: state.baseInfo?.stationSn ?? '',
                      port: cabin.portNo,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    this.value,
    this.showArrow = false,
    this.showDivider = true,
    this.onTap,
  });

  final String label;
  final String? value;
  final bool showArrow;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
          ),
          Text(
            value?.isNotEmpty == true ? value! : '-',
            style: TextStyle(
              fontSize: 14,
              color: showArrow
                  ? const Color(0xFF666666)
                  : const Color(0xFF999999),
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
          if (showArrow) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF999999)),
          ],
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        onTap != null ? InkWell(onTap: onTap, child: content) : content,
        if (showDivider)
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}

/// 文本编辑底部弹窗 (对标 Android dialog_edit_text1.xml)
class _EditTextSheet extends StatefulWidget {
  const _EditTextSheet({
    required this.title,
    required this.currentValue,
    this.keyboardType,
    required this.onSave,
  });

  final String title;
  final String currentValue;
  final TextInputType? keyboardType;
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
              decoration: InputDecoration(
                hintText: '',
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
