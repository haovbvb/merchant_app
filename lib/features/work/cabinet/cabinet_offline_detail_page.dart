import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_controller.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_fault_page.dart';

class CabinetOfflineDetailPage extends ConsumerStatefulWidget {
  const CabinetOfflineDetailPage({super.key});

  @override
  ConsumerState<CabinetOfflineDetailPage> createState() =>
      _CabinetOfflineDetailPageState();
}

class _CabinetOfflineDetailPageState
    extends ConsumerState<CabinetOfflineDetailPage> {
  final TextEditingController _snController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetOfflineProvider);
    final notifier = ref.read(cabinetOfflineProvider.notifier);
    final info = state.baseInfo;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetOfflineDetailTitle)),
      body: Padding(
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
                      notifier.load(sn);
                      notifier.loadLayout(sn);
                    },
              child: state.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.cabinetOfflineQueryAction),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: info == null
                  ? Center(child: Text(l10n.cabinetOfflineEmpty))
                  : DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: [
                              Tab(text: l10n.cabinetOfflineRealtimeTab),
                              Tab(text: l10n.cabinetOfflineWarehouseTab),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _RealtimeInfoTab(
                                  info: info,
                                  secretKey: state.secretKey,
                                ),
                                _WarehouseTab(
                                  state: state,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealtimeInfoTab extends StatelessWidget {
  const _RealtimeInfoTab({required this.info, this.secretKey});

  final CabinetDetailBaseInfoBean info;
  final String? secretKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      children: [
        _InfoTile(label: l10n.cabinetOfflineName, value: info.stationName),
        _InfoTile(label: l10n.cabinetOfflineSnLabel, value: info.stationSn),
        _InfoTile(label: l10n.cabinetOfflinePidLabel, value: info.stationPid),
        _InfoTile(label: l10n.cabinetOfflineAddressLabel, value: info.stationAddress),
        _InfoTile(
          label: l10n.cabinetOfflineStatusLabel,
          value: info.showOnlineStatus ?? info.online,
        ),
        _InfoTile(label: l10n.cabinetOfflineLastHbLabel, value: info.lastHbTime),
        _InfoTile(label: l10n.cabinetOfflineLockDevId, value: info.lockDevId),
        _InfoTile(label: l10n.cabinetOfflineLockIcId, value: info.lockIcId),
        _InfoTile(label: l10n.cabinetOfflineSecretKey, value: secretKey),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: info.stationSn == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CabinetOfflineFaultPage(
                        sn: info.stationSn ?? '',
                      ),
                    ),
                  ),
          child: Text(l10n.cabinetOfflineFaultEntry),
        ),
      ],
    );
  }
}

class _WarehouseTab extends StatelessWidget {
  const _WarehouseTab({required this.state});

  final CabinetOfflineState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.layoutLoading) {
      return const Center(child: CircularProgressIndicator());
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
                  _InfoTile(label: l10n.cabinetOfflinePidLabel, value: item.pid),
                  _InfoTile(label: l10n.cabinetOfflineStatusLabel, value: item.status),
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
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : '-')),
        ],
      ),
    );
  }
}
