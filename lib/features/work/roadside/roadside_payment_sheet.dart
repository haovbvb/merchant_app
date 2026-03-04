import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class RoadsidePaymentSubmit {
  const RoadsidePaymentSubmit({
    required this.fee,
    required this.payType,
    required this.attachments,
  });

  final String fee;
  final int payType;
  final List<String> attachments;
}

Future<bool?> showRoadsidePaymentSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required Future<String?> Function(String path) onUploadImage,
  required Future<bool> Function(RoadsidePaymentSubmit submit) onConfirmPayment,
  int initialPayType = 2,
  int maxAttachments = 5,
  bool closeOnFailure = false,
  String? successMessage,
  String? failureMessage,
}) async {
  final feeController = TextEditingController();
  final picker = ImagePicker();
  final attachmentUrls = <String>[];
  var payType = initialPayType;
  var paying = false;

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setState) {
          final fee = feeController.text.trim();
          final meaningful = _isAmountMeaningful(fee);
          final canConfirm = !paying &&
              meaningful &&
              (payType == 2 || attachmentUrls.isNotEmpty);

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            _costsTitle(context),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xE6000000),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Color(0x99000000),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _totalWithDollarText(context),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0x99000000),
                            ),
                          ),
                          TextField(
                            controller: feeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: const [_AmountInputFormatter()],
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFFFA7D00),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: _amountHint(context),
                              hintStyle: const TextStyle(
                                fontSize: 17,
                                color: Color(0x40000000),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: Text(
                              _paymentMethodsText(context),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0x99000000),
                              ),
                            ),
                          ),
                          _PayMethodRow(
                            text: l10n.roadsidePayTypeCash,
                            selected: payType == 1,
                            onTap: () => setState(() => payType = 1),
                          ),
                          const Divider(height: 1, color: Color(0xFFE6E6E6)),
                          _PayMethodRow(
                            text: l10n.roadsidePayTypeOnline,
                            selected: payType == 2,
                            onTap: () => setState(() => payType = 2),
                          ),
                        ],
                      ),
                    ),
                    if (payType == 1) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _uploadVoucherText(context),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0x99000000),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                ...attachmentUrls.map(
                                  (url) => _ImageTile(
                                    url: url,
                                    onRemove: () =>
                                        setState(() => attachmentUrls.remove(url)),
                                  ),
                                ),
                                if (attachmentUrls.length < maxAttachments)
                                  _AddImageTile(
                                    onTap: () async {
                                      final source = await _pickSource(
                                        sheetContext,
                                        l10n,
                                      );
                                      if (source == null) return;
                                      final picked =
                                          await picker.pickImage(source: source);
                                      if (picked == null) return;
                                      final uploaded =
                                          await onUploadImage(picked.path);
                                      if (uploaded != null &&
                                          uploaded.trim().isNotEmpty) {
                                        setState(
                                          () => attachmentUrls.add(uploaded),
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: canConfirm
                            ? () async {
                                setState(() => paying = true);
                                final ok = await onConfirmPayment(
                                  RoadsidePaymentSubmit(
                                    fee: fee,
                                    payType: payType,
                                    attachments: List.of(attachmentUrls),
                                  ),
                                );
                                if (!sheetContext.mounted) return;
                                setState(() => paying = false);
                                if (ok) {
                                  Navigator.of(sheetContext).pop(true);
                                } else {
                                  if (failureMessage != null &&
                                      failureMessage.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(failureMessage)),
                                    );
                                  }
                                  if (closeOnFailure) {
                                    Navigator.of(sheetContext).pop(false);
                                  }
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          disabledBackgroundColor:
                              AppColors.primaryColor.withValues(alpha: 0.45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          l10n.roadsideConfirmPayment,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  feeController.dispose();

  if (result == true && successMessage != null && successMessage.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage)),
    );
  }

  return result;
}

Future<ImageSource?> _pickSource(
  BuildContext context,
  AppLocalizations l10n,
) async {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(l10n.orderVoucherPickCamera),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.orderVoucherPickGallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      );
    },
  );
}

class _PayMethodRow extends StatelessWidget {
  const _PayMethodRow({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 58,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xE60C0C0D),
                ),
              ),
              const Spacer(),
              Image.asset(
                selected
                    ? 'assets/android/mipmap-xxhdpi/icon_green_checked.png'
                    : 'assets/android/mipmap-xxhdpi/icon_grey_unchecked.png',
                width: 28,
                height: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.photo_camera_outlined,
          size: 30,
          color: Color(0xFF7A8190),
        ),
      ),
    );
  }
}

class _AmountInputFormatter extends TextInputFormatter {
  const _AmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (text.length > 9) return oldValue;
    if (text.startsWith('.')) return oldValue;

    final pattern = RegExp(r'^(?!\.)\d*(\.\d{0,2})?$');
    if (!pattern.hasMatch(text)) return oldValue;
    return newValue;
  }
}

bool _isAmountMeaningful(String value) {
  if (value.trim().isEmpty) return false;
  final pure = value.trim();
  if (pure.runes.every((ch) => String.fromCharCode(ch) == '.')) return false;
  return pure.contains(RegExp(r'[0-9]'));
}

String _costsTitle(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '费用' : 'Costs';
}

String _totalWithDollarText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '总计 (\$)' : 'Total (\$)';
}

String _amountHint(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '请输入金额（无费用填 0）' : 'Please enter amount  (No fee, fill in 0)';
}

String _paymentMethodsText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '支付方式' : 'Payment Methods';
}

String _uploadVoucherText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '上传凭证' : 'Upload Voucher';
}
