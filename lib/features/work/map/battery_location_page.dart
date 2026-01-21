import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/home/widgets/vehicle_map.dart';
import 'package:merchant_app/features/work/map/battery_location_controller.dart';

class BatteryLocationPage extends ConsumerStatefulWidget {
  const BatteryLocationPage({super.key, this.initialSn});

  final String? initialSn;

  @override
  ConsumerState<BatteryLocationPage> createState() => _BatteryLocationPageState();
}

class _BatteryLocationPageState extends ConsumerState<BatteryLocationPage> {
  final TextEditingController _snController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSn?.trim() ?? '';
    if (initial.isNotEmpty) {
      _snController.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(batteryLocationProvider.notifier).queryBattery(initial);
      });
    }
  }

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(batteryLocationProvider);
    final notifier = ref.read(batteryLocationProvider.notifier);
    final detail = state.detail;
    final lat = detail?.latitude;
    final lng = detail?.longitude;
    final hasLocation = lat != null && lng != null;
    final markers = hasLocation
        ? {
            gmaps.Marker(
              markerId: const gmaps.MarkerId('battery'),
              position: gmaps.LatLng(lat, lng),
            ),
          }
        : <gmaps.Marker>{};
    final annotations = hasLocation
        ? {
            amaps.Annotation(
              annotationId: amaps.AnnotationId('battery'),
              position: amaps.LatLng(lat, lng),
            ),
          }
        : <amaps.Annotation>{};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batteryLocationTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: l10n.batteryLocationSn,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.loading
                ? null
                : () => notifier.queryBattery(_snController.text.trim()),
            child: state.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.batteryLocationQuery),
          ),
          const SizedBox(height: 16),
          if (!hasLocation)
            Text(l10n.batteryLocationEmpty)
          else
            SizedBox(
              height: 360,
              child: VehicleMap(
                latitude: lat,
                longitude: lng,
                markers: markers,
                annotations: annotations,
              ),
            ),
        ],
      ),
    );
  }
}
