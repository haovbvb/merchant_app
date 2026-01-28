import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/map/address_picker_page.dart';
import 'package:merchant_app/features/work/map/address_result.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/sell_bind_controller.dart';

class ApplicantResult {
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

  const ApplicantResult({
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

class ApplicantSheet extends ConsumerStatefulWidget {
  const ApplicantSheet({super.key, required this.notifier});

  final SellBindNotifier notifier;

  static Future<ApplicantResult?> show(
    BuildContext context,
    SellBindNotifier notifier,
  ) {
    return showModalBottomSheet<ApplicantResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApplicantSheet(notifier: notifier),
    );
  }

  @override
  ConsumerState<ApplicantSheet> createState() => _ApplicantSheetState();
}

class _ApplicantSheetState extends ConsumerState<ApplicantSheet> {
  final _userIdController = TextEditingController();
  final _accountController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nidController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

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
    final state = ref.watch(sellBindProvider);

    // Update form when user is loaded
    ref.listen<SellBindState>(sellBindProvider, (prev, next) {
      final user = next.user;
      if (user != null && prev?.user != next.user) {
        setState(() {
          _accountController.text = user.username ?? '';
          _firstNameController.text = user.firstName ?? '';
          _lastNameController.text = user.lastName ?? '';
          _phoneController.text = user.phone ?? '';
          _nidController.text = user.idNumber ?? '';
          _birthdayController.text = user.birthday ?? '';
          _emailController.text = user.email ?? '';
          _addressController.text = user.address ?? '';
        });
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_ios, size: 20),
                ),
                const Spacer(),
                Text(
                  l10n.sellBindSelectApplicant,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User ID search
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _userIdController,
                            decoration: InputDecoration(
                              hintText: l10n.sellBindUserIdHint,
                              hintStyle: const TextStyle(
                                color: Color(0xFF999999),
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
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User info card (if loaded)
                  if (state.user != null) _buildUserCard(state),
                  if (state.user != null) const SizedBox(height: 16),

                  // Form fields - Card 1
                  _buildInputField(
                    label: l10n.sellBindAccount,
                    controller: _accountController,
                    isRequired: true,
                  ),
                  _buildDivider(),
                  _buildInputField(
                    label: l10n.sellBindFirstName,
                    controller: _firstNameController,
                    isRequired: true,
                  ),
                  _buildDivider(),
                  _buildInputField(
                    label: l10n.sellBindLastName,
                    controller: _lastNameController,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Form fields - Card 2
                  _buildInputField(
                    label: l10n.sellBindPhone,
                    controller: _phoneController,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildDivider(),
                  _buildInputField(
                    label: l10n.sellBindNid,
                    controller: _nidController,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // NID Photo upload
                  _buildLabel(l10n.sellBindUploadNidPhoto, isRequired: true),
                  const SizedBox(height: 4),
                  Text(
                    l10n.sellBindNidPhotoHint,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildImageUpload(
                        imageUrl: _cardImgUrl,
                        onTap: () => _pickImage(true),
                      ),
                      const SizedBox(width: 12),
                      _buildImageUpload(
                        imageUrl: null,
                        onTap: () => _pickImage(true),
                        showCamera: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Personal Photo upload
                  _buildLabel(l10n.sellBindPersonalPhoto, isRequired: true),
                  const SizedBox(height: 8),
                  _buildImageUpload(
                    imageUrl: _personImgUrl,
                    onTap: () => _pickImage(false),
                    showCamera: _personImgUrl == null,
                  ),
                  const SizedBox(height: 16),

                  // Birthday & Email
                  _buildInputField(
                    label: l10n.sellBindBirthday,
                    controller: _birthdayController,
                    readOnly: true,
                    onTap: _pickBirthday,
                  ),
                  _buildDivider(),
                  _buildInputField(
                    label: l10n.sellBindEmail,
                    controller: _emailController,
                    hintText: l10n.sellBindEmailHint,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildDivider(),
                  _buildInputField(
                    label: l10n.sellBindAddress,
                    controller: _addressController,
                    isRequired: true,
                    hintText: l10n.sellBindAddressHint,
                    suffixIcon: GestureDetector(
                      onTap: _pickAddress,
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  backgroundColor: const Color(0xFF4CAF50),
                  disabledBackgroundColor: const Color(0xFFE8F5E9),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.sellBindSubmit,
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

  Widget _buildUserCard(SellBindState state) {
    final user = state.user!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : null,
            child: user.avatar == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${user.cardNum ?? '-'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                if (user.address != null)
                  Text(
                    user.address!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    String? hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label, isRequired: isRequired),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  onTap: onTap,
                  decoration: InputDecoration(
                    hintText: hintText ?? controller.text,
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              if (suffixIcon != null) suffixIcon,
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

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFEEEEEE));
  }

  Widget _buildImageUpload({
    String? imageUrl,
    required VoidCallback onTap,
    bool showCamera = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image,
                    color: Color(0xFF999999),
                  ),
                ),
              )
            : Icon(
                showCamera ? Icons.camera_alt : Icons.add,
                color: const Color(0xFF999999),
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

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthdayController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  Future<void> _pickAddress() async {
    final result = await Navigator.of(context).push<AddressResult>(
      MaterialPageRoute(builder: (_) => const AddressPickerPage()),
    );
    if (!mounted || result == null) return;
    setState(() {
      _addressController.text = result.address;
    });
  }

  Future<void> _pickImage(bool isCardImage) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final url = await widget.notifier.uploadCardImage(picked.path);
    if (url != null && mounted) {
      setState(() {
        if (isCardImage) {
          _cardImgUrl = url;
        } else {
          _personImgUrl = url;
        }
      });
    }
  }

  bool _canSubmit() {
    return _accountController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _nidController.text.isNotEmpty &&
        _addressController.text.isNotEmpty;
  }

  void _submit() {
    Navigator.of(context).pop(
      ApplicantResult(
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
