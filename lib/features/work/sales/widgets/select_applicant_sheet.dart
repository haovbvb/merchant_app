import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

class SelectApplicantSheet extends StatefulWidget {
  const SelectApplicantSheet({
    super.key,
    required this.title,
    required this.hintText,
    required this.submitText,
    required this.onQueryUser,
  });

  final String title;
  final String hintText;
  final String submitText;
  final Future<bool> Function(String cardNum) onQueryUser;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String hintText,
    required String submitText,
    required Future<bool> Function(String cardNum) onQueryUser,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SelectApplicantSheet(
        title: title,
        hintText: hintText,
        submitText: submitText,
        onQueryUser: onQueryUser,
      ),
    );
  }

  @override
  State<SelectApplicantSheet> createState() => _SelectApplicantSheetState();
}

class _SelectApplicantSheetState extends State<SelectApplicantSheet> {
  final _userIdController = TextEditingController();
  final _focusNode = FocusNode();
  String? _matchedUserId;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) return;
    _searchUser();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_searching &&
        _matchedUserId != null &&
        _matchedUserId == _userIdController.text.trim();

    return Container(
      height: MediaQuery.of(context).size.height * 0.32,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userIdController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: const TextStyle(color: Color(0xFF999999)),
                          border: InputBorder.none,
                        ),
                        onChanged: (_) {
                          if (_matchedUserId != null) {
                            setState(() => _matchedUserId = null);
                          }
                        },
                        onSubmitted: (_) => _searchUser(),
                      ),
                    ),
                    GestureDetector(
                      onTap: _scanUserId,
                      child: AppIcons.scanIcon(color: AppColors.black06Text),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: const Color(0xFFE8F5E9),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _searching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.submitText,
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

  Future<void> _searchUser() async {
    final cardNum = _userIdController.text.trim();
    if (cardNum.isEmpty) return;

    setState(() {
      _searching = true;
      _matchedUserId = null;
    });

    final found = await widget.onQueryUser(cardNum);
    if (!mounted) return;

    setState(() {
      _searching = false;
      _matchedUserId = found ? cardNum : null;
    });

    if (_matchedUserId == null) {
      showToast(context.l10n.userSearchEmpty);
    }
  }

  Future<void> _scanUserId() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage(allowManualInput: true)),
    );
    if (!mounted || result == null || result.isEmpty) return;

    final cardNum = ScanUtils.getUserCarNum(result);
    if (cardNum.isEmpty) return;
    _userIdController.text = cardNum;
    await _searchUser();
  }

  void _submit() {
    final cardNum = _userIdController.text.trim();
    if (cardNum.isEmpty || _matchedUserId != cardNum) return;
    Navigator.of(context).pop(cardNum);
  }
}
