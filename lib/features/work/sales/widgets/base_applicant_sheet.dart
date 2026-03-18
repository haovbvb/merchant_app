import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/image_source_action_sheet.dart';
import 'package:merchant_app/data/models/purchasing_user.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

class ApplicantFormResult {
  const ApplicantFormResult({
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
}

class ApplicantSheetTexts {
  const ApplicantSheetTexts({
    required this.title,
    required this.userIdHint,
    required this.submit,
    required this.account,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.nid,
    required this.uploadNidPhoto,
    required this.nidPhotoHint,
    required this.personalPhoto,
    required this.birthday,
    required this.email,
    required this.emailHint,
    required this.address,
    required this.addressHint,
  });

  final String title;
  final String userIdHint;
  final String submit;
  final String account;
  final String firstName;
  final String lastName;
  final String phone;
  final String nid;
  final String uploadNidPhoto;
  final String nidPhotoHint;
  final String personalPhoto;
  final String birthday;
  final String email;
  final String emailHint;
  final String address;
  final String addressHint;
}

class BaseApplicantSheet extends StatefulWidget {
  const BaseApplicantSheet({
    super.key,
    required this.texts,
    required this.advancedMode,
    required this.onQueryUser,
    required this.onUploadCardImage,
    this.initialCardNum,
  });

  final ApplicantSheetTexts texts;
  final bool advancedMode;
  final String? initialCardNum;
  final Future<PurchasingUser?> Function(String cardNum) onQueryUser;
  final Future<String?> Function(String path) onUploadCardImage;

  @override
  State<BaseApplicantSheet> createState() => _BaseApplicantSheetState();
}

class _BaseApplicantSheetState extends State<BaseApplicantSheet> {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _chineseRegex = RegExp(r'[\u4e00-\u9fff]');

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
  final _emailFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _emailFieldKey = GlobalKey();
  final _addressFieldKey = GlobalKey();

  String? _cardImgUrl;
  String? _personImgUrl;
  String? _birthdayValue;
  final List<String> _cardImgUrls = [];
  PurchasingUser? _user;

  @override
  void initState() {
    super.initState();
    _userIdFocusNode.addListener(_onUserIdFocusChanged);
    _emailFocusNode.addListener(_onEmailFocusChanged);
    _addressFocusNode.addListener(_onAddressFocusChanged);
    final initialCardNum = widget.initialCardNum?.trim() ?? '';
    if (initialCardNum.isNotEmpty) {
      _userIdController.text = initialCardNum;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queryUser(initialCardNum);
      });
    }
  }

  void _onUserIdFocusChanged() {
    if (_userIdFocusNode.hasFocus) return;
    final cardNum = _userIdController.text.trim();
    if (cardNum.isEmpty) return;
    _queryUser(cardNum);
  }

  void _onEmailFocusChanged() {
    _ensureFieldVisible(_emailFocusNode, _emailFieldKey);
  }

  void _onAddressFocusChanged() {
    _ensureFieldVisible(_addressFocusNode, _addressFieldKey);
  }

