import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_putaway_controller.dart';
import 'package:merchant_app/features/work/map/address_picker_page.dart';
import 'package:merchant_app/features/work/map/address_result.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

class CabinetPutawayPage extends ConsumerStatefulWidget {
  const CabinetPutawayPage({super.key});

  @override
  ConsumerState<CabinetPutawayPage> createState() => _CabinetPutawayPageState();
}

class _CabinetPutawayPageState extends ConsumerState<CabinetPutawayPage> {
  final _snController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _swapTimeController = TextEditingController();
  final _storeNumController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _swapTimeController.dispose();
    _storeNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetPutawayProvider);
    final notifier = ref.read(cabinetPutawayProvider.notifier);
    final cabinet = state.cabinet;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetPutawayTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: l10n.cabinetPutawaySn,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanSn,
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => notifier.queryCabinet(
                      _snController.text.trim(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: l10n.cabinetPutawayInfoTitle,
            content: cabinet == null
                ? l10n.cabinetPutawayInfoEmpty
                : '${l10n.cabinetPutawayName}: ${cabinet.stationName ?? '-'}\n'
                    '${l10n.cabinetPutawayModel}: ${cabinet.stationModel ?? '-'}\n'
                    '${l10n.cabinetPutawaySpec}: ${cabinet.stationModelName ?? '-'}',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _addressController,
            label: l10n.cabinetPutawayAddress,
            suffixIcon: IconButton(
              icon: const Icon(Icons.map_outlined),
              onPressed: () => _selectAddress(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _latController,
                  label: l10n.cabinetPutawayLatitude,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _lngController,
                  label: l10n.cabinetPutawayLongitude,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _swapTimeController,
                  label: l10n.cabinetPutawaySwapTime,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _storeNumController,
                  label: l10n.cabinetPutawayStoreNum,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.cabinetPutawayImages),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...state.images.map(
                (url) => InputChip(
                  label: Text(url),
                  onDeleted: () => notifier.removeImage(url),
                ),
              ),
              ActionChip(
                label: Text(l10n.cabinetPutawayAddImage),
                onPressed: state.uploading
                    ? null
                    : () => _pickImages(context, notifier, state.images.length),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.submitting
                ? null
                : () => _submit(context, notifier),
            child: state.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.cabinetPutawaySubmit),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          parseDeviceSn: true,
          deviceType: 3,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
  }

  Future<void> _selectAddress(BuildContext context) async {
    final initial = _buildAddressResult();
    final result = await Navigator.of(context).push<AddressResult>(
      MaterialPageRoute(builder: (_) => AddressPickerPage(initial: initial)),
    );
    if (!mounted || result == null) return;
    _addressController.text = result.address;
    _latController.text = result.latitude.toString();
    _lngController.text = result.longitude.toString();
  }

  AddressResult? _buildAddressResult() {
    final address = _addressController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (address.isEmpty || lat == null || lng == null) return null;
    return AddressResult(address: address, latitude: lat, longitude: lng);
  }

  Future<void> _pickImages(
    BuildContext context,
    CabinetPutawayNotifier notifier,
    int currentCount,
  ) async {
    final l10n = context.l10n;
    final picker = ImagePicker();
    final remaining = 4 - currentCount;
    if (remaining <= 0) {
      showToast(l10n.cabinetPutawayImageLimit);
      return;
    }
    final picks = await picker.pickMultiImage();
    if (!mounted || picks.isEmpty) return;
    for (final item in picks.take(remaining)) {
      final url = await notifier.uploadImage(item.path);
      if (url != null && url.isNotEmpty) {
        notifier.addImage(url);
      }
    }
  }

  Future<void> _submit(
    BuildContext context,
    CabinetPutawayNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final lat = double.tryParse(_latController.text.trim()) ?? 0;
    final lng = double.tryParse(_lngController.text.trim()) ?? 0;
    final swapTime = int.tryParse(_swapTimeController.text.trim()) ?? 0;
    final storeNum = int.tryParse(_storeNumController.text.trim()) ?? 0;
    final ok = await notifier.submit(
      sn: _snController.text.trim(),
      latitude: lat,
      longitude: lng,
      swapTime: swapTime,
      storeNum: storeNum,
      address: _addressController.text.trim(),
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.cabinetPutawaySuccess : l10n.cabinetPutawayFailed);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(content),
          ],
        ),
      ),
    );
  }
}
