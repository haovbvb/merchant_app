import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/pack.dart';
import 'package:merchant_app/features/work/map/address_picker_page.dart';
import 'package:merchant_app/features/work/map/address_result.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/rent_bind_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class RentBindPage extends ConsumerStatefulWidget {
  const RentBindPage({super.key});

  @override
  ConsumerState<RentBindPage> createState() => _RentBindPageState();
}

class _RentBindPageState extends ConsumerState<RentBindPage> {
  final _cardController = TextEditingController();
  final _snController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.listen<RentBindState>(rentBindProvider, (prev, next) {
      final user = next.user;
      if (user == null) return;
      _firstNameController.text = user.firstName ?? _firstNameController.text;
      _lastNameController.text = user.lastName ?? _lastNameController.text;
      _phoneController.text = user.phone ?? _phoneController.text;
      _idController.text = user.idNumber ?? _idController.text;
      _emailController.text = user.email ?? _emailController.text;
      _birthdayController.text = user.birthday ?? _birthdayController.text;
      _addressController.text = user.address ?? _addressController.text;
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _snController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(rentBindProvider);
    final notifier = ref.read(rentBindProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rentBindTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: l10n.rentBindDeviceSection),
          const SizedBox(height: 8),
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: l10n.rentBindDeviceSn,
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
                    onPressed: () => notifier.queryDevice(
                      _snController.text.trim(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _InfoCard(
            title: l10n.rentBindDeviceInfo,
            content: _deviceInfoText(l10n, state),
          ),
          const SizedBox(height: 12),
          _PackList(
            l10n: l10n,
            packs: state.deviceInfo?.packList ?? const [],
            selected: state.selectedPack,
            onSelected: notifier.selectPack,
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.rentBindUserSection),
          const SizedBox(height: 8),
          TextField(
            controller: _cardController,
            decoration: InputDecoration(
              labelText: l10n.rentBindCardNum,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => notifier.queryUser(
                  _cardController.text.trim(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _firstNameController,
            label: l10n.rentBindFirstName,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _lastNameController,
            label: l10n.rentBindLastName,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: l10n.rentBindPhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _idController,
            label: l10n.rentBindIdNumber,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: l10n.rentBindEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _birthdayController,
            label: l10n.rentBindBirthday,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _addressController,
            label: l10n.rentBindAddress,
            suffixIcon: IconButton(
              icon: const Icon(Icons.map_outlined),
              onPressed: () => _selectAddress(context),
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.rentBindAttachment),
          const SizedBox(height: 8),
          Row(
            children: [
              _UploadChip(
                label: l10n.rentBindCardImage,
                value: state.cardImgUrl,
                onTap: () => _pickImage(
                  context,
                  notifier,
                  notifier.setCardImgUrl,
                ),
              ),
              const SizedBox(width: 8),
              _UploadChip(
                label: l10n.rentBindPersonImage,
                value: state.personImgUrl,
                onTap: () => _pickImage(
                  context,
                  notifier,
                  notifier.setPersonImgUrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.rentBindPaymentSection),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.rentBindPayCash),
                selected: state.paySource == 1,
                onSelected: (_) => notifier.updatePaySource(1),
              ),
              ChoiceChip(
                label: Text(l10n.rentBindPayOnline),
                selected: state.paySource == 2,
                onSelected: (_) => notifier.updatePaySource(2),
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
                : Text(l10n.rentBindSubmit),
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

  Future<void> _selectAddress(BuildContext context) async {
    final result = await Navigator.of(context).push<AddressResult>(
      MaterialPageRoute(builder: (_) => const AddressPickerPage()),
    );
    if (!mounted || result == null || result.address.isEmpty) return;
    _addressController.text = result.address;
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(parseDeviceSn: true),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
  }

  String _deviceInfoText(AppLocalizations l10n, RentBindState state) {
    final device = state.deviceInfo;
    if (device == null) return l10n.rentBindDeviceEmpty;
    if (device.batteryVo != null) {
      final battery = device.batteryVo!;
      return 'SN: ${battery.sn ?? '-'}\n${battery.model ?? '-'} ${battery.spec ?? ''}';
    }
    if (device.carVo != null) {
      final car = device.carVo!;
      return 'SN: ${car.sn ?? '-'}\n${car.model} ${car.spec}';
    }
    return l10n.rentBindDeviceEmpty;
  }

  Future<void> _pickImage(
    BuildContext context,
    RentBindNotifier notifier,
    ValueChanged<String?> onSuccess,
  ) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final url = await notifier.uploadCardImage(picked.path);
    if (url != null) {
      onSuccess(url);
    }
  }

  Future<void> _submit(
    BuildContext context,
    RentBindNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final ok = await notifier.submit(
      address: _addressController.text.trim(),
      birthday: _birthdayController.text.trim(),
      cardNum: _cardController.text.trim(),
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      idNumber: _idController.text.trim(),
      phone: _phoneController.text.trim(),
      deviceSn: _snController.text.trim(),
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.rentBindSuccess : l10n.rentBindFailed);
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

class _PackList extends StatelessWidget {
  const _PackList({
    required this.l10n,
    required this.packs,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final List<Pack> packs;
  final Pack? selected;
  final ValueChanged<Pack> onSelected;

  @override
  Widget build(BuildContext context) {
    if (packs.isEmpty) {
      return Text(l10n.rentBindPackEmpty);
    }
    return Column(
      children: packs
          .map(
            (pack) => RadioListTile<Pack>(
              value: pack,
              groupValue: selected,
              onChanged: (value) {
                if (value != null) onSelected(value);
              },
              title: Text(pack.infoName ?? '-'),
              subtitle: Text(
                '${l10n.rentBindPackAmount}: ${pack.packageAmount ?? '-'}',
              ),
            ),
          )
          .toList(),
    );
  }
}

class _UploadChip extends StatelessWidget {
  const _UploadChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(value == null || value!.isEmpty ? label : '✓ $label'),
      onPressed: onTap,
    );
  }
}
