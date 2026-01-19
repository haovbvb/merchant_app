import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/area_country.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/offline_register_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class OfflineUserRegisterPage extends ConsumerStatefulWidget {
  const OfflineUserRegisterPage({super.key});

  @override
  ConsumerState<OfflineUserRegisterPage> createState() =>
      _OfflineUserRegisterPageState();
}

class _OfflineUserRegisterPageState
    extends ConsumerState<OfflineUserRegisterPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _referrerController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(offlineRegisterProvider.notifier).loadAreas();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _referrerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(offlineRegisterProvider);
    final notifier = ref.read(offlineRegisterProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.offlineRegisterTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AreaPicker(
            l10n: l10n,
            selected: state.selectedArea,
            onTap: () => _showAreaSheet(context, state.areas, notifier),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: l10n.offlineRegisterPhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _codeController,
                  label: l10n.offlineRegisterSmsCode,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: state.sending
                    ? null
                    : () => _sendSms(context, notifier),
                child: Text(l10n.offlineRegisterSendCode),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _passwordController,
            label: l10n.offlineRegisterPassword,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() {
                _obscurePassword = !_obscurePassword;
              }),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _firstNameController,
            label: l10n.offlineRegisterFirstName,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _lastNameController,
            label: l10n.offlineRegisterLastName,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _usernameController,
            label: l10n.offlineRegisterUsername,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _birthdayController,
            label: l10n.offlineRegisterBirthday,
            readOnly: true,
            onTap: () => _pickBirthday(context),
            suffixIcon: const Icon(Icons.date_range),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: l10n.offlineRegisterEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _referrerController,
                  label: l10n.offlineRegisterReferrer,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanReferrer,
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.registering
                ? null
                : () => _submit(context, notifier),
            child: state.registering
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.offlineRegisterSubmit),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Future<void> _sendSms(
    BuildContext context,
    OfflineRegisterNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showToast(l10n.offlineRegisterPhoneRequired);
      return;
    }
    final ok = await notifier.sendSms(phone);
    if (!context.mounted) return;
    showToast(ok ? l10n.offlineRegisterSendSuccess : l10n.offlineRegisterSendFail);
  }

  Future<void> _submit(
    BuildContext context,
    OfflineRegisterNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final birthday = _birthdayController.text.trim();
    final email = _emailController.text.trim();
    final referId = _referrerController.text.trim();

    if (phone.isEmpty) {
      showToast(l10n.offlineRegisterPhoneRequired);
      return;
    }
    if (code.isEmpty) {
      showToast(l10n.offlineRegisterCodeRequired);
      return;
    }
    if (password.isEmpty || password.length < 8 || password.length > 16) {
      showToast(l10n.offlineRegisterPasswordInvalid);
      return;
    }
    if (firstName.isEmpty) {
      showToast(l10n.offlineRegisterFirstNameRequired);
      return;
    }
    if (lastName.isEmpty) {
      showToast(l10n.offlineRegisterLastNameRequired);
      return;
    }
    if (username.isEmpty) {
      showToast(l10n.offlineRegisterUsernameRequired);
      return;
    }
    if (email.isNotEmpty && !email.contains('@')) {
      showToast(l10n.offlineRegisterEmailInvalid);
      return;
    }

    final ok = await notifier.register(
      phone: phone,
      smsCode: code,
      password: password,
      firstName: firstName,
      lastName: lastName,
      username: username,
      birthday: birthday.isEmpty ? null : birthday,
      email: email.isEmpty ? null : email,
      referId: referId.isEmpty ? null : referId,
    );

    if (!context.mounted) return;
    showToast(ok ? l10n.offlineRegisterSuccess : l10n.offlineRegisterFailed);
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickBirthday(BuildContext context) async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    _birthdayController.text = DateFormat('yyyy/MM/dd').format(picked);
  }

  Future<void> _scanReferrer() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _referrerController.text = _parseReferrer(result);
  }

  String _parseReferrer(String value) {
    if (value.contains('cardNum=')) {
      final idx = value.indexOf('cardNum=');
      if (idx >= 0 && idx + 8 < value.length) {
        return value.substring(idx + 8);
      }
    }
    return value;
  }

  Future<void> _showAreaSheet(
    BuildContext context,
    List<AreaCountry> list,
    OfflineRegisterNotifier notifier,
  ) async {
    if (list.isEmpty) return;
    final selected = await showModalBottomSheet<AreaCountry>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: list
              .map(
                (area) => ListTile(
                  title: Text(area.country ?? '-'),
                  subtitle: Text(area.areaCode ?? ''),
                  onTap: () => Navigator.of(context).pop(area),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected == null) return;
    notifier.selectArea(selected);
  }
}

class _AreaPicker extends StatelessWidget {
  const _AreaPicker({
    required this.l10n,
    required this.selected,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final AreaCountry? selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = selected?.country ?? l10n.offlineRegisterAreaCode;
    final code = selected?.areaCode ?? '';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(code),
      trailing: const Icon(Icons.expand_more),
      onTap: onTap,
    );
  }
}
