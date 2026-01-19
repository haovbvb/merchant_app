import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/roadside_order_detail.dart';
import 'package:merchant_app/features/work/roadside/roadside_controller.dart';
import 'package:merchant_app/features/work/roadside/roadside_deal_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

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
      appBar: AppBar(title: Text(l10n.roadsideDetailTitle)),
      body: state.loading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? _EmptyView(text: l10n.roadsideDetailEmpty)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _HeaderCard(l10n: l10n, detail: detail),
                    const SizedBox(height: 12),
                    _InfoCard(l10n: l10n, detail: detail),
                    const SizedBox(height: 12),
                    if (detail.opResponse != null &&
                        detail.opResponse!.isNotEmpty)
                      _ResponseCard(l10n: l10n, detail: detail),
                    const SizedBox(height: 12),
                    if ((detail.attachment ?? '').isNotEmpty)
                      _AttachmentCard(
                        l10n: l10n,
                        attachments: detail.attachment ?? '',
                      ),
                    const SizedBox(height: 24),
                    if (detail.status == 0)
                      FilledButton(
                        onPressed: () async {
                          final ok = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => RoadSideDealPage(
                                recordNo: detail.recordNo ?? '',
                              ),
                            ),
                          );
                          if (ok == true && context.mounted) {
                            await notifier.loadDetail(widget.recordNo);
                          }
                        },
                        child: Text(l10n.roadsideDealAction),
                      ),
                    if (detail.status == 1)
                      FilledButton(
                        onPressed: () => _showPayDialog(context, detail),
                        child: Text(l10n.roadsidePayAction),
                      ),
                  ],
                ),
    );
  }

  Future<void> _showPayDialog(
    BuildContext context,
    RoadSideOrderDetail detail,
  ) async {
    final l10n = context.l10n;
    final feeController = TextEditingController();
    int payType = 1;
    final attachments = <String>[];
    final picker = ImagePicker();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.roadsidePayAction),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: feeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.roadsidePayFeeLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.roadsidePayTypeLabel),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.roadsidePayTypeCash),
                        selected: payType == 1,
                        onSelected: (_) => setState(() => payType = 1),
                      ),
                      ChoiceChip(
                        label: Text(l10n.roadsidePayTypeOnline),
                        selected: payType == 2,
                        onSelected: (_) => setState(() => payType = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.roadsideAttachmentLabel),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...attachments.map((url) => Chip(label: Text(url))),
                      ActionChip(
                        label: Text(l10n.roadsideUploadAction),
                        onPressed: () async {
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
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
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              ElevatedButton(
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
                child: Text(l10n.roadsideConfirm),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(l10n, detail.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No.${detail.recordNo ?? '-'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${l10n.roadsideStatusLabel}: $statusLabel'),
                ],
              ),
            ),
            if ((detail.img ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  detail.img!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(l10n.roadsideDeviceSnLabel, detail.deviceSn ?? '-'),
            _infoRow(l10n.roadsideDescLabel, detail.description ?? '-'),
            _infoRow(l10n.roadsideReporterLabel, detail.creator ?? '-'),
            _infoRow(l10n.roadsideReportTimeLabel, detail.reportTime ?? '-'),
            _infoRow(l10n.roadsideLocationLabel, _formatLocation(detail)),
          ],
        ),
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({required this.l10n, required this.detail});

  final AppLocalizations l10n;
  final RoadSideOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.roadsideProcessTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _infoRow(
              l10n.roadsideProcessResult,
              _resultLabel(l10n, detail.result),
            ),
            _infoRow(l10n.roadsideProcessDesc, detail.opResponse ?? '-'),
            _infoRow(
              l10n.roadsideProcessTime,
              detail.processTime?.toString() ?? '-',
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({required this.l10n, required this.attachments});

  final AppLocalizations l10n;
  final String attachments;

  @override
  Widget build(BuildContext context) {
    final list = attachments.split(',').where((e) => e.isNotEmpty).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.roadsideAttachmentLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: list
                  .map(
                    (url) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        url,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
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
        child: Text(text, style: const TextStyle(color: Colors.black54)),
      ),
    );
  }
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

String _statusLabel(AppLocalizations l10n, int? status) {
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

String _resultLabel(AppLocalizations l10n, int? result) {
  switch (result) {
    case 1:
      return l10n.roadsideResultReturnFactory;
    case 2:
      return l10n.roadsideResultCompleted;
    default:
      return '-';
  }
}

String _formatLocation(RoadSideOrderDetail detail) {
  final lat = detail.latitude;
  final lng = detail.longitude;
  if (lat == null || lng == null) return '-';
  return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
}
