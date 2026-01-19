import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_controller.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_success_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class MaintenanceBookPage extends ConsumerStatefulWidget {
  const MaintenanceBookPage({super.key});

  @override
  ConsumerState<MaintenanceBookPage> createState() =>
      _MaintenanceBookPageState();
}

class _MaintenanceBookPageState extends ConsumerState<MaintenanceBookPage> {
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(maintenanceBookProvider);
    final notifier = ref.read(maintenanceBookProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.maintenanceBookTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: l10n.maintenanceSnLabel,
              hintText: l10n.maintenanceSnHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanSn,
              ),
            ),
            onChanged: notifier.updateSn,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.loading ? null : notifier.fetchAppointment,
              child: state.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.maintenanceFetchInfo),
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: l10n.maintenanceVehicleInfo,
            content: state.appointment == null
                ? l10n.maintenanceEmptyInfo
                : _buildVehicleInfo(l10n, state),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: l10n.maintenanceNoteLabel,
              hintText: l10n.maintenanceNoteHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
            onChanged: notifier.updateNote,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.submitting
                  ? null
                  : () async {
                      final success = await notifier.submitMaintenance();
                      if (!context.mounted || !success) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MaintenanceSuccessPage(),
                        ),
                      );
                    },
              child: state.submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.maintenanceSubmit),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    ref.read(maintenanceBookProvider.notifier).updateSn(result);
  }

  String _buildVehicleInfo(AppLocalizations l10n, MaintenanceBookState state) {
    final info = state.appointment;
    if (info == null) return '-';
    final name =
        '${info.firstName ?? ''} ${info.lastName ?? ''}'.trim();
    return '${l10n.maintenanceVehicleSn}: ${info.sn ?? '-'}\n'
        '${l10n.maintenanceVehicleModel}: ${info.carModel ?? '-'}\n'
        '${l10n.maintenanceVehicleCardNum}: ${info.cardNum ?? '-'}\n'
        '${l10n.maintenanceVehicleOwner}: ${name.isEmpty ? '-' : name}\n'
        '${l10n.maintenanceVehiclePhone}: ${info.phone ?? '-'}';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
