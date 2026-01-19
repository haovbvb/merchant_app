import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/roadside/roadside_controller.dart';

class RoadSideDealPage extends ConsumerStatefulWidget {
  const RoadSideDealPage({super.key, required this.recordNo});

  final String recordNo;

  @override
  ConsumerState<RoadSideDealPage> createState() => _RoadSideDealPageState();
}

class _RoadSideDealPageState extends ConsumerState<RoadSideDealPage> {
  final TextEditingController _descController = TextEditingController();
  int _result = 2;

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.roadsideDealTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.roadsideDealResultLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.roadsideResultReturnFactory),
                selected: _result == 1,
                onSelected: (_) => setState(() => _result = 1),
              ),
              ChoiceChip(
                label: Text(l10n.roadsideResultCompleted),
                selected: _result == 2,
                onSelected: (_) => setState(() => _result = 2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.roadsideDealDescLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.roadsideUploadLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...List.generate(state.imageUrls.length, (index) {
                final url = state.imageUrls[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
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
                      child: InkWell(
                        onTap: () => notifier.removeImageAt(index),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                );
              }),
              _AddImageTile(onTap: () => _pickImage(context, notifier)),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: state.submitting
                ? null
                : () async {
                    final desc = _descController.text.trim();
                    if (desc.isEmpty) return;
                    final ok = await notifier.submitReport(
                      recordNo: widget.recordNo,
                      result: _result,
                      desc: desc,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? l10n.roadsideDealSuccess
                            : l10n.roadsideDealFailed),
                      ),
                    );
                    if (ok) {
                      Navigator.of(context).pop(true);
                    }
                  },
            child: state.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.roadsideConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    RoadSideDealNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
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
    if (source == null) return;
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;
    await notifier.uploadImage(picked.path);
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