  void _ensureFieldVisible(FocusNode focusNode, GlobalKey fieldKey) {
    if (!focusNode.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final fieldContext = fieldKey.currentContext;
      if (fieldContext == null) return;
      Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: 0.2,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  @override
  void dispose() {
    _userIdFocusNode
      ..removeListener(_onUserIdFocusChanged)
      ..dispose();
    _emailFocusNode
      ..removeListener(_onEmailFocusChanged)
      ..dispose();
    _addressFocusNode
      ..removeListener(_onAddressFocusChanged)
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
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
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
              child: Center(
                child: Text(
                  widget.texts.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                hintText: widget.texts.userIdHint,
                                hintStyle: const TextStyle(
                                  color: Color(0xFF999999),
                                ),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) {
                                final cardNum = value.trim();
                                if (cardNum.isNotEmpty) {
                                  _queryUser(cardNum);
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
                    if (_user != null) _buildUserCard(),
                    if (_user != null) const SizedBox(height: 16),

                    _buildInputField(
                      label: widget.texts.account,
                      controller: _accountController,
                      isRequired: true,
                      readOnly: true,
                    ),
                    _buildDivider(),
                    _buildInputField(
                      label: widget.texts.firstName,
                      controller: _firstNameController,
                      isRequired: true,
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    ),
                    _buildDivider(),
                    _buildInputField(
                      label: widget.texts.lastName,
                      controller: _lastNameController,
                      isRequired: true,
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      label: widget.texts.phone,
                      controller: _phoneController,
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                        FilteringTextInputFormatter.deny(_chineseRegex),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (widget.advancedMode) ...[
                      _buildInputField(
                        label: widget.texts.nid,
                        controller: _nidController,
                        isRequired: true,
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(
                        widget.texts.uploadNidPhoto,
                        isRequired: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.texts.nidPhotoHint,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCardImageRow(),
                      const SizedBox(height: 16),
                      _buildLabel(widget.texts.personalPhoto, isRequired: true),
                      const SizedBox(height: 8),
                      _buildImageUpload(
                        imageUrl: _personImgUrl,
                        onTap: () {
                          final imageUrl = _personImgUrl;
                          if (imageUrl == null || imageUrl.isEmpty) {
                            _pickImageWithSourceChooser(false);
                            return;
                          }
                          _previewImage(imageUrl);
                        },
                        showCamera: _personImgUrl == null,
                        onDelete: () {
                          setState(() {
                            _personImgUrl = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildInputField(
                      label: widget.texts.birthday,
                      controller: _birthdayController,
                      readOnly: true,
                      onTap: _pickBirthday,
                    ),
                    _buildDivider(),
                    _buildInputField(
                      label: widget.texts.email,
                      controller: _emailController,
                      hintText: widget.texts.emailHint,
                      focusNode: _emailFocusNode,
                      fieldKey: _emailFieldKey,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: widget.advancedMode
                          ? TextInputAction.next
                          : TextInputAction.done,
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    ),
                    if (widget.advancedMode) ...[
                      _buildDivider(),
                      _buildInputField(
                        label: widget.texts.address,
                        controller: _addressController,
                        isRequired: true,
                        hintText: widget.texts.addressHint,
                        focusNode: _addressFocusNode,
                        fieldKey: _addressFieldKey,
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
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
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.texts.submit,
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
      ),
    );
  }

  Widget _buildUserCard() {
    final user = _user!;
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
    FocusNode? focusNode,
    Key? fieldKey,
    TextInputAction? textInputAction,
    Widget? suffixIcon,
  }) {
    return Padding(
      key: fieldKey,
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
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  inputFormatters: inputFormatters,
                  readOnly: readOnly,
                  onTap: onTap,
                  scrollPadding: const EdgeInsets.only(bottom: 180),
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
    VoidCallback? onDelete,
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
        child: Stack(
          children: [
            Positioned.fill(
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
            if (imageUrl != null && onDelete != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImageRow() {
    final children = <Widget>[];
    final showList = _cardImgUrls.take(4).toList();
    for (int index = 0; index < showList.length; index++) {
      final imageUrl = showList[index];
      children.add(
        _buildImageUpload(
          imageUrl: imageUrl,
          onTap: () => _previewImage(imageUrl),
          onDelete: () {
            setState(() {
              _cardImgUrls.removeAt(index);
              _cardImgUrl = _cardImgUrls.isEmpty
                  ? null
                  : _cardImgUrls.join(',');
            });
          },
        ),
      );
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
          onTap: () => _pickImageWithSourceChooser(true),
          showCamera: true,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }

  void _previewImage(String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, color: Colors.white, size: 40),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scanUserId() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(allowManualInput: false),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    final cardNum = ScanUtils.getUserCarNum(result);
    if (cardNum.isEmpty) return;
    _userIdController.text = cardNum;
    await _queryUser(cardNum);
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
      _birthdayValue = _formatBirthdayForSubmit(picked);
      _birthdayController.text = DateFormatUtils.format(
        picked,
        pattern: DateFormatUtils.datePattern,
      );
    });
  }

  Future<void> _pickImageWithSourceChooser(bool isCardImage) async {
    final source = await ImageSourceActionSheet.show(context);
    if (!mounted || source == null) return;
    await _pickImage(isCardImage, source: source);
  }

  Future<void> _pickImage(
    bool isCardImage, {
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final url = await widget.onUploadCardImage(picked.path);
    if (url != null && mounted) {
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
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !_emailRegex.hasMatch(email)) {
      showToast(context.l10n.offlineRegisterEmailInvalid);
      return;
    }

    final user = _user;
    Navigator.of(context).pop(
      ApplicantFormResult(
        cardNum: _userIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        idNumber: widget.advancedMode
            ? _nidController.text.trim()
            : (user?.idNumber ?? ''),
        birthday: _resolveBirthdaySubmitValue(),
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

  Future<void> _queryUser(String cardNum) async {
    final user = await widget.onQueryUser(cardNum);
    if (!mounted) return;
    if (user == null) return;
    _applyUser(user);
  }

  void _applyUser(PurchasingUser user) {
    final rawBirthday = (user.birthday ?? '').trim();
    final parsedBirthday = _tryParseBirthday(rawBirthday);

    setState(() {
      _user = user;
      _userIdController.text = user.cardNum ?? _userIdController.text;
      _accountController.text = user.username ?? '';
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _phoneController.text = user.phone ?? '';
      _nidController.text = user.idNumber ?? '';
      if (parsedBirthday != null) {
        _birthdayController.text = DateFormatUtils.format(
          parsedBirthday,
          pattern: DateFormatUtils.datePattern,
        );
        _birthdayValue = _formatBirthdayForSubmit(parsedBirthday);
      } else {
        _birthdayController.text = user.birthday ?? '';
        _birthdayValue = rawBirthday.isEmpty ? null : rawBirthday;
      }
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
  }

  String _formatBirthdayForSubmit(DateTime date) {
    return DateFormatUtils.format(date, pattern: 'yyyy-MM-dd');
  }

  DateTime? _tryParseBirthday(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final parsed = DateFormatUtils.parse(value);
    if (parsed != null) return parsed;

    try {
      return DateFormat(
        DateFormatUtils.datePattern,
        DateFormatUtils.defaultLocale,
      ).parseStrict(value);
    } catch (_) {}

    try {
      return DateFormat(
        'yyyy-MM-dd',
        DateFormatUtils.defaultLocale,
      ).parseStrict(value);
    } catch (_) {}

    return null;
  }

  String _resolveBirthdaySubmitValue() {
    final stored = (_birthdayValue ?? '').trim();
    if (stored.isNotEmpty) return stored;

    final input = _birthdayController.text.trim();
    if (input.isEmpty) return '';

    final parsed = _tryParseBirthday(input);
    if (parsed != null) return _formatBirthdayForSubmit(parsed);

    return input;
  }
}
