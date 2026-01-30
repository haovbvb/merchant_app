import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/roadside_order_detail.dart';
import 'package:merchant_app/features/work/roadside/roadside_controller.dart';
import 'package:merchant_app/features/work/roadside/roadside_deal_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class RoadSideDetailPage extends ConsumerStatefulWidget {
  const RoadSideDetailPage({super.key, required this.recordNo});

  final String recordNo;

  @override
  ConsumerState<RoadSideDetailPage> createState() => _RoadSideDetailPageState();
}

class _RoadSideDetailPageState extends ConsumerState<RoadSideDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.recordNo.isNotEmpty) {
        ref.read(roadSideDetailProvider.notifier).loadDetail(widget.recordNo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(roadSideDetailProvider);
    final notifier = ref.read(roadSideDetailProvider.notifier);
    final detail = state.detail;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.roadsideDetailTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: state.loading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? _EmptyView(text: l10n.roadsideDetailEmpty)
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Status header card
                            _StatusHeaderCard(l10n: l10n, detail: detail),
                            const SizedBox(height: 12),
                            // User info card
                            _UserInfoCard(
                              l10n: l10n,
                              detail: detail,
                              onCallPhone: () => _callPhone(detail.riderPhone),
                            ),
                            const SizedBox(height: 12),
                            // Date and location row
                            _DateLocationCard(l10n: l10n, detail: detail),
                            const SizedBox(height: 12),
                            // Description card
                            _DescriptionCard(l10n: l10n, detail: detail),
                            const SizedBox(height: 12),
                            // Creator info card
                            _CreatorInfoCard(l10n: l10n, detail: detail),
                            // Processing result card (if processed)
                            if (detail.status != 0 && detail.opResponse != null) ...[
                              const SizedBox(height: 12),
                              _ProcessingResultCard(l10n: l10n, detail: detail),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    // Bottom button
                    _buildBottomButton(context, l10n, detail, notifier),
                  ],
                ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    AppLocalizations l10n,
    RoadSideOrderDetail detail,
    RoadSideDetailNotifier notifier,
  ) {
    if (detail.status == 0) {
      // Waiting for rescue - show "Processing Result" button
      return _BottomButton(
        text: l10n.roadsideDealAction,
        onPressed: () async {
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => RoadSideDealPage(recordNo: detail.recordNo ?? ''),
            ),
          );
          if (ok == true && context.mounted) {
            await notifier.loadDetail(widget.recordNo);
          }
        },
      );
    } else if (detail.status == 1) {
      // In progress - show "Payment" button
      return _BottomButton(
        text: l10n.roadsidePayAction,
        onPressed: () => _showPaymentSheet(context, l10n, detail),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showPaymentSheet(
    BuildContext context,
    AppLocalizations l10n,
    RoadSideOrderDetail detail,
  ) async {
    final feeController = TextEditingController();
    int payType = 1;
    final attachments = <String>[];
    final picker = ImagePicker();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Text(
                          l10n.roadsideCostsTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Total amount
                    Row(
                      children: [
                        Text(
                          l10n.roadsideTotalLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: feeController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF09A2B),
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: const TextStyle(
                                color: Color(0xFFCCCCCC),
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Payment methods
                    Text(
                      l10n.roadsidePaymentMethodLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _PaymentMethodButton(
                          icon: Icons.money,
                          label: l10n.roadsidePayTypeCash,
                          isSelected: payType == 1,
                          onTap: () => setState(() => payType = 1),
                        ),
                        const SizedBox(width: 12),
                        _PaymentMethodButton(
                          icon: Icons.phone_android,
                          label: l10n.roadsidePayTypeOnline,
                          isSelected: payType == 2,
                          onTap: () => setState(() => payType = 2),
                        ),
                      ],
                    ),
                    // Upload voucher (for cash)
                    if (payType == 1) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.roadsideUploadVoucherLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...attachments.map((url) => _VoucherImage(
                                url: url,
                                onRemove: () => setState(() => attachments.remove(url)),
                              )),
                          if (attachments.length < 3)
                            _AddVoucherButton(
                              onTap: () async {
                                final source = await _showImageSourceSheet(context, l10n);
                                if (source == null) return;
                                final picked = await picker.pickImage(source: source);
                                if (picked == null) return;
                                final url = await ref
                                    .read(roadSideDealProvider.notifier)
                                    .uploadImage(picked.path);
                                if (url != null) {
                                  setState(() => attachments.add(url));
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFDDDDDD)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              l10n.roadsideNotPayingYet,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final fee = feeController.text.trim();
                              if (fee.isEmpty) return;
                              final ok = await ref
                                  .read(roadSideDetailProvider.notifier)
                                  .payRoadSide(
                                    recordNo: detail.recordNo ?? '',
                                    fee: fee,
                                    payType: payType,
                                    attachment: attachments.join(','),
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? l10n.roadsidePaySuccess
                                        : l10n.roadsidePayFailed),
                                  ),
                                );
                                if (ok) {
                                  await ref
                                      .read(roadSideDetailProvider.notifier)
                                      .loadDetail(widget.recordNo);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              l10n.roadsideConfirmPayment,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<ImageSource?> _showImageSourceSheet(BuildContext context, AppLocalizations l10n) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
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
      ),
    );
  }
}

// Status header card with icon
class _StatusHeaderCard extends StatelessWidget {
  const _StatusHeaderCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final statusColors = _getStatusColors(detail.status);
    final statusLabel = _getStatusLabel(l10n, detail.status);
    final statusIcon = _getStatusIcon(detail.status);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColors.text,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: statusColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NO.${detail.recordNo ?? '-'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(int? status) {
    switch (status) {
      case 0:
        return Icons.warning_amber_rounded;
      case 1:
        return Icons.access_time;
      case 2:
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }
}

// User info card with phone button
class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({
    required this.l10n,
    required this.detail,
    required this.onCallPhone,
  });

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;
  final VoidCallback onCallPhone;

  @override
  Widget build(BuildContext context) {
    final fullName = '${detail.firstName ?? ''} ${detail.lastName ?? ''}'.trim();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF999999),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // Name and ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : (detail.rider ?? '-'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${detail.cardNum ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          // Phone button
          if (detail.riderPhone != null && detail.riderPhone!.isNotEmpty)
            GestureDetector(
              onTap: onCallPhone,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.phone,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Date and location card
class _DateLocationCard extends StatelessWidget {
  const _DateLocationCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF999999),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detail.reportTime ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black06Text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Location
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Color(0xFF999999),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatLocation(detail),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black06Text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLocation(RoadSideOrderDetail detail) {
    final lat = detail.latitude;
    final lng = detail.longitude;
    if (lat == null || lng == null) return '-';
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }
}

// Description card with device SN
class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.roadsideDescriptionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Device SN badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'SN: ${detail.deviceSn ?? '-'}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Description text
          Text(
            detail.description ?? '-',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
              height: 1.5,
            ),
          ),
          // Image if available
          if ((detail.img ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                detail.img!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Creator info card
class _CreatorInfoCard extends StatelessWidget {
  const _CreatorInfoCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: l10n.roadsideFounderLabel,
            value: detail.creator ?? '-',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: l10n.roadsideCreationTimeLabel,
            value: detail.reportTime ?? '-',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: l10n.roadsideReportSourceLabel,
            value: _getSourceLabel(l10n, detail.source),
          ),
        ],
      ),
    );
  }

  String _getSourceLabel(AppLocalizations l10n, int? source) {
    switch (source) {
      case 1:
        return l10n.roadsideSourceApp;
      case 2:
        return l10n.roadsideSourceWeb;
      default:
        return '-';
    }
  }
}

// Processing result card
class _ProcessingResultCard extends StatelessWidget {
  const _ProcessingResultCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final imgList = (detail.imgList ?? '').split(',').where((e) => e.isNotEmpty).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.roadsideProcessingResultTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rescue result
          _InfoRow(
            label: l10n.roadsideRescueResult,
            value: _getResultLabel(l10n, detail.result),
          ),
          const SizedBox(height: 12),
          // Description
          _InfoRow(
            label: l10n.roadsideDescLabel,
            value: detail.opResponse ?? '-',
          ),
          // Images
          if (imgList.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: imgList
                  .map(
                    (url) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: const Color(0xFFF5F5F5),
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          // Payment info if completed
          if (detail.status == 2 && detail.fee != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.roadsideTotalLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                Text(
                  detail.fee?.toStringAsFixed(2) ?? '0.00',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF09A2B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.roadsidePaymentMethodLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                Text(
                  detail.payWay == 1 ? l10n.roadsidePayTypeCash : l10n.roadsidePayTypeOnline,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black06Text,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getResultLabel(AppLocalizations l10n, int? result) {
    switch (result) {
      case 1:
        return l10n.roadsideResultReturnFactory;
      case 2:
        return l10n.roadsideResultCompleted;
      default:
        return '-';
    }
  }
}

// Info row widget
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
            ),
          ),
        ),
      ],
    );
  }
}

