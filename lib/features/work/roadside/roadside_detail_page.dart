import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/widgets/photo_gallery_viewer.dart';
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
      backgroundColor: const Color(0xFFF5F6F7),
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
        centerTitle: true,
      ),
      body: state.loading && detail == null
          ? const Center(child: SizedBox.shrink())
          : detail == null
              ? _EmptyView(text: l10n.roadsideDetailEmpty)
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _StatusHeader(l10n: l10n, detail: detail),
                            _ContactCard(
                              detail: detail,
                              onCallPhone: () => _callPhone(detail.riderPhone),
                              onNavigate: () => _openNavigation(detail),
                            ),
                            const SizedBox(height: 12),
                            _DescriptionAndMetaCard(l10n: l10n, detail: detail),
                            if (detail.status != 0 && detail.opResponse != null) ...[
                              const SizedBox(height: 12),
                              _ProcessingResultCard(l10n: l10n, detail: detail),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
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
      return _BottomButton(
        text: _processingButtonText(context),
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
    }

    if (detail.status == 1) {
      if (detail.payWay == 2) {
        return const SizedBox.shrink();
      }
      return _BottomButton(
        text: _paymentButtonText(context),
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

  Future<void> _openNavigation(RoadSideOrderDetail detail) async {
    final lat = detail.latitude;
    final lng = detail.longitude;
    if (lat == null || lng == null || (lat == 0 && lng == 0)) return;

    final googleNav = Uri.parse('google.navigation:q=$lat,$lng');
    final mapUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    if (await canLaunchUrl(googleNav)) {
      await launchUrl(googleNav);
      return;
    }
    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: const [_AmountInputFormatter()],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF09A2B),
                            ),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
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
                          ...attachments.map(
                            (url) => _VoucherImage(
                              url: url,
                              onRemove: () => setState(() => attachments.remove(url)),
                            ),
                          ),
                          if (attachments.length < 3)
                            _AddVoucherButton(
                              onTap: () async {
                                final source = await _showImageSourceSheet(
                                  context,
                                  l10n,
                                );
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
                    SizedBox(
                      width: double.infinity,
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
                                content: Text(
                                  ok
                                      ? l10n.roadsidePaySuccess
                                      : l10n.roadsidePayFailed,
                                ),
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
              ),
            ),
          ),
        );
      },
    );
  }

  Future<ImageSource?> _showImageSourceSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) {
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

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEEF8FF), Colors.white],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      child: Row(
        children: [
          Image.asset(
            _statusIconPath(detail.status),
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(l10n, detail.status),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x42262626)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NO.${detail.recordNo ?? '-'}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0x99000000),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusIconPath(int? status) {
    switch (status) {
      case 0:
        return 'assets/android/mipmap-xxhdpi/icon_roadside_status_wait.webp';
      case 1:
        return 'assets/android/mipmap-xxhdpi/icon_roadside_status_pending.webp';
      case 2:
        return 'assets/android/mipmap-xxhdpi/icon_roadside_status_completed.webp';
      default:
        return 'assets/android/mipmap-xxhdpi/icon_roadside_status_wait.webp';
    }
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.detail,
    required this.onCallPhone,
    required this.onNavigate,
  });

  final RoadSideOrderDetail detail;
  final VoidCallback onCallPhone;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final fullName = '${detail.firstName ?? ''} ${detail.lastName ?? ''}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : (detail.rider ?? '-');
    final address = _formatLocation(detail);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _AvatarImage(url: detail.img),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${detail.cardNum ?? '-'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0x99000000),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onCallPhone,
                child: Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_roadside_detail_phone.png',
                  width: 32,
                  height: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          const SizedBox(height: 8),
          Row(
            children: [
              Image.asset(
                'assets/android/mipmap-xxhdpi/icon_roadside_date.png',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${_formatOccurrenceTime(detail.createTime)} ${_occurrenceText(context)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0x99000000),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Image.asset(
                'assets/android/mipmap-xxhdpi/icon_roadside_loc.png',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0x99000000),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onNavigate,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_distination.png',
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLocation(RoadSideOrderDetail detail) {
    final lat = detail.latitude;
    final lng = detail.longitude;
    if (lat == null || lng == null) return '-';
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  String _formatOccurrenceTime(int? millis) {
    if (millis == null || millis <= 0) return '-';
    final locale = Intl.getCurrentLocale().toLowerCase();
    final isZh = locale.startsWith('zh');
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final pattern = isZh ? 'M月dd日, yyyy HH:mm' : 'MMM dd, yyyy HH:mm';
    return DateFormat(pattern).format(date);
  }
}

class _DescriptionAndMetaCard extends StatelessWidget {
  const _DescriptionAndMetaCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.roadsideDescriptionTitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0x800C0C0D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail.description ?? '-',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xE60C0C0D),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const SizedBox(width: 6),
                _DeviceThumb(url: detail.img),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    detail.deviceSn ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xE6000000),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          _MetaRow(label: l10n.roadsideFounderLabel, value: detail.creator ?? '-'),
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          _MetaRow(
            label: l10n.roadsideCreationTimeLabel,
            value: DateFormatUtils.formatString(detail.reportTime),
          ),
          _MetaRow(
            label: l10n.roadsideReportSourceLabel,
            value: _sourceText(context, detail.source),
          ),
        ],
      ),
    );
  }

  String _sourceText(BuildContext context, int? source) {
    final isZh = Localizations.localeOf(context).languageCode
        .toLowerCase()
        .startsWith('zh');
    switch (source) {
      case 1:
        return isZh ? '管理后台' : 'Admin Console';
      case 2:
        return isZh ? '用户App' : 'User App';
      default:
        return '-';
    }
  }
}

