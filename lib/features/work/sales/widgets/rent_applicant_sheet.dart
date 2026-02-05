import 'dart:io';

import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/features/work/map/address_picker_page.dart';
import 'package:merchant_app/features/work/map/address_result.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/rent_bind_controller.dart';

class RentApplicantResult {
  final String cardNum;
  final String firstName;
  final String lastName;
  final String phone;
  final String idNumber;
  final String birthday;
  final String email;
  final String address;
  final String? cardImgUrl;
  final String? personImgUrl;

  const RentApplicantResult({
    required this.cardNum,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.idNumber,
    required this.birthday,
    required this.email,
    required this.address,
    this.cardImgUrl,
    this.personImgUrl,
  });
}

class RentApplicantSheet extends ConsumerStatefulWidget {
  const RentApplicantSheet({super.key, required this.notifier});

  final RentBindNotifier notifier;

  static Future<RentApplicantResult?> show(
    BuildContext context,
    RentBindNotifier notifier,
  ) {
    return showModalBottomSheet<RentApplicantResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RentApplicantSheet(notifier: notifier),
    );
  }

  @override
  ConsumerState<RentApplicantSheet> createState() => _RentApplicantSheetState();
}

class _RentApplicantSheetState extends ConsumerState<RentApplicantSheet> {
  final _userIdController = TextEditingController();
  final _accountController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nidController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String? _nidFrontPath;
  String? _nidBackPath;
  String? _personalPhotoPath;
  String? _cardImgUrl;
  String? _personImgUrl;

  @override
  void dispose() {
    _userIdController.dispose();
    _accountController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _nidController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(rentBindProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_ios, size: 20),
                ),
                const Spacer(),
                Text(
                  l10n.rentBindSelectApplicant,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User ID search
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _userIdController,
                            decoration: InputDecoration(
                              hintText: l10n.rentBindUserIdHint,
                              hintStyle: const TextStyle(
                                color: Color(0xFFCCCCCC),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                widget.notifier.queryUser(value.trim());
                              }
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: _scanUserId,
                          child: AppIcons.scanIcon(
                            color: AppColors.black06Text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User card
                  if (state.user != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: state.user?.avatar != null
                                ? NetworkImage(state.user!.avatar!)
                                : null,
                            child: state.user?.avatar == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID: ${state.user?.cardNum ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black06Text,
                                  ),
                                ),
                                if (state.user?.address != null &&
                                    state.user!.address!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    state.user!.address!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF999999),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form fields
                  _buildFormField(
                    label: l10n.rentBindAccount,
                    controller: _accountController,
                    required: true,
                  ),
                  _buildFormField(
                    label: l10n.rentBindFirstName,
                    controller: _firstNameController,
                    required: true,
                  ),
                  _buildFormField(
                    label: l10n.rentBindLastName,
                    controller: _lastNameController,
                    required: true,
                  ),
                  _buildFormField(
                    label: l10n.rentBindPhone,
                    controller: _phoneController,
                    required: true,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildFormField(
                    label: l10n.rentBindNid,
                    controller: _nidController,
                    required: true,
                  ),

                  // NID Photo upload
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black06Text,
                      ),
                      children: [
                        TextSpan(text: l10n.rentBindUploadNidPhoto),
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.rentBindNidPhotoHint,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPhotoUpload(
                        path: _nidFrontPath,
                        onTap: () => _pickNidPhoto(true),
                      ),
                      const SizedBox(width: 12),
                      _buildPhotoUpload(
                        path: _nidBackPath,
                        onTap: () => _pickNidPhoto(false),
                      ),
                    ],
                  ),

                  // Personal Photo upload
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black06Text,
                      ),
                      children: [
                        TextSpan(text: l10n.rentBindPersonalPhoto),
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPhotoUpload(
                    path: _personalPhotoPath,
                    onTap: _pickPersonalPhoto,
                  ),

                  _buildFormField(
                    label: l10n.rentBindBirthday,
                    controller: _birthdayController,
                    required: false,
                    onTap: () => _selectDate(context),
                    readOnly: true,
                  ),
                  _buildFormField(
                    label: l10n.rentBindEmail,
                    controller: _emailController,
                    required: false,
                    hintText: l10n.rentBindEmailHint,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildFormField(
                    label: l10n.rentBindAddress,
                    controller: _addressController,
                    required: true,
                    hintText: l10n.rentBindAddressHint,
                    suffixIcon: GestureDetector(
                      onTap: () => _selectAddress(context),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Submit button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _canSubmit() ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: const Color(0xFFE8F5E9),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.rentBindSubmit,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required bool required,
    String? hintText,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
            ),
            children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 14,
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFEEEEEE)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload({
    required String? path,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: path != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(
                Icons.camera_alt,
                color: Color(0xFF999999),
                size: 32,
              ),
      ),
    );
  }

  Future<void> _scanUserId() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _userIdController.text = result;
    widget.notifier.queryUser(result);
  }

  Future<void> _pickNidPhoto(bool isFront) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    setState(() {
      if (isFront) {
        _nidFrontPath = picked.path;
      } else {
        _nidBackPath = picked.path;
      }
    });

    // Upload the image
    final url = await widget.notifier.uploadCardImage(picked.path);
    if (url != null && isFront) {
      _cardImgUrl = url;
    }
  }

  Future<void> _pickPersonalPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    setState(() => _personalPhotoPath = picked.path);

    // Upload the image
    final url = await widget.notifier.uploadCardImage(picked.path);
    if (url != null) {
      _personImgUrl = url;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && mounted) {
      _birthdayController.text = DateFormatUtils.format(
        picked,
        pattern: 'dd/MM/yyyy',
      );
    }
  }

  Future<void> _selectAddress(BuildContext context) async {
    final result = await Navigator.of(context).push<AddressResult>(
      MaterialPageRoute(builder: (_) => const AddressPickerPage()),
    );
    if (!mounted || result == null || result.address.isEmpty) return;
    _addressController.text = result.address;
  }

  bool _canSubmit() {
    return _accountController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _nidController.text.isNotEmpty &&
        _nidFrontPath != null &&
        _personalPhotoPath != null &&
        _addressController.text.isNotEmpty;
  }

  void _submit() {
    Navigator.of(context).pop(
      RentApplicantResult(
        cardNum: _userIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        idNumber: _nidController.text.trim(),
        birthday: _birthdayController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        cardImgUrl: _cardImgUrl,
        personImgUrl: _personImgUrl,
      ),
    );
  }
}
