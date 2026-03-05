import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/roadside/roadside_controller.dart';
import 'package:merchant_app/features/work/roadside/roadside_payment_sheet.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class RoadSideDealPage extends ConsumerStatefulWidget {
  const RoadSideDealPage({super.key, required this.recordNo});

  final String recordNo;

  @override
  ConsumerState<RoadSideDealPage> createState() => _RoadSideDealPageState();
}

class _RoadSideDealPageState extends ConsumerState<RoadSideDealPage> {
  final TextEditingController _descController = TextEditingController();
  int? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roadSideDealProvider.notifier).clearImages();
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(roadSideDealProvider);
    final notifier = ref.read(roadSideDealProvider.notifier);

    final canSubmit = _result != null && !state.submitting;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _processingResultTitle(context),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.roadsideRescueResult,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xE60C0C0D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ResultOptionButton(
                                iconPath: _result == 2
                                    ? 'assets/android/mipmap-xxhdpi/icon_result_completed_green.png'
                                    : 'assets/android/mipmap-xxhdpi/icon_deal_complete_unselected.png',
                                label: l10n.roadsideResultCompleted,
                                isSelected: _result == 2,
                                onTap: () => setState(() => _result = 2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ResultOptionButton(
                                iconPath: _result == 1
                                    ? 'assets/android/mipmap-xxhdpi/icon_deal_uncomplete_selected.png'
                                    : 'assets/android/mipmap-xxhdpi/icon_deal_uncomplete_unselected.png',
                                label: l10n.roadsideResultReturnFactory,
                                isSelected: _result == 1,
                                onTap: () => setState(() => _result = 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFE6E6E6)),
                        const SizedBox(height: 14),
                        Text(
                          l10n.roadsideDealDescLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xE60C0C0D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _descController,
                          maxLength: 200,
                          maxLines: 6,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: _descHint(context),
                            hintStyle: const TextStyle(
                              color: Color(0x4D0C0C0D),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.roadsidePhotoLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xE60C0C0D),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${state.imageUrls.length}/5)',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0x660C0C0D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ...List.generate(state.imageUrls.length, (index) {
                              final image = state.imageUrls[index];
                              return _ImageTile(
                                url: image,
                                onRemove: () => notifier.removeImageAt(index),
                              );
                            }),
                            if (state.imageUrls.length < 5)
                              _AddImageTile(
                                onTap: () => _pickImage(context, notifier),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: canSubmit
                      ? () async {
                          final ok = await notifier.submitReport(
                            recordNo: widget.recordNo,
                            result: _result!,
                            desc: _descController.text.trim(),
                          );
                          if (!context.mounted) return;

                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.roadsideDealFailed)),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_dealSuccessToast(context))),
                          );

                          await _showPaymentSheet(context, l10n, notifier);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.45,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.roadsideSubmitButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentSheet(
    BuildContext context,
    AppLocalizations l10n,
    RoadSideDealNotifier notifier,
  ) async {
    final result = await showRoadsidePaymentSheet(
      context: context,
      l10n: l10n,
      initialPayType: 2,
      failureMessage: l10n.roadsidePayFailed,
      onUploadImage: notifier.uploadImage,
      onConfirmPayment: (submit) {
        return ref.read(roadSideDetailProvider.notifier).payRoadSide(
              recordNo: widget.recordNo,
              fee: submit.fee,
              payType: submit.payType,
              attachment: submit.attachments.join(','),
            );
      },
    );

    if (result == true && mounted) {
      Navigator.of(this.context).pop(true);
    }
  }

  Future<void> _pickImage(
    BuildContext context,
    RoadSideDealNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
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
    if (source == null) return;
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;
    await notifier.uploadImage(picked.path);
  }
}

class _ResultOptionButton extends StatelessWidget {
  const _ResultOptionButton({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF5F8FB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 22, height: 22, fit: BoxFit.contain),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? AppColors.primaryColor
                      : const Color(0x99000000),
                ),
              ),
            ),
          ],
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

String _processingResultTitle(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '处理结果' : 'Processing Result';
}

String _dealSuccessToast(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '救援结果提交成功' : 'The rescue result was submitted successfully';
}

String _descHint(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '请输入描述' : 'Please enter your description';
}