// Bottom button
class _BottomButton extends StatelessWidget {
  const _BottomButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Payment method button
class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primaryColor : const Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? AppColors.primaryColor : const Color(0xFF666666),
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Voucher image widget
class _VoucherImage extends StatelessWidget {
  const _VoucherImage({required this.url, required this.onRemove});

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
            width: 72,
            height: 72,
            fit: BoxFit.cover,
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
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Add voucher button
class _AddVoucherButton extends StatelessWidget {
  const _AddVoucherButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDDDDDD), style: BorderStyle.solid),
        ),
        child: const Icon(
          Icons.add,
          color: Color(0xFF999999),
          size: 28,
        ),
      ),
    );
  }
}

// Empty view
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Status colors helper
class _StatusColors {
  const _StatusColors({required this.text, required this.background});

  final Color text;
  final Color background;
}

_StatusColors _getStatusColors(int? status) {
  switch (status) {
    case 0: // Waiting for rescue
      return const _StatusColors(
        text: Color(0xFFE25C5C),
        background: Color(0xFFFFF1F1),
      );
    case 1: // In progress
      return const _StatusColors(
        text: Color(0xFFF09A2B),
        background: Color(0xFFFFF4E6),
      );
    case 2: // Completed
      return const _StatusColors(
        text: Color(0xFF00B88A),
        background: Color(0xFFE9F7F2),
      );
    default:
      return const _StatusColors(
        text: Color(0xFF7A7A7A),
        background: Color(0xFFF2F2F2),
      );
  }
}

String _getStatusLabel(AppLocalizations l10n, int? status) {
  switch (status) {
    case 0:
      return l10n.roadsideStatusWaiting;
    case 1:
      return l10n.roadsideStatusProcessing;
    case 2:
      return l10n.roadsideStatusCompleted;
    default:
      return '-';
  }
}