class _ProcessingResultCard extends StatelessWidget {
  const _ProcessingResultCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final images = (detail.imgList ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _processingButtonText(context),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0x99000000),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(
                _resultIconPath(detail.result),
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                _resultText(l10n, detail.result),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xE60C0C0D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            detail.opResponse ?? '-',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xE6000000),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            DateFormatUtils.formatTimestampMillis(
              detail.processTime,
              pattern: 'MMM dd, yyyy HH:mm:ss',
            ),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0x66000000),
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final image = images[index];
                  return GestureDetector(
                    onTap: () => PhotoGalleryViewer.show(
                      context,
                      images,
                      initialIndex: index,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        image,
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 80,
                          color: const Color(0xFFF2F2F2),
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (detail.status == 2) ...[
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFE6E6E6)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _paymentMethodsText(context),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0x99000000),
                  ),
                ),
                const Spacer(),
                Text(
                  _payWayText(context, detail.payWay),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xE6000000),
                  ),
                ),
                if ((detail.attachment ?? '').trim().isNotEmpty)
                  GestureDetector(
                    onTap: () => PhotoGalleryViewer.show(
                      context,
                      (detail.attachment ?? '')
                          .split(',')
                          .map((item) => item.trim())
                          .where((item) => item.isNotEmpty)
                          .toList(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        _viewVoucherText(context),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0A5BCC),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  _totalText(context),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0x99000000),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${(detail.fee ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFFA7D00),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _resultText(AppLocalizations l10n, int? result) {
    switch (result) {
      case 1:
        return l10n.roadsideResultReturnFactory;
      case 2:
        return l10n.roadsideResultCompleted;
      default:
        return '-';
    }
  }

  String _resultIconPath(int? result) {
    switch (result) {
      case 1:
        return 'assets/android/mipmap-xxhdpi/icon_green_return_factory.png';
      case 2:
        return 'assets/android/mipmap-xxhdpi/icon_result_completed_green.png';
      default:
        return 'assets/android/mipmap-xxhdpi/icon_result_completed_green.png';
    }
  }

  String _payWayText(BuildContext context, int? payWay) {
    final isZh = Localizations.localeOf(context).languageCode
        .toLowerCase()
        .startsWith('zh');
    if (payWay == 1) return isZh ? '现金' : 'Cash';
    if (payWay == 2) return isZh ? '线上' : 'Online';
    return '-';
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xE60C0C0D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0x800C0C0D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Image.asset(
        'assets/android/mipmap-xxhdpi/icon_def_avatar.webp',
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url!,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/android/mipmap-xxhdpi/icon_def_avatar.webp',
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _DeviceThumb extends StatelessWidget {
  const _DeviceThumb({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Image.asset(
        'assets/android/mipmap-xxhdpi/icon_empty_record.png',
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      );
    }
    return Image.network(
      url!,
      width: 32,
      height: 32,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/android/mipmap-xxhdpi/icon_empty_record.png',
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

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
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.1)
                : const Color(0xFFF5F5F5),
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
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

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
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: const Icon(Icons.add, color: Color(0xFF999999), size: 28),
      ),
    );
  }
}

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
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
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

String _processingButtonText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '处理结果' : 'Processing Result';
}

String _paymentButtonText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '支付' : 'Payment';
}

String _paymentMethodsText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '支付方式' : 'Payment Methods';
}

String _viewVoucherText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '查看凭证' : 'View Voucher';
}

String _totalText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '总计' : 'Total';
}

String _occurrenceText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '发生' : 'occurrence';
}
