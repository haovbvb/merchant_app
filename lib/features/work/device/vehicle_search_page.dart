import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/location_permission.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/data/models/near_by_vehicle.dart';
import 'package:merchant_app/features/work/device/device_detail_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleSearchPage extends StatefulWidget {
  const VehicleSearchPage({super.key});

  @override
  State<VehicleSearchPage> createState() => _VehicleSearchPageState();
}

class _VehicleSearchPageState extends State<VehicleSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _api = ApiService();
  final List<NearByVehicle> _items = [];
  final List<String> _history = [];
  bool _loading = false;
  bool _loadingHistory = true;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _initLocation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasHistory = _history.isNotEmpty;
    final hasResult = _items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vehicleSearchTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _search(value),
              decoration: InputDecoration(
                hintText: l10n.vehicleSearchHint,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_search.webp',
                    width: 20,
                    height: 20,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scan,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : hasResult
                      ? _VehicleSearchList(
                          items: _items,
                          latitude: _latitude,
                          longitude: _longitude,
                          onSelected: _openDetail,
                        )
                      : _loadingHistory
                          ? const Center(child: CircularProgressIndicator())
                          : hasHistory
                              ? _VehicleSearchHistory(
                                  title: l10n.deviceSearchHistoryTitle,
                                  clearLabel: l10n.deviceSearchHistoryClear,
                                  items: _history,
                                  onClear: _clearHistory,
                                  onSelected: (value) {
                                    _controller.text = value;
                                    _search(value);
                                  },
                                )
                              : _VehicleSearchEmpty(
                                  text: l10n.vehicleSearchEmpty,
                                ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initLocation() async {
    try {
      final permission = await ensureLocationPermission();
      if (!permission.granted) return;
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (_) {
      // 忽略定位失败，允许继续搜索。
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(StorageKeys.vehicleSearchHistory) ?? [];
    setState(() {
      _history
        ..clear()
        ..addAll(items);
      _loadingHistory = false;
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(StorageKeys.vehicleSearchHistory, _history);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.vehicleSearchHistory);
    setState(() => _history.clear());
  }

  Future<void> _addHistory(String value) async {
    final input = value.trim();
    if (input.isEmpty) return;
    setState(() {
      _history.remove(input);
      _history.insert(0, input);
      if (_history.length > 5) {
        _history.removeLast();
      }
    });
    await _saveHistory();
  }

  Future<void> _search(String value) async {
    final l10n = context.l10n;
    final input = value.trim();
    if (input.isEmpty) {
      setState(() => _items.clear());
      return;
    }
    final sn = ScanUtils.getDeviceSn(input).trim();
    if (sn.isEmpty) return;
    setState(() => _loading = true);
    final response = await _api.get<List<NearByVehicle>>(
      ApiPath.monitorNearByVehicle,
      queryParameters: {
        'latitude': _latitude ?? 0,
        'longitude': _longitude ?? 0,
        'count': 1000,
        'radius': 30000,
        'vehicleSn': sn,
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
    setState(() {
      _loading = false;
      _items
        ..clear()
        ..addAll(response.result ?? const []);
    });
    if (_items.isNotEmpty) {
      await _addHistory(input);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.vehicleSearchEmpty)),
      );
    }
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          parseDeviceSn: true,
          deviceType: 2,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _controller.text = result;
    await _search(result);
  }

  Future<void> _openDetail(String sn) async {
    if (sn.trim().isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailPage(
          initialSn: sn,
          initialDeviceType: 2,
        ),
      ),
    );
  }
}

class _VehicleSearchEmpty extends StatelessWidget {
  const _VehicleSearchEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_empty_search.png',
            width: 160,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _VehicleSearchHistory extends StatelessWidget {
  const _VehicleSearchHistory({
    required this.title,
    required this.clearLabel,
    required this.items,
    required this.onClear,
    required this.onSelected,
  });

  final String title;
  final String clearLabel;
  final List<String> items;
  final VoidCallback onClear;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: Text(clearLabel),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => ActionChip(
                  label: Text(item),
                  onPressed: () => onSelected(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _VehicleSearchList extends StatelessWidget {
  const _VehicleSearchList({
    required this.items,
    required this.latitude,
    required this.longitude,
    required this.onSelected,
  });

  final List<NearByVehicle> items;
  final double? latitude;
  final double? longitude;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final sn = item.sn ?? '-';
        final coordinates = _formatCoordinates(item.latitude, item.longitude);
        final distance = _formatDistance(
          latitude,
          longitude,
          item.latitude,
          item.longitude,
        );
        return Card(
          child: ListTile(
            leading: _VehicleImage(url: item.img),
            title: Text(sn),
            subtitle: Text(
              '${l10n.deviceDetailLocation}: $coordinates\n'
              '${l10n.vehicleSearchDistanceLabel}: $distance\n'
              '${l10n.vehicleSearchBindIdLabel}: ${item.cardNum ?? '-'}',
            ),
            trailing: item.needMaintenance == true
                ? const _WarningChip()
                : null,
            onTap: () => onSelected(sn),
          ),
        );
      },
    );
  }

  String _formatCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null || lat == 0 || lng == 0) return '-';
    return '${lat.toStringAsFixed(6)}  ${lng.toStringAsFixed(6)}';
  }

  String _formatDistance(
    double? lat,
    double? lng,
    double? itemLat,
    double? itemLng,
  ) {
    if (lat == null || lng == null || itemLat == null || itemLng == null) {
      return '-';
    }
    if (itemLat == 0 || itemLng == 0) return '-';
    final meters = Geolocator.distanceBetween(lat, lng, itemLat, itemLng);
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }
}

class _VehicleImage extends StatelessWidget {
  const _VehicleImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const Icon(Icons.directions_bike, size: 36);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.directions_bike),
      ),
    );
  }
}

class _WarningChip extends StatelessWidget {
  const _WarningChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '⚠',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
