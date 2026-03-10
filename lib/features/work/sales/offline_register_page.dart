import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
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
  String? _birthdayValue;

  bool _obscurePassword = true;

  bool get _canSubmit {
    return _phoneController.text.trim().isNotEmpty &&
        _codeController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().isNotEmpty;
  }

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
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Header icon and title
                  _buildHeader(l10n),
                  const SizedBox(height: 24),

                  // Card 1: Phone, Code, Password
                  _buildCard(
                    children: [
                      _buildPhoneField(l10n, state, notifier),
                      _buildDivider(),
                      _buildCodeField(l10n, state, notifier),
                      _buildDivider(),
                      _buildPasswordField(l10n),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card 2: First Name, Last Name, Account
                  _buildCard(
                    children: [
                      _buildInputField(
                        label: l10n.offlineRegisterFirstName,
                        controller: _firstNameController,
                        hintText: l10n.offlineRegisterFirstNameHint,
                        isRequired: true,
                        maxLength: 50,
                        onChanged: (_) => setState(() {}),
                      ),
                      _buildDivider(),
                      _buildInputField(
                        label: l10n.offlineRegisterLastName,
                        controller: _lastNameController,
                        hintText: l10n.offlineRegisterLastNameHint,
                        isRequired: true,
                        maxLength: 50,
                        onChanged: (_) => setState(() {}),
                      ),
                      _buildDivider(),
                      _buildInputField(
                        label: l10n.offlineRegisterUsername,
                        controller: _usernameController,
                        hintText: l10n.offlineRegisterUsernameHint,
                        isRequired: true,
                        maxLength: 50,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                            RegExp(r'[\u4e00-\u9fff]'),
                          ),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card 3: Birthday, Email, Referrer
                  _buildCard(
                    children: [
                      _buildBirthdayField(l10n),
                      _buildDivider(),
                      _buildInputField(
                        label: l10n.offlineRegisterEmail,
                        controller: _emailController,
                        hintText: l10n.offlineRegisterEmailHint,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 50,
                      ),
                      _buildDivider(),
                      _buildReferrerField(l10n),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Submit button
          _buildSubmitButton(l10n, state, notifier),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          
          child: ClipRRect(
            child: Image.asset(
              'assets/android/mipmap-xxhdpi/icon_offline_register.webp',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.offlineRegisterTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black06Text,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFEEEEEE));
  }

  Widget _buildPhoneField(
    AppLocalizations l10n,
    OfflineRegisterState state,
    OfflineRegisterNotifier notifier,
  ) {
    final selected = state.selectedArea;
    final areaCode = selected?.areaCode ?? '+880';
    final countryShort = (selected?.countrySimpleName ?? '').toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(l10n.offlineRegisterPhone, isRequired: true),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showAreaSheet(context, state.areas, notifier, state.selectedArea),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$countryShort $areaCode',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.black06Text,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF666666),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: const Color(0xFFDDDDDD),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 20,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: l10n.offlineRegisterPhoneHint,
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.black06Text,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeField(
    AppLocalizations l10n,
    OfflineRegisterState state,
    OfflineRegisterNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(l10n.offlineRegisterSmsCode, isRequired: true),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: l10n.offlineRegisterCodeHint,
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.black06Text,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (state.countdown > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${state.countdown}s',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: state.sending
                      ? null
                      : () => _sendSms(context, notifier),
                  child: Text(
                    l10n.offlineRegisterSendCode,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(l10n.offlineRegisterPassword, isRequired: true),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  maxLength: 16,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    FilteringTextInputFormatter.deny(RegExp(r'[\u4e00-\u9fff]')),
                  ],
                  decoration: InputDecoration(
                    hintText: l10n.offlineRegisterPasswordHint,
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.black06Text,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _obscurePassword = !_obscurePassword;
                }),
                child: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF999999),
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label, isRequired: isRequired),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              counterText: '',
            ),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.black06Text,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(l10n.offlineRegisterBirthday),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickBirthday(context),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _birthdayController.text.isEmpty
                        ? l10n.offlineRegisterBirthdayHint
                        : _birthdayController.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _birthdayController.text.isEmpty
                          ? const Color(0xFF999999)
                          : AppColors.black06Text,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF999999),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferrerField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(l10n.offlineRegisterReferrer),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _referrerController,
                  maxLength: 20,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[\u4e00-\u9fff]')),
                  ],
                  decoration: InputDecoration(
                    hintText: l10n.offlineRegisterReferrerHint,
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.black06Text,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _scanReferrer,
                child: AppIcons.scanIcon(
                  size: 22,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(
    AppLocalizations l10n,
    OfflineRegisterState state,
    OfflineRegisterNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: const Color(0xFFF5F5F5),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: (!state.registering && _canSubmit)
              ? () => _submit(context, notifier)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            disabledBackgroundColor: const Color(0xFFE8F5E9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: state.registering
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: SizedBox.shrink(),
                )
              : Text(
                  l10n.offlineRegisterSubmit,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
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
    showToast(
        ok ? l10n.offlineRegisterSendSuccess : l10n.offlineRegisterSendFail);
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
    final birthday = _resolveBirthdaySubmitValue();
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
      birthday: birthday,
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
    final today = DateTime(now.year, now.month, now.day);
    final parsed = _tryParseBirthday(_birthdayValue);
    final initial = (parsed != null && !parsed.isAfter(today))
        ? DateTime(parsed.year, parsed.month, parsed.day)
        : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100),
      lastDate: today,
      locale: const Locale(DateFormatUtils.defaultLocale),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthdayValue = DateFormatUtils.format(
        picked,
        pattern: 'yyyy-MM-dd',
      );
      _birthdayController.text = DateFormatUtils.format(
        picked,
        pattern: DateFormatUtils.datePattern,
      );
    });
  }

  String? _resolveBirthdaySubmitValue() {
    if (_birthdayValue != null && _birthdayValue!.trim().isNotEmpty) {
      return _birthdayValue;
    }
    final parsed = _tryParseBirthday(_birthdayController.text.trim());
    if (parsed == null) return null;
    return DateFormatUtils.format(parsed, pattern: 'yyyy-MM-dd');
  }

  DateTime? _tryParseBirthday(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    return DateFormatUtils.parse(raw);
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
    AreaCountry? currentSelected,
  ) async {
    if (list.isEmpty) return;
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<AreaCountry>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.offlineRegisterSelectCountry,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final area = list[index];
                    final isSelected =
                        currentSelected?.areaCode == area.areaCode;
                    return ListTile(
                      title: Text(
                        area.country ?? '-',
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.black06Text,
                        ),
                      ),
                      trailing: Text(
                        area.areaCode ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(area),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black06Text,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    notifier.selectArea(selected);
  }
}
