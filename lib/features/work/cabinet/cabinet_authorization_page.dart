import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/cabinet_authorization_list.dart';
import 'package:merchant_app/data/models/user_authorization_list.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_authorization_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

/// 柜机授权运维主页面 - Station operation authorization
class CabinetAuthorizationPage extends ConsumerStatefulWidget {
  const CabinetAuthorizationPage({super.key});

  @override
  ConsumerState<CabinetAuthorizationPage> createState() =>
      _CabinetAuthorizationPageState();
}

class _CabinetAuthorizationPageState
    extends ConsumerState<CabinetAuthorizationPage> {
  CabinetAuthorization? _selectedStation;
  UserAuthorizationBean? _selectedPerson;
  final DateTime _beginTime = DateTime.now();
  final DateTime _endTime = DateTime.now().add(const Duration(hours: 24));

  String _formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  Future<void> _selectStation() async {
    final result = await Navigator.of(context).push<CabinetAuthorization>(
      MaterialPageRoute(builder: (_) => const _SelectStationPage()),
    );
    if (result != null) {
      setState(() => _selectedStation = result);
    }
  }

  Future<void> _selectPerson() async {
    final sn = _selectedStation?.stationSn ?? '';
    final result = await Navigator.of(context).push<UserAuthorizationBean>(
      MaterialPageRoute(builder: (_) => _SelectPersonPage(sn: sn)),
    );
    if (result != null) {
      setState(() => _selectedPerson = result);
    }
  }

  Future<void> _confirmAuthorization() async {
    final l10n = context.l10n;
    if (_selectedStation == null) {
      showToast(l10n.cabinetAuthSelectStationRequired);
      return;
    }
    if (_selectedPerson == null) {
      showToast(l10n.cabinetAuthSelectPersonRequired);
      return;
    }

    final notifier = ref.read(cabinetAuthorizationProvider.notifier);
    final ok = await notifier.authorize(
      sn: _selectedStation!.stationSn ?? '',
      accountNo: _selectedPerson!.accountNo ?? '',
      beginTime: _formatDateTime(_beginTime),
      endTime: _formatDateTime(_endTime),
    );
    if (!mounted) return;
    showToast(ok ? l10n.cabinetAuthSuccess : l10n.cabinetAuthFailed);
  }

  Future<void> _viewRecords() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _AuthorizedRecordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetAuthorizationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetAuthTitle)),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Station 和 Authorized person 选择区域
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Station
                _SelectField(
                  label: l10n.cabinetAuthStationLabel,
                  value: _selectedStation?.stationSn,
                  placeholder: l10n.cabinetAuthSelectStation,
                  onTap: _selectStation,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // Authorized person
                _SelectField(
                  label: l10n.cabinetAuthPersonLabel,
                  value: _selectedPerson != null
                      ? '${_selectedPerson!.username ?? ''} (${_selectedPerson!.phone ?? ''})'
                      : null,
                  placeholder: l10n.cabinetAuthSelectPerson,
                  onTap: _selectPerson,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Authorization time
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cabinetAuthTimeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatDateTime(_beginTime),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Text(' — ', style: TextStyle(color: Colors.black54)),
                    Expanded(
                      child: Text(
                        _formatDateTime(_endTime),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: state.submitting ? null : _confirmAuthorization,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state.submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.cabinetAuthConfirmButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _viewRecords,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.black26),
                    ),
                    child: Text(
                      l10n.cabinetAuthRecordButton,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 选择字段组件
class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: TextStyle(
                      fontSize: 15,
                      color: value != null ? Colors.black87 : Colors.black38,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 选择柜机页面
class _SelectStationPage extends ConsumerStatefulWidget {
  const _SelectStationPage();

  @override
  ConsumerState<_SelectStationPage> createState() => _SelectStationPageState();
}

class _SelectStationPageState extends ConsumerState<_SelectStationPage> {
  final _searchController = TextEditingController();
  CabinetAuthorization? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cabinetAuthorizationProvider.notifier).queryCabinets('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (result != null && result.isNotEmpty) {
      _searchController.text = result;
      _search();
    }
  }

  void _search() {
    ref
        .read(cabinetAuthorizationProvider.notifier)
        .queryCabinets(_searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetAuthorizationProvider);
    final items = state.cabinetList?.list ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetAuthSelectStationTitle)),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: l10n.cabinetAuthStationSearchHint,
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.search, color: Colors.black38),
                suffixIcon: IconButton(
                  onPressed: _scanQRCode,
                  icon: AppIcons.scanIcon(),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Station list
          Expanded(
            child: state.loadingCabinet
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected =
                          _selected?.stationSn == item.stationSn;

                      return _StationCard(
                        station: item,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selected = item);
                          Navigator.of(context).pop(item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 柜机卡片
class _StationCard extends StatelessWidget {
  const _StationCard({
    required this.station,
    required this.isSelected,
    required this.onTap,
  });

  final CabinetAuthorization station;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOnline = station.onlineStatus == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with image, name, status, SN
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Station image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade100,
                      child: station.standardImg != null &&
                              station.standardImg!.isNotEmpty
                          ? Image.network(
                              station.standardImg!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.electrical_services,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.electrical_services,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.showOnlineStatus ?? 'Station',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: [
                            // Online/Offline badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isOnline ? Colors.green : Colors.red,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isOnline
                                        ? Icons.wifi
                                        : Icons.wifi_off,
                                    size: 12,
                                    color: isOnline ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isOnline ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          isOnline ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SN badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'SN: ${station.stationSn ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Checkmark
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Address
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      station.stationAddress ?? '-',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Port statistics
              Row(
                children: [
                  _PortStat(
                    label: l10n.cabinetAuthAllPort,
                    value: '${station.storeNum ?? 0}',
                  ),
                  _PortStat(
                    label: l10n.cabinetAuthFaultPort,
                    value: '${station.damageNum ?? 0}',
                    valueColor: Colors.red,
                  ),
                  _PortStat(
                    label: l10n.cabinetAuthDisablePort,
                    value: '${station.offlineNum ?? 0}',
                  ),
                  _PortStat(
                    label: l10n.cabinetAuthSwapStandard,
                    value: station.standardSwapTime ?? '-',
                    suffix: 'times/day',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 端口统计
class _PortStat extends StatelessWidget {
  const _PortStat({
    required this.label,
    required this.value,
    this.valueColor,
    this.suffix,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
                if (suffix != null)
                  Text(
                    ' $suffix',
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 选择授权人员页面
class _SelectPersonPage extends ConsumerStatefulWidget {
  const _SelectPersonPage({required this.sn});

  final String sn;

  @override
  ConsumerState<_SelectPersonPage> createState() => _SelectPersonPageState();
}

class _SelectPersonPageState extends ConsumerState<_SelectPersonPage> {
  final _searchController = TextEditingController();
  UserAuthorizationBean? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(cabinetAuthorizationProvider.notifier)
          .queryUsers(widget.sn, '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    ref
        .read(cabinetAuthorizationProvider.notifier)
        .queryUsers(widget.sn, _searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetAuthorizationProvider);
    final items = state.userList?.list ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetAuthSelectPersonTitle)),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: l10n.cabinetAuthPersonSearchHint,
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.search, color: Colors.black38),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Person list
          Expanded(
            child: state.loadingUsers
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected =
                          _selected?.accountNo == item.accountNo;

                      return _PersonCard(
                        person: item,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selected = item);
                          Navigator.of(context).pop(item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 人员卡片
class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.person,
    required this.isSelected,
    required this.onTap,
  });

  final UserAuthorizationBean person;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  ClipOval(
                    child: Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey.shade200,
                      child: person.avatar != null && person.avatar!.isNotEmpty
                          ? Image.network(
                              person.avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.username ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.copy,
                              size: 14,
                              color: Colors.black38,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              person.phone ?? '-',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Checkmark
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),
              Text(
                person.remark ?? l10n.cabinetAuthWorkAccount,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 授权记录页面
class _AuthorizedRecordPage extends ConsumerStatefulWidget {
  const _AuthorizedRecordPage();

  @override
  ConsumerState<_AuthorizedRecordPage> createState() =>
      _AuthorizedRecordPageState();
}

class _AuthorizedRecordPageState extends ConsumerState<_AuthorizedRecordPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cabinetAuthorizationProvider.notifier).queryRecords('', '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetAuthorizationProvider);
    final items = state.recordList?.list ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetAuthRecordTitle)),
      backgroundColor: const Color(0xFFF5F5F5),
      body: state.loadingRecords
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _RecordCard(record: item);
              },
            ),
    );
  }
}

/// 记录卡片
class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sn = record['sn']?.toString() ?? '-';
    final authTime = record['createTime']?.toString() ?? '-';
    final person = record['accountNo']?.toString() ?? '-';
    final beginTime = record['beginTime']?.toString() ?? '-';
    final endTime = record['endTime']?.toString() ?? '-';
    final img = record['standardImg']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade100,
                    child: img != null && img.isNotEmpty
                        ? Image.network(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.electrical_services,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.electrical_services,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SN: $sn',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.cabinetAuthTimeLabel}: $authTime',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Authorized person
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.cabinetAuthPersonLabel,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  person,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
            const Divider(height: 24),

            // Validity period
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.cabinetAuthValidityPeriod,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  '$beginTime ~ $endTime',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
