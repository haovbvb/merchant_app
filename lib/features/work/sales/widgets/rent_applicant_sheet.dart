import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
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
  const RentApplicantSheet({
    super.key,
    required this.notifier,
    required this.advancedMode,
  });

  final RentBindNotifier notifier;
  final bool advancedMode;

  static Future<RentApplicantResult?> show(
    BuildContext context,
    RentBindNotifier notifier, {
    required bool advancedMode,
  }) {
    return showModalBottomSheet<RentApplicantResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          RentApplicantSheet(notifier: notifier, advancedMode: advancedMode),
    );
  }

  @override
  ConsumerState<RentApplicantSheet> createState() => _RentApplicantSheetState();
}

class _RentApplicantSheetState extends ConsumerState<RentApplicantSheet> {
  final _userIdController = TextEditingController();
  final _userIdFocusNode = FocusNode();
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
  final List<String> _cardImgUrls = [];

  @override
  void initState() {
    super.initState();
    _userIdFocusNode.addListener(_onUserIdFocusChanged);
  }

  void _onUserIdFocusChanged() {
    if (_userIdFocusNode.hasFocus) return;
    final cardNum = _userIdController.text.trim();
    if (cardNum.isEmpty) return;
    widget.notifier.queryUser(cardNum);
  }

  @override
  void dispose() {
    _userIdFocusNode
      ..removeListener(_onUserIdFocusChanged)
      ..dispose();
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

    ref.listen<RentBindState>(rentBindProvider, (prev, next) {
      final user = next.user;
      if (user == null || prev?.user == next.user) return;
      setState(() {
        _userIdController.text = user.cardNum ?? _userIdController.text;
        _accountController.text = user.username ?? '';
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _phoneController.text = user.phone ?? '';
        _nidController.text = user.idNumber ?? '';
        _birthdayController.text = user.birthday ?? '';
        _emailController.text = user.email ?? '';
        _addressController.text = user.address ?? '';
        _cardImgUrls
          ..clear()
          ..addAll(
            (user.cardImg ?? '')
                .split(',')
                .map((item) => item.trim())
                .where((item) => item.isNotEmpty)
                .take(4),
          );
        _cardImgUrl = _cardImgUrls.isEmpty ? null : _cardImgUrls.join(',');
        _personImgUrl = user.personImg;
      });
    });

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            focusNode: _userIdFocusNode,
                            decoration: InputDecoration(
                              hintText: l10n.rentBindUserIdHint,
                              hintStyle: const TextStyle(
                                color: Color(0xFF999999),
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              final cardNum = value.trim();
                              if (cardNum.isNotEmpty) {
                                widget.notifier.queryUser(cardNum);
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
                  if (state.user != null) _buildUserCard(state),
                  if (state.user != null) const SizedBox(height: 16),

                  _buildInputField(
                    label: l10n.rentBindAccount,
                    controller: _accountController,
                    isRequired: true,
                    readOnly: true,
                  ),
                  _buildDivider(),
                  _buildInputField(
                    label: l10n.rentBindFirstName,
                    controller: _firstNameController,
                    isRequired: true,
                  ),
                  _buildDivider(),
                  _buildInputField(
                    label: l10n.rentBindLastName,
                    controller: _lastNameController,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: l10n.rentBindPhone,
                    controller: _phoneController,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),

                  if (widget.advancedMode) ...[
                    _buildInputField(
                      label: l10n.rentBindNid,
                      controller: _nidController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel(l10n.rentBindUploadNidPhoto, isRequired: true),
                    const SizedBox(height: 4),
                    Text(
                      l10n.rentBindNidPhotoHint,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCardImageRow(),
                    const SizedBox(height: 16),
                    _buildLabel(l10n.rentBindPersonalPhoto, isRequired: true),
                    const SizedBox(height: 8),
                    _buildImageUpload(
                      imageUrl: _personImgUrl,
                      onTap: () =>
                          _pickImage(false, source: ImageSource.gallery),
                      showCamera: _personImgUrl == null,
                      onCameraTap: () =>
                          _pickImage(false, source: ImageSource.camera),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildInputField(
                    label: l10n.rentBindBirthday,
                    controller: _birthdayController,
                    readOnly: true,
                    onTap: _pickBirthday,
                  ),
                  _buildDivider(),
                  _buildInputField(
                    label: l10n.rentBindEmail,
                    controller: _emailController,
                    hintText: l10n.rentBindEmailHint,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (widget.advancedMode) ...[
                    _buildDivider(),
                    _buildInputField(
                      label: l10n.rentBindAddress,
                      controller: _addressController,
                      isRequired: true,
                      hintText: l10n.rentBindAddressHint,
                      suffixIcon: GestureDetector(
                        onTap: _pickAddress,
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
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

  Widget _buildUserCard(RentBindState state) {
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
                    color: AppColors.black06Text,
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
    List<TextInputFormatter>? inputFormatters,
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
                  inputFormatters: inputFormatters,
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
                    color: AppColors.black06Text,
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
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        if (isRequired)
          const Text(' *', style: TextStyle(fontSize: 14, color: Colors.red)),
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
    VoidCallback? onCameraTap,
  }) {
    return GestureDetector(
      onTap: imageUrl == null && showCamera && onCameraTap != null
          ? onCameraTap
          : onTap,
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
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, color: Color(0xFF999999)),
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

  Widget _buildCardImageRow() {
    final children = <Widget>[];
    final showList = _cardImgUrls.take(4).toList();
    for (final imageUrl in showList) {
      children.add(_buildImageUpload(imageUrl: imageUrl, onTap: () {}));
      if (children.length < 4) {
        children.add(const SizedBox(width: 12));
      }
    }
    if (showList.length < 4) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 12));
      }
      children.add(
        _buildImageUpload(
          imageUrl: null,
          onTap: () => _pickImage(true, source: ImageSource.gallery),
          showCamera: true,
          onCameraTap: () => _pickImage(true, source: ImageSource.camera),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }

  Future<void> _scanUserId() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(allowManualInput: true),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    final cardNum = ScanUtils.getUserCarNum(result);
    if (cardNum.isEmpty) return;
    _userIdController.text = cardNum;
    widget.notifier.queryUser(cardNum);
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
      _birthdayController.text = DateFormatUtils.format(
        picked,
        pattern: 'yyyy-MM-dd',
      );
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

  Future<void> _pickImage(
    bool isCardImage, {
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;
    final url = await widget.notifier.uploadCardImage(picked.path);
    if (!mounted || url == null) return;
    setState(() {
      if (isCardImage) {
        if (_cardImgUrls.length < 4) {
          _cardImgUrls.add(url);
        }
        _cardImgUrl = _cardImgUrls.join(',');
      } else {
        _personImgUrl = url;
      }
    });
  }

  bool _canSubmit() {
    final baseValid =
        _accountController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty;
    if (!widget.advancedMode) {
      return baseValid;
    }
    return baseValid &&
        _nidController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _cardImgUrls.length >= 2 &&
        (_personImgUrl?.isNotEmpty ?? false);
  }

  void _submit() {
    final state = ref.read(rentBindProvider);
    final user = state.user;
    Navigator.of(context).pop(
      RentApplicantResult(
        cardNum: _userIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        idNumber: widget.advancedMode
            ? _nidController.text.trim()
            : (user?.idNumber ?? ''),
        birthday: _birthdayController.text.trim(),
        email: _emailController.text.trim(),
        address: widget.advancedMode
            ? _addressController.text.trim()
            : (user?.address ?? ''),
        cardImgUrl: widget.advancedMode
            ? (_cardImgUrls.isEmpty ? null : _cardImgUrls.join(','))
            : (user?.cardImg ?? _cardImgUrl),
        personImgUrl: widget.advancedMode
            ? _personImgUrl
            : (user?.personImg ?? _personImgUrl),
      ),
    );
  }
}
