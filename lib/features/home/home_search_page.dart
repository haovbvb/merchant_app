import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/data/models/near_by_vehicle.dart';
import 'package:merchant_app/features/work/device/device_detail_page_new.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSearchPage extends StatefulWidget {
  const HomeSearchPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  State<HomeSearchPage> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  static const int _vehicleCount = 1000;
  static const int _vehicleRadius = 30000;

  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _history = const <String>[];
  List<NearByVehicle> _results = const <NearByVehicle>[];
  bool _loadingHistory = true;
  bool _hasSearched = false;
  bool _searching = false;
  String _historyKey = StorageKeys.vehicleSearchHistory;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final account = prefs.getString(StorageKeys.loginAccount) ?? '';
    _historyKey = account.isNotEmpty
        ? '${StorageKeys.vehicleSearchHistory}_$account'
        : StorageKeys.vehicleSearchHistory;
    final items = prefs.getStringList(_historyKey) ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _history = items;
      _loadingHistory = false;
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _history);
  }

  Future<void> _addHistory(String value) async {
    final input = value.trim();
    if (input.isEmpty) return;
    setState(() {
      final next = List<String>.from(_history)
        ..remove(input)
        ..insert(0, input);
      _history = next.length > 5 ? next.sublist(0, 5) : next;
    });
    await _saveHistory();
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    if (!mounted) return;
    setState(() {
      _history = const <String>[];
    });
  }

  Future<void> _scan() async {
    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          allowManualInput: true,
          parseDeviceSn: true,
        ),
      ),
    );
    if (!mounted || raw == null || raw.trim().isEmpty) return;
    final sn = ScanUtils.getDeviceSn(raw).trim();
    if (sn.isEmpty) return;
    _searchController.text = sn;
    await _search(sn);
  }

  Future<void> _search(String value) async {
    final keyword = value.trim();
    if (keyword.isEmpty) {
      setState(() {
        _hasSearched = false;
        _results = const <NearByVehicle>[];
      });
      return;
    }

    setState(() {
      _searching = true;
      _hasSearched = true;
    });

    final response = await _api.get<List<NearByVehicle>>(
      ApiPath.monitorNearByVehicle,
      queryParameters: {
        'latitude': widget.latitude,
        'longitude': widget.longitude,
        'count': _vehicleCount,
        'radius': _vehicleRadius,
        'vehicleSn': keyword,
      },
      parser: (json) => (json as List<dynamic>?)
              ?.map(
                (item) => NearByVehicle.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const <NearByVehicle>[],
    );

    if (!mounted) return;
    final items = response.result ?? const <NearByVehicle>[];
    setState(() {
      _results = items;
      _searching = false;
    });
    if (items.isNotEmpty) {
      await _addHistory(keyword);
    }
  }

  String _distanceLabel(NearByVehicle vehicle) {
    final lat = vehicle.latitude;
    final lng = vehicle.longitude;
    if (lat == null || lng == null || lat == 0 || lng == 0) {
      return '-';
    }
    final meters = Geolocator.distanceBetween(
      widget.latitude,
      widget.longitude,
      lat,
      lng,
    );
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    }
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  String _addressLabel(NearByVehicle vehicle) {
    final address = (vehicle.address ?? '').trim();
    if (address.isNotEmpty) return address;
    final lat = vehicle.latitude;
    final lng = vehicle.longitude;
    if (lat == null || lng == null || lat == 0 || lng == 0) {
      return '-';
    }
    return '${lng.toStringAsFixed(6)} ${lat.toStringAsFixed(6)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: const Color(0xE60C0C0D),
                    ),
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.search,
                              size: 22,
                              color: Color(0x4D0C0C0D),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: l10n.deviceSearchHint,
                                  hintStyle: const TextStyle(
                                    color: Color(0x4D0C0C0D),
                                    fontSize: 14,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xE60C0C0D),
                                  fontSize: 14,
                                ),
                                onSubmitted: _search,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            if (_searchController.text.trim().isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _hasSearched = false;
                                    _results = const <NearByVehicle>[];
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.cancel,
                                    size: 18,
                                    color: Color(0x660C0C0D),
                                  ),
                                ),
                              ),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0x260C0C0D),
                            ),
                            IconButton(
                              onPressed: _scan,
                              icon: Image.asset(
                                'assets/android/mipmap-xxhdpi/icon_grey_scan.png',
                                width: 23,
                                height: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF2F4F7),
                  child: _loadingHistory
                      ? const SizedBox.shrink()
                      : !_hasSearched
                      ? _buildHistory(context)
                      : _buildResults(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    final l10n = context.l10n;
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.searchHistory,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xE60C0C0D),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _clearHistory,
                child: Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_search_delete.webp',
                  width: 22,
                  height: 22,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.delete_outline,
                    size: 22,
                    color: Color(0x660C0C0D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _history
                .map(
                  (item) => GestureDetector(
                    onTap: () {
                      _searchController.text = item;
                      _search(item);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xB30C0C0D),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final l10n = context.l10n;
    if (_searching) {
      return const SizedBox.shrink();
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/icon_empty_search.png',
              width: 90,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.deviceIssueSearchEmpty,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0x800C0C0D),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _results[index];
        return _HomeSearchVehicleCard(
          item: item,
          address: _addressLabel(item),
          distance: _distanceLabel(item),
          onTap: () {
            final sn = (item.sn ?? '').trim();
            if (sn.isEmpty) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DeviceDetailPageNew(
                  initialSn: sn,
                  readOnly: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HomeSearchVehicleCard extends StatelessWidget {
  const _HomeSearchVehicleCard({
    required this.item,
    required this.address,
    required this.distance,
    required this.onTap,
  });

  final NearByVehicle item;
  final String address;
  final String distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: (item.img ?? '').trim().isEmpty
                        ? Container(
                            color: AppColors.bgColor,
                            child: Image.asset(
                              'assets/android/mipmap-xxhdpi/icon_transport_vehicel.png',
                              width: 30,
                              height: 30,
                            ),
                          )
                        : Image.network(
                            item.img!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.bgColor,
                              child: Image.asset(
                                'assets/android/mipmap-xxhdpi/icon_transport_vehicel.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SN: ${item.sn ?? '-'}',
                        style: const TextStyle(
                          color: Color(0xE60C0C0D),
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (item.needMaintenance == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.danger),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.l10n.homeFilterNeedMaintenance,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0x26000000)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Binding ID: ${item.cardNum ?? '-'}',
                              style: const TextStyle(
                                color: Color(0x99000000),
                                fontSize: 12,
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
            const SizedBox(height: 14),
            Container(height: 0.5, color: const Color(0x26000000)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0x66000000),
                  size: 22,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0x99000000),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.navigation_outlined,
                  size: 20,
                  color: Color(0xE60C0C0D),
                ),
                const SizedBox(width: 3),
                Text(
                  distance,
                  style: const TextStyle(
                    color: Color(0xE60C0C0D),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}